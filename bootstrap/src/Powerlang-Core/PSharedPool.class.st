Class {
	#name : #PSharedPool,
	#superclass : #SharedPool,
	#category : #'Powerlang-Core-Compatibility'
}

{ #category : #accessing }
PSharedPool class >> asArray [
	^self classPool asArray
]

{ #category : #accessing }
PSharedPool class >> at: aString [
	| var |
	var :=  self classPool
		associationAt: aString asSymbol
		ifAbsent: [ self error: 'no such pool var' ].
	^var value
]

{ #category : #accessing }
PSharedPool class >> at: aString ifAbsent: aBlock [
	| var |
	var := self classPool associationAt: aString asSymbol ifAbsent: [^aBlock value].
	^ var value
]

{ #category : #accessing }
PSharedPool class >> at: aString put: anObject [
	^self classPool
		at: aString 
		put: anObject
]

{ #category : #accessing }
PSharedPool class >> detect: aBlock ifNone: anotherBlock [
	^self classPool detect: aBlock  ifNone: [ ^ anotherBlock value ].
	
]

{ #category : #accessing }
PSharedPool class >> do: aBlock [
	^self classPool do: aBlock

]
