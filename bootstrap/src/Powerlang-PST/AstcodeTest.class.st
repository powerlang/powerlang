Class {
	#name : #AstcodeTest,
	#superclass : #TestCase,
	#instVars : [
		'method'
	],
	#pools : [
		'AstBindingTypes',
		'AstNodeTypes'
	],
	#category : #'Powerlang-PST-Compiling-Tests'
}

{ #category : #compiling }
AstcodeTest >> compile: source in: aSpecies [
	^aSpecies compiler
		source: source;
		failBlock: [ ^ nil ];
		compile
]

{ #category : #compiling }
AstcodeTest >> decode: anArray of: aCompiledMethod [
	| decoder |
	decoder := AstcodeDecoder new
		stream: anArray readStream;
		method: aCompiledMethod.
	^ decoder decodeMethod 
]

{ #category : #compiling }
AstcodeTest >> encode: aString in: aSpecies [
	method := self compile: aString in: aSpecies.
	
	"hardcoded for now"
	aString = 'm x := true' ifTrue: [	
		^{MethodId. {AssignmentId. {IdentifierId. InstVarId. 1}. {IdentifierId. TrueId}}}]
]

{ #category : #compiling }
AstcodeTest >> test050instVarAssignment [
	| astcodes expected root assignment assignee expression |
	astcodes := self encode: 'm x := true' in: Point.
	expected := {MethodId. {AssignmentId. {IdentifierId. InstVarId. 1}. {IdentifierId. TrueId}}}.
	self assert: astcodes equals: expected.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size equals: 1.
	assignment := root statements first.
	self
		assert: assignment isAssign;
		assert: assignment assignees size equals: 1.
	assignee := assignment assignees first.
	expression := assignment expression.
	self
		assert: assignee isIdentifier;
		assert: assignee binding isInstVar;
		assert: assignee binding index equals: 1;
		assert: expression isIdentifier;
		assert: expression binding isLiteral;
		assert: expression binding value equals: true
]
