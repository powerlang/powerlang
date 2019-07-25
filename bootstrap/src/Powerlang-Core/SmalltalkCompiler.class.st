Class {
	#name : #SmalltalkCompiler,
	#superclass : #Object,
	#instVars : [
		'frontend',
		'source',
		'ast',
		'result',
		'activeScript'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #accessing }
SmalltalkCompiler >> activate: aScriptNode while: aBlock [
	| current |
	current := activeScript.
	activeScript := aScriptNode.
	aBlock value.
	activeScript := current
]

{ #category : #accessing }
SmalltalkCompiler >> activeScript [
	^activeScript
]

{ #category : #accessing }
SmalltalkCompiler >> activeScript: aParseNode [
	activeScript := aParseNode
]

{ #category : #nodes }
SmalltalkCompiler >> assignmentNode [
	^AssignmentNode new compiler: self
]

{ #category : #nodes }
SmalltalkCompiler >> blockNode [
	^BlockNode new compiler: self
]

{ #category : #nodes }
SmalltalkCompiler >> braceNode [
	^BraceNode new compiler: self
]

{ #category : #nodes }
SmalltalkCompiler >> cascadeMessageNode [
	^CascadeMessageNode new compiler: self
]

{ #category : #nodes }
SmalltalkCompiler >> cascadeNode [
	^CascadeNode new compiler: self
]

{ #category : #nodes }
SmalltalkCompiler >> commentNode [
	^CommentNode new compiler: self
]

{ #category : #errors }
SmalltalkCompiler >> compilationError: aString stretch: aStretch [
	^CompilationError new
		compiler: self;
		stretch: aStretch;
		description: aString
]

{ #category : #nodes }
SmalltalkCompiler >> delimiterToken [
	^DelimiterToken new compiler: self
]

{ #category : #nodes }
SmalltalkCompiler >> endToken [
	^EndToken new compiler: self
]

{ #category : #errors }
SmalltalkCompiler >> error: aString at: anInteger [
	| stretch |
	stretch := anInteger thru: anInteger.
	^self error: aString stretch: stretch
]

{ #category : #errors }
SmalltalkCompiler >> error: aString stretch: aStretch [
	| error |
	error := self compilationError: aString stretch: aStretch.
	^error beFatal; signal
]

{ #category : #accessing }
SmalltalkCompiler >> frontend [
	^frontend
]

{ #category : #accessing }
SmalltalkCompiler >> frontend: aCompiler [
	frontend := aCompiler
]

{ #category : #nodes }
SmalltalkCompiler >> identifierNode [
	^IdentifierNode new compiler: self
]

{ #category : #nodes }
SmalltalkCompiler >> literalNode [
	^LiteralNode new compiler: self
]

{ #category : #nodes }
SmalltalkCompiler >> messageNode [
	^MessageNode new compiler: self
]

{ #category : #nodes }
SmalltalkCompiler >> methodNode [
	^MethodNode new compiler: self
]

{ #category : #nodes }
SmalltalkCompiler >> numericLiteralNode [
	^NumberNode new compiler: self
]

{ #category : #services }
SmalltalkCompiler >> parseFragment: aString [
	source := aString.
	[self parseFragment; resolveSemantics] on: CompilationError do: [].
	^ast
]

{ #category : #private }
SmalltalkCompiler >> resetResult [
	result := CompilationResult new compiler: self
]

{ #category : #accessing }
SmalltalkCompiler >> result [
	^result
]

{ #category : #nodes }
SmalltalkCompiler >> returnNode [
	^ReturnNode new compiler: self
]

{ #category : #nodes }
SmalltalkCompiler >> selectorNode [
	^SelectorNode new compiler: self
]

{ #category : #accessing }
SmalltalkCompiler >> sourceCode [
	^source
]

{ #category : #accessing }
SmalltalkCompiler >> sourceCode: aString [
	source := aString
]

{ #category : #nodes }
SmalltalkCompiler >> stringToken [
	^StringToken new compiler: self
]

{ #category : #testing }
SmalltalkCompiler >> supportsBraceNodes [
	^true
]
