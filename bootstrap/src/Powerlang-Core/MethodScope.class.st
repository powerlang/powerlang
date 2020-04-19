Class {
	#name : #MethodScope,
	#superclass : #ScriptScope,
	#instVars : [
		'species',
		'pseudo',
		'ivars',
		'cvars',
		'pools',
		'globals'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #initialization }
MethodScope >> addPool: aPoolDictionary [
	| binder |
	binder := DynamicBinder on: aPoolDictionary.
	pools add: binder
]

{ #category : #initialization }
MethodScope >> addPool: aDictionary of: type [
	| dict |
	dict := DynamicBinder on: aDictionary of: type.
	pools add: dict
]

{ #category : #initialization }
MethodScope >> addPoolBinders: aCollection [
	pools addAll: aCollection
]

{ #category : #private }
MethodScope >> captureEnvironment: aScriptNode [
	self ASSERT: aScriptNode == script
]

{ #category : #services }
MethodScope >> captureLocal: aLocalBinding [
	self ASSERT: (self resolveLocal: aLocalBinding name) notNil.
	^aLocalBinding
]

{ #category : #services }
MethodScope >> captureSelf [
	
]

{ #category : #initialization }
MethodScope >> classBinding [
	^species
]

{ #category : #services }
MethodScope >> environmentIndexOf: aScriptNode [
	self ASSERT: aScriptNode == script.
	^nil
]

{ #category : #testing }
MethodScope >> hasMultipleBindingsFor: aString [
	"
	temporal compatibility
	"
	| count |
	count := 0.
	cvars
		do: [:binder | binder at: aString ifPresent: [:b | count := count + 1]].
	pools
		do: [:binder | binder at: aString ifPresent: [:b | count := count + 1]].
	^count > 1
]

{ #category : #initialization }
MethodScope >> initialize [
	super initialize.
	globals := DynamicBinder on: Dictionary new of: GlobalBinding.
	ivars := StaticBinder new.
	cvars := OrderedCollection new. 
	pools := OrderedCollection new.
	self initializePseudoVars
]

{ #category : #initialization }
MethodScope >> initializeClassVars [
	"
		fixme: bootstrapping should be properly abstracted
		and not checked with isKindOf:
	"

	| vars |
	species instanceSide withAllSuperclasses
		do: [ :class | 
			| binder |
			vars := (class isKindOf: Behavior)
				ifTrue: [ class classPool ]
				ifFalse: [ BootstrapDictionary withAll: class classVariables ].
			binder := DynamicBinder on: vars of: ClassVarBinding.
			cvars add: binder ]
]

{ #category : #initialization }
MethodScope >> initializeInstVars [
	species allInstVarNames withIndexDo: [:name :i | | binding |
		binding := InstVarBinding new name: name; index: i.
		ivars at: name put: binding]
]

{ #category : #initialization }
MethodScope >> initializePoolVars [
	| instance |
	instance := species instanceSide.
	instance sharedPoolsDo: [:name |
		globals
			poolNamed: name
			ifPresent: [:pool | self addPool: pool]].
	instance withAllSuperclasses
		do: [:class | class localPools do: [:pool | self addPool: pool]]
]

{ #category : #initialization }
MethodScope >> initializePseudoVars [
	pseudo := StaticBinder new.
	pseudo
		at: 'nil' put: NilBinding new;
		at: 'true' put: TrueBinding new;
		at: 'false' put: FalseBinding new;
		at: 'self' put: SelfBinding new
]

{ #category : #accessing }
MethodScope >> namespace [
	^globals
]

{ #category : #accessing }
MethodScope >> namespace: aDictionary [
	globals contents: aDictionary
]

{ #category : #services }
MethodScope >> poolFor: aString [
	cvars do: [:binder | binder at: aString ifPresent: [:b | ^binder contents]].
	pools do: [:pool | pool at: aString ifPresent: [:b | ^pool contents]].
	self error: 'not found'
]

{ #category : #services }
MethodScope >> resolve: aString [
	(self resolveLocal: aString) ifNotNil: [:binding | ^binding].
	^self resolveShared: aString
]

{ #category : #services }
MethodScope >> resolveShared: aString [
	(pseudo at: aString) ifNotNil: [:binding | ^binding].
	(ivars at: aString) ifNotNil: [:binding | ^binding].
	cvars do: [:binder | binder at: aString ifPresent: [:binding | ^binding]].
	pools do: [:pool | pool at: aString ifPresent: [:binding | ^binding]].
	^(globals at: aString) ifNil: [UnresolvedBinding new name: aString]
]

{ #category : #services }
MethodScope >> scriptDefining: aString [
	(self resolveLocal: aString) ifNotNil: [^script].
	(self resolveShared: aString) ifNotNil: [^script].
	self ASSERT: false.
	^nil
]

{ #category : #initialization }
MethodScope >> species: aSpecies [
	species ifNotNil: [^self].
	species := aSpecies.
	self initializeInstVars; initializeClassVars; initializePoolVars.
	species superclass isNil ifTrue: [^self].
	pseudo at: 'super' put: SuperBinding new
]

{ #category : #private }
MethodScope >> transferLocal: name [
	^self resolveLocal: name
]
