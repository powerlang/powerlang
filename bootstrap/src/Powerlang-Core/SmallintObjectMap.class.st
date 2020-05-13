Class {
	#name : #SmallintObjectMap,
	#superclass : #ObjectMap,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #'instance creation' }
SmallintObjectMap class >> new: anRGBehavior valued: anInteger [
	^self new initializeAs: anRGBehavior valued: anInteger
]

{ #category : #accessing }
SmallintObjectMap >> at: index [
	self errorNotIndexable
]

{ #category : #accessing }
SmallintObjectMap >> at: index put: anObject [
	self errorNotIndexable
]

{ #category : #initialization }
SmallintObjectMap >> initializeAs: anRGBehavior sized: size [
	self shouldNotImplement
]

{ #category : #initialization }
SmallintObjectMap >> initializeAs: anRGBehavior valued: anInteger [
	self assert: anRGBehavior name == #SmallInteger.
	self assert: anInteger isSmallInteger.
	spec := anRGBehavior.
	value := anInteger.
]

{ #category : #testing }
SmallintObjectMap >> isImmediate [
	^ true
]

{ #category : #printing }
SmallintObjectMap >> printOn: aStream [
	aStream
		nextPutAll: '<<';
		nextPutAll: value printString;
		nextPutAll: '>>'
]

{ #category : #accessing }
SmallintObjectMap >> size [ 
	^ 0
]

{ #category : #accessing }
SmallintObjectMap >> slotAt: index [
	self errorNotIndexable
]

{ #category : #accessing }
SmallintObjectMap >> slotAt: index put: anObject [
	self errorNotIndexable
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
