Class {
	#name : #PowertalkIterativeInterpreter,
	#superclass : #PowertalkEvaluator,
	#instVars : [
		'regR'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #accessing }
PowertalkIterativeInterpreter >> evaluate [
	^self subclassResponsibility

]

{ #category : #accessing }
PowertalkIterativeInterpreter >> hasFinished [
	^ context hasFinished
]

{ #category : #initializing }
PowertalkIterativeInterpreter >> initializeUndermessages [
	super initializeUndermessages.
	undermessages 		at: #_restart put: self underprimitiveRestart
	
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> prepareDispatch: dispatch [
	self subclassResponsibility
]

{ #category : #private }
PowertalkIterativeInterpreter >> prepareFor: anSCompiledMethod [
	self subclassResponsibility
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> prepareForBlock: sblock [
	^self subclassResponsibility	
]

{ #category : #private }
PowertalkIterativeInterpreter >> prepareForExecution: method [
	self subclassResponsibility
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> regR: anObject [ 
	regR := anObject
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> underprimitiveRestart [
	^ self subclassResponsibility 
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitBlock: anSBlock [
	regR := context captureClosure: anSBlock
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitIdentifier: anSIdentifier [
	regR := anSIdentifier binding valueWithin: context
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitLiteral: anSLiteral [
	regR := runtime literalFor: anSLiteral value
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpAssign: anSOpAssign [
	anSOpAssign assignees
		do: [ :identifier | identifier binding assign: regR within: context ]
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpDropToS: anSOpDropToS [
	context dropOperands: anSOpDropToS count
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpLoadRfromFrame: anSOpLoadRfromFrame [
	regR := context stackTemporaryAt: anSOpLoadRfromFrame index
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpLoadRfromStack: anSOpLoadRfromStack [
	regR := context operandAt: anSOpLoadRfromStack index
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpLoadRwithNil: anSOpLoadRwithNil [
	regR := nilObj
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpLoadRwithSelf: anSOpLoadRwithSelf [
	regR := context self
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpPushR: anSOpPushR [
	context pushOperand: regR
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpStoreRintoFrame: anSOpStoreRintoFrame [
	context stackTemporaryAt: anSOpStoreRintoFrame index put: regR
]
