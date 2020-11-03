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

{ #category : #'instance creation' }
LookupNativizer >> newNativizationEnvironment [
	| environment ignored lookup invoke |
	environment := NativizationEnvironment new
		globals: bootstrapper nativizer globals;
		optimizedMethods: bootstrapper nativizer optimizedMethods.
	ignored := HaltingSend new
		filter: #(< <= = > + - * // bitAnd: bitOr: bitXor:).
	lookup := LookupLinker new initializeFrom: environment.
	lookup
		filter:
			#(debuggableCopy acquireReferences nativize refreshBlocks doesNotUnderstandSelector: mustBeBoolean class allocateMoreCaches).
	invoke := InvokeLinker new
		invoker: environment invokeStub;
		addMethods: methods.
	^ environment
		addLinker: invoke;
		addLinker: ignored;
		addLinker: lookup;
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
		add: self >> #NativeCode >> #compiledCode;
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
	^ #(_dispatchOn: _dispatchOn:startingAt: _dispatchDebuggableOn: _dispatchDebuggableOn:startingAt: sentSelector when:use: beInvoke:using: bePolymorphic isStaticSend monomorphicMap:to: polymorphicMap:to: maxSize reset takeNextFreeMIC takeNextFreePIC)
		collect: [ :s | sendsite >> s ]
]
