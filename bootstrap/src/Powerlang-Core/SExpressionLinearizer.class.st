Class {
	#name : #SExpressionLinearizer,
	#superclass : #Object,
	#instVars : [
		'operations',
		'primitives',
		'inBlock',
		'runtime',
		'greaterThan',
		'one',
		'plus',
		'stackTop',
		'dropsArguments',
		'not',
		'equalsEquals',
		'ifTrue',
		'ifFalse',
		'ifTrueIfFalse',
		'ifFalseIfTrue',
		'ifNil',
		'ifNotNil',
		'ifNilIfNotNil',
		'ifNotNilIfNil',
		'whileTrue',
		'whileFalse',
		'whileTrue_',
		'whileFalse_',
		'toDo',
		'toByDo',
		'repeat',
		'timesRepeat',
		'andNot',
		'orNot'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #initialization }
SExpressionLinearizer >> assign: aCollection [
	| op |
	op := SOpAssign new assignees: aCollection.
	operations add: op

]

{ #category : #initialization }
SExpressionLinearizer >> branchIf: aBoolean [
	| class op |
	class := aBoolean
		ifTrue: [ SOpJumpTrue ]
		ifFalse: [ SOpJumpFalse ].
		op := class new.
	operations add: op.
	^op
]

{ #category : #initialization }
SExpressionLinearizer >> branchTargetOf: branch [
	branch target: self currentPC
]

{ #category : #initialization }
SExpressionLinearizer >> currentPC [
	^ operations size
]

{ #category : #initialization }
SExpressionLinearizer >> dispatch: message [
	| op count |
	op := SOpDispatchMessage new message: message.
	operations add: op.
	dropsArguments ifTrue: [ ^self ].
	
	count := message arguments size.
	count > 0 ifTrue: [ count := count + 1 ].
	stackTop := stackTop - count 
]

{ #category : #initialization }
SExpressionLinearizer >> dropCascadeMessageArgs: argsize [
	(argsize = 0 orNot: [ dropsArguments ])
		ifTrue: [ ^ self ].
	self dropToS: argsize
]

{ #category : #initialization }
SExpressionLinearizer >> dropMessageArgs: argsize [
	(argsize = 0 orNot: [ dropsArguments ])
		ifTrue: [ ^ self ].
	self dropToS: argsize + 1
]

{ #category : #initialization }
SExpressionLinearizer >> dropToS [
	^self dropToS: 1
]

{ #category : #initialization }
SExpressionLinearizer >> dropToS: anInteger [
	| op |
	op := SOpDropToS new count: anInteger.
	operations add: op.
	stackTop := stackTop - anInteger
]

{ #category : #initialization }
SExpressionLinearizer >> dropsArguments [
	dropsArguments := true
]

{ #category : #initialization }
SExpressionLinearizer >> initialize [
	dropsArguments := false
]

{ #category : #initialization }
SExpressionLinearizer >> inline: anSMessage binaryWhile: aBoolean [
	"TODO: cleanup block locals to nil after each cycle"

	| start end |
	start := self currentPC.
	self visitStatements: anSMessage receiver statements.
	end := self branchIf: aBoolean not.
	self
		visitStatements: anSMessage arguments first statements;
		jumpTo: start;
		branchTargetOf: end
		
]

{ #category : #initialization }
SExpressionLinearizer >> inline: anSMessage if: aBoolean [
	| branch end |
	anSMessage receiver acceptVisitor: self.
	branch := self branchIf: aBoolean not.
	end := self
		visitStatements: anSMessage arguments first statements;
		jump.
	self
		branchTargetOf: branch;
		loadRwithNil;
		branchTargetOf: end 
		
]

{ #category : #initialization }
SExpressionLinearizer >> inline: anSMessage ifNil: aBoolean [
	| nilObj message branch end arg index |
	anSMessage receiver acceptVisitor: self.
	arg := anSMessage arguments first.
	(arg isBlock and: [ arg inlinedArgs size = 1]) ifTrue: [ 
		index := arg inlinedArgs first.
		self storeRintoFrameAt: index
		 ].
	self pushR.
	nilObj := SLiteral new value: runtime nil.
	message := SMessage new
		receiver: (SOpLoadRfromStack new index: 0);
		arguments: {nilObj};
		selector: equalsEquals.
	self visitMessage: message.
	branch := self branchIf: aBoolean not.

	arg isBlock
		ifTrue: [ self visitStatements: arg statements ]
		ifFalse: [ arg acceptVisitor: self ].
	end := self
		dropToS;
		jump.
	self
		branchTargetOf: branch;
		popR;
		branchTargetOf: end
]

{ #category : #initialization }
SExpressionLinearizer >> inline: anSMessage ifNilIfNotNil: aBoolean [
	| arguments nilObj message branch end arg index |
	anSMessage receiver acceptVisitor: self.
	arguments := anSMessage arguments.
	arg := aBoolean ifTrue: [arguments second] ifFalse: [arguments first].
	(arg isBlock and: [ arg inlinedArgs size = 1 ])
		ifTrue: [ index := arg inlinedArgs first.
			self storeRintoFrameAt: index ].
	self pushR.
	nilObj := SLiteral new value: runtime nil.
	message := SMessage new
		receiver: (SOpLoadRfromStack new index: 0);
		arguments: {nilObj};
		selector: equalsEquals.
	self visitMessage: message.
	branch := self branchIf: aBoolean not.
	end := self
		visitStatements: arguments first statements;
		jump.
	self
		branchTargetOf: branch;
		visitStatements: arguments second statements;
		branchTargetOf: end;
		dropToS
]

{ #category : #initialization }
SExpressionLinearizer >> inline: anSMessage ifTrueIfFalse: aBoolean [
	| branch end |
	anSMessage receiver acceptVisitor: self.
	branch := self branchIf: aBoolean not.
	end := self
		visitStatements: anSMessage arguments first statements;
		jump.
	self
		branchTargetOf: branch;
		visitStatements: anSMessage arguments second statements;
		branchTargetOf: end
]

{ #category : #initialization }
SExpressionLinearizer >> inline: anSMessage unitaryWhile: aBoolean [
	"TODO: cleanup block locals to nil after each cycle"

	| start branch |
	start := self currentPC.
	self visitStatements: anSMessage receiver statements.
	branch :=  self branchIf: aBoolean.
	branch target: start.

]

{ #category : #initialization }
SExpressionLinearizer >> inlineAnd: anSMessage [
	| branch |
	anSMessage receiver acceptVisitor: self.
	branch := self branchIf: false.
	self visitStatements: anSMessage arguments first statements; branchTargetOf: branch
]

{ #category : #initialization }
SExpressionLinearizer >> inlineAndNot: anSMessage [
	| branch message |
	anSMessage receiver acceptVisitor: self.
	branch := self branchIf: false.
	message := SMessage new
		selector: not;
		arguments: #().
	self
		visitStatements: anSMessage arguments first statements;
		dispatch: message;
		branchTargetOf: branch
]

{ #category : #initialization }
SExpressionLinearizer >> inlineOr: anSMessage [
	| branch |
	anSMessage receiver acceptVisitor: self.
	branch := self branchIf: true.
	self visitStatements: anSMessage arguments first statements.
	self branchTargetOf: branch
]

{ #category : #initialization }
SExpressionLinearizer >> inlineOrNot: anSMessage [
	| branch message |
	anSMessage receiver acceptVisitor: self.
		branch := self branchIf: true.
	message := SMessage new
		selector: not;
		arguments: #().
	self
		visitStatements: anSMessage arguments first statements;
		dispatch: message;
		branchTargetOf: branch
]

{ #category : #initialization }
SExpressionLinearizer >> inlineToDo: anSMessage [
	"TODO: cleanup block locals to nil after each cycle"

	| index current limit start end compare increment |
	anSMessage receiver acceptVisitor: self.
	index := anSMessage arguments second inlinedArgs first.
	current := SOpLoadRfromFrame new index: index.
	self storeRintoFrameAt: index.
	anSMessage arguments first acceptVisitor: self.
	self pushR.
	limit := SOpLoadRfromFrame new index: stackTop.
	start := self currentPC.
	compare := SMessage new
		receiver: current;
		selector: greaterThan;
		arguments: {limit}.
	self visitMessage: compare.
	end := self branchIf: true.
	self visitStatements: anSMessage arguments second statements.
	increment := SMessage new
		receiver: current;
		selector: plus;
		arguments: {one}.
	self
		visitMessage: increment;
		storeRintoFrameAt: index;
		jumpTo: start;
		branchTargetOf: end;
		dropToS: 1
]

{ #category : #initialization }
SExpressionLinearizer >> jump [
	| op |
	op := SOpJump new.
	operations add: op.
	^op
]

{ #category : #initialization }
SExpressionLinearizer >> jumpTo: anInteger [
| op |
op := SOpJump new target: anInteger.
	operations add: op
]

{ #category : #initialization }
SExpressionLinearizer >> loadRfromStack: anInteger [
	| op |
	op := SOpLoadRfromStack new index: anInteger.
	operations add: op

]

{ #category : #initialization }
SExpressionLinearizer >> loadRwithNil [
	operations add: SOpLoadRwithNil new
]

{ #category : #initialization }
SExpressionLinearizer >> loadRwithSelf [
	operations add: SOpLoadRwithSelf new
]

{ #category : #initialization }
SExpressionLinearizer >> operations [
^operations
]

{ #category : #initialization }
SExpressionLinearizer >> popR [
	operations add: SOpPopR new.
	stackTop := stackTop - 1
]

{ #category : #initialization }
SExpressionLinearizer >> primitive: aClosure [
	operations add: (SOpPrimitive new block: aClosure)
]

{ #category : #accessing }
SExpressionLinearizer >> primitives: aCollection [ 
	primitives := aCollection
]

{ #category : #initialization }
SExpressionLinearizer >> pushR [
	operations add: SOpPushR new.
	stackTop := stackTop + 1
]

{ #category : #initialization }
SExpressionLinearizer >> reset [
	operations := OrderedCollection new.
	inBlock := false.

]

{ #category : #initialization }
SExpressionLinearizer >> return [
	operations add: SOpReturn new
]

{ #category : #initialization }
SExpressionLinearizer >> return: isLocal [
	|  class |
	class := (isLocal andNot: [ inBlock ])
		ifTrue: [ SOpReturn ]
		ifFalse: [ SOpNonLocalReturn ].
	operations add: class new
]

{ #category : #initialization }
SExpressionLinearizer >> runtime: aPowertalkRuntime [
	| literal |
	runtime := aPowertalkRuntime.
	literal := runtime newInteger: 1.
	one := SLiteral new value: literal.
	plus := runtime symbolFromLocal: #+.
	greaterThan := runtime symbolFromLocal: #>.
	equalsEquals := runtime symbolFromLocal: #==.
	not := runtime symbolFromLocal: #not.
	ifTrue := runtime symbolFromLocal: #ifTrue:.
	ifFalse := runtime symbolFromLocal: #ifFalse:.
	ifTrueIfFalse := runtime symbolFromLocal: #ifTrue:ifFalse:.
	ifFalseIfTrue := runtime symbolFromLocal: #ifFalse:ifTrue:.
	ifNil := runtime symbolFromLocal: #ifNil:.
	ifNotNil := runtime symbolFromLocal: #ifNotNil:.
	ifNilIfNotNil := runtime symbolFromLocal: #ifNil:ifNotNil:.
	ifNotNilIfNil := runtime symbolFromLocal: #ifNotNil:ifNil:.
	whileTrue := runtime symbolFromLocal: #whileTrue.
	whileFalse := runtime symbolFromLocal: #whileFalse.
	whileTrue_ := runtime symbolFromLocal: #whileTrue:.
	whileFalse_ := runtime symbolFromLocal: #whileFalse:.
	toDo := runtime symbolFromLocal: #to:do:.
	toByDo := runtime symbolFromLocal: #to:by:do:.
	andNot := runtime symbolFromLocal: #andNot:.
	orNot	:= runtime symbolFromLocal: #orNot:.

]

{ #category : #initialization }
SExpressionLinearizer >> storeRintoFrameAt: anInteger [
	| op |
	op := SOpStoreRintoFrame new index: anInteger.
	operations add: op
]

{ #category : #initialization }
SExpressionLinearizer >> visitAssignment: anSAssignment [
	anSAssignment expression acceptVisitor: self.
	self
		assign: anSAssignment assignees
]

{ #category : #initialization }
SExpressionLinearizer >> visitBlock: anSBlock [
	| prevInBlock prevOperations statements |
	operations add: anSBlock.
	prevInBlock := inBlock.
	prevOperations := operations.
	inBlock := true.
	operations := OrderedCollection new.
	statements := anSBlock statements.
	statements do: [ :node | node acceptVisitor: self ].
	statements isEmpty
		ifTrue: [ self loadRwithNil ]
		ifFalse: [ statements last isReturn
				ifFalse: [ self return ] ].
	anSBlock isInlined ifFalse: [ 
	runtime
		blockOptimizedCode: anSBlock compiledCode
		put: operations asArray].
	operations := prevOperations.
	inBlock := prevInBlock
]

{ #category : #initialization }
SExpressionLinearizer >> visitCascade: anSCascade [
	| args argsize |
	anSCascade receiver acceptVisitor: self.
	self pushR.
	anSCascade messages
		do: [ :msg | 
			args := msg arguments.
			argsize := args size.
			args
				do: [ :arg | 
					arg acceptVisitor: self.
					self pushR ].
			self
				loadRfromStack: argsize;
				dispatch: msg;
				dropCascadeMessageArgs: argsize ].
	self dropToS
]

{ #category : #initialization }
SExpressionLinearizer >> visitIdentifier: anSIdentifier [
	operations add: anSIdentifier
]

{ #category : #initialization }
SExpressionLinearizer >> visitInlinedMessage: anSMessage [
	| selector |
	selector := anSMessage selector.
	selector == ifTrue
		ifTrue: [ ^ self inline: anSMessage if: true ].
	selector == ifFalse
		ifTrue: [ ^ self inline: anSMessage if: false ].
	selector == ifNil
		ifTrue: [ ^ self inline: anSMessage ifNil: true ].
	selector == ifNotNil
		ifTrue: [ ^ self inline: anSMessage ifNil: false ].
	selector == ifNilIfNotNil
		ifTrue: [ ^ self inline: anSMessage ifNilIfNotNil: true ].
	selector == ifNotNilIfNil
		ifTrue: [ ^ self inline: anSMessage ifNilIfNotNil: false ].
	selector == ifTrueIfFalse
		ifTrue: [ ^ self inline: anSMessage ifTrueIfFalse: true ].
	selector == ifFalseIfTrue
		ifTrue: [ ^ self inline: anSMessage ifTrueIfFalse: false ].
	selector == whileTrue
		ifTrue: [ ^ self inline: anSMessage unitaryWhile: true ].
	selector == whileFalse
		ifTrue: [ ^ self inline: anSMessage unitaryWhile: false ].
	selector == whileTrue_
		ifTrue: [ ^ self inline: anSMessage binaryWhile: true ].
	selector == whileFalse_
		ifTrue: [ ^ self inline: anSMessage binaryWhile: false ].
	selector == repeat
		ifTrue: [ ^ self inlineRepeat: anSMessage ].
	selector == toDo
		ifTrue: [ ^ self inlineToDo: anSMessage ].
	selector == toByDo
		ifTrue: [ ^ self inlineToByDo: anSMessage ].
	selector == timesRepeat
		ifTrue: [ ^ self inlineTimesRepeat: anSMessage ].
	selector == andNot
		ifTrue: [ ^ self inlineAndNot: anSMessage ].
	selector == orNot
		ifTrue: [ ^ self inlineOrNot: anSMessage ].
	selector := runtime localSymbolFrom: selector.
	(selector beginsWith: #or:)
		ifTrue: [ ^ self inlineOr: anSMessage ].
	(selector beginsWith: #and:)
		ifTrue: [ ^ self inlineAnd: anSMessage ].

	self ASSERT: false
]

{ #category : #initialization }
SExpressionLinearizer >> visitLiteral: anSLiteral [
	operations add: anSLiteral
]

{ #category : #initialization }
SExpressionLinearizer >> visitMessage: anSMessage [
	| args argsize |
	anSMessage isInlined
		ifTrue: [ ^ self visitInlinedMessage: anSMessage ].
	anSMessage receiver acceptVisitor: self.
	args := anSMessage arguments.
	argsize := args size.
	argsize > 0
		ifTrue: [ self pushR ].
	args
		do: [ :arg | 
			arg acceptVisitor: self.
			self pushR ].
	argsize > 0
		ifTrue: [ self loadRfromStack: argsize ].
	self dispatch: anSMessage; dropMessageArgs: argsize.
	
]

{ #category : #initialization }
SExpressionLinearizer >> visitMethod: anSMethod [
	| primitive statements symbol |
	self reset.
	primitive := anSMethod pragma.
	primitive
		ifNotNil: [ symbol := runtime localSymbolFrom: anSMethod primitive.
			primitive := primitives at: symbol.
			^ self
				primitive: primitive;
				return ].
	stackTop := runtime methodTempCount: anSMethod compiledCode.
	statements := anSMethod statements.
	statements do: [ :node | node acceptVisitor: self ].
	(statements isEmpty orNot: [ statements last isReturn ])
		ifTrue: [ self
				loadRwithSelf;
				return ]
]

{ #category : #visiting }
SExpressionLinearizer >> visitOpLoadRfromFrame: anSOpLoadRfromFrame [ 
	operations add: anSOpLoadRfromFrame
]

{ #category : #visiting }
SExpressionLinearizer >> visitOpLoadRfromStack: anSOpLoadRfromStack [
self loadRfromStack: anSOpLoadRfromStack index
]

{ #category : #initialization }
SExpressionLinearizer >> visitReturn: anSReturn [
	anSReturn expression acceptVisitor: self.
	self
		return: anSReturn local
]

{ #category : #private }
SExpressionLinearizer >> visitStatements: aCollection [ 
	aCollection do: [:sexpression | sexpression acceptVisitor: self]
	
]
