Class {
	#name : #STemporaryBinding,
	#superclass : #SLocalBinding,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
STemporaryBinding class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeTemporary
]

{ #category : #'as yet unclassified' }
STemporaryBinding >> assign: value within: anEvaluationContext [
	anEvaluationContext temporaryAt: position in: environment put: value
]

{ #category : #testing }
STemporaryBinding >> isInCurrentEnvironment [
	^environment = 1
]

{ #category : #testing }
STemporaryBinding >> isTemporary [
	^true
]

{ #category : #'as yet unclassified' }
STemporaryBinding >> printOn: aStream [
	aStream
		nextPutAll: 'STemporary ';
		print: position;
		nextPutAll: ' @ env ';
		print: environment
]

{ #category : #'as yet unclassified' }
STemporaryBinding >> valueWithin: anEvaluationContext [
	^ anEvaluationContext temporaryAt: position in: environment
]
