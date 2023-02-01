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

{ #category : #accessing }
LinkedLinearEvaluationContext >> regPC: anInteger [
	pc := anInteger
]

{ #category : #visiting }
LinkedLinearEvaluationContext >> restart [
	super restart.
	pc := 1
]

{ #category : #accessing }
LinkedLinearEvaluationContext >> stackTemporaryAt: index [
	| size |
	size := temporaries size.
	^index > size
		ifTrue: [ operands at: index - size ]
		ifFalse: [ temporaries at: index ]
]

{ #category : #accessing }
LinkedLinearEvaluationContext >> stackTemporaryAt: index put: value [
	| size |
	size := temporaries size.
	^ index > size
		ifTrue: [ operands at: index - size put: value ]
		ifFalse: [ temporaries at: index put: value ]
]

{ #category : #visiting }
LinkedLinearEvaluationContext >> work: aCollection [
	work := aCollection
]
