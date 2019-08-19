Class {
	#name : #SmallintObjectMap,
	#superclass : #ObjectMap,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #testing }
SmallintObjectMap >> isImmediate [
	^ true
]

{ #category : #accessing }
SmallintObjectMap >> size [ 
	^0
]

{ #category : #accessing }
SmallintObjectMap >> value [
	^value
]

{ #category : #accessing }
SmallintObjectMap >> value: aSmallInteger [
	value := aSmallInteger
]
