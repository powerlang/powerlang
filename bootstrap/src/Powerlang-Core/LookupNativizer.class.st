Class {
	#name : #LookupNativizer,
	#superclass : #Object,
	#instVars : [
		'bootstrapper',
		'methods'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #'as yet unclassified' }
LookupNativizer >> >> aSymbol [
	^bootstrapper spec at: aSymbol
]

{ #category : #accessing }
LookupNativizer >> bootstrapper: aSmalltalkBootstrapper [
	bootstrapper := aSmalltalkBootstrapper
]

{ #category : #'as yet unclassified' }
LookupNativizer >> closureMethods [
	^ self selectorLookupMethods , self globalLookupMethods
		, self otherLookupMethods , bootstrapper undermethods
		, self sendSiteMethods
]

{ #category : #'as yet unclassified' }
LookupNativizer >> globalLookupMethods [
	| result out global |
	result := OrderedCollection new.
	result
		add: (self >> #ProtoObject) >> #_cachedLookup:;
		add: (self >> #ProtoObject) >> #_cachedLookup:in:;
		add: (self >> #Thread) metaclass >> #currentGlobalLookup;
		add: (self >> #GlobalDispatchCache) metaclass >> #current.
	out := #(initialize flushAll: #flush:forSpecies: #flush:for: #flush:for:startingAt:).
	global := (self >> #GlobalDispatchCache) methods
		reject: [ :m | out includes: m selector ].
	^ result
		addAll: global;
		yourself
]

{ #category : #accessing }
LookupNativizer >> methodFor: selector [
	^methods detect: [:m | m selector == selector].

]

{ #category : #accessing }
LookupNativizer >> methods [
	^methods
]

{ #category : #accessing }
LookupNativizer >> nativizeMethods [
	| environment | 
	methods := self closureMethods collect: [:m | bootstrapper compile: m ].
	environment := self newNativizationEnvironment.
	methods do: [:m | environment nativize: m]
]

{ #category : #initialization }
LookupNativizer >> newNativizationEnvironment [
	| invoked ignored sent composite |
	invoked := methods copyWith: bootstrapper writeBarrier.
	invoked := InvokeLinker new
		methods: invoked;
		invoker: bootstrapper invoke.
	ignored := HaltingSend new
		filter: #(< <= = > + - * // bitAnd: bitOr: bitXor:).
	sent := LazyLinker new
		filter:
			#(debuggableCopy acquireReferences nativize refreshBlocks doesNotUnderstandSelector: mustBeBoolean class allocateMoreCaches).
	composite := CompositeMessageLinker new
		add: InlineMessageLinker new;
		add: invoked;
		add: ignored;
		add: sent;
		yourself.
	^ bootstrapper nativizer copy
		messageLinker: composite;
		completeInitialization
]

{ #category : #'as yet unclassified' }
LookupNativizer >> otherLookupMethods [
	^ OrderedCollection new
		add: self >> #ProtoObject >> #objectAtValid:put:;
		add: self >> #ProtoObject >> #behavior;
		add: self >> #CompiledMethod >> #prepareForExecution;
		add: self >> #CompiledMethod >> #isNativized;
		add: self >> #CompiledMethod >> #validNativeCodeAddress;
		add: self >> #CompiledMethod >> #nativeCode;
		add: self >> #CompiledMethod >> #selector;
		add: self >> #NativeCode >> #code;
		add: self >> #Species >> #instanceBehavior;
		add: self >> #Process >> #wantsToStepInto;
		yourself
]

{ #category : #'as yet unclassified' }
LookupNativizer >> selectorLookupMethods [
	^ OrderedCollection new
		add: (self >> #ProtoObject) >> #_lookup:;
		add: (self >> #ProtoObject) >> #_lookup:in:;
		add: (self >> #ProtoObject) >> #_lookup:inDictionary:;
		yourself
]

{ #category : #'as yet unclassified' }
LookupNativizer >> sendSiteMethods [
	| sendsite |
	sendsite := self >> #SendSite.
	^ #(_dispatchOn: #_dispatchOn:startingAt: _dispatchDebuggableOn: #_dispatchDebuggableOn:startingAt: sentSelector #when:use: #beInvoke:using: bePolymorphic isStaticSend #monomorphicMap:to: #polymorphicMap:to: maxSize reset takeNextFreeMIC takeNextFreePIC)
		collect: [ :s | sendsite >> s ]
]
