Class {
	#name : #SmalltalkBootstrapper,
	#superclass : #Object,
	#instVars : [
		'index',
		'classes',
		'objects',
		'symbols',
		'nilObj',
		'trueObj',
		'falseObj',
		'environment'
	],
	#classVars : [
		'Spec'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #accessing }
SmalltalkBootstrapper class >> fromSpec [
	^self new spec: self spec
]

{ #category : #accessing }
SmalltalkBootstrapper class >> spec [
	Spec ifNil:[
		| repo |
		repo := TonelRepository new directory: '../pst' asFileReference.
		Spec := repo asRingEnvironmentWith: #(kernel).
		Spec clean.
	].
	^ Spec
	
]

{ #category : #initialization }
SmalltalkBootstrapper >> => aSymbol [
	^environment at: aSymbol
]

{ #category : #initialization }
SmalltalkBootstrapper >> basicNewBytes: classname contents: aByteObject [
	| obj |
	obj := ByteObjectMap new: self => classname valued: aByteObject.
	^objects add: obj
]

{ #category : #initialization }
SmalltalkBootstrapper >> basicNewSlots: classname [
	^self basicNewSlots: classname sized: 0

]

{ #category : #initialization }
SmalltalkBootstrapper >> basicNewSlots: classname sized: size [
	| spec instance |
	spec := environment at: classname.
	instance := SlotObjectMap new: spec size: size withAll: nilObj.
	^ objects add: instance
]

{ #category : #building }
SmalltalkBootstrapper >> build [
	self genesis
]

{ #category : #initialization }
SmalltalkBootstrapper >> buildTestMethod [
	| method astcodes |
	method := self newSlots: 'CompiledMethod'.
	astcodes := self transferArrayDeep: self testMethodAstcodes.
	method
		nativeCode: nilObj;
		astcodes: astcodes.
	^ method
]

{ #category : #initialization }
SmalltalkBootstrapper >> classNamed: name [
	^self objectNamed: name
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> classNamedOrNil: aSymbol [
	^ index at: aSymbol ifAbsent: nilObj
]

{ #category : #initialization }
SmalltalkBootstrapper >> classes [
	^classes
]

{ #category : #initialization }
SmalltalkBootstrapper >> createClass: definition [
	| class behavior |
	class := self basicNewSlots: #Class.
	self define: class as: definition name.
	behavior := self basicNewSlots: #Behavior.
	behavior class: class.
	class instanceBehavior: behavior.
	classes at: definition put: class.
	self define: class as: definition name

]

{ #category : #initialization }
SmalltalkBootstrapper >> createClasses [
	environment allClasses
		do: [ :def | self createClass: def; createMetaclass: def ];
		do: [ :def | self initializeClass: def; initializeMetaclass: def]
]

{ #category : #initialization }
SmalltalkBootstrapper >> createFalse [
	falseObj := self basicNewSlots: #False
]

{ #category : #initialization }
SmalltalkBootstrapper >> createLoadAction [
	|  message receiver selector argument arguments |
	message := self new: #MessageSend.
	receiver := self newSmallInteger: 10.
	selector := self newSymbol: #gcd:.
	argument := self newSmallInteger: 15.
	arguments := self newArray: {argument}.
	message receiver: receiver; selector: selector; arguments: arguments.
	^message
]

{ #category : #initialization }
SmalltalkBootstrapper >> createMetaclass: spec [
	|  meta ibehavior class |
	meta := self basicNewSlots: #Metaclass.
	ibehavior := self basicNewSlots: #Behavior.
	ibehavior class: meta.
	class := classes at: spec.
	class behavior: ibehavior.
	meta instanceBehavior: ibehavior; class: class.

]

{ #category : #initialization }
SmalltalkBootstrapper >> createModule [
	| module array |
	module := self new: #Module.
	array := self newArray: classes values.
	module classes: array; loadAction: self createLoadAction.
	^module
]

{ #category : #initialization }
SmalltalkBootstrapper >> createNil [
	nilObj := self basicNewSlots: #UndefinedObject.
]

{ #category : #initialization }
SmalltalkBootstrapper >> createTrue [
	trueObj := self basicNewSlots: #True
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> define: anObject as: aSymbol [
	^ index at: aSymbol put: anObject
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> falseObject [
	^ falseObj
]

{ #category : #initialization }
SmalltalkBootstrapper >> formatOfClass: definition [
	| variable pointers |
	variable := definition isVariable ifTrue: [ 16r2000 ] ifFalse: [ 0 ].
	pointers := definition isBytes ifTrue: [ 0 ] ifFalse: [16r4000 ].
	^variable | pointers | definition allInstVarNames size
]

{ #category : #building }
SmalltalkBootstrapper >> genesis [
	"
	Create the world (should take less than 6 days). This is named 'genesis' to remind us those who had
	done this (and much more) before us. Namely SELF people. I (JV) would like to use this opportunity and point you to
	
	https://github.com/russellallen/self/blob/2bcf2c4cab23f52bf68ac4f617020e748699a548/vm/src/any/memory/universe.cpp#L79
	"	
	self
		createNil;
		createTrue;
		createFalse;
		createClasses;
		initializeBehaviors;
		validate
]

{ #category : #initialization }
SmalltalkBootstrapper >> initialize [
	index := Dictionary new.
	classes := OrderedDictionary new.
	objects := OrderedCollection new.
	symbols := OrderedDictionary new
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeBehavior: anObjectMap [
	| class |
	class := classes at: anObjectMap spec.
	anObjectMap behavior: class instanceBehavior.

]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeBehaviors [
	objects do: [:o | o behavior ifNil: [ self initializeBehavior: o ]]
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeClass: definition [
	| class supername superclass name flag ivars classIvars pools subclasses format |
	class := classes at: definition.
	supername := definition superclass ifNotNil: [ :s | s name ].
	superclass := self classNamedOrNil: supername.
	subclasses := definition subclasses collect: [ :def | self classNamed: def name ].
	subclasses := self newArray: subclasses.
	name := self newString: definition name.
	flag := self formatOfClass: definition.
	format := self newSmallInteger: flag.
	ivars := self newStringArray: definition instVarNames.
	classIvars := self newStringArray: definition classVarNames.
	pools := self newStringArray: definition sharedPools.
	class
		superclass: superclass;
		format: format;
		instanceVariables: ivars;
		organization: nilObj;
		name: name;
		subclasses: subclasses;
		classVariables: classIvars;
		sharedPools: pools
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeMetaclass: definition [
	| class meta supername superclass ivars supermeta flags format |
	class := classes at: definition.
	meta := class behavior slotNamed: #class.
	supername := definition superclass ifNotNil: [ :s | s name ].
	superclass := self classNamedOrNil: supername.
	supermeta := superclass == nilObj
		ifTrue: [ self classNamed: #ProtoObject ]
		ifFalse: [ superclass behavior slotNamed: #class].
	ivars := self newStringArray: definition metaclass instVarNames.
	flags := self formatOfClass: definition metaclass.
	format := self newSmallInteger: flags.
	meta
		superclass: supermeta;
		format: format;
		instanceVariables: ivars;
		organization: nilObj
]

{ #category : #initialization }
SmalltalkBootstrapper >> instanceBehaviorOf: classname [
	| class |
	class := self classNamed: classname.
	^class instanceBehavior

]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> nameOf: anObject [
	^ index keyAtValue: anObject ifAbsent: nil
]

{ #category : #initialization }
SmalltalkBootstrapper >> new: classname [
	"	Allocate an object of pointer type. It is niled-out "

	^self new: classname sized: 0
]

{ #category : #initialization }
SmalltalkBootstrapper >> new: classname sized: size [
	"
	Allocate an object of pointer type (as SlotObjectMap).
	It is niled-out, and 	`size` is the size of indexed part (i.e.,
	shall not include named slots)
	"

	| obj |
	obj := self newSlots: classname sized: size.
	1 to: obj basicSize do: [ :i | obj basicAt: i put: nilObj ].
	^ obj
]

{ #category : #initialization }
SmalltalkBootstrapper >> newArray: anArray [
	| instance |
	instance := self newSlots: 'Array' sized: anArray size.
	anArray withIndexDo: [ :obj :i | instance at: i put: obj ].
	^ instance
]

{ #category : #initialization }
SmalltalkBootstrapper >> newBehavior [
	^ self newSlots: 'Behavior'
]

{ #category : #initialization }
SmalltalkBootstrapper >> newBytes: classname contents: aByteObject [
	| obj |
	obj := self basicNewBytes: classname contents: aByteObject. 
	self initializeBehavior: obj.
	^obj
]

{ #category : #initialization }
SmalltalkBootstrapper >> newBytesFrom: aByteObject [
	^self newBytes: aByteObject class name contents: aByteObject
]

{ #category : #initialization }
SmalltalkBootstrapper >> newClosure: aPCompiledBlock [
	^ self newSlots: 'Closure'
]

{ #category : #initialization }
SmalltalkBootstrapper >> newMethod: anAstcode selector: aSymbol in: classname format: anInteger literals: anArray [
	| method astcodes class selector format |
	method := self newSlots: 'CompiledMethod'.
	astcodes := self transferAstcodesFrom: anAstcode.
	class := self classNamed: classname.
	selector := self newSymbol: aSymbol.
	format := self newSmallInteger: anInteger.
	method
		nativeCode: self nilObject;
		astcodes: astcodes;
		class: class;
		selector: selector;
		format: format;
		source: self nilObject.
	^ method
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> newNamed: aSymbol [
	| obj |
	obj := self newSlots: aSymbol.
	^ index at: aSymbol put: obj
]

{ #category : #initialization }
SmalltalkBootstrapper >> newSlots: classname [
	^self newSlots: classname sized: 0
]

{ #category : #initialization }
SmalltalkBootstrapper >> newSlots: classname sized: size [
	| obj |
	obj := self basicNewSlots: classname sized: size.
	self initializeBehavior: obj.
	^obj
]

{ #category : #initialization }
SmalltalkBootstrapper >> newSmallInteger: anInteger [
	^SmallintObjectMap new: self => #SmallInteger valued: anInteger
]

{ #category : #initialization }
SmalltalkBootstrapper >> newString: aString [
	| bytes |
	bytes := aString copyWith: Character null.
	^self newBytes: 'String' contents: bytes
]

{ #category : #initialization }
SmalltalkBootstrapper >> newStringArray: strings [
	| array bytes |
	array := self newSlots: 'Array' sized: strings size.
	strings
		withIndexDo: [ :s :i |
			bytes := self newString: s.
			array at: i put: bytes ].
	^ array
]

{ #category : #initialization }
SmalltalkBootstrapper >> newSymbol: aSymbol [
	| new bytes |
	symbols at: aSymbol ifPresent: [:s | ^s ].
	bytes := aSymbol copyWith: Character null.
	new := self newBytes: 'Symbol' contents: bytes.
	^symbols at: aSymbol put: new
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> nilObject [
	^nilObj 
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> objectNamed: aSymbol [
	^ index at: aSymbol
]

{ #category : #accessing }
SmalltalkBootstrapper >> objects [
	^ objects
]

{ #category : #initialization }
SmalltalkBootstrapper >> spec: anRGEnvironment [
	environment := anRGEnvironment
]

{ #category : #initialization }
SmalltalkBootstrapper >> specNamed: aSymbol [
	^environment at: aSymbol
]

{ #category : #initialization }
SmalltalkBootstrapper >> testMethodAstcodes [
	"m instVar1 := true
	#(MethodId #(AssignmentId #(IdentifierId InstVarId 1) #(IdentifierId TrueId)))"
	^#(1 #(8 #(3 8 1) #(3 2)))
]

{ #category : #initialization }
SmalltalkBootstrapper >> transferArrayDeep: anArray [
	| copy transferred |
	copy := self newSlots: 'Array' sized: anArray size.
	anArray
		withIndexDo: [ :elem :i | 
			transferred := elem isSmallInteger
				ifTrue: [ self newSmallInteger: elem ]
				ifFalse: [ self transferArrayDeep: elem ].
			copy at: i put: transferred ].
	^ copy
]

{ #category : #initialization }
SmalltalkBootstrapper >> transferAstcodesFrom: anArray [
	| copy transferred |
	copy := self newSlots: 'Array' sized: anArray size.
	anArray withIndexDo: [ :elem :i | 
			transferred := elem isSmallInteger
				ifTrue: [ self newSmallInteger: elem ]
				ifFalse: [ self transferAstcodesFrom: elem ].
			copy at: i put: transferred ].
	^ copy
]

{ #category : #initialization }
SmalltalkBootstrapper >> transferObjectDeep: anObject [
	| transferred slot |
	anObject isSmallInteger ifTrue: [ ^self newSmallInteger: anObject ].
	anObject isBytes ifTrue: [ ^self newBytesFrom: anObject ].
	transferred := self newSlots: anObject class name sized: anObject size.
	anObject withIndexDo: [ :elem :i | 
			slot := self transferObjectDeep: elem.
			transferred at: i put: slot ].
	^ transferred
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> trueObject [
	^ trueObj
]

{ #category : #validating }
SmalltalkBootstrapper >> validate [
	objects do:[:obj | obj validate]
]

{ #category : #validating }
SmalltalkBootstrapper >> writer [
	^ImageSegmentWriter new objects: objects; module: self createModule
]
