Class {
	#name : #SClosure,
	#superclass : #Array,
	#type : #variable,
	#instVars : [
		'block',
		'home'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #accessing }
SClosure >> block [
	^block
]

{ #category : #accessing }
SClosure >> block: aPCompiledMethod [
	block := aPCompiledMethod
]

{ #category : #accessing }
SClosure >> evaluateWith: anObject [
	^self value: anObject
	
]

{ #category : #accessing }
SClosure >> evaluateWith: anObject with: anotherObject [
	block argumentCount = 2
		ifFalse: [^super evaluateWith: anObject with: anotherObject].
	^self value: anObject value: anotherObject
	
]

{ #category : #accessing }
SClosure >> home: anObject [
	home := anObject
]

{ #category : #accessing }
SClosure >> isSelfEvaluating [
	^false
]

{ #category : #accessing }
SClosure >> value [
	^home evaluateBlock: self
]

{ #category : #accessing }
SClosure >> value: anObject [
	^home evaluateBlock: self with: anObject
]

{ #category : #accessing }
SClosure >> value: anObject1 value: anObject2 [ 
	^ home evaluateBlock: self with: anObject1 with: anObject2
]

{ #category : #accessing }
SClosure >> value: anObject1 value: anObject2 with: anObject3 [
	^ home evaluateBlock: self with: anObject1 with: anObject2 with: anObject3
]

{ #category : #accessing }
SClosure >> whileFalse: aBlockSubject [
	| result |
	[ result := home evaluateBlock: self.
	result _gate handle asLocalBoolean ] 
		whileFalse: [ home evaluateBlock: aBlockSubject _gate handle oid ]
]

{ #category : #accessing }
SClosure >> whileTrue: aBlockSubject [
	| result |
	[ result := home evaluateBlock: self.
	result _gate handle asLocalBoolean ]
		whileTrue: [ home evaluateBlock: aBlockSubject _gate handle oid ]
]
