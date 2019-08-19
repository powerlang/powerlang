Class {
	#name : #MetaclassMirror,
	#superclass : #SpeciesMirror,
	#category : #'Powerlang-Core-Mirrors'
}

{ #category : #accessing }
MetaclassMirror >> classVariables [
	^self instanceClass classVariables
]

{ #category : #constants }
MetaclassMirror >> instanceClass [
	| class |
	class := self getInstVarNamed: #class.
	^class asClassMirror
]

{ #category : #constants }
MetaclassMirror >> localEquivalent [
	^(handle runtime objectModel at: self instanceClass localName asSymbol) metaclass
]

{ #category : #constants }
MetaclassMirror >> localName [
	^self instanceClass localName , ' class'
]

{ #category : #private }
MetaclassMirror >> structureType [
	^#Metaclass
]

{ #category : #accessing }
MetaclassMirror >> subclasses [
	| instance |
	instance := self instanceClass.
	^instance reflectsNil
		ifTrue: [#()]
		ifFalse: [instance subclasses collect: [:class | class class]]
]
