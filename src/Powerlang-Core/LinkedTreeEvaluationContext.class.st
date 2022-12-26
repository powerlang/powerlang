Class {
	#name : #LinkedTreeEvaluationContext,
	#superclass : #IterativeLinkedEvaluationContext,
	#category : #'Powerlang-Core-Execution'
}

{ #category : #'instance creation' }
LinkedTreeEvaluationContext class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #visiting }
LinkedTreeEvaluationContext >> beBlock [
	super beBlock.
	work := OrderedCollection new: 5.

]

{ #category : #visiting }
LinkedTreeEvaluationContext >> hasWork [
	^work notEmpty
]

{ #category : #visiting }
LinkedTreeEvaluationContext >> initialize [
	super initialize.
	work := OrderedCollection new: 5
]

{ #category : #visiting }
LinkedTreeEvaluationContext >> popOperation [
	^ work removeLast
]

{ #category : #visiting }
LinkedTreeEvaluationContext >> pushOperation: anSExpression [
	work add: anSExpression
]

{ #category : #visiting }
LinkedTreeEvaluationContext >> restart [
	super restart.
		work reset.

]
