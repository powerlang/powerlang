Class {
	#name : #SBlock,
	#superclass : #SScript,
	#instVars : [
		'capturedVariables'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SBlock class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeBlock
]

{ #category : #visiting }
SBlock >> acceptVisitor: visitor [
	^visitor visitBlock: self
]

{ #category : #accessing }
SBlock >> capturedVariables [
	^capturedVariables
]

{ #category : #accessing }
SBlock >> capturedVariables: aCollection [
	capturedVariables := aCollection
]

{ #category : #initialization }
SBlock >> initialize [
	capturedVariables := #()
]

{ #category : #initialization }
SBlock >> isInlined [
	^true
]

{ #category : #unclassified }
SBlock >> printOn: aStream indent: anInteger [
	aStream nextPutAll: '{BlockId.'; cr.
	super printOn: aStream indent: anInteger.
	aStream nextPutAll: '}'
]
