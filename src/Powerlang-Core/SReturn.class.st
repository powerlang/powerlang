Class {
	#name : #SReturn,
	#superclass : #SExpression,
	#instVars : [
		'local',
		'expression'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SReturn class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeReturn
]

{ #category : #visiting }
SReturn >> acceptVisitor: visitor [
	^visitor visitReturn: self
]

{ #category : #visiting }
SReturn >> expression [
	^expression
]

{ #category : #visiting }
SReturn >> expression: anSExpression [
	expression := anSExpression
]

{ #category : #visiting }
SReturn >> isReturn [
	^true
]

{ #category : #visiting }
SReturn >> local [
	^local
]

{ #category : #visiting }
SReturn >> local: aBoolean [
	local := aBoolean
]

{ #category : #visiting }
SReturn >> printOn: aStream indent: anInteger [
	aStream tab: anInteger; nextPutAll: '{ReturnId.'; cr.
	expression printOn: aStream indent: anInteger + 1.
	aStream nextPutAll: '}'
]
