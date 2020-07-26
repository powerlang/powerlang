Class {
	#name : #SBraceNode,
	#superclass : #SParseNode,
	#instVars : [
		'elements',
		'message'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #visiting }
SBraceNode >> acceptVisitor: visitor [
	^visitor visitBraceNode: self
]

{ #category : #testing }
SBraceNode >> asMessageNode [
	message notNil ifTrue: [^message].
	^message := self expanded
]

{ #category : #accessing }
SBraceNode >> elements [
	^elements
]

{ #category : #accessing }
SBraceNode >> elements: aCollection [
	elements := aCollection asArray
]

{ #category : #accessing }
SBraceNode >> expanded [
	| receiver n new argument array messages i you yourself cascade |
	receiver := compiler identifierNode name: 'Array'.
	n := elements size.
	new := compiler selectorNode symbol: #new:.
	argument := compiler numericLiteralNode value: n.
	array := compiler messageNode.
	array receiver: receiver.
	array selector: new.
	array arguments: (Array with: argument).
	i := 0.
	messages := elements collect: [:elem | | msg sel idx args |
		i := i + 1.
		msg := compiler cascadeMessageNode position: elem position; end: elem end.
		sel := compiler selectorNode symbol: #at:put:.
		idx := compiler numericLiteralNode value: i.
		args := Array with: idx with: elem.
		msg selector: sel; arguments: args].
	you := compiler selectorNode symbol: #yourself.
	yourself := compiler cascadeMessageNode.
	yourself selector: you.
	yourself arguments: #().
	messages := messages copyWith: yourself.
	cascade := compiler cascadeNode receiver: array.
	messages do: [:msg | msg cascade: cascade].
	^cascade messages: messages
]

{ #category : #testing }
SBraceNode >> isBraceNode [
	^true
]

{ #category : #enumerating }
SBraceNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	elements do: [:n | n nodesDo: aBlock includingDeclarations: aBoolean]
]
