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
	#category : #'Powerlang-SCompiler-Backend'
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
	self
		nextPut: ArgumentId;
		nextIntegerPut: anInteger;
		nextIntegerPut: encoded
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
AstcodeEncoder >> encodeDynamicVar: name [
	stream nextPut: DynamicVarId.
	self nextSymbolPut: name
]

{ #category : #visiting }
AstcodeEncoder >> encodeFalse [
	stream nextPut: FalseId
]

{ #category : #visiting }
AstcodeEncoder >> encodeLoadRvisitingReceiver [
	stream nextPut: LoadRvisitingReceiverId
]

{ #category : #visiting }
AstcodeEncoder >> encodeNestedDynamicVar: name [
	stream nextPut: NestedDynamicVarId.
	self nextLiteralPut: name 
]

{ #category : #visiting }
AstcodeEncoder >> encodeNil [
	stream nextPut: NilId
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
	self
		nextPut: TemporaryId;
		nextIntegerPut: anInteger;
		nextIntegerPut: encoded
]

{ #category : #visiting }
AstcodeEncoder >> encodeTrue [
	stream nextPut: TrueId
]

{ #category : #visiting }
AstcodeEncoder >> encodedEnvironment: aLocalEnvironment [
	aLocalEnvironment isStack
		ifTrue: [ ^ aLocalEnvironment isInlinedArgument
				ifTrue: [ -1 ]
				ifFalse: [ -2 ] ].
	aLocalEnvironment isCurrent
		ifTrue: [ ^ 0 ].
	^ aLocalEnvironment index
]

{ #category : #accessing }
AstcodeEncoder >> initialize [
	stream := #[] writeStream
]

{ #category : #accessing }
AstcodeEncoder >> method: aCompiledMethod [
	method := aCompiledMethod
]

{ #category : #visiting }
AstcodeEncoder >> nextBigIntegerPut: anInteger [
	stream
		nextPut: 16r80;
		int64: anInteger
]

{ #category : #visiting }
AstcodeEncoder >> nextBooleanPut: aBoolean [
	stream nextPut: aBoolean asBit

]

{ #category : #visiting }
AstcodeEncoder >> nextIntegerPut: anInteger [
	| value |
	(anInteger > 127 or: [ anInteger < -127 ])
		ifTrue: [ ^ self nextBigIntegerPut: anInteger ].
	value := anInteger >= 0
		ifTrue: [ anInteger ]
		ifFalse: [ anInteger + 16r100 ].
	stream nextPut: value
]

{ #category : #visiting }
AstcodeEncoder >> nextLiteralPut: anObject [
	| index |
	index := method
		indexOf: anObject
		ifAbsent: [ self ASSERT: false ].
	self nextIntegerPut: index
]

{ #category : #visiting }
AstcodeEncoder >> nextPut: anInteger [
	stream nextPut: anInteger
]

{ #category : #visiting }
AstcodeEncoder >> nextPutAll: aCollection [
	stream nextPut: aCollection size; nextPutAll: aCollection
]

{ #category : #visiting }
AstcodeEncoder >> nextSymbolPut: aSymbol [
	| index |
	index := method
		indexOf: aSymbol asSymbol
		ifAbsent: [ self ASSERT: false ].
	self nextIntegerPut: index
]

{ #category : #visiting }
AstcodeEncoder >> nextTypePut: anInteger [
	stream nextPut: anInteger
]

{ #category : #visiting }
AstcodeEncoder >> visitAssignment: anAssignmentNode [
	| assignees |
	self nextTypePut: AssignmentId.
	assignees := anAssignmentNode assignees.
	self nextIntegerPut: assignees size.
	assignees do: [ :node | node acceptVisitor: self ].
	anAssignmentNode expression acceptVisitor: self
]

{ #category : #visiting }
AstcodeEncoder >> visitBlock: aBlockNode [
	| args inlined |
	self nextTypePut: BlockId.
	inlined := aBlockNode isInlined.
	self nextBooleanPut: inlined.
	inlined
		ifTrue: [ args := aBlockNode arguments collect: [ :id | id binding index ].
			self nextPutAll: args asArray ]
		ifFalse: [ | index captured |
			index := self compiledBlockIndexOf: aBlockNode.
			self nextPut: index.
			captured := self encodeClosureElements: aBlockNode.
			self nextPutAll: captured ].
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
	| messages |
	self nextTypePut: CascadeId.
	aCascadeNode receiver acceptVisitor: self.
	messages := aCascadeNode messages.
	self nextIntegerPut: messages size.
	messages do: [ :node | self visitCascadeMessage: node ]
]

{ #category : #visiting }
AstcodeEncoder >> visitCascadeMessage: aCascadeMessageNode [
	| arguments |
	self nextSymbolPut: aCascadeMessageNode selector symbol.
	arguments := aCascadeMessageNode arguments.
	self nextIntegerPut: arguments size.
	arguments do: [ :arg | arg acceptVisitor: self ]
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
	self
		nextTypePut: LiteralId;
		nextIntegerPut: index.
	index = 0
		ifTrue: [ self nextIntegerPut: aLiteralNode value ]
]

{ #category : #visiting }
AstcodeEncoder >> visitMessage: aMessageNode [
	| arguments |
	self
		nextTypePut: MessageId;
		nextBooleanPut: aMessageNode isInlined;
		nextSymbolPut: aMessageNode selector symbol.
	aMessageNode receiver acceptVisitor: self.
	arguments := aMessageNode arguments.
	self nextIntegerPut: arguments size.
	arguments do: [ :arg | arg acceptVisitor: self ]
]

{ #category : #visiting }
AstcodeEncoder >> visitMethod: aMethodNode [
	| pragma |
	self nextTypePut: MethodId.
	pragma := aMethodNode pragma.
	pragma isUsed
		ifTrue: [ self nextTypePut: PragmaId.
			pragma name
				ifNotNil: [ self nextSymbolPut: pragma name ]
				ifNil: [ self nextPut: 0 ] ].
	self visitScript: aMethodNode.
	^ stream contents 
]

{ #category : #visiting }
AstcodeEncoder >> visitParseNode: aParseNode [
	^self ASSERT: false
]

{ #category : #visiting }
AstcodeEncoder >> visitReturn: aReturnNode [
	self
		nextTypePut: ReturnId;
		nextBooleanPut: script realScript isMethod.
	
		aReturnNode expression acceptVisitor: self
]

{ #category : #visiting }
AstcodeEncoder >> visitScript: aScriptNode [
	| prev statements |
	prev := script.
	script := aScriptNode.
	statements := aScriptNode statements.
	self nextIntegerPut: statements size.
	statements do: [ :node | node acceptVisitor: self ].
	script := prev
]
