Class {
	#name : #SBlock,
	#superclass : #SScript,
	#instVars : [
		'index',
		'capturedVariables',
		'inlinedArgs'
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

{ #category : #accessing }
SBlock >> capturesHome [
	^compiledCode capturesHome
]

{ #category : #accessing }
SBlock >> index [
	^index
]

{ #category : #accessing }
SBlock >> index: anInteger [
	index := anInteger
]

{ #category : #initialization }
SBlock >> initialize [
	capturedVariables := #()
]

{ #category : #accessing }
SBlock >> inlinedArgs [
	^ inlinedArgs
]

{ #category : #accessing }
SBlock >> inlinedArgs: anArray [
	inlinedArgs:= anArray 
]

{ #category : #initialization }
SBlock >> isBlock [
	^true
]

{ #category : #initialization }
SBlock >> isInlined [
	^ compiledCode isNil
]

{ #category : #accessing }
SBlock >> offsetOfCurrentEnvironment [
	^ 2
]

{ #category : #accessing }
SBlock >> optimizedCode [
	^compiledCode optimizedCode
]

{ #category : #unclassified }
SBlock >> printOn: aStream indent: anInteger [
	aStream
		tab: anInteger;
		nextPutAll: '{BlockId. capturedVariables: ';
		print: capturedVariables;
		cr.
	super printOn: aStream indent: anInteger.
	aStream nextPutAll: '}'
]
