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

{ #category : #initialization }
AstcodeEncoder class >> initializeBindingTypes [
	"
	self initializeBindingTypes
	"
	AstBindingTypes := PoolDictionary newConstantPool.
	AstBindingTypes
		at: 'NilId' put: 1;
		at: 'TrueId' put: 2;
		at: 'FalseId' put: 3;
		at: 'ArgumentId' put: 4;
		at: 'TemporaryId' put: 5;
		at: 'SelfId' put: 6;
		at: 'SuperId' put: 7;
		at: 'InstVarId' put: 8;
		at: 'ClassVarId' put: 9;
		at: 'GlobalValueId' put: 10;
		at: 'GlobalClassId' put: 11;
		at: 'PoolVarId' put: 12;
		at: 'ConstantPoolId' put: 13;
		at: 'LoadRwithSelfId' put: 20;
		at: 'LoadAwithSelfId' put: 21;
		at: 'LoadRwithInstVarId' put: 22;
		at: 'LoadAwithInstVarId' put: 23;
		at: 'LoadRvisitingReceiverId' put: 24;
		at: 'LoadAvisitingArgumentId' put: 25;
		at: 'LoadRwithLiteralId' put: 26;
		at: 'LoadAwithLiteralId' put: 27;
		at: 'EnsureRisSmallIntegerId' put: 28;
		at: 'EnsureAisSmallIntegerId' put: 29;
		at: 'LoadRwithArgumentId' put: 30;
		at: 'LoadAwithArgumentId' put: 31;
		at: 'LoadRwithTemporaryId' put: 32;
		at: 'LoadAwithTemporaryId' put: 33
]

{ #category : #initialization }
AstcodeEncoder class >> initializeClosureElementTypes [
	"
	self initializeClosureElementTypes
	"
	ClosureElementTypes := PoolDictionary newConstantPool.
	ClosureElementTypes
		at: #Self put: 0;
		at: #Argument put: 1;
		at: #Environment put: 2;
		at: #EnvironmentValue put: 3
]

{ #category : #initialization }
AstcodeEncoder class >> initializeNodeTypes [
	"
	self initializeNodeTypes
	"
	AstNodeTypes := PoolDictionary newConstantPool.
	AstNodeTypes
		at: 'MethodId' put: 1;
		at: 'BlockId' put: 2;
		at: 'IdentifierId' put: 3;
		at: 'LiteralId' put: 4;
		at: 'MessageId' put: 5;
		at: 'CascadeId' put: 6;
		at: 'BraceId' put: 7;
		at: 'AssignmentId' put: 8;
		at: 'ReturnId' put: 9
]

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
	index := method indexOf: association ifAbsent: [self ASSERT: false].
	stream nextPut: GlobalClassId; nextPut: index
]

{ #category : #visiting }
AstcodeEncoder >> encodeClassVar: association [
	| index |
	index := method indexOf: association ifAbsent: [self ASSERT: false].
	stream nextPut: ClassVarId; nextPut: index
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
AstcodeEncoder >> encodePoolVar: association [
	| index |
	index := method indexOf: association ifAbsent: [self ASSERT: false].
	stream nextPut: PoolVarId; nextPut: index
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
AstcodeEncoder >> nextLiteralPut: literalValue [
	| index |
	index := method literals indexOf: literalValue.
	self assert: index != 0.
	self nextPut: index.
	
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
	aCascadeMessageNode arguments do: [:arg | 
		self nestedEncode: [arg acceptVisitor: self]]
]

{ #category : #visiting }
AstcodeEncoder >> visitIdentifier: anIdentifierNode [
	self nextTypePut: IdentifierId.
	anIdentifierNode binding encodeUsing: self
]

{ #category : #visiting }
AstcodeEncoder >> visitLiteral: aLiteralNode [
	| value |
	
	self nextTypePut: LiteralId.
	
	value := aLiteralNode value.
	value isSmallInteger ifTrue:[
			self nextPut: 0; nextPut: value.		
	] ifFalse:[
			self nextLiteralPut: value
	].
]

{ #category : #visiting }
AstcodeEncoder >> visitMessage: aMessageNode [
	| selector |
	selector := aMessageNode selector symbol.
	self nextTypePut: MessageId; nextLiteralPut: selector.
	self nestedEncode: [aMessageNode receiver acceptVisitor: self].
	aMessageNode arguments do: [:arg | 
		self nestedEncode: [arg acceptVisitor: self]].
	
]

{ #category : #visiting }
AstcodeEncoder >> visitMethod: aMethodNode [
	| pragma |
	self nextTypePut: MethodId.
	pragma := aMethodNode pragma.
	pragma isPrimitive ifTrue: [ self nextTypePut: PrimitiveId; nextLiteralPut: pragma name ].
	self visitScript: aMethodNode.
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
