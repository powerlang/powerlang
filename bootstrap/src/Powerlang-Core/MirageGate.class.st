Class {
	#name : #MirageGate,
	#superclass : #Gate,
	#instVars : [
		'class'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #accessing }
MirageGate >> classBinding [
	^class
]

{ #category : #notifications }
MirageGate >> dispatch: aMessage [
	^self dispatch: aMessage from: nil
]

{ #category : #notifications }
MirageGate >> dispatch: aMessage from: parentInterpreter [
	| method interpreter |
	method := self lookup: aMessage selector.
	interpreter := SExpressionInterpreter
		on: aMessage receiver
		with: aMessage arguments
		for: method.
	^interpreter parent: parentInterpreter; evaluate: method astcode
]

{ #category : #private }
MirageGate >> getInstVarNamed: name [
	| index |
	index := class indexOfSlot: name.
	index = 0 ifTrue: [self error: 'instance variable not found'].
	^self slotAt: index
]

{ #category : #accessing }
MirageGate >> handle: anObjectHandle [
	super handle: anObjectHandle.
	class := handle mirror reflectedClass localEquivalent
]

{ #category : #nativizing }
MirageGate >> lookup: selector [
	^class compiledMethodFor: selector
]

{ #category : #private }
MirageGate >> printOn: aStream [
	aStream nextPutAll: 'mirage gate on: ' , handle printString
]

{ #category : #services }
MirageGate >> slotAt: index [
	| slot |
	slot := handle slotAt: index.
	^self mirageOn: slot
]
