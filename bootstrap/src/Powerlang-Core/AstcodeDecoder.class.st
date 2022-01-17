Class {
	#name : #AstcodeDecoder,
	#superclass : #Object,
	#instVars : [
		'method',
		'stream',
		'nodeTypes',
		'bindingTypes'
	],
	#pools : [
		'AstBindingTypes',
		'AstNodeTypes'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #'instance creation' }
AstcodeDecoder class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #public }
AstcodeDecoder >> bindingTypeOf: id [
	^bindingTypes at: id
]

{ #category : #public }
AstcodeDecoder >> decodeArgument [
	^SArgumentBinding new
		index: self nextInteger;
		environment: self nextInteger
]

{ #category : #public }
AstcodeDecoder >> decodeAssignment [
	| assignment codes |
	assignment := SAssignment new.
	codes := stream upToEnd collect: [:elem | self decodeNode: elem].
	assignment expression: codes last.
	1 to: codes size - 1 do: [:i | | identifier |
		identifier := codes at: i.
		assignment assign: identifier].
	^assignment
]

{ #category : #public }
AstcodeDecoder >> decodeBlock [
	| expression next block index |
	expression := SBlock new.
	next := stream peek.
	next != 0
		ifTrue: [ index := stream next. block := method at: index.
			expression
				compiledCode: block;
				index: index;
				capturedVariables: stream next ]
		ifFalse: [ stream next.
			expression inlinedArgs: stream next ].
	expression statements: self decodeStatements.
	^ expression
]

{ #category : #public }
AstcodeDecoder >> decodeCascade [
	| receiver messages prev |
	receiver := self decodeNode: stream next.
	prev := stream.
	messages := stream upToEnd collect: [:elem | 
		stream := elem readStream.
		SCascadeMessage decodeUsing: self].
	stream := prev.
	^SCascade new receiver: receiver; messages: messages
]

{ #category : #public }
AstcodeDecoder >> decodeCascadeMessage [
	| index selector arguments |
	index := stream next.
	selector := index = 0 ifTrue: [stream next] ifFalse: [method at: index].
	arguments := stream upToEnd collect: [:node | self decodeNode: node].
	^SCascadeMessage new selector: selector; arguments: arguments
]

{ #category : #initialization }
AstcodeDecoder >> decodeClassBinding [
	| index assoc |
		index := self nextInteger.

	assoc := method at: index.
	^ SClassBinding new index: index; association: assoc
]

{ #category : #public }
AstcodeDecoder >> decodeClassVar [
	| index assoc |
	index := self nextInteger.
	assoc := method at: index.
	^ SClassVarBinding new index: index; association: assoc
]

{ #category : #public }
AstcodeDecoder >> decodeConstantPoolVar [
	| index assoc |
	index := self nextInteger.
	assoc := method at: index.
	^ SConstantPoolBinding new
		index: index;
		association: assoc
]

{ #category : #public }
AstcodeDecoder >> decodeDynamicVar [
	| index name |
	index := self nextInteger.
	name := method at: index.
	^ SDynamicBinding new name: name
]

{ #category : #initialization }
AstcodeDecoder >> decodeGlobalBinding [
	| index assoc |
	index := self nextInteger.
	assoc := method at: index.
	^ SGlobalBinding new index: index; association: assoc
]

{ #category : #public }
AstcodeDecoder >> decodeIdentifier [
	| type binding |
	type := self bindingTypeOf: self nextInteger.
	binding := type decodeUsing: self.
	^ SIdentifier new binding: binding
]

{ #category : #public }
AstcodeDecoder >> decodeInlineNodes: anArray [
  | prev result type decoded |
  anArray ifNil: [ ^#() ].
  prev := stream.
  result := OrderedCollection new.
  stream := anArray readStream.
  [ stream atEnd ] whileFalse: [ type := self nodeTypeOf: stream next.
		decoded := type decodeUsing: self.
		result add: decoded ]. 
  stream := prev.
  ^result
]

{ #category : #initialization }
AstcodeDecoder >> decodeInstVar [
	^SInstVarBinding new index: self nextInteger
]

{ #category : #public }
AstcodeDecoder >> decodeLiteral [
	| index value |
	index := self nextInteger.
	value := index = 0
		ifTrue: [ stream next ]
		ifFalse: [ method at: index ].
	^ SLiteral new index: index; value: value
]

{ #category : #public }
AstcodeDecoder >> decodeMessage [
	| index selector receiver arguments opcodes |
	index := stream next.
	selector := index = 0
		ifTrue: [ stream next ]
		ifFalse: [ method at: index ].
	receiver := self decodeNode: stream next.
	arguments := self decodeNodes: stream next.
	stream atEnd
		ifFalse: [ opcodes := stream peek = 0
				ifTrue: [ stream next.
					#inlined ]
				ifFalse: [ self decodeInlineNodes: stream next ] ].
	^ SMessage new
		receiver: receiver;
		selector: selector;
		arguments: arguments;
		opcodes: opcodes
]

{ #category : #public }
AstcodeDecoder >> decodeMethod [
	| type node next pragma |
	type := stream next.
	type != MethodId
		ifTrue: [ self error: 'method astcode expected' ].
	node := SMethod new.
	next := stream peek.
	(next = PragmaId)
		ifTrue:
			[ stream next.
			pragma := SPragma new
				name: stream next.
			node pragma: pragma ].
		 node
			compiledCode: method;
		statements: self decodeStatements.
	^ node
]

{ #category : #public }
AstcodeDecoder >> decodeNode: anArray [
	| prev type result |
	prev := stream.
	stream := anArray readStream.
	type := self nodeTypeOf: stream next.
	result := type decodeUsing: self.
	stream := prev.
	^result
]

{ #category : #public }
AstcodeDecoder >> decodeNodes: anArray [
	anArray ifNil: [^#(  )].
	^anArray collect: [:arg | self decodeNode: arg  ].

]

{ #category : #public }
AstcodeDecoder >> decodePoolVar [
	| index assoc |
	index := self nextInteger.

	assoc := method at: index.
	^ SPoolVarBinding new index: index; association: assoc
]

{ #category : #public }
AstcodeDecoder >> decodeReturn [
	| expression local |
	local := stream next.
	expression := self decodeNode: stream next.
	^SReturn new local: local; expression: expression
]

{ #category : #public }
AstcodeDecoder >> decodeStatement: anArray [
	^self decodeNode: anArray
]

{ #category : #public }
AstcodeDecoder >> decodeStatements [
	^stream upToEnd collect: [:statement | self decodeStatement: statement]
]

{ #category : #public }
AstcodeDecoder >> decodeTemporary [
	^STemporaryBinding new
		index: self nextInteger;
		environment: self nextInteger
]

{ #category : #initialization }
AstcodeDecoder >> initialize [
	nodeTypes := Dictionary new: 40.
	bindingTypes := Dictionary new: 20.
	nodeTypes
		at: AssignmentId put: SAssignment;
		at: BlockId put: SBlock;
		at: CascadeId put: SCascade;
		at: LiteralId put: SLiteral;
		at: IdentifierId put: SIdentifier;
		at: MessageId put: SMessage;
		at: ReturnId put: SReturn;
		at: LoadRwithSelfId put: LoadRwithSelf;
		at: LoadAwithSelfId put: LoadAwithSelf;
		at: LoadRwithNilId put: LoadRwithNil;
		at: LoadAwithNilId put: LoadAwithNil;
		at: LoadRwithFalseId put: LoadRwithFalse;
		at: LoadAwithFalseId put: LoadAwithFalse;
		at: LoadRwithTrueId put: LoadRwithTrue;
		at: LoadAwithTrueId put: LoadAwithTrue;
		at: LoadRwithArgumentId put: LoadRwithArgument;
		at: LoadAwithArgumentId put: LoadAwithArgument;
		at: LoadRwithTemporaryId put: LoadRwithTemporary;
		at: LoadAwithTemporaryId put: LoadAwithTemporary;
		at: LoadRwithInstVarId put: LoadRwithInstVar;
		at: LoadAwithInstVarId put: LoadAwithInstVar;
		at: LoadAwithGlobalId put: LoadAwithGlobal;
		at: LoadAwithClassVarId put: LoadAwithClassVar;
		at: LoadAwithPoolVarId put: LoadAwithPoolVar;
		at: LoadAwithConstPoolId put: LoadAwithConstPoolVar;
		at: LoadRwithDynamicVarId put: LoadRwithDynamicVar;
		at: LoadAwithDynamicVarId put: LoadAwithDynamicVar;
		at: LoadRvisitingReceiverId put: LoadRvisitingReceiver;
		at: LoadAvisitingArgumentId put: LoadAvisitingArgument;
		"		at: LoadRwithLiteralId put: LoadRwithLiteral;"
			at: LoadAwithLiteralId put: LoadAwithLiteral;
		at: EnsureRisSmallIntegerId put: EnsureRSmallInteger;
		at: EnsureAisSmallIntegerId put: EnsureASmallInteger;
		at: PushRid put: PushRopcode;
		at: PopRid put: PopRopcode.
	bindingTypes
		at: NilId put: SNilBinding;
		at: TrueId put: STrueBinding;
		at: FalseId put: SFalseBinding;
		at: ArgumentId put: SArgumentBinding;
		at: TemporaryId put: STemporaryBinding;
		at: SelfId put: SSelfBinding;
		at: SuperId put: SSuperBinding;
		at: InstVarId put: SInstVarBinding;
		at: DynamicVarId put: SDynamicBinding;
		at: ClassVarId put: SClassVarBinding;
		at: GlobalValueId put: SGlobalBinding;
		at: GlobalClassId put: SClassBinding;
		at: PoolVarId put: SPoolVarBinding;
		at: ConstantPoolId put: SConstantPoolBinding
]

{ #category : #unclassified }
AstcodeDecoder >> literalAt: anInteger [
	^method at: anInteger
]

{ #category : #accessing }
AstcodeDecoder >> method: aCompiledMethod [
	method := aCompiledMethod
]

{ #category : #public }
AstcodeDecoder >> next [
	^stream next
]

{ #category : #initialization }
AstcodeDecoder >> nextInteger [
	^stream next
]

{ #category : #public }
AstcodeDecoder >> nodeTypeOf: id [
	^nodeTypes at: id
]

{ #category : #accessing }
AstcodeDecoder >> stream: aStream [
	stream := aStream
]
