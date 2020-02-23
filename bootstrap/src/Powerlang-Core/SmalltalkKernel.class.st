Class {
	#name : #SmalltalkKernel,
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
SmalltalkKernel class >> spec [
	Spec ifNil:[
		| repo |
		repo := TonelRepository new directory: '../pst' asFileReference.
		Spec := repo asRingEnvironmentWith: #(kernel).
		Spec clean.
	].
	^ Spec
	
]

{ #category : #initialization }
SmalltalkKernel >> => aSymbol [
	^environment at: aSymbol
]

{ #category : #initialization }
SmalltalkKernel >> basicNewBytes: classname contents: aByteObject [
	| obj |
	obj := ByteObjectMap new: self => classname valued: aByteObject.
	^objects add: obj
]

{ #category : #initialization }
SmalltalkKernel >> basicNewSlots: classname [
	^self basicNewSlots: classname sized: 0

]

{ #category : #initialization }
SmalltalkKernel >> basicNewSlots: classname sized: size [
	| spec instance |
	spec := environment at: classname.
	instance := SlotObjectMap new: spec size: size withAll: nilObj.
	^ objects add: instance
]

{ #category : #building }
SmalltalkKernel >> build [
	self
		createNil;
		createTrue;
		createFalse;
		createClasses;
		initializeBehaviors
]

{ #category : #initialization }
SmalltalkKernel >> buildTestMethod [
	| method astcodes |
	method := self newSlots: 'CompiledMethod'.
	astcodes := self transferArrayDeep: self testMethodAstcodes.
	method
		nativeCode: nilObj;
		astcodes: astcodes.
	^ method
]

{ #category : #initialization }
SmalltalkKernel >> classNamed: name [
	^self objectNamed: name
]

{ #category : #'as yet unclassified' }
SmalltalkKernel >> classNamedOrNil: aSymbol [
	^ index at: aSymbol ifAbsent: nilObj
]

{ #category : #initialization }
SmalltalkKernel >> classes [
	^classes
]

{ #category : #initialization }
SmalltalkKernel >> createClass: definition [
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
SmalltalkKernel >> createClasses [
	environment allClasses
		do: [ :def | self createClass: def; createMetaclass: def ];
		do: [ :def | self initializeClass: def; initializeMetaclass: def]
]

{ #category : #initialization }
SmalltalkKernel >> createFalse [
	falseObj := self basicNewSlots: #False
]

{ #category : #initialization }
SmalltalkKernel >> createMetaclass: spec [
	|  meta ibehavior class |
	meta := self basicNewSlots: #Metaclass.
	ibehavior := self basicNewSlots: #Behavior.
	ibehavior class: meta.
	class := classes at: spec.
	class behavior: ibehavior.
	meta instanceBehavior: ibehavior; class: class.

]

{ #category : #initialization }
SmalltalkKernel >> createNil [
	nilObj := self basicNewSlots: #UndefinedObject.
]

{ #category : #initialization }
SmalltalkKernel >> createTrue [
	trueObj := self basicNewSlots: #True
]

{ #category : #'as yet unclassified' }
SmalltalkKernel >> define: anObject as: aSymbol [
	^ index at: aSymbol put: anObject
]

{ #category : #'as yet unclassified' }
SmalltalkKernel >> falseObject [
	^ falseObj
]

{ #category : #initialization }
SmalltalkKernel >> formatOfClass: definition [
	| variable pointers |
	variable := definition isVariable ifTrue: [ 16r2000 ] ifFalse: [ 0 ].
	pointers := definition isBytes ifTrue: [ 0 ] ifFalse: [16r4000 ].
	^variable | pointers | definition allInstVarNames size
]

{ #category : #initialization }
SmalltalkKernel >> initialize [
	index := Dictionary new.
	classes := OrderedDictionary new.
	objects := OrderedCollection new.
	symbols := OrderedDictionary new
]

{ #category : #initialization }
SmalltalkKernel >> initializeBehavior: anObjectMap [
	| class |
	class := classes at: anObjectMap spec.
	anObjectMap behavior: class instanceBehavior.

]

{ #category : #initialization }
SmalltalkKernel >> initializeBehaviors [
	objects do: [:o | o behavior ifNil: [ self initializeBehavior: o ]]
]

{ #category : #initialization }
SmalltalkKernel >> initializeClass: definition [
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
SmalltalkKernel >> initializeMetaclass: definition [
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
SmalltalkKernel >> instanceBehaviorOf: classname [
	| class |
	class := self classNamed: classname.
	^class instanceBehavior

]

{ #category : #'as yet unclassified' }
SmalltalkKernel >> nameOf: anObject [
	^ index keyAtValue: anObject ifAbsent: nil
]

{ #category : #initialization }
SmalltalkKernel >> new: classDef sized: size [
	"
	Allocate an object of pointer type (as SlotObjectMap).
	It is niled-out, and 	`size` is the size of indexed part (i.e.,
	shall not include named slots)
	"

	| obj |
	obj := self newSlots: classDef sized: size.
	1 to: obj basicSize do: [ :i | obj basicAt: i put: nilObj ].
	^ obj
]

{ #category : #initialization }
SmalltalkKernel >> newArray: anArray [
	| instance |
	instance := self newSlots: 'Array' sized: anArray size.
	anArray withIndexDo: [ :obj :i | instance at: i put: nilObj ].
	^ instance
]

{ #category : #initialization }
SmalltalkKernel >> newBehavior [
	^ self newSlots: 'Behavior'
]

{ #category : #initialization }
SmalltalkKernel >> newBytes: classname contents: aByteObject [
	| obj |
	obj := self basicNewBytes: classname contents: aByteObject. 
	self initializeBehavior: obj.
	^obj
]

{ #category : #initialization }
SmalltalkKernel >> newBytesFrom: aByteObject [
	^self newBytes: aByteObject class name contents: aByteObject
]

{ #category : #initialization }
SmalltalkKernel >> newClosure: aPCompiledBlock [
	^ self newSlots: 'Closure'
]

{ #category : #initialization }
SmalltalkKernel >> newMethod: anAstcode selector: aSymbol in: classname format: anInteger literals: anArray [
	| method astcodes class selector format |
	method := self newSlots: 'CompiledMethod'.
	astcodes := self transferAstcodesFrom: anAstcode.
	class := self classNamed: classname.
	selector := self newSymbol: aSymbol.
	format := self newSmallInteger: anInteger.
	method
		nativeCode: self nilObject;
		semantics: astcodes;
		class: class;
		selector: selector;
		format: format;
		source: self nilObject.
	^ method
]

{ #category : #'as yet unclassified' }
SmalltalkKernel >> newNamed: aSymbol [
	| obj |
	obj := self newSlots: aSymbol.
	^ index at: aSymbol put: obj
]

{ #category : #initialization }
SmalltalkKernel >> newSlots: classname [
	^self newSlots: classname sized: 0
]

{ #category : #initialization }
SmalltalkKernel >> newSlots: classname sized: size [
	| obj |
	obj := self basicNewSlots: classname sized: size.
	self initializeBehavior: obj.
	^obj
]

{ #category : #initialization }
SmalltalkKernel >> newSmallInteger: anInteger [
	^SmallintObjectMap new: self => #SmallInteger valued: anInteger
]

{ #category : #initialization }
SmalltalkKernel >> newString: aString [
	| bytes |
	bytes := aString copyWith: Character null.
	^self newBytes: 'String' contents: bytes
]

{ #category : #initialization }
SmalltalkKernel >> newStringArray: strings [
	| array bytes |
	array := self newSlots: 'Array' sized: strings size.
	strings
		withIndexDo: [ :s :i |
			bytes := self newString: s.
			array at: i put: bytes ].
	^ array
]

{ #category : #initialization }
SmalltalkKernel >> newSymbol: aSymbol [
	| new bytes |
	symbols at: aSymbol ifPresent: [:s | ^s ].
	bytes := aSymbol copyWith: Character null.
	new := self newBytes: 'Symbol' contents: bytes.
	^symbols at: aSymbol put: new
]

{ #category : #'as yet unclassified' }
SmalltalkKernel >> nilObject [
	^nilObj 
]

{ #category : #'as yet unclassified' }
SmalltalkKernel >> objectNamed: aSymbol [
	^ index at: aSymbol
]

{ #category : #accessing }
SmalltalkKernel >> objects [
	^ objects
]

{ #category : #initialization }
SmalltalkKernel >> spec: anRGEnvironment [
	environment := anRGEnvironment
]

{ #category : #initialization }
SmalltalkKernel >> specNamed: aSymbol [
	^environment at: aSymbol
]

{ #category : #initialization }
SmalltalkKernel >> testMethodAstcodes [
	"m instVar1 := true
	#(MethodId #(AssignmentId #(IdentifierId InstVarId 1) #(IdentifierId TrueId)))"
	^#(1 #(8 #(3 8 1) #(3 2)))
]

{ #category : #initialization }
SmalltalkKernel >> transferArrayDeep: anArray [
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
SmalltalkKernel >> transferAstcodesFrom: anArray [
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
SmalltalkKernel >> transferObjectDeep: anObject [
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
SmalltalkKernel >> trueObject [
	^ trueObj
]
