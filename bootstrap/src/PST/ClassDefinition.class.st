Class {
	#name : #ClassDefinition,
	#superclass : #Object,
	#instVars : [
		'name',
		'superclass',
		'instVars',
		'classVars',
		'classInstVars',
		'sharedPools',
		'methods',
		'classMethods'
	],
	#category : #'PST-Specification'
}

{ #category : #accessing }
ClassDefinition >> allClassVars [
	| all class |
	all := OrderedCollection new.
	class := self.
	[ class notNil ]
		whileTrue: [ all addAllFirst: class classVars.
			class := class superclass ].
	^ all
]

{ #category : #accessing }
ClassDefinition >> allInstVars [
	| all class |
	all := OrderedCollection new.
	class := self.
	[ class notNil ]
		whileTrue: [ all addAllFirst: class instVars.
			class := class superclass].
	^ all
]

{ #category : #accessing }
ClassDefinition >> classInstVars [
	^ classInstVars
]

{ #category : #accessing }
ClassDefinition >> classInstVars: anObject [
	classInstVars := anObject
]

{ #category : #accessing }
ClassDefinition >> classMethods [
	^ classMethods
]

{ #category : #accessing }
ClassDefinition >> classMethods: anObject [
	classMethods := anObject
]

{ #category : #accessing }
ClassDefinition >> classVars [
	^ classVars
]

{ #category : #accessing }
ClassDefinition >> classVars: anObject [
	classVars := anObject
]

{ #category : #accessing }
ClassDefinition >> initialize [
	instVars := #().
	classVars := #().
	classInstVars := #().
	sharedPools := #().
	methods := OrderedCollection new.
	classMethods := OrderedCollection new
]

{ #category : #accessing }
ClassDefinition >> instVars [
	^ instVars
]

{ #category : #accessing }
ClassDefinition >> instVars: anObject [
	instVars := anObject
]

{ #category : #accessing }
ClassDefinition >> loadFrom: definitions within: aProjectSpec [
	| declaration superdef |
	declaration := definitions first.
	superdef := aProjectSpec classNamed: declaration superclassName.
	self
		instVars: declaration instVarNames;
		classInstVars: declaration classInstVarNames;
		classVars: declaration classVarNames;
		superclass: superdef.
	definitions asOrderedCollection
		removeFirst;
		do: [ :m | methods add: m ]
]

{ #category : #accessing }
ClassDefinition >> methods [
	^ methods
]

{ #category : #accessing }
ClassDefinition >> methods: anObject [
	methods := anObject
]

{ #category : #accessing }
ClassDefinition >> name [
	^ name
]

{ #category : #accessing }
ClassDefinition >> name: anObject [
	name := anObject
]

{ #category : #printing }
ClassDefinition >> printOn: aStream [
	aStream nextPut: ${; nextPutAll: name; nextPut: $}
]

{ #category : #accessing }
ClassDefinition >> protocols [
	^ (self methods collect: [ :m | m protocol ]) asSet
]

{ #category : #accessing }
ClassDefinition >> sharedPools [
	^ sharedPools
]

{ #category : #accessing }
ClassDefinition >> sharedPools: anObject [
	sharedPools := anObject
]

{ #category : #accessing }
ClassDefinition >> superclass [
	^ superclass
]

{ #category : #accessing }
ClassDefinition >> superclass: supername [
	| object |
	object := supername = 'nil' ifTrue: [ nil ] ifFalse: [ supername ].
	superclass := object
]

{ #category : #accessing }
ClassDefinition >> superclassName [
	^ superclass ifNotNil: [ superclass name ]
]
