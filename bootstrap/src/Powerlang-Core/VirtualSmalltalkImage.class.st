Class {
	#name : #VirtualSmalltalkImage,
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
		'kernel',
		'identityMap'
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
VirtualSmalltalkImage class >> fromSpec [
	^ self new kernel: self kernelSpec
]

{ #category : #accessing }
VirtualSmalltalkImage class >> kernelSpec [
	^ KernelSpec ifNil: [ KernelSpec := self newKernelSpec ]
]

{ #category : #'instance creation' }
VirtualSmalltalkImage class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #accessing }
VirtualSmalltalkImage class >> newKernelSpec [
	| current repo spec |
	current := 'specs/current' asFileReference contents trim.
	repo := TonelRepository new
		directory: ('specs/' , current) asFileReference.
	spec := repo asRingEnvironmentWith: #(Kernel).
	^ spec clean
]

{ #category : #initialization }
VirtualSmalltalkImage >> => aSymbol [
	^ kernel at: aSymbol
]

{ #category : #services }
VirtualSmalltalkImage >> basicNewBytes: classname contents: aByteObject [
	^ self basicNewBytesOf: self => classname contents: aByteObject
]

{ #category : #services }
VirtualSmalltalkImage >> basicNewBytesOf: anRGBehavior  contents: aByteObject [
	^ ByteObjectMap new: anRGBehavior valued: aByteObject
]

{ #category : #accessing }
VirtualSmalltalkImage >> basicNewSlots: classname [
	^ self basicNewSlots: classname sized: 0
]

{ #category : #accessing }
VirtualSmalltalkImage >> basicNewSlots: classname in: spec [
	^ self basicNewSlots: classname in: spec sized: 0
]

{ #category : #accessing }
VirtualSmalltalkImage >> basicNewSlots: classname in: spec sized: size [
	| species |
	species := spec at: classname.
	^self basicNewSlotsOf: species sized: size
]

{ #category : #accessing }
VirtualSmalltalkImage >> basicNewSlots: classname sized: size [
	^ self basicNewSlots: classname in: kernel sized: size
]

{ #category : #accessing }
VirtualSmalltalkImage >> basicNewSlotsOf: anRGBehavior sized: size [
	^ SlotObjectMap new: anRGBehavior size: size withAll: nilObj
]

{ #category : #'own services' }
VirtualSmalltalkImage >> buildSpecies: spec [
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

{ #category : #accessing }
VirtualSmalltalkImage >> classFor: anRGBehavior [
	^classes at: anRGBehavior
]

{ #category : #building }
VirtualSmalltalkImage >> classNamed: aString [
	^self classFor: self => aString
]

{ #category : #accessing }
VirtualSmalltalkImage >> classes [
	^ classes
]

{ #category : #accessing }
VirtualSmalltalkImage >> createSpecies: definition [
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
VirtualSmalltalkImage >> false [
	^ falseObj
]

{ #category : #building }
VirtualSmalltalkImage >> fixBehaviors [
self
				initializeBehavior: nilObj;
				initializeBehavior: trueObj;
				initializeBehavior: falseObj.
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
VirtualSmalltalkImage >> formatOfClass: definition [
	| variable pointers |
	variable := definition isVariable ifTrue: [ 16r2000 ] ifFalse: [ 0 ].
	pointers := definition isBytes ifTrue: [ 0 ] ifFalse: [16r4000 ].
	^variable | pointers | definition allInstVarNames size
]

{ #category : #building }
VirtualSmalltalkImage >> genesis [
	"
	Create the world (should take less than 6 days). This is named 'genesis' to remind us those who had
	done this (and much more) before us. Namely SELF people. I (JV) would like to use this opportunity and point you to
	
	https://github.com/russellallen/self/blob/2bcf2c4cab23f52bf68ac4f617020e748699a548/vm/src/any/memory/universe.cpp#L79
	"

	nilObj := self basicNewSlots: #UndefinedObject.
	trueObj := self basicNewSlots: #True.
	falseObj := self basicNewSlots: #False.
	kernel allClasses do: [ :def | self createSpecies: def ].
	self fixBehaviors. 
	kernel allClasses do: [ :def | self buildSpecies: def ]
]

{ #category : #accessing }
VirtualSmalltalkImage >> includes: anObject [
	^identityMap includesKey: anObject
]

{ #category : #accessing }
VirtualSmalltalkImage >> initialize [
	classes := OrderedDictionary new.
	metaclasses := OrderedDictionary new.
		identityMap := IdentityDictionary new
]

{ #category : #initialization }
VirtualSmalltalkImage >> initializeBehavior: anObjectMap [
	| class |
	class := classes at: anObjectMap spec.
	anObjectMap behavior: class instanceBehavior.

]

{ #category : #building }
VirtualSmalltalkImage >> initializeClass: definition superclass: superclass superbehavior: superbehavior [
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
		organization: nilObj;
		name: name;
		subclasses: subclasses;
		sharedPools: pools.
	definition metaclass allInstVarNames
		do: [ :ivar | class slotNamed: ivar put: nilObj ]
]

{ #category : #building }
VirtualSmalltalkImage >> initializeMetaclass: definition superclass: superclass [
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

{ #category : #accessing }
VirtualSmalltalkImage >> kernel [
	^kernel
]

{ #category : #accessing }
VirtualSmalltalkImage >> kernel: anRGEnvironment [
	kernel := anRGEnvironment 
]

{ #category : #accessing }
VirtualSmalltalkImage >> map: anObject to: anObjectMap [
	identityMap at: anObject put: anObjectMap
]

{ #category : #accessing }
VirtualSmalltalkImage >> metaclassFor: anRGBehavior [
	^ metaclasses at: anRGBehavior
]

{ #category : #initialization }
VirtualSmalltalkImage >> newArray: anArray [
	| assoc |
	assoc := self newSlots: 'Array' sized: anArray size.
	anArray withIndexDo: [ :obj :i | assoc at: i put: obj ].
	^ assoc
]

{ #category : #initialization }
VirtualSmalltalkImage >> newAssociation: anAssociation [
	| assoc key value |
	assoc := self newSlots: 'Association'.
	key := self transferLiteralDeep: anAssociation key.
	value := self transferLiteralDeep: anAssociation value.
	^ assoc
		key: key;
		value: value; yourself
]

{ #category : #initialization }
VirtualSmalltalkImage >> newBytes: classname contents: aByteObject [
	| obj |
	obj := self basicNewBytes: classname contents: aByteObject.
	self initializeBehavior: obj.
	^ obj
]

{ #category : #initialization }
VirtualSmalltalkImage >> newBytesFrom: aByteObject [
	^self newBytes: aByteObject class name contents: aByteObject
]

{ #category : #initialization }
VirtualSmalltalkImage >> newBytesOf: anRGBehavior contents: aByteObject [
	| obj |
	obj := self basicNewBytesOf: anRGBehavior contents: aByteObject.
	self initializeBehavior: obj.
	^ obj
]

{ #category : #initialization }
VirtualSmalltalkImage >> newBytesOf: anRGBehavior sized: anInteger [
	| contents |
	contents := ByteArray new: anInteger.
	^ self newBytesOf: anRGBehavior contents: contents
]

{ #category : #accessing }
VirtualSmalltalkImage >> newFloatFrom: aFloat [
	^ self newBytes: 'Float' contents: aFloat pointerDouble
]

{ #category : #initialization }
VirtualSmalltalkImage >> newInteger: anInteger [
	anInteger > maxSMI
		ifTrue: [ ^ self newLargePositiveInteger: anInteger ].
	anInteger < minSMI
		ifTrue: [ ^ self newLargeNegativeInteger: anInteger ].
	^self newSmallInteger: anInteger
]

{ #category : #initialization }
VirtualSmalltalkImage >> newLargeNegativeInteger: anInteger [
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
VirtualSmalltalkImage >> newLargePositiveInteger: anInteger [
	| size bytes |
	size := (anInteger bytesCount alignedTo: 2) max: wordSize.
	bytes := anInteger asByteArrayOfSize: size.
	^ self newBytes: #LargePositiveInteger contents: bytes reversed
]

{ #category : #initialization }
VirtualSmalltalkImage >> newSlots: classname [
	^self newSlots: classname sized: 0
]

{ #category : #initialization }
VirtualSmalltalkImage >> newSlots: classname sized: size [
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
VirtualSmalltalkImage >> newSlotsOf: anRGBehavior sized: size [
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
VirtualSmalltalkImage >> newSmallInteger: anInteger [
	self ASSERT: (anInteger between: minSMI and: maxSMI).
	^ SmallintObjectMap
		new: self => #SmallInteger
		valued: anInteger
]

{ #category : #initialization }
VirtualSmalltalkImage >> newString: aString [
	| bytes |
	bytes := aString copyWith: Character null.
	^self newBytes: 'String' contents: bytes
]

{ #category : #initialization }
VirtualSmalltalkImage >> newStringArray: strings [
	| array bytes |
	array := self newSlots: 'Array' sized: strings size.
	strings
		withIndexDo: [ :s :i |
			bytes := self newString: s.
			array at: i put: bytes ].
	^ array
]

{ #category : #accessing }
VirtualSmalltalkImage >> newSymbol: aSymbol [
	| new bytes |
	identityMap at: aSymbol ifPresent: [ :s | ^ s ].
	bytes := aSymbol copyWith: Character null.
	new := self newBytes: 'Symbol' contents: bytes.
	^ identityMap at: aSymbol put: new
]

{ #category : #accessing }
VirtualSmalltalkImage >> nil [
	^ nilObj
]

{ #category : #accessing }
VirtualSmalltalkImage >> speciesFor: anRGBehavior [
	^classes at: anRGBehavior ifAbsent: [ metaclasses at: anRGBehavior]
]

{ #category : #testing }
VirtualSmalltalkImage >> surrogateFor: anObject [
	^ identityMap at: anObject ifAbsent: nil
]

{ #category : #accessing }
VirtualSmalltalkImage >> transferBlock: anSCompiledBlock [
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
VirtualSmalltalkImage >> transferLiteral: anObject [
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
VirtualSmalltalkImage >> transferLiteralDeep: anObject [
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
VirtualSmalltalkImage >> true [
	^ trueObj
]

{ #category : #accessing }
VirtualSmalltalkImage >> wordSize [
	^ wordSize
]

{ #category : #accessing }
VirtualSmalltalkImage >> wordSize: anInteger [
	wordSize := anInteger.
		maxSMI := (1 bitShift: wordSize * 8 - 2) - 1.
	minSMI := maxSMI negated - 1

]
