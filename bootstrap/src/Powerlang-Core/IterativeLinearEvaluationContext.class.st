Class {
	#name : #IterativeLinearEvaluationContext,
	#superclass : #IterativeEvaluationContext,
	#instVars : [
		'pc'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #visiting }
IterativeLinearEvaluationContext >> initialize [
	super initialize.
pc := 1
]

{ #category : #accessing }
IterativeLinearEvaluationContext >> nextOperation [
	| op |
	pc <= work size ifFalse: [^nil].
	op := work at: pc.
	pc := pc + 1.
	^ op
]

{ #category : #visiting }
IterativeLinearEvaluationContext >> restart [
	super restart.
	pc := 1
]

{ #category : #visiting }
IterativeLinearEvaluationContext >> work: aCollection [
	work := aCollection
]
