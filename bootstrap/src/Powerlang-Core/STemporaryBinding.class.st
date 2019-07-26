Class {
	#name : #STemporaryBinding,
	#superclass : #SLocalBinding,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
STemporaryBinding class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeTemporary
]

{ #category : #testing }
STemporaryBinding >> isInCurrentEnvironment [
	^environment = 1
]

{ #category : #testing }
STemporaryBinding >> isTemporary [
	^true
]
