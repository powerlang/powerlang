Class {
	#name : #RecursiveEvaluationContext,
	#superclass : #EvaluationContext,
	#instVars : [
		'nonLocalReturn'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #'as yet unclassified' }
RecursiveEvaluationContext >> evaluateFor: interpreter [
	| sexpressions result |
	nonLocalReturn := [ :value | 
	interpreter context: self home parent.
	^ value ].
	sexpressions := system sexpressionsOf: method.
	result := interpreter visitMethod: sexpressions.
	interpreter context: self parent.
	^ result
]

{ #category : #'as yet unclassified' }
RecursiveEvaluationContext >> return: anObject [
	^self isBlock
		ifTrue: [ nonLocalReturn value: anObject ]
		ifFalse: [ anObject ]
]
