Class {
	#name : #SmallintObjectMap,
	#superclass : #ObjectMap,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #accessing }
SmallintObjectMap >> bodySizeInBytes [
	"Return the size of object body(s) in bytes. 
	 This DOES NOT INCLUDE any passing."
	
	^ self shouldNotImplement 

]

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

{ #category : #accessing }
SmallintObjectMap >> smallHeaderFlags [
	"Return value of 'flags' field of small header"

	self shouldNotImplement 
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
