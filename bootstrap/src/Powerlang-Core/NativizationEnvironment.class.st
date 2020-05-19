Class {
	#name : #NativizationEnvironment,
	#superclass : #Object,
	#instVars : [
		'abi',
		'safepointCheck',
		'methodNativizer',
		'messageLinker',
		'busy'
	],
	#classVars : [
		'Current'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #initialization }
NativizationEnvironment class >> commonMessageLinkersUsing: invokeStub [
	| normal barrier |
	normal := InvokeLinker with: self invokedMethods using: invokeStub.
	barrier := InvokeLinker new addMethod: self writeBarrierMethod.
	^InlineMessageLinker availableInliners , (Array with: normal with: barrier) 
]

{ #category : #accessing }
NativizationEnvironment class >> current [
	^Current ifNil: [BeeKernelBootstrapper new environment] 
]

{ #category : #accessing }
NativizationEnvironment class >> current: anEnvironment [
	^ Current := anEnvironment 
]

{ #category : #private }
NativizationEnvironment class >> forTesting [
	^self new 
]

{ #category : #initialization }
NativizationEnvironment class >> initializeInSelfHostedBee [
	| invoke messageLinker common lookup checker |
	invoke := Smalltalk at: #Invoke.
	common := self commonMessageLinkersUsing: invoke.
	lookup := LookupLinker new loadCodeFrom: Smalltalk.
	messageLinker := CompositeMessageLinker new
		denominateAll: common;
		denominate: lookup.
	checker := Heartbeat class >> #safepointCheck.
	^self resetCurrent
		messageLinker: messageLinker;
		safepointCheck: checker;
		completeInitialization 
]

{ #category : #private }
NativizationEnvironment class >> invokedMethods [
	| methods |
	methods := self primitiveObjectMethods copy.
	methods add: Object >> #_replaceFrom:to:with:.
	#(#allocate:size: #instanceBehavior
		#_instancesAreArrayed #_instancesHavePointers #nil:slotsOf: #memory
		#primitiveNewBytes:
		#primitiveNewPointers: #zero:bytesOf:)
		do: [:selector | methods add: Species >> selector].
	"removed because of incorrectness:  isNullTerminated"
	^methods 
]

{ #category : #testing }
NativizationEnvironment class >> isUndermethod: selector [
	^ self primitiveObject isUndermethod: selector 
]

{ #category : #accessing }
NativizationEnvironment class >> primitiveObject [
	^ ProtoObject 
]

{ #category : #accessing }
NativizationEnvironment class >> primitiveObjectMethods [
	^ self primitiveObject undermethods 
]

{ #category : #private }
NativizationEnvironment class >> resetCurrent [
	^ self current: self new 
]

{ #category : #initialization }
NativizationEnvironment class >> writeBarrierMethod [
	^ ProtoObject >> #holdRefererIfNeeded: 
]

{ #category : #initialization }
NativizationEnvironment >> abi [
	^ abi 
]

{ #category : #initialization }
NativizationEnvironment >> abi: anAbi [
	abi := anAbi 
]

{ #category : #initialization }
NativizationEnvironment >> astcodeNativizer [
	^ SExpressionNativizer new
		  abi: abi;
		  messageLinker: messageLinker 
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
NativizationEnvironment >> completeInitialization [
	methodNativizer := self createMethodNativizer 
]

{ #category : #initialization }
NativizationEnvironment >> createMethodNativizer [
	^ SExpressionNativizer new
		  abi: abi;
		  messageLinker: messageLinker;
		  safepointCheck: safepointCheck
]

{ #category : #initialization }
NativizationEnvironment >> createMethodNativizerOn: anAssembler [
	^ (SExpressionNativizer on: anAssembler)
		  abi: abi;
		  messageLinker: messageLinker;
		  safepointCheck: safepointCheck
]

{ #category : #initialization }
NativizationEnvironment >> initialize [
	busy := false.
	abi := ABI forIntel: 8
]

{ #category : #initialization }
NativizationEnvironment >> messageLinker: aLinker [
	messageLinker := aLinker 
]

{ #category : #accessing }
NativizationEnvironment >> methodNativizer [
	^ methodNativizer 
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
			  [ aBlock value: methodNativizer ] ensure: [ busy := false ] ]
		  ifTrue: [ 
			  | old |
			  old := methodNativizer. 
			  [ 
			  methodNativizer := self createMethodNativizer.
			  aBlock value: methodNativizer ] ensure: [ methodNativizer := old ] ]
]

{ #category : #services }
NativizationEnvironment >> optimizedNativeCodeFor: aCompiledMethod [
	^ (self optimizingNativizer on: aCompiledMethod)
		  messageLinker: messageLinker;
		  abi: abi;
		  nativeCode
]

{ #category : #initialization }
NativizationEnvironment >> optimizingNativizer [
	^OptimizingNativizer
]

{ #category : #initialization }
NativizationEnvironment >> safepointCheck: anObject [
	safepointCheck := anObject 
]

{ #category : #initialization }
NativizationEnvironment >> sexpressionOffsetsOf: code [
	| method |
	method := code method.
	(self shouldOptimize: method) ifTrue: [ ^ #(  ) ].
	^ self nativizerDuring: [ :nativizer | 
		  method nativeCode isNil ifFalse: [ method := method copy ]. 
		  nativizer compile: method.
		  nativizer sexpressionOffsetsOf: code ]
]

{ #category : #private }
NativizationEnvironment >> shouldOptimize: method [
	method isDebuggable ifTrue: [ ^ false ].
	method isCallback ifTrue: [ ^ false ].
	(method classBinding == Object and: [ 
		 self class isUndermethod: method selector ]) ifTrue: [ ^ true ].
	(method classBinding == ProtoObject and: [ 
		 #( behavior class primitiveAt: ) includes: method selector ])  
		ifTrue: [ ^ true ].
	(method classBinding == Object and: [ 
		 #( at: #at:put: basicByteAt: #basicByteAt:put: byteAtValid:
		    #byteAtValid:put: basicObjectAt: #basicObjectAt:put:
		    #primitiveAt:put: #replaceBytesForwardFrom:to:with:startingAt: ) 
			 includes: method selector ]) ifTrue: [ ^ true ].
	(method classBinding == Array and: [ 
		 #( at: #at:put: ) includes: method selector ]) ifTrue: [ ^ true ].
	(method classBinding == SendSite and: [ 
		 #( _dispatchOn: #_dispatchOn:startingAt: _dispatchDebuggableOn:
		    #_dispatchDebuggableOn:startingAt: ) includes: method selector ]) 
		ifTrue: [ ^ true ].
	(method classBinding == Species and: [ 
		 #( #allocate:size: primitiveNew primitiveNew: instSize primitiveNewBytes:
		    primitiveNewPointers: ) includes: method selector ]) ifTrue: [ 
		^ true ].
	(method classBinding == Float class and: [ 
		 #( basicNew new ) includes: method selector ]) ifTrue: [ ^ true ].
	(method classBinding == CompiledBlock and: [ 
		 #( argumentCount arity blockCode method ) includes: method selector ]) 
		ifTrue: [ ^ true ].
	(method classBinding == Closure and: [ 
		 #( value value: #value:value: ) includes: method selector ]) 
		ifTrue: [ ^ true ].
	(method classBinding == CompiledMethod and: [ 
		 #( at: blockCount isNativized ) includes: method selector ]) 
		ifTrue: [ ^ true ].
	(method classBinding == String and: [ 
		 #( at: #at:put: byteAt: #byteAt:put: ) includes: method selector ]) 
		ifTrue: [ ^ true ].
	(method classBinding == GCSpace and: [ 
		 #( lockedAllocateIfPossible: lockedAllocateUnsafe:
		    shallowCopy: ) includes: method selector ]) ifTrue: [ ^ true ].
	(method classBinding == Memory and: [ 
		 #( shallowCopy: ) includes: method selector ]) ifTrue: [ ^ true ].
	^ false
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
