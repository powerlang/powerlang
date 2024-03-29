Class {
	#name : #AstcodeDecoder,
	#superclass : #Object,
	#instVars : [
		'method',
		'stream',
		'builder'
	],
	#classVars : [
		'BindingTypes',
		'NodeTypes'
	],
	#pools : [
		'AstBindingTypes',
		'AstNodeTypes'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #'class initialization' }
AstcodeDecoder class >> initialize [
	NodeTypes := Dictionary new.
	BindingTypes := Dictionary new.
	NodeTypes
		at: AssignmentId put: SAssignment;
		at: BlockId put: SBlock;
		at: CascadeId put: SCascade;
		at: LiteralId put: SLiteral;
		at: IdentifierId put: SIdentifier;
		at: MessageId put: SMessage;
		at: ReturnId put: SReturn.
	BindingTypes
		at: NilId put: SNilBinding;
		at: TrueId put: STrueBinding;
		at: FalseId put: SFalseBinding;
		at: ArgumentId put: SArgumentBinding;
		at: TemporaryId put: STemporaryBinding;
		at: SelfId put: SSelfBinding;
		at: SuperId put: SSuperBinding;
		at: DynamicVarId put: SDynamicBinding;
		at: NestedDynamicVarId put: SNestedDynamicBinding
]

{ #category : #'instance creation' }
AstcodeDecoder class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #public }
AstcodeDecoder >> bindingTypeOf: id [
	^ BindingTypes at: id
]

{ #category : #accessing }
AstcodeDecoder >> builder: aRuntime [ 
	builder := aRuntime
]

{ #category : #public }
AstcodeDecoder >> decodeArgument [
	^ SArgumentBinding new
		index: self nextInteger;
		environment: self nextEnvironment
]

{ #category : #public }
AstcodeDecoder >> decodeAssignment [
	| assignment assignees |
	assignment := SAssignment new.
	
	assignees := self nextExpressionArray.
	assignment expression: self nextExpression.
	assignees do: [ :identifier | assignment assign: identifier ].
	^ assignment
]

{ #category : #public }
AstcodeDecoder >> decodeBlock [
	| expression inlined block index |
	expression := SBlock new.
	inlined := self nextBoolean.
	inlined
		ifTrue: [ expression inlinedArgs: self nextArray ]
		ifFalse: [ index := self nextInteger.
			block := self literalAt: index.
			builder ifNotNil: [ builder blockOptimizedCode: block put: expression ].
			expression
				compiledCode: block;
				index: index;
				capturedVariables: self nextArray ].
	expression statements: self nextExpressionArray.
	^ expression
]

{ #category : #public }
AstcodeDecoder >> decodeCascade [
	| cascade receiver messages message count |
	cascade := SCascade new.
	receiver := self nextExpression.
	count := self nextInteger.
	messages := (1 to: count)
		collect: [ :i | 
			message := SCascadeMessage decodeUsing: self.
			message cascade: cascade ].
	^ cascade
		receiver: receiver;
		messages: messages
]

{ #category : #public }
AstcodeDecoder >> decodeCascadeMessage [
	| selector arguments |
	selector := self nextSymbol.
	arguments := self nextExpressionArray.
	^ SCascadeMessage new
		selector: selector;
		arguments: arguments
]

{ #category : #public }
AstcodeDecoder >> decodeDynamicVar [
	^ SDynamicBinding new name: self nextSymbol
]

{ #category : #public }
AstcodeDecoder >> decodeIdentifier [
	| type binding |
	type := self bindingTypeOf: self nextInteger.
	binding := type decodeUsing: self.
	^ SIdentifier new binding: binding
]

{ #category : #public }
AstcodeDecoder >> decodeLiteral [
	| index value |
	index := self nextInteger.
	value := index = 0
		ifTrue: [ self nextLiteralInteger ]
		ifFalse: [ self literalAt: index ].
	^ SLiteral new
		index: index;
		value: value
]

{ #category : #public }
AstcodeDecoder >> decodeMessage [
	| inlined selector receiver arguments |
	inlined := self nextBoolean.
	selector := self nextSymbol.
	receiver := self nextExpression.
	arguments := self nextExpressionArray.
	^ SMessage new
		receiver: receiver;
		selector: selector;
		arguments: arguments;
		inlined: inlined
]

{ #category : #public }
AstcodeDecoder >> decodeMethod [
	| type node next pragma |
	type := stream next.
	type != MethodId
		ifTrue: [ self error: 'method astcode expected' ].
	node := SMethod new.
	next := stream peek.
	next = PragmaId
		ifTrue: [ stream next.
			pragma := SPragma new name: self nextSymbolOrNil.
			node pragma: pragma ].
	node
		compiledCode: method;
		statements: self nextExpressionArray.
	^ node
]

{ #category : #public }
AstcodeDecoder >> decodeNestedDynamicVar [
	^ SNestedDynamicBinding new
		name:
			self nextSymbol.

]

{ #category : #public }
AstcodeDecoder >> decodeReturn [
	| expression local |
	local := self nextBoolean.
	expression := self nextExpression.
	^ SReturn new
		local: local;
		expression: expression
]

{ #category : #public }
AstcodeDecoder >> decodeTemporary [
	^ STemporaryBinding new
		index: self nextInteger;
		environment: self nextEnvironment
]

{ #category : #unclassified }
AstcodeDecoder >> literalAt: anInteger [
	^ builder ifNil: [method at: anInteger] ifNotNil: [builder method: method literalAt: anInteger]
]

{ #category : #accessing }
AstcodeDecoder >> method: aMethod [
	method := aMethod
]

{ #category : #public }
AstcodeDecoder >> nextArray [
	| count |
	count := self nextInteger.
	^ stream next: count
]

{ #category : #initialization }
AstcodeDecoder >> nextBoolean [
	^ stream next = 1
]

{ #category : #public }
AstcodeDecoder >> nextEnvironment [
	| value |
	value := self nextInteger.
	^ value != -2
		ifTrue: [ value ]
]

{ #category : #public }
AstcodeDecoder >> nextExpression [
	| type |
	type := self nodeTypeOf: stream next.
	^type decodeUsing: self.

]

{ #category : #public }
AstcodeDecoder >> nextExpressionArray [
	| count |
	count := self nextInteger.
	^(1 to: count) collect: [ :arg | self nextExpression ]
]

{ #category : #initialization }
AstcodeDecoder >> nextInteger [
	| value |
	value := stream next.
	value = 16r80
		ifTrue: [ ^ stream int64 ].
	^ value <= 127
		ifTrue: [ value ]
		ifFalse: [ value - 16r100 ]
]

{ #category : #unclassified }
AstcodeDecoder >> nextLiteralInteger [
	| value |
	value := self nextInteger.
	^ builder
		ifNil: [ value ]
		ifNotNil: [ builder newInteger: value ]
]

{ #category : #public }
AstcodeDecoder >> nextSymbol [
	| index |
	index := self nextInteger.
	^ self literalAt: index
]

{ #category : #public }
AstcodeDecoder >> nextSymbolOrNil [
	| index |
	index := self nextInteger.
	^index != 0 ifTrue: [ self literalAt: index]
]

{ #category : #initialization }
AstcodeDecoder >> nextUnsignedInteger [
	| value |
	value := self nextByte.
	^value < 128
		ifTrue: [value]
		ifFalse: [value - 128 + (self nextUnsignedInteger bitShift: 7)]
]

{ #category : #public }
AstcodeDecoder >> nodeTypeOf: id [
	^NodeTypes at: id
]

{ #category : #accessing }
AstcodeDecoder >> stream: aStream [
	stream := aStream
]
