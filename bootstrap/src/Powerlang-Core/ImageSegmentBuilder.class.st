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

{ #category : #utilities }
ImageSegmentBuilder >> findClassDef: name [
	"Return a class definition (as RGBehavior) for class
	 with given name or nil (if not found in definitions)"
	
	^definition at: name
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
	| superObj superMetaObj metaObj |
	clsDef superclass notNil ifTrue:[			
			superObj := classDef2ClassObjMap at: (self findClassDef: clsDef superclass name) .
			superMetaObj := classDef2ClassObjMap at: (self findClassDef: clsDef superclass name) metaclass.
	] ifFalse:[
			superObj := classDef2ClassObjMap at: (kernel at: #Class).
			superMetaObj := classDef2ClassObjMap at: (kernel at: #Class) metaclass.
	].

	"Link classes"
	clsObj superclass: superObj.
	clsObj instanceBehavior next: superObj instanceBehavior.
			
	"Link metaclasses"
	metaObj := classDef2ClassObjMap at: clsDef metaclass.			
	metaObj superclass: superObj behavior.
	metaObj instanceBehavior next: superMetaObj instanceBehavior.
	


]

{ #category : #initialization }
ImageSegmentBuilder >> initialize [
	super initialize.
	objects := OrderedCollection new.
	classDef2ClassObjMap := Dictionary new.
	symbol2symbolObjMap := Dictionary new.
	kernel := self class kernel.
]

{ #category : #utilities }
ImageSegmentBuilder >> makeArray: items [
	| arrayObj index |
	
	arrayObj := self makeArraySize: items size.
	index := 1.
	items do:[:item | 
		arrayObj at: index put: item.
		index := index + 1.
	].
	^arrayObj
]

{ #category : #utilities }
ImageSegmentBuilder >> makeArraySize: size [
	^self makeInstanceOf: #Array size: size
]

{ #category : #'building-private' }
ImageSegmentBuilder >> makeBehaviorFor: clsObj methods: methods [
	| tableObj methodsObj behaviorObj |
	
	tableObj := self makeInstanceOf: #InlinedHashTable size: methods size * 2.
	methods withIndexDo: [ :methodDef :methodNo |
		| methodObj selectorObj selectorIdx |
		
		methodObj := self makeMethodDef: methodDef.
		selectorObj := methodObj selector.
		
		selectorIdx := ((methodNo - 1) * 2) + 1.
		
		tableObj at: selectorIdx put: selectorObj.
		tableObj at: selectorIdx + 1 put: methodObj.		
	].
		
	methodsObj := self makeInstanceOf: #MethodDictionary.
	methodsObj tally: (self makeSmallInteger: methods size).
	methodsObj table: tableObj.
	methodsObj class: clsObj.
	
	behaviorObj := self makeInstanceOf: #Behavior.
	behaviorObj methods: methodsObj.

	
	^behaviorObj 
]

{ #category : #'building-private' }
ImageSegmentBuilder >> makeClass: className [
	"Create a single class and return it."	
	| clsDef clsObj metaObj |
	
	clsDef := self findClassDef: className.
	self assert: clsDef notNil.  
	self assert: clsDef isMeta not.
	self assert: clsDef metaclass instSize == 0.
				
	clsObj := self makeInstanceOf: #Class.
	classDef2ClassObjMap at: clsDef put: clsObj.
	clsObj instanceBehavior: (self makeBehaviorFor: clsObj methods: clsDef methods).
	clsObj name: (self makeSymbol: clsDef name).
	
	metaObj := self makeInstanceOf: #Metaclass.
	classDef2ClassObjMap at: clsDef metaclass put: metaObj.
	metaObj instanceBehavior: (self makeBehaviorFor: metaObj methods: clsDef metaclass methods).
	metaObj class: clsObj.
	
	clsObj behavior: metaObj instanceBehavior.
		
	^ clsObj.
	
]

{ #category : #'building-private' }
ImageSegmentBuilder >> makeClassIfNotAlready: className [
	"Create given class if it's not already created and return it."
	self assert: (self findClassDef: className) notNil.

	^classDef2ClassObjMap 
		at: (self findClassDef: className)
		ifAbsent:[self makeClass: className]
	
]

{ #category : #'building-private' }
ImageSegmentBuilder >> makeClasses [
	self makeClasses: definition 	
]

{ #category : #'building-private' }
ImageSegmentBuilder >> makeClasses: environment [
	environment behaviorsDo: [:behavior | 
		behavior isMeta ifFalse:[
			self makeClassIfNotAlready: behavior  name ]	
		]
	
]

{ #category : #utilities }
ImageSegmentBuilder >> makeFloat: value [
	"CRAP CRAP CRAP, totally bogus!"
	^self nilObj 	
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
	
	clsDef := (self findClassDef: className) ifNil:[kernel at: className].
	
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
	obj isImmediate ifFalse:[
		objects add: obj.
	].
	^obj
	
	
	
	
]

{ #category : #utilities }
ImageSegmentBuilder >> makeInteger: value [
	value isSmallInteger ifTrue:[
		^self makeSmallInteger: value.
	] ifFalse:[
		"CRAP CRAP CRAP, totally bogus!"
		^self nilObj 	
	]
	
]

{ #category : #utilities }
ImageSegmentBuilder >> makeLiteral: anObject [
	anObject isArray ifTrue:[
		^self makeArray: (anObject collect:[:e|self makeLiteral:e])
	].	
	anObject == true ifTrue:[
		^self trueObj 
	].
	anObject == false ifTrue:[
		^self falseObj 
	].
	anObject isNil ifTrue:[
		^self nilObj 
	].
	anObject isSymbol ifTrue:[
		^self makeSymbol: anObject.
	].
	anObject isString ifTrue:[
		^self makeString: anObject.
	].
	anObject class == Association ifTrue:[
		| assoc |
		
		assoc := self makeInstanceOf: #Association.
		assoc key: (self makeLiteral: anObject key).
		assoc value: (self makeLiteral: anObject value).
		^assoc.
	].
	anObject isClass ifTrue:[
		^classDef2ClassObjMap at: anObject
	].
	anObject isFloat ifTrue:[
		^self makeFloat: anObject.
	].
	anObject isInteger ifTrue:[
		^self makeInteger: anObject.
	].
	self error: 'Invalid literal object'
		

]

{ #category : #'building-private' }
ImageSegmentBuilder >> makeMethodDef: anRGMethod [
	| compiler methodInfo astcodesObj literalsObj methodObj  |
	
	[
	compiler := Compiler forClass: anRGMethod parent.
	methodInfo := compiler compile: anRGMethod sourceCode.	
	astcodesObj := self makeLiteral: methodInfo astcodes.
	literalsObj := self makeLiteral: methodInfo literals asArray.
	] on: Error do:[:ex| 
		methodInfo := astcodesObj := literalsObj := nil.
		Transcript show: 'PST: failed to compile ', anRGMethod parent name , ' >> ' , anRGMethod selector, ': ', ex messageText; cr.
	].
	
	methodObj := self makeInstanceOf: #CompiledMethod size: 0.
	methodObj class: (classDef2ClassObjMap at: anRGMethod methodClass).
	methodObj selector: (self makeSymbol: anRGMethod selector).
	methodObj nativeCode: (self makeSmallInteger: 0).
	methodInfo notNil ifTrue:[
		methodObj format: (self makeSmallInteger: methodInfo format).
		methodObj bytecodes: astcodesObj.
		methodObj literals: literalsObj.
	].
	^methodObj 
]

{ #category : #utilities }
ImageSegmentBuilder >> makeSmallInteger: value [
	^(self makeInstanceOf: #SmallInteger)
		value: value;
		yourself
	
]

{ #category : #utilities }
ImageSegmentBuilder >> makeString: value [
	^ self makeInstanceOf: #String bytes: value asByteArray
	
]

{ #category : #utilities }
ImageSegmentBuilder >> makeSymbol: value [
	^ symbol2symbolObjMap 
			at: value asSymbol 
			ifAbsentPut: [ self makeInstanceOf: #Symbol bytes: value asByteArray ].
	
]

{ #category : #'building-private' }
ImageSegmentBuilder >> makeTOC [
	self notYetImplemented 
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
		toc: tocObj;
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
