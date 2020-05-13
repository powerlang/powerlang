Class {
	#name : #BootstrapEmulator,
	#superclass : #Object,
	#instVars : [
		'nilObj',
		'falseObj',
		'trueObj',
		'classes',
		'spec',
		'cache',
		'globals',
		'bootstrapper',
		'symbolCache'
	],
	#pools : [
		'ClosureElementTypes'
	],
	#category : #'Powerlang-Core-Emulation'
}

{ #category : #accessing }
BootstrapEmulator >> booleanFrom: anObject [
anObject == falseObj ifTrue: [ ^false ].
	anObject == trueObj ifTrue: [ ^true ].	
	self error: 'not a boolean'
]

{ #category : #accessing }
BootstrapEmulator >> bootstrapper [
	^ bootstrapper
]

{ #category : #accessing }
BootstrapEmulator >> bootstrapper: aSmalltalkBootstrapper [
	bootstrapper := aSmalltalkBootstrapper
]

{ #category : #accessing }
BootstrapEmulator >> classes [
	^ classes
]

{ #category : #accessing }
BootstrapEmulator >> classes: aDictionary [
	classes := aDictionary
]

{ #category : #accessing }
BootstrapEmulator >> compile: anRGMethod [
	| compiler method |
	compiler := Compiler namespace: globals.
	method := compiler
		forClass: anRGMethod parent;
		compile: anRGMethod sourceCode.
	^ bootstrapper transferSimpleLiterals: method
]

{ #category : #accessing }
BootstrapEmulator >> dispatch: aMethod with: aMessage [
	^self dispatch: aMethod with: aMessage from: nil
]

{ #category : #accessing }
BootstrapEmulator >> dispatch: aMethod with: aMessage from: parent [
	| interpreter |
	interpreter := MethodEvaluator new
		receiver: aMessage receiver;
		arguments: aMessage arguments;
		method: aMethod;
		system: self;
		parent: parent.
	^ interpreter evaluate: aMethod sexpressions
]

{ #category : #accessing }
BootstrapEmulator >> doLookup: aSymbol startingAt: aBehavior [
	| next m c |
	"emulated behavior can be different from the object one, so we first do the switch"
	next := spec at: aBehavior name.
	[ m := next methodNamed: aSymbol.
	m ifNotNil: [ ^ self compile: m ].
	next := next superclass.
	next notNil ] whileTrue.
	^ aBehavior isMeta
		ifTrue: [ c := aBehavior environment at: #Class.
			self lookup: aSymbol startingAt: c ]
]

{ #category : #accessing }
BootstrapEmulator >> falseObject [
	^ falseObj
]

{ #category : #accessing }
BootstrapEmulator >> falseObject: anObjectMap [
	falseObj := anObjectMap
]

{ #category : #accessing }
BootstrapEmulator >> globals [
	^ globals
]

{ #category : #accessing }
BootstrapEmulator >> globals: aDictionary [
	globals := aDictionary
]

{ #category : #accessing }
BootstrapEmulator >> initialize [
	cache := Dictionary new.
	symbolCache := IdentityDictionary new
]

{ #category : #accessing }
BootstrapEmulator >> lookup: aSymbol startingAt: aBehavior [
	^cache at: aSymbol -> aBehavior ifAbsentPut: [ self doLookup: aSymbol startingAt: aBehavior ]
]

{ #category : #'instance creation' }
BootstrapEmulator >> new: aSymbol [
	^self new: aSymbol size: 0
]

{ #category : #'instance creation' }
BootstrapEmulator >> new: anRGBehavior size: anInteger [
	| base behavior |
	self ASSERT: anRGBehavior isMeta.
	base := anRGBehavior baseClass.
	behavior := bootstrapper instanceBehaviorOfSpec: base.
	^ (ObjectMap new: base size: anInteger)
		behavior: behavior;
		atAllPut: nilObj
]

{ #category : #'instance creation' }
BootstrapEmulator >> newBytes: anRGBehavior size: anInteger [
	| base behavior |
	self ASSERT: anRGBehavior isMeta.
	base := anRGBehavior baseClass.
	behavior := bootstrapper instanceBehaviorOfSpec: base.
	^ (ByteObjectMap new: base size: anInteger)
		behavior: behavior
]

{ #category : #'instance creation' }
BootstrapEmulator >> newNamed: aSymbol [
	self newNamed: aSymbol size: 0
]

{ #category : #'instance creation' }
BootstrapEmulator >> newNamed: aSymbol size: anInteger [
	| behavior |
	behavior := bootstrapper spec at: aSymbol.
	^ self new: behavior metaclass size: anInteger
]

{ #category : #'instance creation' }
BootstrapEmulator >> newSmallInteger: anInteger [
	^bootstrapper newSmallInteger: anInteger
]

{ #category : #accessing }
BootstrapEmulator >> nextHash [
	| last shifted hash |
	last := bootstrapper lastHash.
	shifted := last bitShift: -1.
	hash := (last bitAnd: 1) = 0
		ifTrue: [ shifted ]
		ifFalse: [ shifted bitXor: 16rD561 ].
	bootstrapper lastHash: hash
]

{ #category : #accessing }
BootstrapEmulator >> nilObject [
	^ nilObj
]

{ #category : #accessing }
BootstrapEmulator >> nilObject: anObjectMap [
	nilObj := anObjectMap
]

{ #category : #accessing }
BootstrapEmulator >> send: aMessage [
	^ self send: aMessage super: false from: nil
]

{ #category : #accessing }
BootstrapEmulator >> send: aMessage super: aBoolean from: anEvaluator [
	| behavior method |
	behavior := aBoolean
		ifTrue: [ anEvaluator method classBinding superclass ]
		ifFalse: [ aMessage receiver spec ].
	method := self lookup: aMessage selector startingAt: behavior.
	self ASSERT: method notNil.
	^ self dispatch: method with: aMessage from: anEvaluator
]

{ #category : #accessing }
BootstrapEmulator >> spec [
	^ spec
]

{ #category : #accessing }
BootstrapEmulator >> spec: anObject [
	spec := anObject
]

{ #category : #accessing }
BootstrapEmulator >> symbolFrom: anObjectMap [
	^ symbolCache
		at: anObjectMap
		ifAbsentPut: [ anObjectMap bytes allButLast asString asSymbol ]
]

{ #category : #'as yet unclassified' }
BootstrapEmulator >> transferLiteral: anObject [
	| class transferred slot |
	class := anObject class.
	(class inheritsFrom: ObjectMap)
		ifTrue: [ ^ anObject ].
	class = SmallInteger
		ifTrue: [ ^ self newSmallInteger: anObject ].
	(class inheritsFrom: Symbol)
		ifTrue: [ ^ bootstrapper newSymbol: anObject ].
	(class inheritsFrom: String)
		ifTrue: [ ^ bootstrapper newString: anObject ].
	class = ByteArray
		ifTrue: [ ^ bootstrapper newBytesFrom: anObject ].
	transferred := self newNamed: anObject class name size: anObject size.
	anObject
		withIndexDo: [ :elem :i | 
			slot := bootstrapper transferLiteralDeep: elem.
			transferred at: i put: slot ].
	^ transferred
]

{ #category : #accessing }
BootstrapEmulator >> trueObject [
	^ trueObj
]

{ #category : #accessing }
BootstrapEmulator >> trueObject: anObjectMap [
	trueObj := anObjectMap
]
