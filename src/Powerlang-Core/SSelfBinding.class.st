Class {
	#name : #SSelfBinding,
	#superclass : #SBinding,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SSelfBinding class >> decodeUsing: anAstcodeDecoder [
	^self new
]

{ #category : #testing }
SSelfBinding >> isSelf [
	^true
]

{ #category : #printing }
SSelfBinding >> printOn: aStream [
	aStream nextPutAll: 'SelfId'
]

{ #category : #testing }
SSelfBinding >> valueWithin: anEvaluationContext [
	^ anEvaluationContext receiver
]
