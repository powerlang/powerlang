Class {
	#name : #ImageSegmentBuilder,
	#superclass : #Object,
	#instVars : [
		'objects',
		'classDef2ClassObjMap',
		'symbol2symbolObjMap',
		'definition',
		'kernel',
		'tocObj'
	],
	#classVars : [
		'Kernel'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #acccessing }
ImageSegmentBuilder class >> kernel [
	Kernel isNil ifTrue:[
		| repo |
		repo := TonelRepository new directory: '../pst' asFileReference.
		Kernel := repo  asRingEnvironmentWith: #(kernel).
		Kernel clean.
	].
	^ Kernel
	
]

{ #category : #acccessing }
ImageSegmentBuilder class >> kernel: anRGEnvironment [
	Kernel := anRGEnvironment 
]

{ #category : #building }
ImageSegmentBuilder >> build [
	self notYetImplemented 
]

{ #category : #acccessing }
ImageSegmentBuilder >> falseObj [
	self notYetImplemented 
]

{ #category : #'building-private' }
ImageSegmentBuilder >> fixBehaviorIn: obj [
	| cls |
	
	cls := classDef2ClassObjMap at: obj behaviorDef.
	obj behavior: cls instanceBehavior. 
]

{ #category : #'building-private' }
ImageSegmentBuilder >> fixBehaviorInIfNotAlready: obj [
	obj behavior isNil ifTrue:[
		self fixBehaviorIn: obj
	]
]

{ #category : #'building-private' }
ImageSegmentBuilder >> fixBehaviors [
	objects withIndexDo:[:obj :idx| self fixBehaviorInIfNotAlready: obj ].
]

{ #category : #'building-private' }
ImageSegmentBuilder >> fixHierarchy [
	definition behaviorsDo: [:behaviorDef | 
		behaviorDef isMeta ifFalse:[	
			self assert: (classDef2ClassObjMap includesKey: behaviorDef).
			self fixHierarchyIn: (classDef2ClassObjMap at: behaviorDef) def: behaviorDef.
		]	
	]
]

{ #category : #'building-private' }
ImageSegmentBuilder >> fixHierarchyIn: clsObj def: clsDef [
	"
	Fix hierarchy (superclasses, behavior links) in given class.
	"
	clsDef superclass notNil ifTrue:[
			| superObj |
			
			superObj := classDef2ClassObjMap at: clsDef superclass.
			
			"Link classes"
			clsObj superclass: superObj.
			clsObj instanceBehavior next: superObj instanceBehavior.
			
			"Link superclasses"
			clsObj behavior superclass: superObj behavior.
			clsObj behavior instanceBehavior next: superObj behavior instanceBehavior.			
	] ifFalse:[
		| classObj |
		
		classObj := classDef2ClassObjMap at: (kernel at: #Class).
		
		clsObj behavior superclass: classObj.
		clsObj behavior instanceBehavior next: classObj instanceBehavior.
	]
	


]

{ #category : #initialization }
ImageSegmentBuilder >> initialize [
	super initialize.
	objects := OrderedCollection new.
	classDef2ClassObjMap := Dictionary new.
	symbol2symbolObjMap := Dictionary new.
	kernel := self class kernel.
]

{ #category : #'building-private' }
ImageSegmentBuilder >> makeBehaviorFor: clsObj size: size [
	| behaviorObj |
	
	behaviorObj := self makeInstanceOf: #Behavior "size: size * 2".
	^behaviorObj 
]

{ #category : #'building-private' }
ImageSegmentBuilder >> makeClass: className [
	"Create a single class and return it."	
	| clsDef clsObj metaObj |
	
	clsDef := definition at: className.
	self assert: clsDef notNil.  
	self assert: clsDef isMeta not.
	self assert: clsDef metaclass instSize == 0.
				
	clsObj := self makeInstanceOf: #Class.
	clsObj instanceBehavior: (self makeBehaviorFor: clsObj size: clsDef methods size).
	clsObj name: (self makeSymbol: clsDef name).
	
	metaObj := self makeInstanceOf: #Metaclass.
	metaObj instanceBehavior: (self makeBehaviorFor: metaObj size: clsDef metaclass methods size).
	metaObj class: clsObj.
	
	clsObj behavior: metaObj.
	
	classDef2ClassObjMap at: clsDef put: clsObj.
	classDef2ClassObjMap at: clsDef metaclass put: metaObj.
	^ clsObj.
	
]

{ #category : #'building-private' }
ImageSegmentBuilder >> makeClassIfNotAlready: className [
	"Create given class if it's not already created and return it."
	self assert: (definition at: className) notNil.

	^classDef2ClassObjMap 
		at: (definition at: className)
		ifAbsent:[self makeClass: className]
	
]

{ #category : #'building-private' }
ImageSegmentBuilder >> makeClasses [
	definition behaviorsDo: [:behavior | 
		behavior isMeta ifFalse:[
			self makeClassIfNotAlready: behavior  name ]	
		]
	
]

{ #category : #utilities }
ImageSegmentBuilder >> makeInstanceOf: className [
	^ self makeInstanceOf: className size: 0
	
	
]

{ #category : #utilities }
ImageSegmentBuilder >> makeInstanceOf: className bytes: bytes [
	| obj |
		
	obj := self makeInstanceOf: className size: bytes size.
	1 to: bytes size do:[:i | obj at: i put: (bytes at:i) ].
	^obj.
]

{ #category : #utilities }
ImageSegmentBuilder >> makeInstanceOf: className size: size [
	"Allocate, nil-out and return an instance (as ObjectMap) of class `className`.
	`size` is the size of indexed part of the object (i.e., shall not include 
	named slots). For non-variable objects, must be 0.
	
	Slots of the object is set to nilObj (for pointer-objects) or to 0 (byte-objects).
	Smallinteger instances are set to 0.
	"
	| clsDef obj  |
	
	clsDef := (definition at: className) ifNil:[kernel at: className].
	
	self assert: clsDef notNil.
	
	obj := ObjectMap new: clsDef size: size.
	obj isBytes ifTrue:[
		1 to: obj size do:[:i | obj at: i put: 0 ].
	] ifFalse:[
		obj isPointers ifTrue:[
			| numSlots null |
			
			numSlots := obj behaviorDef instSize.
			null := self nilObj.
			1 to: obj size do:[:i |				
				i <= numSlots ifTrue:[
					obj slotAt: i put: null.		
				] ifFalse:[
					obj at: i - numSlots put: null.
				]
			]
		] ifFalse:[
			self assert: obj isImmediate.
			obj value: 0.
		]
	].
	objects add: obj.
	^obj
	
	
	
	
]

{ #category : #utilities }
ImageSegmentBuilder >> makeSmallInteger: value [
	^(self makeInstanceOf: #SmallInteger)
		value: value;
		yourself
	
]

{ #category : #utilities }
ImageSegmentBuilder >> makeSymbol: value [
	^ symbol2symbolObjMap 
			at: value asSymbol 
			ifAbsentPut: [ self makeInstanceOf: #Symbol bytes: value asByteArray ].
	
]

{ #category : #acccessing }
ImageSegmentBuilder >> nilObj [
	self notYetImplemented 
]

{ #category : #acccessing }
ImageSegmentBuilder >> trueObj [
	self notYetImplemented 
]

{ #category : #accessing }
ImageSegmentBuilder >> validate [
	objects do:[:obj | obj validate]
]

{ #category : #writing }
ImageSegmentBuilder >> write [
	^ ByteArray streamContents:[:s | self writeTo: s ]
]

{ #category : #writing }
ImageSegmentBuilder >> writeTo: aStream [
	ImageSegmentWriter new
		stream: aStream;
		objects: objects; 
		write
		
]

{ #category : #writing }
ImageSegmentBuilder >> writeToFile: file [
	file asFileReference binaryWriteStreamDo: [ :stream |
		"Bit stupid - we write into internal ByteArray backed stream and
		then write it to real file. That's because WriteStream and ZnWriteStream
		are not polymorphic. Sigh"

		stream nextPutAll: self write.
	]
	
		
]
