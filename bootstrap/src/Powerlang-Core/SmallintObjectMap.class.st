Class {
	#name : #SmallintObjectMap,
	#superclass : #ObjectMap,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #initialization }
SmallintObjectMap >> initializeWithDef: anRGBehavior size: size [
	self assert: anRGBehavior name == #SmallInteger.
	self assert: size == 0.
	
	behaviorDef := anRGBehavior.
]

{ #category : #testing }
SmallintObjectMap >> isImmediate [
	^ true
]

{ #category : #accessing }
SmallintObjectMap >> size [ 
	^ 0
]

{ #category : #validation }
SmallintObjectMap >> validate [ 
	super validate.
	self assert: value isSmallInteger 
]

{ #category : #accessing }
SmallintObjectMap >> value [
	^value
]

{ #category : #accessing }
SmallintObjectMap >> value: aSmallInteger [
	value := aSmallInteger
]
