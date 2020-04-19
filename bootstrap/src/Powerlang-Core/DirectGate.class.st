Class {
	#name : #DirectGate,
	#superclass : #Gate,
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #accessing }
DirectGate >> dispatch: aMessage from: parentInterpreter [
	| receiver method interpreter |
	receiver := aMessage receiver.
	method := handle runtime lookup: aMessage selector on: receiver.
	method ifNil: [ self ASSERT: false ].
	interpreter := PstInterpreter
		on: receiver
		with: aMessage arguments
		for: method.
	^ interpreter
		parent: parentInterpreter;
		evaluate: method
]

{ #category : #accessing }
DirectGate >> dispatchSuper: aMessage from: parentInterpreter [
	| receiver method interpreter |
	receiver := aMessage receiver.
	method := handle runtime
		lookupSuper: aMessage selector
		on: receiver
		from: parentInterpreter method classBinding superclass name.
	method ifNil: [ self ASSERT: false ].
	interpreter := PstInterpreter
		on: receiver
		with: aMessage arguments
		for: method.
	^ interpreter
		parent: parentInterpreter;
		evaluate: method
]

{ #category : #private }
DirectGate >> getInstVarNamed: name [
	| index |
	index := handle mirror reflectedClass indexOfSlot: name.
	index = 0 ifTrue: [self error: 'instance variable not found'].
	^self slotAt: index
]

{ #category : #private }
DirectGate >> slotAt: index [
	| slot |
	slot := handle slotAt: index.
	^self maneuvererOn: slot
]
