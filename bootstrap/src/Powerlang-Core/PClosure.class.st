Class {
	#name : #PClosure,
	#superclass : #Array,
	#type : #variable,
	#instVars : [
		'block',
		'home'
	],
	#category : #'Powerlang-Core-PST'
}

{ #category : #accessing }
PClosure >> block [
	^block
]

{ #category : #accessing }
PClosure >> block: aPCompiledMethod [
	block := aPCompiledMethod
]

{ #category : #accessing }
PClosure >> evaluateWith: anObject [
	^self value: anObject
	
]

{ #category : #accessing }
PClosure >> evaluateWith: anObject with: anotherObject [
	block argumentCount = 2
		ifFalse: [^super evaluateWith: anObject with: anotherObject].
	^self value: anObject value: anotherObject
	
]

{ #category : #accessing }
PClosure >> home: anObject [
	home := anObject
]

{ #category : #accessing }
PClosure >> isSelfEvaluating [
	^false
]

{ #category : #accessing }
PClosure >> value [
	^home evaluateBlock: self
]

{ #category : #accessing }
PClosure >> value: anObject [
	^home evaluateBlock: self with: anObject
]

{ #category : #accessing }
PClosure >> value: anObject1 value: anObject2 [ 
	^ home evaluateBlock: self with: anObject1 with: anObject2
]

{ #category : #accessing }
PClosure >> value: anObject1 value: anObject2 with: anObject3 [
	^ home evaluateBlock: self with: anObject1 with: anObject2 with: anObject3
]

{ #category : #accessing }
PClosure >> whileFalse: aBlockSubject [
	| result |
	[ result := home evaluateBlock: self.
	result _gate handle asLocalBoolean ] 
		whileFalse: [ home evaluateBlock: aBlockSubject _gate handle oid ]
]

{ #category : #accessing }
PClosure >> whileTrue: aBlockSubject [
	| result |
	[ result := home evaluateBlock: self.
	result _gate handle asLocalBoolean ]
		whileTrue: [ home evaluateBlock: aBlockSubject _gate handle oid ]
]
