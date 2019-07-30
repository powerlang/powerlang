Class {
	#name : #SmalltalkKernel,
	#superclass : #Object,
	#instVars : [
		'project',
		'index',
		'classes',
		'objects',
		'symbols',
		'nilObj',
		'trueObj',
		'falseObj'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #building }
SmalltalkKernel >> build [
	self
		createNil;
		createTrue;
		createFalse;
		createEmptyClasses;
		buildClasses;
		buildBehaviors;
		buildNil;
		buildTrue;
		buildFalse
]

{ #category : #initialization }
SmalltalkKernel >> buildBehaviors [
	| b behavior |
	b := self instanceBehaviorOf: 'Behavior'.
	classes
		do: [ :class | 
			behavior := class at: 'instanceBehavior'.
			behavior
				behavior: b ]
]

{ #category : #initialization }
SmalltalkKernel >> buildClass: class from: definition [
	| behavior superclass name ivars classIvars pools subclasses |
	behavior := self newBehavior.
	superclass := self classNamedOrNil: definition supername.
	subclasses := definition subclasses collect: [ :def | self classNamed: def name ].
	subclasses := self newArray: subclasses.
	name := self newString: definition name.
	ivars := self newStringArray: definition instVarNames.
	classIvars := self newStringArray: definition classVarNames.
	pools := self newStringArray: definition sharedPools.
	class
		behavior: behavior;
		at: 'superclass' put: superclass;
		at: 'format' put: nilObj;
		at: 'instanceVariables' put: ivars;
		at: 'organization' put: nilObj;
		at: 'name' put: name;
		at: 'subclasses' put: subclasses;
		at: 'classVariables' put: classIvars;
		at: 'sharedPools' put: pools
]

{ #category : #initialization }
SmalltalkKernel >> buildClasses [
	project classes
		with: classes
		do: [ :spec :class | self buildClass: class from: spec ]
]

{ #category : #initialization }
SmalltalkKernel >> buildFalse [
	| behavior |
	behavior := self instanceBehaviorOf: 'False'.
	falseObj behavior: behavior
]

{ #category : #initialization }
SmalltalkKernel >> buildNil [
	| behavior |
	behavior := self instanceBehaviorOf: 'UndefinedObject'.
	nilObj behavior: behavior
]

{ #category : #initialization }
SmalltalkKernel >> buildTestMethod [
	| method behavior astcodes |
	method := self newSlots.
	behavior := self instanceBehaviorOf: 'CompiledMethod'.
	astcodes := self transferAstcodesFrom: self testMethodAstcodes.
	method
		behavior: behavior;
		at: 'nativeCode' put: self nilObject;
		at: 'astcodes' put: astcodes.
	^ method
]

{ #category : #initialization }
SmalltalkKernel >> buildTrue [
	| behavior |
	behavior := self instanceBehaviorOf: 'True'.
	trueObj behavior: behavior
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
SmalltalkKernel >> createEmptyClasses [
	| class behavior |
	project classes
		do: [ :definition | 
			class := self newNamed: definition name.
			behavior := self newSlots
				at: 'methods' put: nilObj;
				at: 'next' put: nilObj;
				at: 'class' put: class;
				yourself.
			class at: 'superclass' put: nilObj; at: 'instanceBehavior' put: behavior.
			classes add: class ]
]

{ #category : #initialization }
SmalltalkKernel >> createFalse [
	falseObj := self newSlots
]

{ #category : #initialization }
SmalltalkKernel >> createNil [
	nilObj := self newSlots
]

{ #category : #initialization }
SmalltalkKernel >> createTrue [
	trueObj := self newSlots
]

{ #category : #initialization }
SmalltalkKernel >> initialize [
	index := Dictionary new.
	classes := OrderedCollection new.
	objects := OrderedCollection new.
	symbols := OrderedDictionary new
]

{ #category : #initialization }
SmalltalkKernel >> instanceBehaviorOf: classname [
	| class |
	class := self classNamed: classname.
	^class at: 'instanceBehavior'.

]

{ #category : #initialization }
SmalltalkKernel >> newArray: anArray [
	| instance |
	instance := self newTyped: 'Array'.
	anArray do: [ :obj | instance add: obj ].
	^ instance
]

{ #category : #initialization }
SmalltalkKernel >> newBehavior [
	^ self newTyped: 'Behavior'
]

{ #category : #initialization }
SmalltalkKernel >> newBytes [

	| instance |
	instance := ByteObjectMap new.
	^ objects add: instance

]

{ #category : #initialization }
SmalltalkKernel >> newBytesTyped: classname contents: aByteObject [
	| behavior |
	behavior := self instanceBehaviorOf: classname.
	^ self newBytes
		behavior: behavior;
		contents: aByteObject
]

{ #category : #initialization }
SmalltalkKernel >> newMethod: anAstcode selector: aSymbol in: classname format: anInteger literals: anArray [
	| method astcodes class selector format |
	method := self newTyped: 'CompiledMethod'.
	astcodes := self transferAstcodesFrom: anAstcode.
	class := self classNamed: classname.
	selector := self newSymbol: aSymbol.
	format := self newSmallInteger: anInteger.
	method
		at: 'nativeCode' put: self nilObject;
		at: 'astcodes' put: astcodes;
		at: 'class' put: class;
		at: 'selector' put: selector;
		at: 'format' put: format;
		at: 'source' put: self nilObject.
	^ method
]

{ #category : #'as yet unclassified' }
SmalltalkKernel >> newNamed: aSymbol [
	^ index at: aSymbol put: self newSlots
]

{ #category : #initialization }
SmalltalkKernel >> newSlots [

	| instance |
	instance := SlotObjectMap new.
	^ objects add: instance
]

{ #category : #initialization }
SmalltalkKernel >> newSmallInteger: anInteger [
	^SmallintObjectMap new value: anInteger
]

{ #category : #initialization }
SmalltalkKernel >> newString: aString [

	^self newBytesTyped: 'String' contents: aString
]

{ #category : #initialization }
SmalltalkKernel >> newStringArray: strings [
	| array bytes |
	array := self newTyped: 'Array'.
	strings
		do: [ :s | 
			bytes := self newString: s.
			array add: bytes ].
	^array
]

{ #category : #initialization }
SmalltalkKernel >> newSymbol: aSymbol [
	| new |
	symbols at: aSymbol ifPresent: [:s | ^s ].
	new := self newBytesTyped: 'Symbol' contents: aSymbol.
	^symbols at: aSymbol put: new
]

{ #category : #initialization }
SmalltalkKernel >> newTyped: classname [
	| behavior |
	behavior := self instanceBehaviorOf: classname.
	^self newSlots behavior: behavior
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
SmalltalkKernel >> project [
	^project
]

{ #category : #initialization }
SmalltalkKernel >> project: aProjectSpec [
	project := aProjectSpec
]

{ #category : #initialization }
SmalltalkKernel >> testMethodAstcodes [
	"m instVar1 := true
	#(MethodId #(AssignmentId #(IdentifierId InstVarId 1) #(IdentifierId TrueId)))"
	^#(1 #(8 #(3 8 1) #(3 2)))
]

{ #category : #initialization }
SmalltalkKernel >> transferAstcodesFrom: anArray [
	| array behavior transferred |
	array := self newSlots.
	behavior := self instanceBehaviorOf: 'Array'.
	array behavior: behavior.
	anArray
		do: [ :elem | 
			transferred := elem isSmallInteger
				ifTrue: [ self newSmallInteger: elem ]
				ifFalse: [ self transferAstcodesFrom: elem ].
			array add: transferred ].
	^ array
]

{ #category : #initialization }
SmalltalkKernel >> transferObjectDeep: anObject [
	| transferred behavior slot |
	transferred := self newSlots.
	behavior := self instanceBehaviorOf: anObject class name.
	transferred behavior: behavior.
	anObject
		do: [ :elem | 
			slot := elem isSmallInteger
				ifTrue: [ self newSmallInteger: elem ]
				ifFalse: [ self transferObjectDeep: elem ].
			transferred add: slot ].
	^ transferred
]
