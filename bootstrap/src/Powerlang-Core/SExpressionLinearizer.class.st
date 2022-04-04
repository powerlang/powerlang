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
		'dropsArguments'
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
	| op |
	op := SOpDispatchMessage new message: message.
	operations add: op.
	"dispatch removes the receiver from stack when pushed"
	message arguments notEmpty
		ifTrue: [ stackTop := stackTop - 1 ]
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
SExpressionLinearizer >> inline: anSMessage branchIf: aBoolean [
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
		branchTargetOf: end
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
SExpressionLinearizer >> loadRfromFrameAt: anInteger [
	| op |
	op := SOpLoadRfromFrame new index: anInteger.
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
	greaterThan := runtime symbolFromLocal: #>
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
	anSBlock optimizedCode: operations asArray.
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
				dispatch: msg; dropToS: argsize ].
	self dropToS
]

{ #category : #initialization }
SExpressionLinearizer >> visitIdentifier: anSIdentifier [
	operations add: anSIdentifier
]

{ #category : #initialization }
SExpressionLinearizer >> visitInlinedMessage: anSMessage [
	| selector |
	selector := runtime symbolFrom: anSMessage selector.
	selector == #ifTrue:
		ifTrue: [ ^ self inline: anSMessage branchIf: true ].
	selector == #ifFalse:
		ifTrue: [ ^ self inline: anSMessage branchIf: false ].
	selector == #ifNil:
		ifTrue: [ ^ self inlineBranch: anSMessage ifNil: true ].
	selector == #ifNotNil:
		ifTrue: [ ^ self inlineBranch: anSMessage ifNil: false ].
	selector == #ifNil:ifNotNil:
		ifTrue: [ ^ self inlineBranch: anSMessage ifNilIfNotNil: true ].
	selector == #ifNil:ifNotNil:
		ifTrue: [ ^ self inlineBranch: anSMessage ifNilIfNotNil: false ].
	selector == #ifTrue:ifFalse:
		ifTrue: [ ^ self inline: anSMessage ifTrueIfFalse: true ].
	selector == #ifFalse:ifTrue:
		ifTrue: [ ^ self inline: anSMessage ifTrueIfFalse: false ].
	selector == #whileTrue
		ifTrue: [ ^ self inline: anSMessage unitaryWhile: true ].
	selector == #whileFalse
		ifTrue: [ ^ self inline: anSMessage unitaryWhile: false ].
	selector == #whileTrue:
		ifTrue: [ ^ self inline: anSMessage binaryWhile: true ].
	selector == #whileFalse:
		ifTrue: [ ^ self inline: anSMessage binaryWhile: false ].
	selector == #repeat
		ifTrue: [ ^ self inlineRepeat: anSMessage ].
	selector == #to:do:
		ifTrue: [ ^ self inlineToDo: anSMessage ].
	selector == #to:by:do:
		ifTrue: [ ^ self inlineToByDo: anSMessage ].
	selector == #timesRepeat:
		ifTrue: [ ^ self inlineTimesRepeat: anSMessage].
	(selector beginsWith: #or:)
		ifTrue: [ ^ self inlineOr: anSMessage ].
	(selector beginsWith: #and:)
		ifTrue: [ ^ self inlineAnd: anSMessage ].
	selector == #andNot:
		ifTrue: [ ^ self inlineAndNot: anSMessage ].
	selector == #orNot:
		ifTrue: [ ^ self inlineOrNot: anSMessage ].
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
	| primitive statements |
	self reset.
	primitive := anSMethod pragma.
	primitive
		ifNotNil: [ primitive := primitives at: anSMethod primitive.
			^ self
				primitive: primitive;
				return ].
	stackTop := anSMethod compiledCode tempCount.
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
