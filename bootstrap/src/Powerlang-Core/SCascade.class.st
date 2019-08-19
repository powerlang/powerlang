Class {
	#name : #SCascade,
	#superclass : #SExpression,
	#instVars : [
		'receiver',
		'messages'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SCascade class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeCascade
]

{ #category : #visiting }
SCascade >> acceptVisitor: visitor [
	^visitor visitCascade: self
]

{ #category : #testing }
SCascade >> isCascade [
	^true
]

{ #category : #accessing }
SCascade >> messages [
	^messages
]

{ #category : #accessing }
SCascade >> messages: aCollection [
	messages := aCollection
]

{ #category : #accessing }
SCascade >> receiver [
	^receiver
]

{ #category : #accessing }
SCascade >> receiver: anSExpression [
	receiver := anSExpression
]
