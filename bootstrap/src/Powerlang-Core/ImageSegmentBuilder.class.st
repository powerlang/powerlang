"
A base instance of VirtualSmalltalkImage only contains empty classes, nil, true, false,
and barely anything else. I am in charge of adding the Kernel module object to it and the
methods to the classes.
"
Class {
	#name : #ImageSegmentBuilder,
	#superclass : #Object,
	#instVars : [
		'index',
		'classes',
		'methods',
		'runtime',
		'image',
		'objects',
		'smalltalk'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #'instance creation' }
ImageSegmentBuilder class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #initialization }
ImageSegmentBuilder >> => aSymbol [
	^ self specs at: aSymbol
]

{ #category : #building }
ImageSegmentBuilder >> addGenesisObjects [
	objects
		add: image nil;
		add: image false;
		add: image true;
		add: image kernel.
	runtime namespace valuesDo: [ :obj | objects add: obj ].
	smalltalk ifNotNil: [ objects add: smalltalk value ]
]

{ #category : #services }
ImageSegmentBuilder >> addObjectDeep: anObject [
	self ASSERT: (anObject isKindOf: ObjectMap).
	anObject isImport
		ifTrue: [ ^ self addImport: anObject ].
	anObject isImmediate
		ifTrue: [ ^ self ].
	(objects includes: anObject)
		ifTrue: [ ^ self ].
	objects add: anObject.
	anObject slotsDo: [ :s | self addObjectDeep: s ].
	^ anObject
]

{ #category : #initialization }
ImageSegmentBuilder >> classSpecs [
	^ self specs allClasses
]

{ #category : #initialization }
ImageSegmentBuilder >> classes [
	^classes
]

{ #category : #initialization }
ImageSegmentBuilder >> compile: anRGMethod [
	^runtime compile: anRGMethod
]

{ #category : #initialization }
ImageSegmentBuilder >> createLoadAction [
	^ image nil
]

{ #category : #initialization }
ImageSegmentBuilder >> createMethodDictionary: species sized: anInteger [
	| behavior md size dictionary |
	behavior := species instanceBehavior.
	md := image classNamed: #MethodDictionary.
	size := image newInteger: anInteger.
	dictionary := runtime send: #new: to: md with: {size}.
	behavior methods: dictionary.
	^dictionary
]

{ #category : #initialization }
ImageSegmentBuilder >> export: anObject as: aSymbol [
	runtime globals at: aSymbol put: anObject
]

{ #category : #initialization }
ImageSegmentBuilder >> fillClasses [
	| class meta |
	self classSpecs
		do: [ :def | 
			self log: 'filling ' , def name , '...'.
			class := image classFor: def.
			meta := class behavior slotNamed: #class.
			self
				fillSpecies: meta with: def metaclass;
				fillSpecies: class with: def ]
]

{ #category : #initialization }
ImageSegmentBuilder >> fillSpecies: species with: classDefinition [
	| dictionary smethod transferred |
	dictionary := self
		createMethodDictionary: species
		sized: classDefinition methods size.
	classDefinition methods
		do: [ :methodDefinition | 
			smethod := runtime compile: methodDefinition.
			methods at: methodDefinition put: smethod.
			transferred := self transferMethod: smethod in: species.
			runtime
				send: #basicAt:put:
				to: dictionary
				with:
					{transferred selector.
					transferred} ]
]

{ #category : #accessing }
ImageSegmentBuilder >> image [
	^ image
]

{ #category : #initialization }
ImageSegmentBuilder >> image: aVirtualImage [
	image := aVirtualImage.
	runtime := image runtime 
]

{ #category : #initialization }
ImageSegmentBuilder >> initialize [
	index := OrderedDictionary new.
	classes := OrderedDictionary new.
	methods := OrderedDictionary new.
	objects := OrderedCollection new.
	runtime := VirtualRuntime new
]

{ #category : #initialization }
ImageSegmentBuilder >> initialize32BitImage [
	image := VirtualImage fromSpec
		wordSize: 4;
		genesis.
	runtime := VirtualRuntime new image: image; initializeClassPools
]

{ #category : #initialization }
ImageSegmentBuilder >> initialize64BitImage [
	image := VirtualImage fromSpec
		wordSize: 8;
		genesis.
	runtime := VirtualRuntime new
		image: image;
		initializeClassPools
]

{ #category : #initialization }
ImageSegmentBuilder >> log: aString [
	Transcript
		show: aString;
		cr
]

{ #category : #initialization }
ImageSegmentBuilder >> methodSubset: aDictionary [
	| all species m |
	all := aDictionary
		flatCollect: [ :assoc | 
			species := self => assoc key.
			assoc value
				collect: [ :sel | 
					m := species >> sel.
					self ASSERT: m notNil.
					m ] ].
	^ all asOrderedCollection
]

{ #category : #initialization }
ImageSegmentBuilder >> methods [
	^methods
]

{ #category : #initialization }
ImageSegmentBuilder >> nativizeForDMR [
	DMRBootstrapper new
		image: image;
		builder: self;
		nativize;
		initializeKernelModule
]

{ #category : #initialization }
ImageSegmentBuilder >> newCallback: aNativeCode bytesFrom: aByteArray [
	| code original behavior class |
	code := image newBytesFrom: aByteArray.
	original := code behavior.
	behavior := image newSlots: 'CallbackBehavior'.
	class := original slotNamed: 'class'.
	behavior
		slotNamed: 'class' put: class;
		methods: original methods;
		next: image nil;
		nativeCode: aNativeCode.
	code behavior: behavior.
	^ code
]

{ #category : #initialization }
ImageSegmentBuilder >> newMethod: anAstcode selector: aSymbol in: classname format: anInteger literals: anArray [
	| method astcodes class selector format |
	method := image newSlots: 'CompiledMethod'.
	astcodes := self transferAstcodesFrom: anAstcode.
	class := image classNamed: classname.
	selector := image newSymbol: aSymbol.
	format := image newInteger: anInteger.
	method
		nativeCode: image nil;
		astcodes: astcodes;
		class: class;
		selector: selector;
		format: format;
		source: image nil.
	^ method
]

{ #category : #accessing }
ImageSegmentBuilder >> objects [
	^objects
]

{ #category : #accessing }
ImageSegmentBuilder >> runtime [
	^ runtime
]

{ #category : #initialization }
ImageSegmentBuilder >> specs [
	^ image specs
]

{ #category : #initialization }
ImageSegmentBuilder >> transferArrayDeep: anArray [
	| copy transferred |
	copy := image newSlots: 'Array' sized: anArray size.
	anArray
		withIndexDo: [ :elem :i | 
			transferred := elem isInteger
				ifTrue: [ image newInteger: elem ]
				ifFalse: [ self transferArrayDeep: elem ].
			copy at: i put: transferred ].
	^ copy
]

{ #category : #initialization }
ImageSegmentBuilder >> transferAstcodesFrom: anArray [
	| copy transferred |
	copy := image newSlots: 'Array' sized: anArray size.
	anArray
		withIndexDo: [ :elem :i | 
			transferred := elem isInteger
				ifTrue: [ image newInteger: elem ]
				ifFalse: [ self transferAstcodesFrom: elem ].
			copy at: i put: transferred ].
	^ copy
]

{ #category : #initialization }
ImageSegmentBuilder >> transferMethod: anSCompiledMethod in: species [
	| size classname transferred astcodes selector format literal tliteral |
	(image includes: anSCompiledMethod)
		ifTrue: [ self ASSERT: false ].
	size := anSCompiledMethod size.
	classname := anSCompiledMethod isCallback
		ifTrue: [ 'CallbackMethod' ]
		ifFalse: [ 'CompiledMethod' ].
	transferred := image newSlots: classname sized: size.
	image map: anSCompiledMethod to: transferred.
	astcodes := image transferLiteralDeep: anSCompiledMethod astcodes.
	selector := image newSymbol: anSCompiledMethod selector.
	format := image newInteger: anSCompiledMethod format.
	transferred
		astcodes: astcodes;
		class: species;
		selector: selector;
		format: format;
		source: image nil.
	1 to: size do: [ :i | 
		literal := anSCompiledMethod at: i.
		tliteral := image transferLiteralDeep: literal.
		transferred at: i put: tliteral ].
	^ transferred
]

{ #category : #initialization }
ImageSegmentBuilder >> transferSimpleLiterals: method [
	"fixme: to be used by emulator only"

	| literal class |
	1 to: method size do: [ :i | 
		literal := method at: i.
		class := literal class.
		((class inheritsFrom: ObjectMap)
			or: [ class = SCompiledBlock ])
			ifFalse: [ method at: i put: (self transferLiteralDeep: literal) ] ].
	^ method
]

{ #category : #initialization }
ImageSegmentBuilder >> undermethods [
	^ (self => #ProtoObject) methods
		select: [ :m | m category = 'header access' ]
]

{ #category : #validating }
ImageSegmentBuilder >> validate [
	objects do:[:obj | obj validate]
]

{ #category : #validating }
ImageSegmentBuilder >> writer [
	^ ImageSegmentWriter new
		roots: objects;
		module: image kernel;
		wordSize: image wordSize;
		space: image kernel memory edenSpace;
		yourself
]
