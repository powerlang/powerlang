Class {
	#name : #PowertalkEvaluatorError,
	#superclass : #Error,
	#instVars : [
		'context'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #signalling }
PowertalkEvaluatorError class >> signal: aString on: anEvaluationContext [

	^ self new 
		  context: anEvaluationContext;
		  signal: aString
]

{ #category : #accessing }
PowertalkEvaluatorError >> context [
	^context
]

{ #category : #accessing }
PowertalkEvaluatorError >> context: anEvaluationContext [

	context := anEvaluationContext
]
