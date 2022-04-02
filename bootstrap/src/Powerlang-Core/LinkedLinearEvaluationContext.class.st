Class {
	#name : #LinkedLinearEvaluationContext,
	#superclass : #IterativeLinkedEvaluationContext,
	#instVars : [
		'pc'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #visiting }
LinkedLinearEvaluationContext >> initialize [
	super initialize.
pc := 1
]

{ #category : #accessing }
LinkedLinearEvaluationContext >> nextOperation [
	| op |
	pc <= work size ifFalse: [^nil].
	op := work at: pc.
	pc := pc + 1.
	^ op
]

{ #category : #visiting }
LinkedLinearEvaluationContext >> restart [
	super restart.
	pc := 1
]

{ #category : #visiting }
LinkedLinearEvaluationContext >> work: aCollection [
	work := aCollection
]
