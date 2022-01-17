Class {
	#name : #DMRBootstrapper,
	#superclass : #SmalltalkBootstrapper,
	#instVars : [
		'nativizer',
		'image'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #accessing }
DMRBootstrapper >> image: aVirtualSmalltalkImage [
	image := aVirtualSmalltalkImage
]

{ #category : #initialization }
DMRBootstrapper >> initializeInlinedMethods [
	| compiled |
	compiled := self inlinedMethods
		collect: [ :method | builder methods at: method ].
	nativizer inlinedMethods: compiled
]

{ #category : #initialization }
DMRBootstrapper >> initializeInvokedMethods [
	| compiled |
	compiled := self invokedMethods
		collect: [ :method | builder methods at: method ].
	nativizer invokedMethods: compiled
]

{ #category : #initialization }
DMRBootstrapper >> initializeKernelModule [
	| runtime smethod transferred array module |
	module := builder module.
	runtime := {(image => #Kernel >> #entry:argv:)}
		collect: [ :def | 
			smethod := builder methods at: def.
			transferred := image surrogateFor: smethod.
			transferred nativeCode machineCode ].
	array := image newArray: builder classes values.
	module
		name: (image newString: 'Kernel');
		version: (image newString: '0.1.0');
		exports: array;
		hash: image nil;
		loadAction: builder createLoadAction;
		runtime: (image newArray: runtime)
]

{ #category : #initialization }
DMRBootstrapper >> initializeNativizer [
	nativizer := NativizationEnvironment new.
	self
		initializeNativizerGlobals;
		initializeInlinedMethods;
		initializeInvokedMethods;
		initializeOptimizedMethods;
		nativizeInvoke;
		nativizeWriteBarrier;
		nativizeLookup;
		transferNativizerGlobals;
		setupMessageLinkers
]

{ #category : #initialization }
DMRBootstrapper >> initializeNativizerGlobals [
	| smi items |
	smi := image classNamed: #SmallInteger.
	nativizer globalNamed: #SmallIntegerBehavior put: smi behavior.
	items := Dictionary newFromPairs: {
		#Lookup .           (NativeCode new code: 'Lookup Placeholder').
		#LookupSuper .      (NativeCode new code: 'LookupSuper Placeholder').
		#DebuggableLookup . (NativeCode new code: 'DebuggableLookup placeholder').
		#DebuggableLookupSuper. (NativeCode new code: 'DebuggableLookupSuper placholder').
		#Invoke .           (NativeCode new code: 'Invoke placeholder').
		#Safepoint .        (NativeCode new code: 'SafepointCheck placeholder').
		#WriteBarrier .     (NativeCode new code: 'Write Barrier placeholder')}.
	items
		keysAndValuesDo: [ :key :placeholder | nativizer globalNamed: key put: placeholder ]
]

{ #category : #initialization }
DMRBootstrapper >> initializeOptimizedMethods [
	| compiled |
	compiled := self optimizedMethods
		collect: [ :method | builder methods at: method ].
	nativizer optimizedMethods: compiled
]

{ #category : #initialization }
DMRBootstrapper >> initializeSendSite [
		self initializeSendSiteMIC: nativizer monomorphicCache
			PIC: nativizer polymorphicCache

]

{ #category : #initialization }
DMRBootstrapper >> initializeSendSiteMIC: micStub PIC: picStub [
	| class lkup invk mic pic |
	class := image classNamed: #SendSite.
	lkup := nativizer globalNamed: #Lookup.
	lkup := image surrogateFor: lkup.
	invk := nativizer globalNamed: #Invoke.
	invk := image surrogateFor: invk.
	mic := image newBytesFrom: micStub.
	pic := image newBytesFrom: picStub.
	builder runtime
		send: #allocateInitialCachesUsing: to: class with: {lkup};
		send: #initializeInvoke: to: class with: {invk};
		send: #monomorphicCache: to: class with: {mic};
		send: #polymorphicCache: to: class with: {pic}
]

{ #category : #initialization }
DMRBootstrapper >> inlinedMethods [
	| map |
	map := {(#ProtoObject
		->
			#(#objectAtValid: #objectAtValid:put: #behavior #class #primitiveAt: #_cachedLookup: #_cachedLookup:in:)).
	(#Object
		-> #(#byteAtValid: #byteAtValid:put: #basicObjectIndexOf: #at:put:)).
	(#Species
		->
			#(#instSize #_instancesAreArrayed #_instancesHavePointers #memory #instanceBehavior #primitiveNew #primitiveNew:)).
	(#CompiledMethod
		->
			#(#prepareForExecution #isNativized #nativeCode #blockCount #literalIndexFrom:)).
	(#CompiledBlock -> #(#argumentCount #blockNumber #blockCode #method)).
	(#NativeCode -> #(#code)).
	(#GCSpace -> #(#commitedLimit #nextFree #nextFree:)).
	(#CharacterArray -> #(#characterAtValid:))}.
	^ builder undermethods , (builder methodSubset: map)
]

{ #category : #initialization }
DMRBootstrapper >> invokedMethods [
	| map |
	map := {(#ProtoObject
		-> #(behavior class primitiveAt: #initializeExtended:contentSize:)).
	(#Object -> #(#_replaceFrom:to:with:)).
	(#Species
		->
			#(#allocate:size: instanceBehavior _instancesAreArrayed _instancesHavePointers #nil:slotsOf: memory primitiveNewBytes: primitiveNewPointers: #zero:bytesOf:))}.
	^ builder undermethods , (builder methodSubset: map)
]

{ #category : #initialization }
DMRBootstrapper >> mapNativizerGlobal: name to: transferred [
	| placeholder |
	placeholder := nativizer globalNamed: name.
	image
		map: placeholder to: transferred;
		map: placeholder code to: transferred machineCode.
	builder name: transferred as: name
]

{ #category : #initialization }
DMRBootstrapper >> nativize [
	self
		initializeNativizer;
		initializeSendSite;
		nativizeRemainingMethods
]

{ #category : #initialization }
DMRBootstrapper >> nativizeInvoke [
	| invoke |
	invoke := builder compile: builder => #SendSite >> #_invokeOn:.
	nativizer nativizeOptimizing: invoke.
	self transfer: invoke in: #ProtoObject asNativizerGlobal: #Invoke
]

{ #category : #initialization }
DMRBootstrapper >> nativizeLookup [
	| n transferred species lookup lookupSuper |
	n := LookupNativizer new
		bootstrapper: self;
		nativizeMethods.
	lookup := n methodFor: #_dispatchOn:.
	lookupSuper := n methodFor: #_dispatchOn:startingAt:.
	n methods
		do: [ :m | 
			species := image speciesFor: image => m classBinding name.
			transferred := builder transferMethod: m in: species.
			image map: m to: transferred ];
		do: [ :m | 
			transferred := image surrogateFor: m.
			self transferNativeCode: m nativeCode of: transferred ].
	transferred := (image surrogateFor: lookup) nativeCode.
	self mapNativizerGlobal: #Lookup to: transferred.
	transferred := (image surrogateFor: lookupSuper) nativeCode.
	self mapNativizerGlobal: #LookupSuper to: transferred
]

{ #category : #initialization }
DMRBootstrapper >> nativizeRemainingMethods [
	builder classSpecs
		do: [ :def | 
			self
				trace: 'nativizing ' , def name , '...';
				nativizeRemainingMethodsIn: def;
				nativizeRemainingMethodsIn: def metaclass ]
]

{ #category : #initialization }
DMRBootstrapper >> nativizeRemainingMethodsIn: species [
	builder methods
		do: [ :smethod | 
			smethod nativeCode
				ifNil: [ "self haltIf: smethod selector == #foo."
					nativizer nativize: smethod.
					self transferNativeCodeOfMethod: smethod ] ]
]

{ #category : #initialization }
DMRBootstrapper >> nativizeWriteBarrier [
	| map inlined dispatcher barrier |
	map := {('Memory class' -> #(current)).
	(#Memory -> #(isYoung: isYoungSafe: remember:)).
	(#CriticalArray -> #(unsafeAdd: #unsafeAt:put:)).
	(#Magnitude -> #(#between:and:))}.
	inlined := builder methodSubset: map.
	inlined addAll: builder undermethods.
	inlined := inlined collect: [ :m | builder compile: m ].
	barrier := builder
		compile: builder => #ProtoObject >> #holdRefererIfNeeded:.
	dispatcher := LookupLinker new initializeFrom: nativizer.
	NativizationEnvironment new
		globals: nativizer globals;
		inlinedMethods: inlined;
		messageLinker: dispatcher;
		completeInitialization;
		nativizeOptimizing: barrier.
	self
		transfer: barrier
		in: #ProtoObject
		asNativizerGlobal: #WriteBarrier
]

{ #category : #initialization }
DMRBootstrapper >> nativizer [
	^nativizer
]

{ #category : #initialization }
DMRBootstrapper >> optimizedMethods [
	| map |
	map := {(#ProtoObject
		->
			#(behavior class primitiveAt: #primitiveAt:put: #initializeExtended:contentSize:)).
	(#Object
		->
			#(at: #at:put: basicByteAt: #basicByteAt:put: byteAtValid: #byteAtValid:put: basicObjectAt: #basicObjectAt:put: #replaceBytesForwardFrom:to:with:startingAt:)).
	(#SendSite
		->
			#(_dispatchOn: #_dispatchOn:startingAt: _dispatchDebuggableOn: #_dispatchDebuggableOn:startingAt:)).
	(#Species
		->
			#(#allocate:size: primitiveNew primitiveNew: instSize primitiveNewBytes: primitiveNewPointers:)).
	(#'Float class' -> #(new)).
	(#CompiledBlock -> #(argumentCount arity blockCode method)).
	(#Closure -> #(value value: #value:value:)).
	(#CompiledMethod -> #(blockCount isNativized)).
	(#String -> #(at: #at:put: byteAt: #byteAt:put:)).
	(#GCSpace
		-> #(lockedAllocateIfPossible: lockedAllocateUnsafe: shallowCopy:)).
	(#Memory -> #(shallowCopy:))}.
	^ builder undermethods , (builder methodSubset: map)
]

{ #category : #initialization }
DMRBootstrapper >> setupMessageLinkers [
	| invoker dispatcher |
	invoker := InvokeLinker new
		invoker: nativizer invokeStub;
		addMethods: nativizer invokedMethods.
	dispatcher := LookupLinker new initializeFrom: nativizer.
	nativizer
		addLinker: invoker;
		addLinker: dispatcher;
		completeInitialization
]

{ #category : #initialization }
DMRBootstrapper >> transfer: anSMethod in: classname asNativizerGlobal: name [
	| species transferred |
	species := image classNamed: classname.
	transferred := builder transferMethod: anSMethod in: species.
	transferred := self
		transferNativeCode: anSMethod nativeCode
		of: transferred.
	self mapNativizerGlobal: name to: transferred
]

{ #category : #initialization }
DMRBootstrapper >> transferNativeCode: aNativeCode of: compiledCode [
	| size transferred code slot callback |
	size := aNativeCode size.
	transferred := image newSlots: 'NativeCode' sized: size.
	callback := compiledCode classname = #CallbackMethod.
	code := callback
		ifTrue: [ builder newCallback: transferred bytesFrom: aNativeCode code ]
		ifFalse: [ image newBytesFrom: aNativeCode code ].
	transferred
		machineCode: code;
		compiledCode: compiledCode.
	compiledCode nativeCode: transferred.
	aNativeCode
		withIndexDo: [ :elem :i | 
			slot := image transferLiteralDeep: elem.
			transferred at: i put: slot ].
	^ transferred
]

{ #category : #initialization }
DMRBootstrapper >> transferNativeCodeOfMethod: anSCompiledMethod [
	| transferred remaining literal block position |
	transferred := image surrogateFor: anSCompiledMethod.
	self transferNativeCode: anSCompiledMethod nativeCode of: transferred.
	remaining := anSCompiledMethod blockCount.
	position := 1.
	[ remaining > 0 ]
		whileTrue: [ literal := anSCompiledMethod at: position.
			literal isBlock
				ifTrue: [ block := transferred at: position.
					self transferNativeCode: literal nativeCode of: block.
					remaining := remaining - 1 ].
			position := position + 1 ].
	^ transferred
]

{ #category : #initialization }
DMRBootstrapper >> transferNativizerGlobals [
	image transferLiteralDeep: nativizer globals

]

{ #category : #accessing }
DMRBootstrapper >> undermethods [
	^builder undermethods
]
