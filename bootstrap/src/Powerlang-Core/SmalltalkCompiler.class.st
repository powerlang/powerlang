Class {
	#name : #SmalltalkCompiler,
	#superclass : #Object,
	#instVars : [
		'frontend',
		'source',
		'ast',
		'result'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #nodes }
SmalltalkCompiler >> commentNode [
	^CommentNode new compiler: self
]

{ #category : #nodes }
SmalltalkCompiler >> delimiterToken [
	^DelimiterToken new compiler: self
]

{ #category : #nodes }
SmalltalkCompiler >> endToken [
	^EndToken new compiler: self
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
SmalltalkCompiler >> literalNode [
	^LiteralNode new compiler: self
]

{ #category : #nodes }
SmalltalkCompiler >> numericLiteralNode [
	^NumberNode new compiler: self
]

{ #category : #private }
SmalltalkCompiler >> resetResult [
	result := CompilationResult new compiler: self
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
