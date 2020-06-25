"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OptimizingInstructionSelector,
	#superclass : #Object,
	#instVars : [
		'firstBlock',
		'tiles',
		'roots',
		'messages'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #unclassified }
OptimizingInstructionSelector class >> new [
	^self basicNew initialize
]

{ #category : #unclassified }
OptimizingInstructionSelector >> doSelection [
	self numberArguments.
	firstBlock reversePostOrderDo: [:block | self generateTilingFor: block].
	self removeUnused
]

{ #category : #unclassified }
OptimizingInstructionSelector >> firstBlock: aBasicBlock [
	firstBlock := aBasicBlock
]

{ #category : #unclassified }
OptimizingInstructionSelector >> generateTilingFor: block [
	block firstInstruction acceptVisitor: self
]

{ #category : #unclassified }
OptimizingInstructionSelector >> initialize [
	tiles := IdentityDictionary new.
	self initializeMessages
]

{ #category : #unclassified }
OptimizingInstructionSelector >> initializeMessages [
	messages := Dictionary new
		at: #'+' put: #CommutativeBinary:;
		at: #'-' put: #Minus:;
		at: #'*' put: #CommutativeBinary:;
		at: #'<' put: #Compare:;
		at: #'<=' put: #Compare:;
		at: #'=' put: #Compare:;
		at: #'==' put: #Compare:;
		at: #'~=' put: #Compare:;
		at: #'!=' put: #Compare:;
		at: #'>=' put: #Compare:;
		at: #'>' put: #Compare:;
		at: #'&' put: #CommutativeBinary:;
		at: #bitAnd: put: #CommutativeBinary:;
		at: #_byteAt: put: #Binary:;
		at: #_basicAt: put: #Binary:;
		at: #_byteAt:put: put: #Ternary:;
		at: #_basicAt:put: put: #Ternary:;
		at: #_basicFlags put: #Unary:;
		at: #_smallSize put: #Unary:;
		at: #_largeSize put: #Unary:;
		at: #_isSmallInteger put: #Unary:;
		at: #_transferControlTo: put: #Binary:;
		at: #not put: #Not:;
		yourself
]

{ #category : #unclassified }
OptimizingInstructionSelector >> insertCopyResultAfter: anInstruction [
	| copy |
	copy := OUnaryOperation receiver: anInstruction name: #copyResult.
	anInstruction
		afterInsert: copy;
		replaceAllUsesWith: copy;
		addUse: copy at: #receiver
]

{ #category : #unclassified }
OptimizingInstructionSelector >> insertPush: anInstruction before: instruction [
	| push tile |
	push := OUnaryOperation receiver: anInstruction name: #push.
	anInstruction addUse: push at: #receiver.
	instruction beforeInsert: push.
	tile := self newTile: push.
	self tile: push as: tile beUsed.
	^push
]

{ #category : #unclassified }
OptimizingInstructionSelector >> newTile: instruction [
	^OTiling for: instruction
]

{ #category : #unclassified }
OptimizingInstructionSelector >> numberArguments [
	| count instruction i |
	count := 0.
	instruction := firstBlock firstInstruction next.
	[instruction next isLoadImplicit] whileTrue: [
		instruction := instruction next.
		count := count + 1].
	i := 0.
	[i < count] whileTrue: [
		instruction name: i + 3.
		instruction := instruction prev.
		i := i + 1]
]

{ #category : #unclassified }
OptimizingInstructionSelector >> removeUnused [
	firstBlock instructionsWithSuccessorsDo: [:instruction | | tile |
		tile := self tileOf: instruction.
		(tile instruction == instruction and: [tile isUsed])
			ifFalse: [instruction replaceAllUsesWith: tile instruction; dissolve]]
]

{ #category : #unclassified }
OptimizingInstructionSelector >> selectorFor: name [
	^(#send , (messages at: name ifAbsent: [#GenericMessage:])) asSymbol
]

{ #category : #unclassified }
OptimizingInstructionSelector >> send: instruction left: left commutativeRight: right [
	right isConstant
		ifTrue: [^self tile: instruction using: left toConstant: right value].
	left isConstant
		ifTrue: [^self tile: instruction using: right toConstant: left value].
	self tile: instruction using: left to: right
]

{ #category : #unclassified }
OptimizingInstructionSelector >> send: instruction left: left comparedTo: right [
	right isConstant
		ifTrue: [^self tile: instruction using: left toConstant: right value].
	left isConstant
		ifTrue: [^(self tile: instruction using: right toConstant: left value) invertOperation].
	self tile: instruction using: left to: right
]

{ #category : #unclassified }
OptimizingInstructionSelector >> send: instruction left: left minusRight: right [
	right isConstant
		ifTrue: [^self tile: instruction using: left toConstant: right value].
	left isConstant
		ifTrue: [^(self doesntWork
			tile: instruction
			using: right
			toConstant: 0 - left value)
			invert].
	self tile: instruction using: left to: right
]

{ #category : #unclassified }
OptimizingInstructionSelector >> send: instruction left: left right: right [
	right isConstant
		ifTrue: [^self tile: instruction using: left toConstant: right value].
	left isConstant
		ifTrue: [^self tile: instruction using: right toConstant: left value].
	self tile: instruction using: left to: right
]

{ #category : #unclassified }
OptimizingInstructionSelector >> send: instruction receiver: receiver [
	receiver isConstant ifTrue: [^self tile: instruction toConstant: receiver].
	self tile: instruction receiver: receiver
]

{ #category : #unclassified }
OptimizingInstructionSelector >> send: instruction
receiver: receiver
left: left
right: right [
	"
	right isConstant
		ifTrue: [^self tile: instruction using: left toConstant: right value].
	left isConstant
		ifTrue: [^self tile: instruction using: right toConstant: left value].
	"
	self
		tile: instruction
		using: receiver
		left: left
		right: right
]

{ #category : #unclassified }
OptimizingInstructionSelector >> sendBinary: instruction [
	self
		send: instruction
		left: instruction receiver
		right: instruction arguments first
]

{ #category : #unclassified }
OptimizingInstructionSelector >> sendCommutativeBinary: instruction [
	self
		send: instruction
		left: instruction receiver
		commutativeRight: instruction arguments first
]

{ #category : #unclassified }
OptimizingInstructionSelector >> sendCompare: instruction [
	self
		send: instruction
		left: instruction receiver
		comparedTo: instruction arguments first
]

{ #category : #unclassified }
OptimizingInstructionSelector >> sendGenericMessage: instruction [
	| arguments values tile new |
	arguments := instruction arguments.
	values := Array with: instruction receiver withAll: arguments.
	new := arguments
		collect: [:argument | self insertPush: argument before: instruction].
	instruction arguments: new.
	arguments do: [:argument | argument removeUse: instruction].
	values do: [:value | (self tileOf: value) beUsed].
	tile := self newTile: instruction.
	self
		tile: instruction as: tile beUsed;
		insertCopyResultAfter: instruction
]

{ #category : #unclassified }
OptimizingInstructionSelector >> sendMinus: instruction [
	self
		send: instruction
		left: instruction receiver
		minusRight: instruction arguments first
]

{ #category : #unclassified }
OptimizingInstructionSelector >> sendNot: instruction [
	| negated tile |
	negated := (self tileOf: instruction receiver) beUsed.
	negated instruction negateOperation.
	tile := self newTile: instruction.
	self tile: instruction as: tile.
	^instruction
]

{ #category : #unclassified }
OptimizingInstructionSelector >> sendTernary: instruction [
	self
		send: instruction
		receiver: instruction receiver
		left: instruction arguments first
		right: instruction arguments second
]

{ #category : #unclassified }
OptimizingInstructionSelector >> sendUnary: instruction [
	self send: instruction receiver: instruction receiver
]

{ #category : #unclassified }
OptimizingInstructionSelector >> tile: instruction as: tile [
	tiles at: instruction put: tile
]

{ #category : #unclassified }
OptimizingInstructionSelector >> tile: instruction receiver: receiver [
	| receivertile new tile |
	receivertile := (self tileOf: receiver) beUsed.
	new := OUnaryOperation new receiver: receiver; name: instruction selector.
	receiver addUse: new at: #receiver.
	instruction beforeInsert: new.
	tile := self newTile: new.
	self
		tile: new as: tile;
		tile: instruction as: tile.
	^new
]

{ #category : #unclassified }
OptimizingInstructionSelector >> tile: instruction
using: receiver
left: left
right: right [
	| lefttile righttile receivertile tile new |
	receivertile := (self tileOf: receiver) beUsed.
	lefttile := (self tileOf: left) beUsed.
	righttile := (self tileOf: right) beUsed.
	new := OTernaryOperation
		receiver: receiver
		left: left
		right: right
		name: instruction selector.
	receiver addUse: new at: #receiver.
	left addUse: new at: #left.
	right addUse: new at: #right.
	instruction beforeInsert: new.
	tile := self newTile: new.
	self
		tile: new as: tile beUsed;
		tile: instruction as: righttile "for at:put:".
	^new
]

{ #category : #unclassified }
OptimizingInstructionSelector >> tile: instruction using: left to: right [
	| lefttile righttile tile new |
	lefttile := (self tileOf: left) beUsed.
	righttile := (self tileOf: right) beUsed.
	new := OBinaryVariableOperation
		left: left
		right: right
		name: instruction selector.
	left addUse: new at: #left.
	right addUse: new at: #right.
	instruction beforeInsert: new.
	tile := self newTile: new.
	self
		tile: new as: tile;
		tile: instruction as: tile.
	^new
]

{ #category : #unclassified }
OptimizingInstructionSelector >> tile: instruction using: left toConstant: value [
	| lefttile new tile |
	lefttile := (self tileOf: left) beUsed.
	new := OBinaryConstantOperation
		left: left
		right: value
		name: instruction selector.
	left addUse: new at: #left.
	instruction beforeInsert: new.
	tile := self newTile: new.
	self
		tile: new as: tile;
		tile: instruction as: tile.
	^new
]

{ #category : #unclassified }
OptimizingInstructionSelector >> tileOf: instruction [
	^tiles at: instruction
]

{ #category : #unclassified }
OptimizingInstructionSelector >> visitJump: instruction [
	| new |
	new := self newTile: instruction.
	self tile: instruction as: new beUsed
]

{ #category : #unclassified }
OptimizingInstructionSelector >> visitJumpFalse: instruction [
	| tile new |
	tile := self tileOf: instruction variable.
	tile beUsed.
	new := self newTile: instruction.
	self tile: instruction as: new beUsed
]

{ #category : #unclassified }
OptimizingInstructionSelector >> visitJumpTrue: instruction [
	| tile new |
	tile := self tileOf: instruction variable.
	tile beUsed.
	new := self newTile: instruction.
	self tile: instruction as: new beUsed
]

{ #category : #unclassified }
OptimizingInstructionSelector >> visitLoadConstant: instruction [
	| tile |
	tile := self newTile: instruction.
	self tile: instruction as: tile
]

{ #category : #unclassified }
OptimizingInstructionSelector >> visitLoadImplicit: instruction [
	| tile sourcetile new |
	instruction name isSmallInteger
		ifTrue: [
			sourcetile := (self tileOf: instruction source) beUsed.
			new := OBinaryConstantOperation
				left: instruction source
				right: instruction name
				name: #_basicAt:.
			instruction source addUse: new at: #left.
			instruction beforeInsert: new; replaceAllUsesWith: new; dissolve.
			tile := self newTile: new.
			self tile: new as: tile]
		ifFalse: [
			tile := self newTile: instruction.
			self tile: instruction as: tile.
			instruction name == #activationRecord ifTrue: [tile beUsed]]
]

{ #category : #unclassified }
OptimizingInstructionSelector >> visitMessageSend: instruction [
	| selector |
	selector := self selectorFor: instruction selector.
	self perform: selector with: instruction
]

{ #category : #unclassified }
OptimizingInstructionSelector >> visitPhi: instruction [
	| tile |
	instruction variables
		collect: [:source | self tileOf: source]
		thenDo: #beUsed.
	tile := self newTile: instruction.
	self tile: instruction as: tile
]

{ #category : #unclassified }
OptimizingInstructionSelector >> visitReturn: instruction [
	| tile new |
	tile := self tileOf: instruction source.
	tile beUsed.
	new := self newTile: instruction.
	self tile: instruction as: new beUsed
]

{ #category : #unclassified }
OptimizingInstructionSelector >> visitUnary: instruction [
	| tile new |
	tile := self tileOf: instruction receiver.
	tile beUsed.
	new := self newTile: instruction.
	self tile: instruction as: new beUsed
]
