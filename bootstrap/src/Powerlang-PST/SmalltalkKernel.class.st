Class {
	#name : #SmalltalkKernel,
	#superclass : #Object,
	#instVars : [
		'index',
		'classes',
		'nilObj',
		'trueObj',
		'falseObj',
		'objects',
		'project'
	],
	#category : #'Powerlang-PST-Building'
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
	|  b behavior |
	b := self instanceBehaviorOf: 'Behavior'.
	classes
		do: [ :class | 
			behavior := class at: 'instanceBehavior'.
			behavior behavior: b ]
]

{ #category : #initialization }
SmalltalkKernel >> buildClass: class from: definition [
	| behavior superclass name ivars classIvars cvars pools |
	behavior := self newBehavior.
	superclass := self classNamedOrNil: definition superclassName.
	name := self newString: definition name.
	ivars := self newStringArray: definition instVars.
	classIvars := self newStringArray: definition classInstVars.
	cvars := self newStringArray: definition classVars.
	pools := self newStringArray: definition sharedPools.
	class
		behavior: behavior;
		at: 'superclass' put: superclass;
		at: 'name' put: name;
		at: 'instVars' put: ivars;
		at: 'classInstVars' put: classIvars;
		at: 'cvars' put: cvars;
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
SmalltalkKernel >> createEmptyClasses [
	| class behavior |
	project classes
		do: [ :definition | 
			class := self newNamed: definition name.
			behavior := self newSlots
				at: 'class' put: class;
				yourself.
			class at: 'instanceBehavior' put: behavior.
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
	objects := OrderedCollection new
]

{ #category : #initialization }
SmalltalkKernel >> instanceBehaviorOf: classname [
	| class |
	class := self classNamed: classname.
	^class at: 'instanceBehavior'.

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
				ifTrue: [ SmallintObjectMap new value:elem ]
				ifFalse: [ self transferAstcodesFrom: elem ].
			array add: transferred ].
	^ array
]
