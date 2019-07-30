Class {
	#name : #AstcodeEncoder,
	#superclass : #ParseTreeVisitor,
	#instVars : [
		'method',
		'stream',
		'script'
	],
	#pools : [
		'AstBindingTypes',
		'AstNodeTypes',
		'ClosureElementTypes'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #visiting }
AstcodeEncoder >> compiledBlockIndexOf: aBlockNode [
	| index |
	index := method
		findFirst: [:literal | literal isBlock
			and: [literal id == aBlockNode index]].
	^index
]

{ #category : #visiting }
AstcodeEncoder >> encodeArgument: anInteger env: environment [
	| encoded |
	encoded := self encodedEnvironment: environment.
	stream
		nextPut: ArgumentId;
		nextPut: anInteger;
		nextPut: encoded
]

{ #category : #visiting }
AstcodeEncoder >> encodeClassBinding: association [
	| index |
	index := method indexOf: association ifAbsent: [self halt].
	stream nextPut: GlobalClassId; nextPut: index
]

{ #category : #visiting }
AstcodeEncoder >> encodeClosureElements: aBlockNode [
	| scope parent |
	scope := aBlockNode scope.
	parent := aBlockNode realParent.
	^Array streamContents: [:s |
		scope capturedEnvironments do: [:e | | index |
			e == parent ifTrue: [s nextPut: Environment] ifFalse: [
				index := e environmentIndexOf: aBlockNode.
				s nextPut: EnvironmentValue; nextPut: index]].
		scope capturedArguments do: [:a | | binding |
			binding := aBlockNode parent scope resolve: a name.
			s nextPut: binding environmentType; nextPut: binding position]]
]

{ #category : #visiting }
AstcodeEncoder >> encodeFalse [
	stream nextPut: FalseId
]

{ #category : #visiting }
AstcodeEncoder >> encodeInlinedMessage: aMessageNode [
	self nextTypePut: 0
]

{ #category : #visiting }
AstcodeEncoder >> encodeInstVar: index [
	stream nextPut: InstVarId; nextPut: index
]

{ #category : #visiting }
AstcodeEncoder >> encodeNil [
	stream nextPut: NilId
]

{ #category : #visiting }
AstcodeEncoder >> encodeSelf [
	stream nextPut: SelfId
]

{ #category : #visiting }
AstcodeEncoder >> encodeSuper [
	stream nextPut: SuperId
]

{ #category : #visiting }
AstcodeEncoder >> encodeTemporary: anInteger env: environment [
	| encoded |
	encoded := self encodedEnvironment: environment.
	stream
		nextPut: TemporaryId;
		nextPut: anInteger;
		nextPut: encoded
]

{ #category : #visiting }
AstcodeEncoder >> encodeTrue [
	stream nextPut: TrueId
]

{ #category : #visiting }
AstcodeEncoder >> encodedEnvironment: aLocalEnvironment [
	aLocalEnvironment isStack ifTrue: [^0].
	^aLocalEnvironment index ifNil: [1]
]

{ #category : #accessing }
AstcodeEncoder >> initialize [
	stream := #() writeStream
]

{ #category : #accessing }
AstcodeEncoder >> method: aCompiledMethod [
	method := aCompiledMethod
]

{ #category : #visiting }
AstcodeEncoder >> nestedEncode: aBlock [
	| prev nested |
	prev := stream.
	nested := Array streamContents: [:s | 
		stream := s.
		aBlock value.
		stream contents].
	stream := prev.
	stream nextPut: nested
]

{ #category : #visiting }
AstcodeEncoder >> nextPut: anInteger [
	stream nextPut: anInteger
]

{ #category : #visiting }
AstcodeEncoder >> nextTypePut: anInteger [
	stream nextPut: anInteger
]

{ #category : #visiting }
AstcodeEncoder >> visitAssignment: anAssignmentNode [ 
	self nextTypePut: AssignmentId.
	anAssignmentNode assignees
		do: [:node | self nestedEncode: [node acceptVisitor: self]].
	self nestedEncode: [anAssignmentNode expression acceptVisitor: self]
]

{ #category : #visiting }
AstcodeEncoder >> visitBlock: aBlockNode [
	self nextTypePut: BlockId.
	aBlockNode isInlined ifTrue: [stream nextPut: 0] ifFalse: [| index captured |
		index := self compiledBlockIndexOf: aBlockNode.
		self nextPut: index.
		captured := self encodeClosureElements: aBlockNode.
		stream nextPut: captured].
	self visitScript: aBlockNode
]

{ #category : #visiting }
AstcodeEncoder >> visitCascade: aCascadeNode [
	self
		nextTypePut: CascadeId;
		nestedEncode: [aCascadeNode receiver acceptVisitor: self].
	aCascadeNode messages
		do: [:node | self nestedEncode: [self visitCascadeMessage: node]]
]

{ #category : #visiting }
AstcodeEncoder >> visitCascadeMessage: aCascadeMessageNode [
	| symbol selector |
	symbol := aCascadeMessageNode selector symbol.
	selector := method indexOf: symbol.
	self nextPut: selector.
	selector = 0 ifTrue: [self nextPut: symbol].
	self
		nestedEncode: [aCascadeMessageNode arguments
			do: [:arg | arg acceptVisitor: self]]
]

{ #category : #visiting }
AstcodeEncoder >> visitIdentifier: anIdentifierNode [
	self nextTypePut: IdentifierId.
	anIdentifierNode binding encodeUsing: self
]

{ #category : #visiting }
AstcodeEncoder >> visitLiteral: aLiteralNode [
	| index |
	index := method indexOf: aLiteralNode value.
	self nextTypePut: LiteralId; nextPut: index.
	index = 0 ifTrue: [self nextPut: aLiteralNode value]
]

{ #category : #visiting }
AstcodeEncoder >> visitMessage: aMessageNode [
	| symbol selector |
	symbol := aMessageNode selector symbol.
	selector := method indexOf: symbol.
	self nextTypePut: MessageId; nextPut: selector.
	selector = 0 ifTrue: [self nextPut: symbol].
	self
		nestedEncode: [aMessageNode receiver acceptVisitor: self];
		nestedEncode: [aMessageNode arguments do: [:arg | arg acceptVisitor: self]].
	
]

{ #category : #visiting }
AstcodeEncoder >> visitMethod: aMethodNode [
	self nextTypePut: MethodId; visitScript: aMethodNode.
	^stream contents
]

{ #category : #visiting }
AstcodeEncoder >> visitParseNode: aParseNode [
	^self ASSERT: false
]

{ #category : #visiting }
AstcodeEncoder >> visitReturn: aReturnNode [
	self
		nextTypePut: ReturnId;
		nextPut: script realScript isMethod;
		nestedEncode: [aReturnNode expression acceptVisitor: self]
]

{ #category : #visiting }
AstcodeEncoder >> visitScript: aScriptNode [
	| prev |
	prev := script.
	script := aScriptNode.
	aScriptNode statements
		do: [:node | self nestedEncode: [node acceptVisitor: self]].
	script := prev
]
