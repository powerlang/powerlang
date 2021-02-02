Class {
	#name : #AstcodeEncoder,
	#superclass : #SParseTreeVisitor,
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

{ #category : #'instance creation' }
AstcodeEncoder class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

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
		scope capturesSelf ifTrue: [ s nextPut: Self ].
		scope capturedEnvironments do: [:e | | index |
			e == parent ifTrue: [s nextPut: Environment] ifFalse: [
				index := aBlockNode environmentIndexOf: e.
				self ASSERT: index notNil.
				s nextPut: EnvironmentValue; nextPut: index]].
		scope capturedArguments do: [:a | | binding |
			binding := aBlockNode parent scope resolve: a name.
			s 	nextPut: binding environmentType; nextPut: binding index]]
	
]

{ #category : #visiting }
AstcodeEncoder >> encodeFalse [
	stream nextPut: FalseId
]

{ #category : #visiting }
AstcodeEncoder >> encodeGlobalVar: association [
	| index |
	index := method indexOf: association ifAbsent: [ self ASSERT: false ].
	stream
		nextPut: GlobalValueId;
		nextPut: index
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
AstcodeEncoder >> encodeLoadAwithArg: anInteger env: environment [
	| encoded |
	encoded := self encodedEnvironment: environment.
	stream
		nextPut: LoadAwithArgumentId;
		nextPut: anInteger;
		nextPut: encoded
]

{ #category : #visiting }
AstcodeEncoder >> encodeLoadAwithClassVar: association [
	| index |
	index := method indexOf: association ifAbsent: [ self ASSERT: false ].
	stream
		nextPut: LoadAwithClassVarId;
		nextPut: index
]

{ #category : #visiting }
AstcodeEncoder >> encodeLoadAwithConstPoolVar: value [
	| index |
	index := method indexOf: value ifAbsent: [ self ASSERT: false ].
	stream
		nextPut: LoadAwithConstPoolId;
		nextPut: index
]

{ #category : #visiting }
AstcodeEncoder >> encodeLoadAwithGlobal: association [
	| index |
	index := method indexOf: association ifAbsent: [ self ASSERT: false ].
	stream
		nextPut: LoadAwithGlobalId;
		nextPut: index
]

{ #category : #visiting }
AstcodeEncoder >> encodeLoadAwithInstVar: anInteger [
	stream nextPut: LoadAwithInstVarId; nextPut: anInteger
]

{ #category : #visiting }
AstcodeEncoder >> encodeLoadAwithLiteral: value [
	| index |
	index := method indexOf: value.
	stream nextPut: LoadAwithLiteralId; nextPut: index.
	index = 0 ifTrue: [stream nextPut: value]
]

{ #category : #visiting }
AstcodeEncoder >> encodeLoadAwithNil [
	stream nextPut: LoadAwithNilId
]

{ #category : #visiting }
AstcodeEncoder >> encodeLoadAwithPoolVar: association [
	| index |
	index := method indexOf: association ifAbsent: [ self ASSERT: false ].
	stream
		nextPut: LoadAwithPoolVarId;
		nextPut: index
]

{ #category : #visiting }
AstcodeEncoder >> encodeLoadAwithSelf [
	stream nextPut: LoadAwithSelfId
]

{ #category : #visiting }
AstcodeEncoder >> encodeLoadAwithTemp: anInteger env: environment [
	| encoded |
	encoded := self encodedEnvironment: environment.
	stream
		nextPut: LoadAwithTemporaryId;
		nextPut: anInteger;
		nextPut: encoded
]

{ #category : #visiting }
AstcodeEncoder >> encodeLoadRvisitingReceiver [
	stream nextPut: LoadRvisitingReceiverId
]

{ #category : #visiting }
AstcodeEncoder >> encodeNil [
	stream nextPut: NilId
]

{ #category : #visiting }
AstcodeEncoder >> encodeOptimizedBinary: aMessageNode [
	| optimizer |
	optimizer := BinaryMessageOptimizer on: aMessageNode using: self.
	self nestedEncode: [optimizer emitOpcodes]
]

{ #category : #visiting }
AstcodeEncoder >> encodeOptimizedMessage: aMessageNode [
	| selector |
	selector := aMessageNode selector.
	aMessageNode isInlined ifTrue: [^self encodeInlinedMessage: aMessageNode].
	(BinaryMessageOptimizer optimizesMessage: selector value) ifFalse: [^self].
	aMessageNode arguments size = 1
		ifTrue: [^self encodeOptimizedBinary: aMessageNode]
]

{ #category : #visiting }
AstcodeEncoder >> encodePoolConst: association [
	| index |
	index := method indexOf: association ifAbsent: [ self ASSERT: false ].
	stream
		nextPut: ConstantPoolId;
		nextPut: index
]

{ #category : #visiting }
AstcodeEncoder >> encodePoolVar: association [
	| index |
	index := method indexOf: association ifAbsent: [self ASSERT: false].
	stream nextPut: PoolVarId; nextPut: index
]

{ #category : #visiting }
AstcodeEncoder >> encodePopR [
	stream nextPut: PopRid
]

{ #category : #visiting }
AstcodeEncoder >> encodePushR [
	stream nextPut: PushRid
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
	aLocalEnvironment isStack
		ifTrue: [ ^ aLocalEnvironment isInlinedArgument ifTrue: [-1] ifFalse: [nil] ].
	aLocalEnvironment isCurrent
		ifTrue: [ ^ 0 ].
	^ aLocalEnvironment index
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
	| args |
	self nextTypePut: BlockId.
	aBlockNode isInlined
		ifTrue: [ stream nextPut: 0. args := aBlockNode arguments collect: [:id | id binding index]. 
			stream nextPut: args asArray ]
		ifFalse: [ | index captured |
			index := self compiledBlockIndexOf: aBlockNode.
			self nextPut: index.
			captured := self encodeClosureElements: aBlockNode.
			stream nextPut: captured ].
	self visitScript: aBlockNode
]

{ #category : #visiting }
AstcodeEncoder >> visitBraceNode: aBraceNode [
	aBraceNode isLiteral
		ifTrue: [self visitLiteral: aBraceNode asLiteralNode]
		ifFalse: [self visitCascade: aBraceNode asMessageNode]
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
	self
		nextTypePut: MessageId;
		nextPut: selector.
	selector = 0
		ifTrue: [ self nextPut: symbol ].
	self nestedEncode: [ aMessageNode receiver acceptVisitor: self ].
	self
		nestedEncode: [ aMessageNode arguments do: [ :arg | self nestedEncode: [arg acceptVisitor: self] ] ].
	self encodeOptimizedMessage: aMessageNode
]

{ #category : #visiting }
AstcodeEncoder >> visitMethod: aMethodNode [
	| pragma |
	self nextTypePut: MethodId.
	pragma := aMethodNode pragma.
	pragma isUsed ifTrue: [ self nextTypePut: PragmaId; nextPut: pragma name ].
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
