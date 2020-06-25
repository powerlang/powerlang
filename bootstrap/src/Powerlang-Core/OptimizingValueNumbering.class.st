"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OptimizingValueNumbering,
	#superclass : #Object,
	#instVars : [
		'firstBlock',
		'currentBlock',
		'names',
		'hashes',
		'hashesOut'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #private }
OptimizingValueNumbering >> addNewName: instruction [
	^names at: instruction put: '{v' , names size printString , '}'
]

{ #category : #unclassified }
OptimizingValueNumbering >> hashOfLoadConstant: instruction [
	^[instruction value printString] on: Error do: [^nil]
]

{ #category : #unclassified }
OptimizingValueNumbering >> hashOfUnary: instruction [
	| receiver |
	receiver := self nameOf: instruction receiver.
	^receiver , instruction name
]

{ #category : #unclassified }
OptimizingValueNumbering >> isCommutative: name [
	^name = #'+' or: [name = #'*']
]

{ #category : #unclassified }
OptimizingValueNumbering >> isStillAlive: block [
	^block withPredecessors includes: firstBlock
]

{ #category : #unclassified }
OptimizingValueNumbering >> nameOf: instruction [
	^names at: instruction
]

{ #category : #unclassified }
OptimizingValueNumbering >> processMemoryStore: value as: storeHash andLoads: loadHash [
	hashes
		at: loadHash
		put: value
	"facil hashes at: storeHash ifPresent: [:mapping | (mapping value livesInSameBlockThan: store)  ifTrue: [mapping value dissolve]]"
	"dificil hashes at: storeHash ifPresent: [:mapping | postDominatorTree does: blockOf dominate: currentBlock ifTrue: [mapping value dissolve]]"
]

{ #category : #unclassified }
OptimizingValueNumbering >> resultOfBinaryWithConstants: aBinaryInstruction [
	| operation left right |
	operation := aBinaryInstruction name.
	left := aBinaryInstruction left value.
	right := aBinaryInstruction right value.
	operation = #'+' ifTrue: [^left + right].
	operation = #'-' ifTrue: [^left - right].
	operation = #'*' ifTrue: [^left * right].
	operation = #'//' ifTrue: [^left // right].
	operation = #'=' ifTrue: [^left = right].
	self halt
]

{ #category : #unclassified }
OptimizingValueNumbering >> unifyPredecessorHashes [
	| incoming any |
	hashes := Dictionary new.
	currentBlock predecessors size = 0 ifTrue: [^self].
	incoming := currentBlock predecessors
		collect: [:pred | hashesOut at: pred ifAbsent: [Dictionary new]].
	any := incoming removeLast.
	any keysAndValuesDo: [:hash :value | | unanimous |
		unanimous := incoming
			conform: [:dict | dict
				at: hash
				ifAbsent: false
				ifPresent: [:prev | prev = value]].
		unanimous ifTrue: [hashes at: hash put: value]]
]

{ #category : #unclassified }
OptimizingValueNumbering >> valueBranchTo: aBasicBlock [
	| source last comparison hash name |
	aBasicBlock predecessors size != 1 ifTrue: [^self].
	source := aBasicBlock predecessors first.
	last := source lastInstruction.
	last isConditionalJump ifFalse: [^self].
	comparison := last variable.
	name := self nameOf: comparison.
	hash := 'branch' , name.
	last target == aBasicBlock
		ifTrue: [hashes at: hash put: last isJumpTrue]
		ifFalse: [hashes at: hash put: last isJumpFalse]
]

{ #category : #private }
OptimizingValueNumbering >> valueOf: hash be: instruction [
	hashes at: hash ifPresent: [:value | | copy |
		copy := instruction replaceWithCopyOf: value.
		self addNewName: copy.
		^copy == value ifFalse: [
			(copy isUnaryOperation and: [copy name = #copy])
				ifTrue: [hashes at: (self hashOfUnary: copy) put: instruction].
			copy isConstant
				ifTrue: [hashes at: (self hashOfLoadConstant: copy) put: instruction]]].
	hashes at: hash put: instruction
]

{ #category : #unclassified }
OptimizingValueNumbering >> visitBinaryWithConstant: instruction [
	| left right hash selector load temp value replacement |
	left := self nameOf: instruction left.
	right := instruction right printString.
	(self isCommutative: instruction name) ifTrue: [
		left > right ifTrue: [
			temp := left.
			left := right.
			right := temp]].
	hash := left , instruction name , right.
	(#(_basicFlags: _extendedFlags:) includes: instruction name)
		ifTrue: [
			selector := instruction name allButLast: 1.
			load := left , selector.
			self processMemoryStore: instruction right as: hash andLoads: load]
		ifFalse: [
			(instruction left isConstant and: instruction name != #_basicAt:) ifTrue: [
				value := self resultOfBinaryWithConstants: instruction.
				replacement := OLoadConstant valued: value.
				instruction dissolveReplacingWith: replacement.
				^self
					addNewName: replacement;
					visitLoadConstant: replacement;
					valueOf: hash be: replacement].
			self valueOf: hash be: instruction]
]

{ #category : #unclassified }
OptimizingValueNumbering >> visitBinaryWithVariable: instruction [
	| left right hash selector load temp |
	left := self nameOf: instruction left.
	right := self nameOf: instruction right.
	(self isCommutative: instruction name) ifTrue: [
		left > right ifTrue: [
			temp := left.
			left := right.
			right := temp]].
	hash := left , instruction name , right.
	(#(_basicFlags: _extendedFlags:) includes: instruction name)
		ifTrue: [
			selector := instruction name allButLast: 1.
			load := left , selector.
			self processMemoryStore: instruction right as: hash andLoads: load]
		ifFalse: [self valueOf: hash be: instruction]
]

{ #category : #unclassified }
OptimizingValueNumbering >> visitBranch: branch [
	| hash receiver |
	receiver := self nameOf: branch variable.
	hash := 'branch' , receiver.
	hashes at: hash ifPresent: [:outcome | 
		outcome isBoolean
			ifTrue: [branch replaceWithUnconditional: outcome in: currentBlock]]
]

{ #category : #unclassified }
OptimizingValueNumbering >> visitJump: aJumpInstruction [
	
]

{ #category : #unclassified }
OptimizingValueNumbering >> visitJumpFalse: branch [
	self visitBranch: branch
]

{ #category : #unclassified }
OptimizingValueNumbering >> visitJumpTrue: branch [
	self visitBranch: branch
]

{ #category : #unclassified }
OptimizingValueNumbering >> visitLoadConstant: instruction [
	| hash |
	hash := self hashOfLoadConstant: instruction.
	hash ifNil: [self].
	self valueOf: hash be: instruction
]

{ #category : #unclassified }
OptimizingValueNumbering >> visitLoadImplicit: instruction [
	
]

{ #category : #unclassified }
OptimizingValueNumbering >> visitMessageSend: instruction [
	| loads |
	loads := names keys select: [:instr | 
		instr isPrimitiveOperation
			and: [#(_basicAt: _byteAt: _basicFlags) includes: instr name]].
	loads do: [:load | hashes removeAllSuchThat: [:value | value = load]]
]

{ #category : #unclassified }
OptimizingValueNumbering >> visitNullary: instruction [
	
]

{ #category : #unclassified }
OptimizingValueNumbering >> visitPhi: instruction [
	
]

{ #category : #unclassified }
OptimizingValueNumbering >> visitReturn: instruction [
	
]

{ #category : #unclassified }
OptimizingValueNumbering >> visitTernary: instruction [
	| receiver operand left right hash load |
	receiver := self nameOf: instruction receiver.
	operand := instruction left.
	left := operand isInstruction
		ifTrue: [self nameOf: operand]
		ifFalse: [operand printString].
	right := self nameOf: instruction right.
	hash := receiver , instruction name , left , right.
	(#(_basicAt:put: _byteAt:put:) includes: instruction name)
		ifTrue: [| selector |
			selector := instruction name allButLast: 4.
			load := receiver , selector , left.
			self processMemoryStore: instruction right as: hash andLoads: load]
		ifFalse: [^self valueOf: hash be: instruction]
]

{ #category : #unclassified }
OptimizingValueNumbering >> visitUnary: instruction [
	| hash |
	(#(push) includes: instruction name) ifTrue: [^self].
	hash := self hashOfUnary: instruction.
	self valueOf: hash be: instruction
]

{ #category : #unclassified }
OptimizingValueNumbering >> workFrom: aBasicBlock [
	| count |
	hashes := Dictionary new.
	hashesOut := Dictionary new.
	names := Dictionary new.
	firstBlock := aBasicBlock.
	count := 0.
	aBasicBlock instructionsWithSuccessorsDo: [:inst | 
		names at: inst put: '{v' , count printString , '}'.
		count := count + 1].
	aBasicBlock withSuccessorsPostOrder
		reverseDo: [:block | self workOn: block]
]

{ #category : #unclassified }
OptimizingValueNumbering >> workOn: aBlock [
	(self isStillAlive: aBlock) ifFalse: [^self].
	currentBlock := aBlock.
	self unifyPredecessorHashes.
	self valueBranchTo: aBlock.
	currentBlock firstInstruction acceptVisitor: self.
	hashesOut at: aBlock put: hashes copy
]
