Class {
	#name : #IterativeLinkedEvaluationContext,
	#superclass : #LinkedEvaluationContext,
	#instVars : [
		'operands',
		'work'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #'as yet unclassified' }
IterativeLinkedEvaluationContext >> beBlock [
	super beBlock.
	operands := nil
]

{ #category : #'as yet unclassified' }
IterativeLinkedEvaluationContext >> dropOperands: anInteger [
	anInteger timesRepeat: [ operands removeLast ]
]

{ #category : #'as yet unclassified' }
IterativeLinkedEvaluationContext >> hasFinished [
	^parent isNil
]

{ #category : #visiting }
IterativeLinkedEvaluationContext >> operandAt: anInteger [
	^operands at: operands size - anInteger 
]

{ #category : #'as yet unclassified' }
IterativeLinkedEvaluationContext >> popOperand [
	^operands removeLast
]

{ #category : #'as yet unclassified' }
IterativeLinkedEvaluationContext >> popOperands: anInteger [

	^ anInteger = 0 ifTrue: [#()] ifFalse: [operands removeLast: anInteger]
]

{ #category : #'as yet unclassified' }
IterativeLinkedEvaluationContext >> pushOperand: anObject [
	
	operands ifNil: [ operands := OrderedCollection new ].
	operands add: anObject
]

{ #category : #'as yet unclassified' }
IterativeLinkedEvaluationContext >> restart [
	operands ifNotNil: [operands reset]
]
