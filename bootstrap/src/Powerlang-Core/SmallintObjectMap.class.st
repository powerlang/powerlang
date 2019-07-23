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
	self error: 'shouldn''t be asked for size'
]

{ #category : #accessing }
SmallintObjectMap >> value [
	^value
]

{ #category : #accessing }
SmallintObjectMap >> value: aSmallInteger [
	value := aSmallInteger
]
