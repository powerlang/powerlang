"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OptimizingVariableBinder,
	#superclass : #Object,
	#instVars : [
		'definitions',
		'currentBlock',
		'dominatorTree',
		'immediateDominators',
		'dominanceFrontiers',
		'pendingReads',
		'pendingPhis',
		'abi',
		'method'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #unclassified }
OptimizingVariableBinder class >> new [
	^self basicNew initialize
]

{ #category : #accessing }
OptimizingVariableBinder >> abi: anAbi [
	abi := anAbi
]

{ #category : #unclassified }
OptimizingVariableBinder >> define: value as: name [
	self define: value as: name in: currentBlock
]

{ #category : #private }
OptimizingVariableBinder >> define: value as: name in: block [
	| here |
	here := definitions at: block ifAbsentPut: [Dictionary new].
	here at: name put: value
]

{ #category : #unclassified }
OptimizingVariableBinder >> definitionOf: name [
	^self definitionOf: name from: currentBlock
]

{ #category : #unclassified }
OptimizingVariableBinder >> definitionOf: name before: block [
	| instruction current |
	instruction := block firstInstruction.
	[instruction isPhi] whileTrue: [
		instruction variables first = name ifTrue: [^instruction].
		instruction := instruction next].
	current := block.
	[
		current := immediateDominators
			at: current
			ifAbsent: [self error: 'undefined variable <' , name , '>'].
		current notNil]
		whileTrue: [
			definitions
				at: current
				ifPresent: [:here | here at: name ifPresent: [:value | ^value]]]
]

{ #category : #unclassified }
OptimizingVariableBinder >> definitionOf: name from: block [
	| current |
	current := block.
	[current notNil] whileTrue: [
		definitions
			at: current
			ifPresent: [:here | here at: name ifPresent: [:value | ^value]].
		current := immediateDominators
			at: current
			ifAbsent: [^block lastValue
			"BMNullaryOperation
				name: 'nop'
				self error: 'undefined variable <' , name , '>'"]]
]

{ #category : #unclassified }
OptimizingVariableBinder >> definitionOf: name in: block [
	definitions
		at: block
		ifPresent: [:here | here at: name ifPresent: [:value | ^value]].
	^nil
]

{ #category : #unclassified }
OptimizingVariableBinder >> doBindingFrom: firstBlock [
	dominatorTree := firstBlock dominatorTree.
	immediateDominators := dominatorTree allImmediateDominators.
	dominanceFrontiers := firstBlock
		dominanceFrontiersUsing: immediateDominators.
	firstBlock reversePostOrderDo: [:block | 
		currentBlock := block.
		block firstInstruction acceptVisitor: self].
	self resolvePendingReads; rewritePhis
]

{ #category : #unclassified }
OptimizingVariableBinder >> initialize [
	definitions := Dictionary new.
	pendingReads := OrderedCollection new.
	pendingPhis := OrderedCollection new
]

{ #category : #unclassified }
OptimizingVariableBinder >> insertPhiOf: name at: block [
	| size variables phi |
	(self definitionOf: name in: block) ifNotNil: [^self].
	size := block predecessors size.
	variables := (Array new: size)
		atAllPut: name;
		asOrderedCollection.
	phi := OPhi withAll: variables in: block predecessors.
	block firstInstruction beforeInsert: phi.
	pendingPhis add: phi -> block.
	self define: phi as: name in: block
]

{ #category : #unclassified }
OptimizingVariableBinder >> lowerReadArgument: aReadVariable binding: binding [
	| source |
	source := self definitionOf: binding index asString asSymbol.
	aReadVariable replaceAllUsesWith: source; dissolve
]

{ #category : #private }
OptimizingVariableBinder >> lowerReadAssociaion: aReadVariable binding: binding [
  | global read value name load | 
  binding isPoolVar ifTrue: [ load := OLoadConstant valued: binding value.
		^aReadVariable dissolveReplacingWith: load ].
  name := binding association key asString asSymbol.
  (name == #WordSize or: [ name == #WordSizeShift ]) ifTrue: [ value := name == #WordSize ifTrue: [ abi wordSize ] ifFalse: [ abi wordSizeShift ].
		load := OLoadConstant valued: value.
		^aReadVariable dissolveReplacingWith: load ].
  global := OLoadConstant valued: binding association.
  read := OBinaryConstantOperation left: global right: 2 name: #_basicAt:.
  global addUse: read at: #left.
  aReadVariable
	 beforeInsert: global;
	 dissolveReplacingWith: read
]

{ #category : #unclassified }
OptimizingVariableBinder >> lowerReadInstanceVar: aReadVariable binding: binding [
	| receiver index load |
	receiver := self definitionOf: #self.
	"	index := method classField indexOfSlot: name."
	index := binding index.
	load := OBinaryConstantOperation
		left: receiver
		right: index
		name: #_basicAt:.
	receiver addUse: load at: #left.
	aReadVariable dissolveReplacingWith: load
]

{ #category : #unclassified }
OptimizingVariableBinder >> lowerReadLiteral: aReadVariable binding: binding [
	| constant |
	constant := OLoadConstant valued: binding value.
	aReadVariable dissolveReplacingWith: constant
]

{ #category : #unclassified }
OptimizingVariableBinder >> lowerReadSelf: aReadVariable [
	| receiver |
	receiver := self definitionOf: #self.
	^aReadVariable replaceAllUsesWith: receiver; dissolve
]

{ #category : #unclassified }
OptimizingVariableBinder >> lowerReadTemporary: aReadVariable binding: binding [
	| source |
	source := self definitionOf: binding name asSymbol in: currentBlock.
	source
		ifNil: [pendingReads add: aReadVariable -> currentBlock]
		ifNotNil: [aReadVariable replaceAllUsesWith: source; dissolve]
]

{ #category : #unclassified }
OptimizingVariableBinder >> lowerWriteAssociation: aWriteVariable binding: binding [
	| global write |
	global := OLoadConstant valued: binding association.
	write := OTernaryOperation
		receiver: global
		left: 1
		right: aWriteVariable source
		name: #_basicAt:put:.
	global addUse: write at: #receiver.
	aWriteVariable source addUse: write at: #right.
	aWriteVariable beforeInsert: global; dissolveReplacingWith: write
]

{ #category : #unclassified }
OptimizingVariableBinder >> lowerWriteInstanceVar: aWriteVariable binding: binding [
	| this write |
	this := self definitionOf: #self.
	write := OTernaryOperation
		receiver: this
		left: binding index
		right: aWriteVariable source
		name: #_basicAt:put:.
	this addUse: write at: #receiver.
	aWriteVariable source addUse: write at: #right.
	aWriteVariable dissolveReplacingWith: write
]

{ #category : #unclassified }
OptimizingVariableBinder >> lowerWriteTemporary: aWriteVariable binding: binding [
	self define: aWriteVariable source as: binding name asSymbol.
	aWriteVariable dissolve.
	(dominanceFrontiers at: currentBlock)
		do: [:block | self insertPhiOf: binding name asSymbol at: block]
]

{ #category : #unclassified }
OptimizingVariableBinder >> resolvePendingReads [
	pendingReads do: [:association | | read block source |
		read := association key.
		block := association value.
		source := self definitionOf: read binding name asSymbol before: block.
		read replaceWithCopyOf: source]
]

{ #category : #unclassified }
OptimizingVariableBinder >> rewritePhis [
	pendingPhis do: [:association | | phi block |
		phi := association key.
		block := association value.
		(phi livesAfter: phi orOutOf: block)
			ifTrue: [
				block predecessors withIndexDo: [:predecessor :i | | name source |
					name := phi variables at: i.
					source := self definitionOf: name from: predecessor.
					phi variables at: i put: source.
					source addUse: phi at: predecessor]]
			ifFalse: [phi clearVariables; dissolve]]
]

{ #category : #unclassified }
OptimizingVariableBinder >> visitBinaryWithConstant: instruction [
	
]

{ #category : #unclassified }
OptimizingVariableBinder >> visitBinaryWithVariable: instruction [
	
]

{ #category : #unclassified }
OptimizingVariableBinder >> visitDefineArgument: instruction [
	self define: instruction as: instruction name
]

{ #category : #unclassified }
OptimizingVariableBinder >> visitJump: aJumpInstruction [
	
]

{ #category : #unclassified }
OptimizingVariableBinder >> visitJumpFalse: aJumpInstruction [
	
]

{ #category : #unclassified }
OptimizingVariableBinder >> visitJumpTrue: aJumpInstruction [
	
]

{ #category : #unclassified }
OptimizingVariableBinder >> visitLoadConstant: aLoadImplicit [
	
]

{ #category : #unclassified }
OptimizingVariableBinder >> visitMessageSend: aMessageSend [
	
]

{ #category : #unclassified }
OptimizingVariableBinder >> visitPhi: aPhi [
	
]

{ #category : #unclassified }
OptimizingVariableBinder >> visitReadVariable: aReadVariable [
	| binding |
	self ASSERT: (aReadVariable binding isKindOf: SBinding).
	binding := aReadVariable binding.
	binding isTemporary
		ifTrue: [ ^ self lowerReadTemporary: aReadVariable binding: binding ].
	binding isArgument
		ifTrue: [ ^ self lowerReadArgument: aReadVariable binding: binding ].
	binding isSelf
		ifTrue: [ ^ self lowerReadSelf: aReadVariable ].
	binding isLiteral
		ifTrue: [ ^ self lowerReadLiteral: aReadVariable binding: binding ].
	binding isInstVar
		ifTrue: [ ^ self lowerReadInstanceVar: aReadVariable binding: binding ].
	binding isAssociation
		ifTrue: [ ^ self lowerReadAssociaion: aReadVariable binding: binding ].
	self ASSERT: false
]

{ #category : #unclassified }
OptimizingVariableBinder >> visitReturn: aReturnInstruction [
	
]

{ #category : #unclassified }
OptimizingVariableBinder >> visitTernary: instruction [
	
]

{ #category : #unclassified }
OptimizingVariableBinder >> visitUnary: instruction [
	
]

{ #category : #unclassified }
OptimizingVariableBinder >> visitWriteVariable: aWriteVariable [
	| binding |
	binding := aWriteVariable binding.
	self ASSERT: (binding isKindOf: SBinding).
	binding isTemporary
		ifTrue: [ ^ self lowerWriteTemporary: aWriteVariable binding: binding ].
	binding isInstVar
		ifTrue: [ ^ self
				lowerWriteInstanceVar: aWriteVariable
				binding: binding ].
	binding isAssociation
		ifTrue:
			[ ^ self lowerWriteAssociation: aWriteVariable binding: binding ].
	self halt
]

{ #category : #accessing }
OptimizingVariableBinder >> wordSize [
	^abi wordSize
]

{ #category : #accessing }
OptimizingVariableBinder >> wordSizeShift [
	^abi wordSizeShift
]
