"
I allow sending messages to objects of the `VirtualSmalltalkImage`.
The messages are interpreted and evaluated with the objects living in
that virtual image, and our semantics tries to mimic as much as possible
the one of the final system.
"
Class {
	#name : #VirtualRuntime,
	#superclass : #Object,
	#instVars : [
		'image',
		'frames',
		'methodCache',
		'symbolCache',
		'smallintBehavior',
		'overrides',
		'virtualSpecies',
		'namespace'
	],
	#classVars : [
		'Undermessages'
	],
	#pools : [
		'ClosureElementTypes'
	],
	#category : #'Powerlang-Core-Emulation'
}

{ #category : #'class initialization' }
VirtualRuntime class >> initialize [
	"
	self initialize
	"
	Undermessages := #(_basicAt: #_basicAt:put: _bitShiftLeft: _byteAt: #_byteAt:put: _smallSize _largeSize _isSmallInteger _basicHash _basicHash: _smallIntegerByteAt: _uShortAtOffset: #_uShortAtOffset:put:)
]

{ #category : #'instance creation' }
VirtualRuntime class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #services }
VirtualRuntime >> booleanFrom: anObject [
	anObject == image false
		ifTrue: [ ^ false ].
	anObject == image true
		ifTrue: [ ^ true ].
	self error: 'not a boolean'
]

{ #category : #testing }
VirtualRuntime >> builderOf: closure [
	frames
		reverseDo: [ :frame | 
			(frame built: closure)
				ifTrue: [ ^ frame ] ].
	self error: 'home of closure not found'
]

{ #category : #accessing }
VirtualRuntime >> compile: anRGMethod [
	| compiler spec class |
	compiler := SCompiler new.
	spec := anRGMethod parent.
	class := self virtualSpeciesFor: spec.
	^ compiler
		forClass: class;
		compile: anRGMethod sourceCode
]

{ #category : #accessing }
VirtualRuntime >> doLookup: aSymbol startingAt: aBehavior [
	| behavior m c smethod |
	behavior := aBehavior.
	[ m := self methodFor: aSymbol in: behavior.
	m
		ifNotNil: [ smethod := self compile: m.
			^ self transferMethodLiterals: smethod ].
	behavior := behavior superclass.
	behavior notNil ] whileTrue.
	^ aBehavior isMeta
		ifTrue: [ c := aBehavior environment at: #Class.
			self doLookup: aSymbol startingAt: c ]
]

{ #category : #accessing }
VirtualRuntime >> false [
	^ image false
]

{ #category : #accessing }
VirtualRuntime >> frames [
	^ frames
]

{ #category : #accessing }
VirtualRuntime >> image: aVirtualImage [
	image := aVirtualImage.
	namespace image: image.
	smallintBehavior := (image classNamed: #SmallInteger)
		instanceBehavior.
	self
		initializeEmulationOverrides;
		initializeNamespace
]

{ #category : #initialization }
VirtualRuntime >> initialize [
	frames := OrderedCollection new.
	methodCache := Dictionary new.
	symbolCache := IdentityDictionary new.
	overrides := Dictionary new.
	virtualSpecies := OrderedDictionary new.
	namespace := VirtualDictionary new
]

{ #category : #'own services' }
VirtualRuntime >> initializeClassPools [
	| dictionary virtual cvars |
	dictionary := image classNamed: #Dictionary.
	image classes
		keysAndValuesDo: [ :spec :map | 
			virtual := self virtualSpeciesFor: spec.
			cvars := self send: #new to: dictionary.
			virtual classPool
				associations do: [ :assoc | self send: #add: to: cvars with: {assoc} ].
			map classVariables: cvars ]
]

{ #category : #accessing }
VirtualRuntime >> initializeEmulationOverrides [
	self
		override: #Species -> #basicNew with: 'basicNew <primitive: New>';
		override: #Species -> #basicNew:
			with: 'basicNew: anInteger <primitive: NewSized>';
		override: #Species -> #new with: 'new <primitive: New>';
		override: #Species -> #new:
			with: 'new: anInteger <primitive: NewSized>';
		override: #Species -> #primitiveNewBytes:
			with: 'primitiveNewBytes: anInteger <primitive: NewBytes>';
		override: #'Float class' -> #new with: 'new <primitive: FloatNew>';
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
		override: #ProtoObject -> #primitiveAt:put:
			with: 'primitiveAt: anInteger put: anObject <primitive: AtPut>';
		override: #ProtoObject -> #basicHash
			with: 'basicHash <primitive: Hash>';
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
			with: 'value: a1 value: a2 <primitive: ClosureValueWithArgs>';
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

{ #category : #'own services' }
VirtualRuntime >> initializeNamespace [
	| assoc |
	assoc := image newAssociation: #WordSize -> image wordSize.
	namespace add: assoc.
	assoc := image newAssociation: #LastHash ->1.
	namespace add: assoc.
					
	image classes
		keysAndValuesDo: [ :spec :map | 
			assoc := image newAssociation: spec name asSymbol -> map.
			namespace add: assoc.
			spec
				sharedPoolsDo: [ :pool | 
					assoc := image newAssociation: pool name asSymbol -> nil.
					namespace add: assoc ] ]
]

{ #category : #testing }
VirtualRuntime >> isUndermessage: selector [
	^ Undermessages includes: selector
]

{ #category : #accessing }
VirtualRuntime >> lookup: aSymbol startingAt: aBehavior [
	^methodCache at: aSymbol -> aBehavior ifAbsentPut: [ self doLookup: aSymbol startingAt: aBehavior ]
]

{ #category : #accessing }
VirtualRuntime >> methodFor: aSymbol in: anRGBehavior [
	overrides at: anRGBehavior->aSymbol ifPresent: [:m | ^m].
	^anRGBehavior methodNamed: aSymbol
]

{ #category : #accessing }
VirtualRuntime >> namespace [
	^ namespace
]

{ #category : #accessing }
VirtualRuntime >> newBytesOf: anRGBehavior  sized: anInteger [
	^ image newBytesOf: anRGBehavior  sized: anInteger
]

{ #category : #accessing }
VirtualRuntime >> newClosure: anInteger [
	^image newSlots: #Closure sized: anInteger
]

{ #category : #services }
VirtualRuntime >> newInteger: anInteger [ 
	^image newInteger: anInteger 
]

{ #category : #accessing }
VirtualRuntime >> newOf: anRGBehavior [ 
	^ image newSlotsOf: anRGBehavior sized: 0
]

{ #category : #accessing }
VirtualRuntime >> newOf: anRGBehavior sized: anInteger [
	^ anRGBehavior isBytes
		ifTrue: [ image newBytesOf: anRGBehavior sized: anInteger ]
		ifFalse: [ image newSlotsOf: anRGBehavior sized: anInteger ]
]

{ #category : #accessing }
VirtualRuntime >> newSlotsOf: anRGBehavior sized: anInteger [
	^ image newSlotsOf: anRGBehavior sized: anInteger
]

{ #category : #accessing }
VirtualRuntime >> nil [
	^ image nil
]

{ #category : #accessing }
VirtualRuntime >> override: assoc with: source [
	| species selector method override |
	species := image specs at: assoc key.
	selector := assoc value.
	method := species methodNamed: selector.
	override := method copy sourceCode: source.
	overrides at: species -> selector put: override
]

{ #category : #accessing }
VirtualRuntime >> popFrame [
	frames removeLast
]

{ #category : #accessing }
VirtualRuntime >> pushFrame: aMethodEvaluator [
	frames addLast: aMethodEvaluator
]

{ #category : #accessing }
VirtualRuntime >> send: aSymbol to: receiver [
	^ self send: aSymbol to: receiver with: {}
]

{ #category : #accessing }
VirtualRuntime >> send: aSymbol to: receiver with: anArray [
	^ self send: aSymbol to: receiver with: anArray super: false
]

{ #category : #accessing }
VirtualRuntime >> send: aSymbol to: receiver with: arguments super: aBoolean [
	| behavior method environment frame |
	(self isUndermessage: aSymbol)
		ifTrue: [ ^ frames last staticSend: aSymbol to: receiver with: arguments ].
	behavior := aBoolean
		ifTrue: [ frames last classBinding superclass spec ]
		ifFalse: [ receiver spec ].
	method := self lookup: aSymbol startingAt: behavior.
	self ASSERT: method notNil.
	environment := image newSlots: #Array sized: method environmentCount.
	frame := MethodEvaluator new
		receiver: receiver;
		arguments: arguments;
		environment: environment;
		method: method;
		system: self.
	^ frame evaluate
]

{ #category : #accessing }
VirtualRuntime >> smallintBehavior [
	^smallintBehavior
]

{ #category : #services }
VirtualRuntime >> symbolFrom: anObjectMap [
	^ symbolCache
		at: anObjectMap
		ifAbsentPut: [ anObjectMap asString asSymbol ]
]

{ #category : #accessing }
VirtualRuntime >> transferLiteral: anObject [
	^image transferLiteral: anObject
]

{ #category : #accessing }
VirtualRuntime >> transferMethodLiterals: method [
	| class |
	method withIndexDo: [:literal :i | 
		class := literal class.
		((class inheritsFrom: ObjectMap)
			or: [ class = SCompiledBlock ])
			ifFalse: [ method at: i put: (image transferLiteralDeep: literal) ] ].
	^ method
]

{ #category : #accessing }
VirtualRuntime >> true [
	^image true
]

{ #category : #accessing }
VirtualRuntime >> unwindUpTo: environment returning: value [
	| frame |
	frames size to: 1 by: -1 do: [ :i | 
		frame := frames at: i.
		frame returning: value.
		(frame isHomeOf: environment)
			ifTrue: [ ^ frames removeLast: frames size - i +1 ] ].
	self error: 'frame not found'
]

{ #category : #accessing }
VirtualRuntime >> virtualClassFor: spec [
	| superclass supervirtual virtual map |
	superclass := spec superclass.
	map := image classFor: spec.
	supervirtual := superclass
		ifNotNil: [ self virtualSpeciesFor: superclass ].
	virtual := VirtualClass new
		spec: spec;
		superclass: supervirtual;
		map: map;
		module: namespace.
	virtual createClassAssociationsWith: image.
	^ virtualSpecies at: spec put: virtual
]

{ #category : #accessing }
VirtualRuntime >> virtualMetaclassFor: spec [
	| superclass supervirtual class virtual map |
	class := self virtualSpeciesFor: spec instanceSide.
	map := 	image speciesFor: spec.
	superclass := spec superclass ifNil: image => #Class.
	supervirtual := self virtualSpeciesFor: superclass.
	virtual := VirtualMetaclass new
		spec: spec;
		superclass: supervirtual;
		map: map;
		class: class.
	^ virtualSpecies at: spec put: virtual
]

{ #category : #accessing }
VirtualRuntime >> virtualSpeciesFor: spec [

	virtualSpecies at: spec ifPresent: [ :existing | ^ existing ].
^	spec isMeta ifTrue: [self virtualMetaclassFor: spec] ifFalse: [self virtualClassFor: spec]

]
