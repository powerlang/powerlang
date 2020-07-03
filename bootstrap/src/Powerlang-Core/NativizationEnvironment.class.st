Class {
	#name : #NativizationEnvironment,
	#superclass : #Object,
	#instVars : [
		'abi',
		'safepointCheck',
		'messageLinker',
		'spec',
		'optimizedMethods',
		'invokedMethods',
		'inlinedMethods',
		'cachedNativizer',
		'busy',
		'methodInstSize'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #private }
NativizationEnvironment class >> forTesting [
	^ self forTesting: SmalltalkBootstrapper spec
]

{ #category : #private }
NativizationEnvironment class >> forTesting: anRGEnvironment [ 
	^ self new spec: anRGEnvironment
]

{ #category : #initialization }
NativizationEnvironment >> abi [
	^ abi 
]

{ #category : #initialization }
NativizationEnvironment >> abi: anAbi [
	abi := anAbi 
]

{ #category : #'*Powerlang-Core-OCompiler' }
NativizationEnvironment >> bareMetalNativizer [
	^OptimizingNativizer
]

{ #category : #initialization }
NativizationEnvironment >> be32bits [
	abi := X86ABI new 
]

{ #category : #initialization }
NativizationEnvironment >> be64bits [
	abi := X64ABI new 
]

{ #category : #initialization }
NativizationEnvironment >> compileOptimizedMethodsWith: compiler [
	| smethod |
	optimizedMethods withIndexDo:[:method :i | smethod := compiler compile: method. optimizedMethods at: i put: smethod ]

]

{ #category : #initialization }
NativizationEnvironment >> completeInitialization [
	cachedNativizer := self newExpressionNativizer 
]

{ #category : #initialization }
NativizationEnvironment >> initialize [
	busy := false.
	abi := ABI forIntel: 8.
	messageLinker := HaltingSend new.
	optimizedMethods := OrderedCollection new.
	invokedMethods := OrderedCollection new.
	inlinedMethods := OrderedCollection new
]

{ #category : #initialization }
NativizationEnvironment >> inlinedMethods [
	^inlinedMethods
]

{ #category : #accessing }
NativizationEnvironment >> messageLinker [
	^ messageLinker
]

{ #category : #initialization }
NativizationEnvironment >> messageLinker: aLinker [
	messageLinker := aLinker 
]

{ #category : #accessing }
NativizationEnvironment >> methodInstSize [
^methodInstSize 
]

{ #category : #accessing }
NativizationEnvironment >> methodNativizer [
	^ cachedNativizer 
]

{ #category : #initialization }
NativizationEnvironment >> methodSubset: aDictionary [
	| species |
	^aDictionary flatCollect: [ :assoc | 
		species := spec at: assoc key.
		assoc value collect: [:sel | species >> sel ] ].	
]

{ #category : #services }
NativizationEnvironment >> nativeCodeFor: aCompiledMethod [
	^ (self shouldOptimize: aCompiledMethod)
		  ifTrue: [ self optimizedNativeCodeFor: aCompiledMethod ]
		  ifFalse: [ self unoptimizedNativeCodeFor: aCompiledMethod ] 
]

{ #category : #initialization }
NativizationEnvironment >> nativizerDuring: aBlock [
	^ busy
		  ifFalse: [ 
			  busy := true.
			  [ aBlock value: cachedNativizer ] ensure: [ busy := false ] ]
		  ifTrue: [ 
			  | old |
			  old := cachedNativizer. 
			  [ 
			  cachedNativizer := self newExpressionNativizer.
			  aBlock value: cachedNativizer ] ensure: [ cachedNativizer := old ] ]
]

{ #category : #initialization }
NativizationEnvironment >> newExpressionNativizer [
	^ SExpressionNativizer new environment: self
]

{ #category : #services }
NativizationEnvironment >> optimizedNativeCodeFor: anSCompiledMethod [
	^ self optimizingNativizer
		method: anSCompiledMethod;
		nativeCode
]

{ #category : #initialization }
NativizationEnvironment >> optimizingNativizer [
	^OptimizingNativizer new environment: self
]

{ #category : #initialization }
NativizationEnvironment >> safepointCheck: anObject [
	safepointCheck := anObject 
]

{ #category : #initialization }
NativizationEnvironment >> setupInlinedMethods [
	| map methods |
	map := {(#ProtoObject
		->
			#(#objectAtValid: #objectAtValid:put: #behavior #class #primitiveAt: #_cachedLookup: #_cachedLookup:in:)).
	(#Object
		->
			#(#byteAtValid: #byteAtValid:put: #basicObjectIndexOf: #at:put:)).
	(#Species
		->
			#(#instSize #_instancesAreArrayed #_instancesHavePointers #memory #instanceBehavior #primitiveNew #primitiveNew:)).
	(#CompiledMethod
		->
			#(#prepareForExecution #isNativized #nativeCode #blockCount #literalIndexFrom:)).
	(#CompiledBlock -> #(#argumentCount #blockNumber #blockCode #method)).
	(#NativeCode -> #(#code #isFresh)).
	(#GCSpace -> #(#commitedLimit #nextFree #nextFree:)).
	(#CharacterArray -> #(#characterAtValid:))}.
	methods := self methodSubset: map.
	inlinedMethods
		addAll: self undermethods;
		addAll: methods
]

{ #category : #initialization }
NativizationEnvironment >> setupInvokedMethods [
	| map methods |
	map := { 
		#ProtoObject -> #( behavior class primitiveAt: #initializeExtended:contentSize: ).
		#Object -> #( #_replaceFrom:to:with: ).
		#Species -> #( #allocate:size: instanceBehavior _instancesAreArrayed
			           _instancesHavePointers #nil:slotsOf: memory primitiveNewBytes:
			           primitiveNewPointers: #zero:bytesOf: )}.
	methods := self methodSubset: map.
	invokedMethods
		addAll: self undermethods;
		addAll: methods
]

{ #category : #initialization }
NativizationEnvironment >> setupOptimizedMethods [
	| map methods |
	map := {
			#ProtoObject -> #(behavior class primitiveAt: initializeExtended:contentSize:).
			#Object -> #(at: #at:put: basicByteAt: #basicByteAt:put: byteAtValid:
		    #byteAtValid:put: basicObjectAt: #basicObjectAt:put:
		    #primitiveAt:put: #replaceBytesForwardFrom:to:with:startingAt:).
			#Array -> #(at: #at:put:).
			#SendSite -> #(_dispatchOn: #_dispatchOn:startingAt: _dispatchDebuggableOn:
		    #_dispatchDebuggableOn:startingAt: ).
			#Species -> #( #allocate:size: primitiveNew primitiveNew: instSize primitiveNewBytes:
		    primitiveNewPointers: ).
			#'Float class' -> #( basicNew new ).
			#CompiledBlock -> #( argumentCount arity blockCode method ).
			#Closure -> #( value value: #value:value: ).
			#CompiledMethod -> #( at: blockCount isNativized ).
			#String -> #( at: #at:put: byteAt: #byteAt:put: ).
			#GCSpace -> #( lockedAllocateIfPossible: lockedAllocateUnsafe: shallowCopy: ).
			#Memory -> #( shallowCopy: ) 
	}.
	methods := self methodSubset: map.
	optimizedMethods addAll: self undermethods; addAll: methods
]

{ #category : #initialization }
NativizationEnvironment >> sexpressionOffsetsOf: code [
	| method |
	method := code method.
	(self shouldOptimize: method) ifTrue: [ ^ #(  ) ].
	^ self nativizerDuring: [ :nativizer | 
		  method nativeCode ifNotNil: [ method := method copy ]. 
		  nativizer compile: method.
		  nativizer sexpressionOffsetsOf: code ]
]

{ #category : #'*Powerlang-Core-OCompiler' }
NativizationEnvironment >> shouldOptimize: method [
	^optimizedMethods includes: method
]

{ #category : #initialization }
NativizationEnvironment >> spec: anRGEnvironment [
	spec := anRGEnvironment.
	methodInstSize := (spec at: #CompiledMethod) instSize.
	self
		setupOptimizedMethods;
		setupInlinedMethods;
		setupInvokedMethods
]

{ #category : #initialization }
NativizationEnvironment >> undermethods [
	^(spec at: #ProtoObject) methods select: [:m | m selector beginsWith: '_'].	
]

{ #category : #services }
NativizationEnvironment >> unoptimizedNativeCodeFor: aCompiledMethod [
	| code |
	code := self nativizerDuring: [ :nativizer | 
		        nativizer nativeCodeFor: aCompiledMethod ].
	^ code 
]

{ #category : #initialization }
NativizationEnvironment >> wordSize [
	^ abi wordSize 
]

{ #category : #initialization }
NativizationEnvironment >> wordSizeShift [
	^ abi wordSizeShift 
]
