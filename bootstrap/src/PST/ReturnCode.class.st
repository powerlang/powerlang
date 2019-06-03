Class {
	#name : #ReturnCode,
	#superclass : #Astcode,
	#instVars : [
		'expression'
	],
	#category : #'PST-Compiling'
}

{ #category : #'as yet unclassified' }
ReturnCode class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeReturn
]

{ #category : #accessing }
ReturnCode >> expression [
	^expression
]

{ #category : #accessing }
ReturnCode >> expression: anAstcode [
	 expression := anAstcode
]

{ #category : #testing }
ReturnCode >> isReturn [
	^true
]

{ #category : #testing }
ReturnCode >> printOn: aStream [
	aStream nextPutAll: '{ReturnId. '.
	expression printOn: aStream.
	aStream nextPutAll: '}'
]
