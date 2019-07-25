Class {
	#name : #ParseNode,
	#superclass : #Token,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #enumerating }
ParseNode >> allNodesDo: aBlock [
	self nodesDo: aBlock includingDeclarations: true
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
ParseNode >> isImmediate [
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
ParseNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	aBlock evaluateWith: self
]
