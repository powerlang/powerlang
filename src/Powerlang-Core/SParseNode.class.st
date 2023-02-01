Class {
	#name : #SParseNode,
	#superclass : #SToken,
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #visiting }
SParseNode >> acceptVisitor: visitor [
	^visitor visitParseNode: self
]

{ #category : #enumerating }
SParseNode >> allNodesDo: aBlock [
	self nodesDo: aBlock includingDeclarations: true
]

{ #category : #accessing }
SParseNode >> ast [
	^compiler ast
]

{ #category : #testing }
SParseNode >> hasAssign [
	^false
]

{ #category : #testing }
SParseNode >> isAssign [
	^false
]

{ #category : #testing }
SParseNode >> isBraceNode [
	^false
]

{ #category : #testing }
SParseNode >> isCascade [
	^false
]

{ #category : #testing }
SParseNode >> isCascadeMessage [
	^false
]

{ #category : #testing }
SParseNode >> isEvaluable [
	^false
]

{ #category : #testing }
SParseNode >> isImmediate [
	^false
]

{ #category : #testing }
SParseNode >> isMessageNode [
	^false
]

{ #category : #testing }
SParseNode >> isMethod [
	^false
]

{ #category : #testing }
SParseNode >> isMethodArgument [
	^false
]

{ #category : #testing }
SParseNode >> isMethodTemporary [
	^false
]

{ #category : #testing }
SParseNode >> isReturn [
	^false
]

{ #category : #testing }
SParseNode >> isSelector [
	^false
]

{ #category : #testing }
SParseNode >> isSelf [
	^false
]

{ #category : #testing }
SParseNode >> isSuper [
	^false
]

{ #category : #printing }
SParseNode >> moveCommentsFrom: aParseNode [
	aParseNode moveCommentsTo: self
]

{ #category : #enumerating }
SParseNode >> nodeWithLiteral: anObject [
	^self nodesDetect: [:n | (n isLiteral or: [n isSelector]) and: [n value = anObject]] ifAbsent: nil

]

{ #category : #enumerating }
SParseNode >> nodesDetect: aBlock ifAbsent: absentBlock [
	self nodesDo: [:node | (aBlock value: node) ifTrue: [ ^node ] ] includingDeclarations: false.
	^absentBlock value
]

{ #category : #enumerating }
SParseNode >> nodesDo: aBlock [
	self nodesDo: aBlock includingDeclarations: false
]

{ #category : #enumerating }
SParseNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	aBlock evaluateWith: self
]

{ #category : #printing }
SParseNode >> variableNamed: aString [
	self
		allNodesDo: [:node | (node isIdentifier and: [node name = aString])
			ifTrue: [^node]].
	^nil
]
