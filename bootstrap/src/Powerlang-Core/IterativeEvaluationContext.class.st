Class {
	#name : #IterativeEvaluationContext,
	#superclass : #EvaluationContext,
	#instVars : [
		'operands',
		'work'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #'as yet unclassified' }
IterativeEvaluationContext >> beBlock [
	super beBlock.
	operands := nil
]

{ #category : #'as yet unclassified' }
IterativeEvaluationContext >> hasFinished [
	^parent isNil
]

{ #category : #visiting }
IterativeEvaluationContext >> operandAt: anInteger [
	^operands at: operands size - anInteger 
]

{ #category : #'as yet unclassified' }
IterativeEvaluationContext >> popOperand [
	^operands removeLast
]

{ #category : #'as yet unclassified' }
IterativeEvaluationContext >> popOperands: anInteger [

	^ anInteger = 0 ifTrue: [#()] ifFalse: [operands removeLast: anInteger]
]

{ #category : #'as yet unclassified' }
IterativeEvaluationContext >> pushOperand: anObject [
	
	operands ifNil: [ operands := OrderedCollection new ].
	operands add: anObject
]

{ #category : #'as yet unclassified' }
IterativeEvaluationContext >> restart [
	operands ifNotNil: [operands reset]
]
