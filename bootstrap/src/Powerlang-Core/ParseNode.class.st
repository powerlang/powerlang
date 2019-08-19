Class {
	#name : #ParseNode,
	#superclass : #Token,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #visiting }
ParseNode >> acceptVisitor: visitor [
	^visitor visitParseNode: self
]

{ #category : #enumerating }
ParseNode >> allNodesDo: aBlock [
	self nodesDo: aBlock includingDeclarations: true
]

{ #category : #accessing }
ParseNode >> ast [
	^compiler ast
]

{ #category : #testing }
ParseNode >> isAssign [
	^false
]

{ #category : #testing }
ParseNode >> isBraceNode [
	^false
]

{ #category : #testing }
ParseNode >> isCascade [
	^false
]

{ #category : #testing }
ParseNode >> isCascadeMessage [
	^false
]

{ #category : #testing }
ParseNode >> isEvaluable [
	^false
]

{ #category : #testing }
ParseNode >> isImmediate [
	^false
]

{ #category : #testing }
ParseNode >> isMessageNode [
	^false
]

{ #category : #testing }
ParseNode >> isMethod [
	^false
]

{ #category : #testing }
ParseNode >> isReturn [
	^false
]

{ #category : #testing }
ParseNode >> isSelector [
	^false
]

{ #category : #testing }
ParseNode >> isSelf [
	^false
]

{ #category : #testing }
ParseNode >> isSuper [
	^false
]

{ #category : #printing }
ParseNode >> moveCommentsFrom: aParseNode [
	aParseNode moveCommentsTo: self
]

{ #category : #enumerating }
ParseNode >> nodeWithLiteral: anObject [
	^self nodesDetect: [:n | (n isLiteral or: [n isSelector]) and: [n value = anObject]] ifAbsent: nil

]

{ #category : #enumerating }
ParseNode >> nodesDetect: aBlock ifAbsent: absentBlock [
	self nodesDo: [:node | (aBlock value: node) ifTrue: [ ^node ] ] includingDeclarations: false.
	^absentBlock value
]

{ #category : #enumerating }
ParseNode >> nodesDo: aBlock [
	self nodesDo: aBlock includingDeclarations: false
]

{ #category : #enumerating }
ParseNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	aBlock evaluateWith: self
]
