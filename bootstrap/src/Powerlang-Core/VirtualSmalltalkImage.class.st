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
		'kernel'
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
	^ByteObjectMap new: self => classname valued: aByteObject.

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
	^ SlotObjectMap new: species size: size withAll: nilObj
]

{ #category : #accessing }
VirtualSmalltalkImage >> basicNewSlots: classname sized: size [
	^ self basicNewSlots: classname in: kernel sized: size
]

{ #category : #accessing }
VirtualSmalltalkImage >> booleanFrom: anObject [
anObject == falseObj ifTrue: [ ^false ].
	anObject == trueObj ifTrue: [ ^true ].	
	self error: 'not a boolean'
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
VirtualSmalltalkImage >> initialize [
	classes := OrderedDictionary new.
	metaclasses := OrderedDictionary new
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
VirtualSmalltalkImage >> kernel: anRGBehavior [
	kernel := anRGBehavior
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
	^ ByteObjectMap
		new: self => #LargeNegativeInteger
		valued: bytes
]

{ #category : #initialization }
VirtualSmalltalkImage >> newLargePositiveInteger: anInteger [
	| size bytes |
	size := (anInteger bytesCount alignedTo: 2) max: wordSize.
	bytes := anInteger asByteArrayOfSize: size.
	^ ByteObjectMap
		new: self => #LargePositiveInteger
		valued: bytes
]

{ #category : #initialization }
VirtualSmalltalkImage >> newSlots: classname sized: size [
	| obj |
	obj := self basicNewSlots: classname sized: size.
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
VirtualSmalltalkImage >> nil [
	^ nilObj
]

{ #category : #accessing }
VirtualSmalltalkImage >> true [
	^ trueObj
]

{ #category : #accessing }
VirtualSmalltalkImage >> wordSize: anInteger [
	wordSize := anInteger.
		maxSMI := (1 bitShift: wordSize * 8 - 2) - 1.
	minSMI := maxSMI negated - 1

]
