"
I'm in charge of creating and managing the objects of an image. I'm created from a spec,
and I know how to bootstrap and connect an initial graph of objects and classes.

I do not add the spec methods to classes, as it requires some emulation done by
the `VirtualRuntime`. That step is left to the `VirtualImage`
that also creates the Kernel module.
"
Class {
	#name : #VirtualImage,
	#superclass : #Object,
	#instVars : [
		'nilObj',
		'falseObj',
		'trueObj',
		'wordSize',
		'minSMI',
		'maxSMI',
		'classes',
		'metaclasses',
		'identityMap',
		'specs',
		'kernel',
		'runtime'
	],
	#pools : [
		'ClosureElementTypes'
	],
	#classInstVars : [
		'KernelSpec'
	],
	#category : #'Powerlang-Core-Emulation'
}

{ #category : #accessing }
VirtualImage class >> fromSpec [
	^ self new specs: self kernelSpec
]

{ #category : #accessing }
VirtualImage class >> kernelSpec [
	^ KernelSpec ifNil: [ KernelSpec := self newKernelSpec ]
]

{ #category : #'instance creation' }
VirtualImage class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #accessing }
VirtualImage class >> newKernelSpec [
	| root current repo spec |

	root := (Smalltalk getPackageDirectoryForPackage: self package) / '..' / '..'.	
	current := (root / 'specs' / 'current') contents asString trim.
	repo := TonelRepository new
		directory: (root / 'specs' / current).
	spec := repo asRingEnvironmentWith: #(Kernel).
	^ spec clean

]

{ #category : #initialization }
VirtualImage >> => aSymbol [
	^ specs at: aSymbol
]

{ #category : #services }
VirtualImage >> basicNewBytes: classname contents: aByteObject [
	^ self basicNewBytesOf: self => classname contents: aByteObject
]

{ #category : #services }
VirtualImage >> basicNewBytesOf: anRGBehavior  contents: aByteObject [
	^ ByteObjectMap new: anRGBehavior valued: aByteObject
]

{ #category : #accessing }
VirtualImage >> basicNewSlots: classname [
	^ self basicNewSlots: classname sized: 0
]

{ #category : #accessing }
VirtualImage >> basicNewSlots: classname in: spec [
	^ self basicNewSlots: classname in: spec sized: 0
]

{ #category : #accessing }
VirtualImage >> basicNewSlots: classname in: spec sized: size [
	| species |
	species := spec at: classname.
	^self basicNewSlotsOf: species sized: size
]

{ #category : #accessing }
VirtualImage >> basicNewSlots: classname sized: size [
	^ self basicNewSlots: classname in: specs sized: size
]

{ #category : #accessing }
VirtualImage >> basicNewSlotsOf: anRGBehavior sized: size [
	^ SlotObjectMap new: anRGBehavior size: size withAll: nilObj
]

{ #category : #'own services' }
VirtualImage >> bootstrap [
	runtime := VirtualRuntime new.
	runtime
		image: self;
		send: #initialize to: kernel
]

{ #category : #'own services' }
VirtualImage >> buildSpecies: spec [
	| sspec sclass sbehavior metasuper  |
	sspec := spec superclass.
	sspec
		ifNil: [ sclass := nilObj.
			sbehavior := nilObj.
			metasuper := classes at: self => #Class ]
		ifNotNil: [ sclass := classes at: sspec.
			sbehavior := sclass instanceBehavior.
			metasuper := metaclasses at: sspec metaclass ].
	self
		initializeClass: spec superclass: sclass superbehavior: sbehavior;
		initializeMetaclass: spec metaclass superclass: metasuper
]

{ #category : #'own services' }
VirtualImage >> builder [
	^	ImageSegmentBuilder new image: self.
]

{ #category : #accessing }
VirtualImage >> classFor: anRGBehavior [
	^classes at: anRGBehavior
]

{ #category : #building }
VirtualImage >> classNamed: aString [
	^self classFor: self => aString
]

{ #category : #accessing }
VirtualImage >> classes [
	^ classes
]

{ #category : #accessing }
VirtualImage >> createSpecies: definition [
	| class meta ibehavior cbehavior |
	class := self basicNewSlots: #Class.
	class initializeAs: definition metaclass sized: 0.
	meta := self basicNewSlots: #Metaclass.
	ibehavior := self basicNewSlots: #Behavior.
	cbehavior := self basicNewSlots: #Behavior.
	ibehavior class: class.
	cbehavior class: meta.
	meta
		class: class;
		instanceBehavior: cbehavior.
	class
		instanceBehavior: ibehavior;
		behavior: cbehavior.
	classes at: definition put: class.
	metaclasses at: definition metaclass put: meta
]

{ #category : #accessing }
VirtualImage >> false [
	^ falseObj
]

{ #category : #building }
VirtualImage >> fixBehaviors [
	self
		initializeBehavior: nilObj;
		initializeBehavior: trueObj;
		initializeBehavior: falseObj;
		initializeBehavior: kernel.
	classes
		do: [ :c | 
			| m |
			m := c behavior slotNamed: 'class'.
			self
				initializeBehavior: c instanceBehavior;
				initializeBehavior: c behavior;
				initializeBehavior: m ]
]

{ #category : #initialization }
VirtualImage >> formatOfClass: definition [
	| variable pointers |
	variable := definition isVariable ifTrue: [ 16r2000 ] ifFalse: [ 0 ].
	pointers := definition isBytes ifTrue: [ 0 ] ifFalse: [16r4000 ].
	^variable | pointers | definition allInstVarNames size
]

{ #category : #building }
VirtualImage >> genesis [
	"
	Create the world (should take less than 6 days). This is named 'genesis' to remind us those who had
	done this (and much more) before us. Namely SELF people. I (JV) would like to use this opportunity and point you to
	
	https://github.com/russellallen/self/blob/2bcf2c4cab23f52bf68ac4f617020e748699a548/vm/src/any/memory/universe.cpp#L79
	"

	nilObj := self basicNewSlots: #UndefinedObject.
	trueObj := self basicNewSlots: #True.
	falseObj := self basicNewSlots: #False.
	kernel := self basicNewSlots: #Kernel.
	specs allClasses do: [ :def | self createSpecies: def ].
	self fixBehaviors.
	specs allClasses do: [ :def | self buildSpecies: def ]
]

{ #category : #accessing }
VirtualImage >> includes: anObject [
	^identityMap includesKey: anObject
]

{ #category : #accessing }
VirtualImage >> initialize [
	classes := OrderedDictionary new.
	metaclasses := OrderedDictionary new.
		identityMap := IdentityDictionary new
]

{ #category : #initialization }
VirtualImage >> initializeBehavior: anObjectMap [
	| class |
	class := classes at: anObjectMap spec.
	anObjectMap behavior: class instanceBehavior.

]

{ #category : #building }
VirtualImage >> initializeClass: definition superclass: superclass superbehavior: superbehavior [
	| class name flag ivars poolnames pools subclasses format |
	class := classes at: definition.
	class instanceBehavior next: superbehavior.
	subclasses := definition subclasses
		collect: [ :def | classes at: def ].
	subclasses := self newArray: subclasses.
	name := self newString: definition name.
	flag := self formatOfClass: definition.
	format := self newInteger: flag.
	ivars := self newStringArray: definition instVarNames.
	poolnames := definition sharedPools collect: #name.
	pools := self newStringArray: poolnames.
	class
		superclass: superclass;
		format: format;
		instanceVariables: ivars;
		classVariables: nilObj;
		organization: nilObj;
		name: name;
		subclasses: subclasses;
		sharedPools: pools.
	definition metaclass allInstVarNames
		do: [ :ivar | class slotNamed: ivar put: nilObj ]
]

{ #category : #building }
VirtualImage >> initializeMetaclass: definition superclass: superclass [
	| meta ivars flags format superbehavior |
	meta := metaclasses at: definition.
	superbehavior := superclass instanceBehavior.
	meta instanceBehavior next: superbehavior.
	ivars := self newStringArray: definition instVarNames.
	flags := self formatOfClass: definition. 
	format := self newInteger: flags.
	meta
		superclass: superclass;
		format: format;
		instanceVariables: ivars;
		organization: nilObj
]

{ #category : #building }
VirtualImage >> kernel [
	^kernel
]

{ #category : #accessing }
VirtualImage >> map: anObject to: anObjectMap [
	identityMap at: anObject put: anObjectMap
]

{ #category : #accessing }
VirtualImage >> metaclassFor: anRGBehavior [
	^ metaclasses at: anRGBehavior
]

{ #category : #initialization }
VirtualImage >> newArray: anArray [
	| assoc |
	assoc := self newSlots: 'Array' sized: anArray size.
	anArray withIndexDo: [ :obj :i | assoc at: i put: obj ].
	^ assoc
]

{ #category : #initialization }
VirtualImage >> newAssociation: anAssociation [
	| assoc key value |
	assoc := self newSlots: 'Association'.
	key := self transferLiteralDeep: anAssociation key.
	value := self transferLiteralDeep: anAssociation value.
	^ assoc
		key: key;
		value: value; yourself
]

{ #category : #initialization }
VirtualImage >> newBytes: classname contents: aByteObject [
	| obj |
	obj := self basicNewBytes: classname contents: aByteObject.
	self initializeBehavior: obj.
	^ obj
]

{ #category : #initialization }
VirtualImage >> newBytesFrom: aByteObject [
	^self newBytes: aByteObject class name contents: aByteObject
]

{ #category : #initialization }
VirtualImage >> newBytesOf: anRGBehavior contents: aByteObject [
	| obj |
	obj := self basicNewBytesOf: anRGBehavior contents: aByteObject.
	self initializeBehavior: obj.
	^ obj
]

{ #category : #initialization }
VirtualImage >> newBytesOf: anRGBehavior sized: anInteger [
	| contents |
	contents := ByteArray new: anInteger.
	^ self newBytesOf: anRGBehavior contents: contents
]

{ #category : #accessing }
VirtualImage >> newFloatFrom: aFloat [
	^ self newBytes: 'Float' contents: aFloat pointerDouble
]

{ #category : #initialization }
VirtualImage >> newInteger: anInteger [
	anInteger > maxSMI
		ifTrue: [ ^ self newLargePositiveInteger: anInteger ].
	anInteger < minSMI
		ifTrue: [ ^ self newLargeNegativeInteger: anInteger ].
	^self newSmallInteger: anInteger
]

{ #category : #initialization }
VirtualImage >> newLargeNegativeInteger: anInteger [
	| size bytes byte |
	size := (anInteger bytesCount alignedTo: 2) max: wordSize.
	bytes := ByteArray new: size withAll: 16rFF.
	1 to: anInteger bytesCount do: [ :i | 
		byte := anInteger byteAt: i.
		byte > 0
			ifTrue: [ byte := 256 - byte ].
		bytes at: i put: byte ].
	^ self newBytes: #LargeNegativeInteger contents: bytes
]

{ #category : #initialization }
VirtualImage >> newLargePositiveInteger: anInteger [
	| size bytes |
	size := (anInteger bytesCount alignedTo: 2) max: wordSize.
	bytes := anInteger asByteArrayOfSize: size.
	^ self newBytes: #LargePositiveInteger contents: bytes reversed
]

{ #category : #initialization }
VirtualImage >> newSlots: classname [
	^self newSlots: classname sized: 0
]

{ #category : #initialization }
VirtualImage >> newSlots: classname sized: size [
"
	Allocate an object of pointer type (as SlotObjectMap).
	It is niled-out, and 	`size` is the size of indexed part (i.e.,
	shall not include named slots)
	"

	| obj |
	obj := self basicNewSlots: classname sized: size.
	self initializeBehavior: obj.
	^ obj
]

{ #category : #initialization }
VirtualImage >> newSlotsOf: anRGBehavior sized: size [
	"
	Allocate an object of pointer type (as SlotObjectMap).
	It is niled-out, and 	`size` is the size of indexed part (i.e.,
	shall not include named slots)
	"

	| obj |
	obj := self basicNewSlotsOf: anRGBehavior sized: size.
	self initializeBehavior: obj.
	^ obj
]

{ #category : #initialization }
VirtualImage >> newSmallInteger: anInteger [
	self ASSERT: (anInteger between: minSMI and: maxSMI).
	^ SmallintObjectMap
		new: self => #SmallInteger
		valued: anInteger
]

{ #category : #initialization }
VirtualImage >> newString: aString [
	| bytes |
	bytes := aString copyWith: Character null.
	^self newBytes: 'String' contents: bytes
]

{ #category : #initialization }
VirtualImage >> newStringArray: strings [
	| array bytes |
	array := self newSlots: 'Array' sized: strings size.
	strings
		withIndexDo: [ :s :i |
			bytes := self newString: s.
			array at: i put: bytes ].
	^ array
]

{ #category : #accessing }
VirtualImage >> newSymbol: aSymbol [
	| new bytes |
	identityMap at: aSymbol ifPresent: [ :s | ^ s ].
	bytes := aSymbol copyWith: Character null.
	new := self newBytes: 'Symbol' contents: bytes.
	^ identityMap at: aSymbol put: new
]

{ #category : #accessing }
VirtualImage >> nil [
	^ nilObj
]

{ #category : #accessing }
VirtualImage >> runtime [
	^ runtime
]

{ #category : #accessing }
VirtualImage >> speciesFor: anRGBehavior [
	^classes at: anRGBehavior ifAbsent: [ metaclasses at: anRGBehavior]
]

{ #category : #accessing }
VirtualImage >> specs [
	^specs
]

{ #category : #accessing }
VirtualImage >> specs: anRGEnvironment [
	specs := anRGEnvironment 
]

{ #category : #testing }
VirtualImage >> surrogateFor: anObject [
	^ identityMap at: anObject ifAbsent: nil
]

{ #category : #accessing }
VirtualImage >> transferBlock: anSCompiledBlock [
	| transferred method format |
	identityMap at: anSCompiledBlock
		ifPresent: [ :b | ^ b ].
	transferred := self newSlots: #CompiledBlock.
	identityMap at: anSCompiledBlock put: transferred.
	method := identityMap at: anSCompiledBlock method.
	format := self newInteger: anSCompiledBlock format.
	transferred
		method: method;
		format: format;
		nativeCode: nilObj.
	^ transferred
]

{ #category : #accessing }
VirtualImage >> transferLiteral: anObject [
	| class transferred slot |
	class := anObject class.
	(class inheritsFrom: ObjectMap)
		ifTrue: [ ^ anObject ].
	(class inheritsFrom: Integer)
		ifTrue: [ ^ self newInteger: anObject ].
	(class inheritsFrom: Symbol)
		ifTrue: [ ^ self newSymbol: anObject ].
	(class inheritsFrom: String)
		ifTrue: [ ^ self newString: anObject ].
	class = ByteArray
		ifTrue: [ ^ self newBytesFrom: anObject ].
	transferred := self newSlots: anObject class name sized: anObject size.
	anObject
		withIndexDo: [ :elem :i | 
			slot := self transferLiteralDeep: elem.
			transferred at: i put: slot ].
	^ transferred
]

{ #category : #accessing }
VirtualImage >> transferLiteralDeep: anObject [
	| class transferred slot size ivar |
	class := anObject class.
	anObject isInteger
		ifTrue: [ ^ self newInteger: anObject ].
	anObject == nil
		ifTrue: [ ^ nilObj ].
	anObject == false
		ifTrue: [ ^ falseObj ].
	anObject == true
		ifTrue: [ ^ trueObj ].
	identityMap at: anObject ifPresent: [ :existing | ^ existing ].
	(class == Symbol or:[class inheritsFrom: Symbol])
		ifTrue: [ ^ self newSymbol: anObject ].
	(anObject isString)
		ifTrue: [ ^ self newString: anObject ].
	class = ByteArray
		ifTrue: [ ^ self newBytesFrom: anObject ].
	(class == Float or:[class inheritsFrom: Float])
		ifTrue: [ ^ self newFloatFrom: anObject ].
	(class inheritsFrom: ObjectMap)
		ifTrue: [ ^ anObject ].
	class == SCompiledBlock
		ifTrue: [ ^ self transferBlock: anObject ].
	size := class isVariable
		ifTrue: [ anObject size ]
		ifFalse: [ 0 ].
	transferred := self newSlots: class name sized: size.
	1 to: class instSize do: [ :i | 
		ivar := anObject instVarAt: i.
		slot := self transferLiteralDeep: ivar.
		transferred slotAt: i put: slot ].
	size > 0
		ifTrue: [ anObject
				withIndexDo: [ :elem :i | 
					slot := self transferLiteralDeep: elem.
					transferred at: i put: slot ] ].
	^ transferred
]

{ #category : #accessing }
VirtualImage >> true [
	^ trueObj
]

{ #category : #accessing }
VirtualImage >> wordSize [
	^ wordSize
]

{ #category : #accessing }
VirtualImage >> wordSize: anInteger [
	wordSize := anInteger.
	maxSMI := (1 bitShift: wordSize * 8 - 2) - 1.
	minSMI := maxSMI negated - 1

]
