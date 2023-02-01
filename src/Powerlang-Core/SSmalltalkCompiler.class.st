Class {
	#name : #SSmalltalkCompiler,
	#superclass : #Object,
	#instVars : [
		'frontend',
		'source',
		'ast',
		'result',
		'headless',
		'blocks',
		'leaf',
		'activeScript'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk'
}

{ #category : #'instance creation' }
SSmalltalkCompiler class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #accessing }
SSmalltalkCompiler >> activate: aScriptNode while: aBlock [
	| current |
	current := activeScript.
	activeScript := aScriptNode.
	aBlock value.
	activeScript := current
]

{ #category : #accessing }
SSmalltalkCompiler >> activeScope [
	^activeScript scope
]

{ #category : #accessing }
SSmalltalkCompiler >> activeScript [
	^activeScript
]

{ #category : #accessing }
SSmalltalkCompiler >> activeScript: aParseNode [
	activeScript := aParseNode
]

{ #category : #nodes }
SSmalltalkCompiler >> assignmentNode [
	^SAssignmentNode new compiler: self
]

{ #category : #accessing }
SSmalltalkCompiler >> ast [
	^ast
]

{ #category : #emitting }
SSmalltalkCompiler >> blockCount [
	^blocks
]

{ #category : #emitting }
SSmalltalkCompiler >> blockIndex [
	blocks := blocks + 1.
	^blocks - 1
]

{ #category : #nodes }
SSmalltalkCompiler >> blockNode [
	^SBlockNode new compiler: self
]

{ #category : #nodes }
SSmalltalkCompiler >> braceNode [
	^SBraceNode new compiler: self
]

{ #category : #nodes }
SSmalltalkCompiler >> buildMethod [
	result method: ast buildMethod
]

{ #category : #nodes }
SSmalltalkCompiler >> cascadeMessageNode [
	^SCascadeMessageNode new compiler: self
]

{ #category : #nodes }
SSmalltalkCompiler >> cascadeNode [
	^SCascadeNode new compiler: self
]

{ #category : #nodes }
SSmalltalkCompiler >> commentNode [
	^SCommentNode new compiler: self
]

{ #category : #errors }
SSmalltalkCompiler >> compilationError: aString stretch: aStretch [
	^SCompilationError new
		compiler: self;
		stretch: aStretch;
		description: aString
]

{ #category : #nodes }
SSmalltalkCompiler >> compileMethod: aString [
	source := aString.
	frontend protect: [
		self
			parseMethod;
			resolveSemantics;
			buildMethod].
	^result
]

{ #category : #nodes }
SSmalltalkCompiler >> delimiterToken [
	^SDelimiterToken new compiler: self
]

{ #category : #nodes }
SSmalltalkCompiler >> endToken [
	^SEndToken new compiler: self
]

{ #category : #errors }
SSmalltalkCompiler >> error: aString at: anInteger [
	| stretch |
	stretch := anInteger thru: anInteger.
	^self error: aString stretch: stretch
]

{ #category : #errors }
SSmalltalkCompiler >> error: aString stretch: aStretch [
	| error |
	error := self compilationError: aString stretch: aStretch.
	^error beFatal; signal
]

{ #category : #accessing }
SSmalltalkCompiler >> frontend [
	^frontend
]

{ #category : #accessing }
SSmalltalkCompiler >> frontend: aCompiler [
	frontend := aCompiler
]

{ #category : #nodes }
SSmalltalkCompiler >> hasBlocks [
	^ blocks > 0
]

{ #category : #nodes }
SSmalltalkCompiler >> hasSends [
^ leaf not
]

{ #category : #nodes }
SSmalltalkCompiler >> identifierNode [
	^SIdentifierNode new compiler: self
]

{ #category : #nodes }
SSmalltalkCompiler >> initialize [
	self reset

]

{ #category : #nodes }
SSmalltalkCompiler >> literalNode [
	^SLiteralNode new compiler: self
]

{ #category : #nodes }
SSmalltalkCompiler >> messageNode [
	^SMessageNode new compiler: self
]

{ #category : #nodes }
SSmalltalkCompiler >> methodNode [
	^SMethodNode new compiler: self
]

{ #category : #nodes }
SSmalltalkCompiler >> noticeSend [
	leaf := false
]

{ #category : #nodes }
SSmalltalkCompiler >> numericLiteralNode [
	^SNumberNode new compiler: self
]

{ #category : #services }
SSmalltalkCompiler >> parseFragment [
	headless := false.
	self reset.
	ast := self parser methodFragment.
	result ast: ast
]

{ #category : #services }
SSmalltalkCompiler >> parseFragment: aString [
	source := aString.
	[self parseFragment; resolveSemantics] on: SCompilationError do: [].
	^ast
]

{ #category : #services }
SSmalltalkCompiler >> parseMethod [
	headless := false.
	self reset.
	ast := self parser method.
	result ast: ast
]

{ #category : #services }
SSmalltalkCompiler >> parseMethod: aString [
	source := aString.
	frontend protect: [self parseMethod; resolveSemantics].
	^result
]

{ #category : #accessing }
SSmalltalkCompiler >> parser [
	^SSmalltalkParser new compiler: self
]

{ #category : #nodes }
SSmalltalkCompiler >> pragmaNode [
	^SPragmaNode new compiler: self
]

{ #category : #nodes }
SSmalltalkCompiler >> reset [
	self resetResult.
	leaf := true.
	blocks := 0.
]

{ #category : #private }
SSmalltalkCompiler >> resetResult [
	result := SCompilationResult new compiler: self
]

{ #category : #services }
SSmalltalkCompiler >> resolveSemantics [
	ast acceptVisitor: SSemanticVisitor new
]

{ #category : #accessing }
SSmalltalkCompiler >> result [
	^result
]

{ #category : #nodes }
SSmalltalkCompiler >> returnNode [
	^SReturnNode new compiler: self
]

{ #category : #accessing }
SSmalltalkCompiler >> scanner [
	^SSmalltalkScanner new compiler: self
]

{ #category : #nodes }
SSmalltalkCompiler >> selectorNode [
	^SSelectorNode new compiler: self
]

{ #category : #accessing }
SSmalltalkCompiler >> sourceCode [
	^source
]

{ #category : #accessing }
SSmalltalkCompiler >> sourceCode: aString [
	source := aString
]

{ #category : #nodes }
SSmalltalkCompiler >> stringToken [
	^SStringToken new compiler: self
]

{ #category : #testing }
SSmalltalkCompiler >> supportsBraceNodes [
	^true
]

{ #category : #errors }
SSmalltalkCompiler >> warning: aString at: aStretch [
	| error |
	error := self compilationError: aString stretch: aStretch.
	error beWarning; signal
]
