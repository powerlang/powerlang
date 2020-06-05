Class {
	#name : #BootstrapEmulator,
	#superclass : #Object,
	#instVars : [
		'nilObj',
		'falseObj',
		'trueObj',
		'smallintBehavior',
		'classes',
		'spec',
		'globals',
		'cvarMap',
		'cache',
		'bootstrapper',
		'symbolCache',
		'overrides',
		'wrappers'
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
	| compiler class method |
	compiler := Compiler namespace: globals.
	class := wrappers at: anRGMethod parent.
	method := compiler
		forClass: class;
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
	[ m := self methodFor: aSymbol in: next.
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
	symbolCache := IdentityDictionary new.
	overrides := Dictionary new.
	wrappers := OrderedDictionary new.
]

{ #category : #accessing }
BootstrapEmulator >> initializeEmulationOverrides [
	self
		override: #Species -> #basicNew with: 'basicNew <primitive: New>';
		override: #Species -> #basicNew:
			with: 'basicNew: anInteger <primitive: NewSized>';
		override: #Species -> #new with: 'new <primitive: New>';
		override: #Species -> #new:
			with: 'new: anInteger <primitive: NewSized>';
		override: #Species -> #primitiveNewBytes:
			with: 'primitiveNewBytes: anInteger <primitive: NewBytes>';
		override: #ProtoObject -> #_size
			with: '_size <primitive: UnderSize>';
		override: #ProtoObject -> #behavior
			with: 'behavior <primitive: Behavior>';
		override: #ProtoObject -> #==
			with: '== anObject <primitive: Equal>';
		override: #ProtoObject -> #primitiveSize
			with: 'primitiveSize <primitive: Size>';
		override: #ProtoObject -> #primitiveAt:
			with: 'primitiveAt: anInteger <primitive: At>';
		override: #ProtoObject -> #basicHash
			with: 'basicHash <primitive: Hash>';
		override: #Object -> #primitiveAt:put:
			with: 'primitiveAt: anInteger put: anObject <primitive: AtPut>';
		override: #SmallInteger -> #+
			with: '+ anObject <primitive: SMIPlus>';
		override: #SmallInteger -> #-
			with: '- anObject <primitive: SMIMinus>';
		override: #SmallInteger -> #*
			with: '* anObject <primitive: SMITimes>';
		override: #SmallInteger -> #//
			with: '// anObject <primitive: SMIIntDiv>';
		override: #SmallInteger -> #\\
			with: '\\ anObject <primitive: SMIIntQuot>';
		override: #SmallInteger -> #bitAnd:
			with: 'bitAnd: aNumber <primitive: SMIBitAnd>';
		override: #SmallInteger -> #bitXor:
			with: 'bitXor: aNumber <primitive: SMIBitXor>';
		override: #SmallInteger -> #bitShift:
			with: 'bitShift: aNumber <primitive: SMIBitShift>';
		override: #SmallInteger -> #highBit
			with: 'highBit <primitive: SMIHighBit>';
		override: #SmallInteger -> #>
			with: '> anObject <primitive: SMIGreaterThan>';
		override: #SmallInteger -> #>=
			with: '>= anObject <primitive: SMIGreaterEqualThan>';
		override: #SmallInteger -> #=
			with: '= anObject <primitive: SMIEqual>';
		override: #SmallInteger -> #sizeInBytes
			with: 'sizeInBytes <primitive: SMISize>';
		override: #Closure -> #value
			with: 'value <primitive: ClosureValue>';
		override: #Closure -> #evaluateAtomically
			with: 'evaluateAtomically <primitive: ClosureValue>';
		override: #Closure -> #value:
			with: 'value: a1 <primitive: ClosureValueWithArgs>';
		override: #Closure -> #value:value:
			with: 'value: a1 value: 2 <primitive: ClosureValueWithArgs>';
		override: #Closure -> #value:value:value:
			with: 'value: a1 value: a2 value: a3 <primitive: ClosureValueWithArgs>';
		override: #Closure -> #evaluateWith:
			with: 'evaluateWith: arg <primitive: ClosureValueWithArgs>';
		override: #Closure -> #evaluateWith:with:
			with: 'evaluateWith: a1 with: a2 <primitive: ClosureValueWithArgs>';
		override: #Closure -> #whileTrue:
			with: 'whileTrue: aBlock <primitive: ClosureWhileTrue>';
		override: #Closure -> #whileFalse:
			with: 'whileFalse: aBlock <primitive: ClosureWhileFalse>';
		override: #Closure -> #argumentCount
			with: 'argumentCount <primitive: ClosureArgumentCount>';
		override: #String -> #replaceFrom:to:with:startingAt:
			with:
			'replaceFrom: start to: end with: aCollection startingAt: position <primitive: StringReplaceFromToWithStartingAt>';
		override: #'HashTable class' -> #primeFor:
			with: 'primeFor: anInteger <primitive: PrimeFor>'
]

{ #category : #accessing }
BootstrapEmulator >> lookup: aSymbol startingAt: aBehavior [
	^cache at: aSymbol -> aBehavior ifAbsentPut: [ self doLookup: aSymbol startingAt: aBehavior ]
]

{ #category : #accessing }
BootstrapEmulator >> methodFor: aSymbol in: anRGBehavior [
	overrides at: anRGBehavior->aSymbol ifPresent: [:m | ^m].
	^anRGBehavior methodNamed: aSymbol
]

{ #category : #'instance creation' }
BootstrapEmulator >> new: aSymbol [
	^self new: aSymbol size: 0
]

{ #category : #'instance creation' }
BootstrapEmulator >> new: anRGBehavior size: anInteger [
	| base behavior map |
	self ASSERT: anRGBehavior isMeta.
	base := anRGBehavior baseClass.
	behavior := bootstrapper instanceBehaviorOfSpec: base.
	map := (ObjectMap new: base size: anInteger)
		behavior: behavior.
	map isBytes ifFalse: [ 
		map atAllPut: nilObj].
	^map
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
BootstrapEmulator >> newInteger: anInteger [
	^ bootstrapper newInteger: anInteger
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
BootstrapEmulator >> override: assoc with: source [
	| species selector method override |
	species := spec at: assoc key.
	selector := assoc value.
	method := species methodNamed: selector.
	override := method copy sourceCode: source.
	overrides at: species->selector put: override
]

{ #category : #accessing }
BootstrapEmulator >> send: aMessage [
	^ self send: aMessage super: false from: nil
]

{ #category : #accessing }
BootstrapEmulator >> send: aMessage super: aBoolean from: anEvaluator [
	| behavior method |
	behavior := aBoolean
		ifTrue: [ anEvaluator method classBinding superclass spec ]
		ifFalse: [ aMessage receiver spec ].
	method := self lookup: aMessage selector startingAt: behavior.
	self ASSERT: method notNil.
	^ self dispatch: method with: aMessage from: anEvaluator
]

{ #category : #accessing }
BootstrapEmulator >> smallintBehavior [
	^smallintBehavior
]

{ #category : #accessing }
BootstrapEmulator >> smallintBehavior: anObjectMap [ 
	 smallintBehavior := anObjectMap 
]

{ #category : #accessing }
BootstrapEmulator >> spec [
	^ spec
]

{ #category : #accessing }
BootstrapEmulator >> spec: anObject [
	spec := anObject.
	self initializeEmulationOverrides
]

{ #category : #accessing }
BootstrapEmulator >> symbolFrom: anObjectMap [
	^ symbolCache
		at: anObjectMap
		ifAbsentPut: [ anObjectMap asString asSymbol ]
]

{ #category : #'as yet unclassified' }
BootstrapEmulator >> transferLiteral: anObject [
	| class transferred slot |
	class := anObject class.
	(class inheritsFrom: ObjectMap)
		ifTrue: [ ^ anObject ].
	(class inheritsFrom: Integer)
		ifTrue: [ ^ self newInteger: anObject ].
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

{ #category : #accessing }
BootstrapEmulator >> wrap: anObjectMap using: anRGBehavior cvars: aBootstrapDictionary [
	| wrapper |
	wrapper := BootstrapClass spec: anRGBehavior map: anObjectMap cvars: aBootstrapDictionary .
	wrappers at: anRGBehavior put: wrapper
]
