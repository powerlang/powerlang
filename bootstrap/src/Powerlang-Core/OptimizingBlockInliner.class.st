"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OptimizingBlockInliner,
	#superclass : #Object,
	#instVars : [
		'firstBlock'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #unclassified }
OptimizingBlockInliner >> doInline [
	self inlineInnerBlocksOf: firstBlock
]

{ #category : #unclassified }
OptimizingBlockInliner >> inline: aMessageSend in: block [
	^self performInlinerFor: aMessageSend in: block
]

{ #category : #unclassified }
OptimizingBlockInliner >> inlineAnd: message in: block [
	| closure firstSkipped lastSkipped join |
	closure := message arguments first.
	firstSkipped := closure firstBlock.
	self inlineInnerBlocksOf: firstSkipped.
	lastSkipped := firstSkipped lastBlock.
	join := block splitAfter: message.
	join
		insertPhiOf: message receiver
		at: block
		and: lastSkipped
		replacing: message.
	block endWithJumpFalseTo: join skipping: firstSkipped if: message receiver.
	lastSkipped endWithJumpTo: join.
	firstSkipped addPredecessor: block.
	join addPredecessor: block; addPredecessor: lastSkipped.
	^join
]

{ #category : #unclassified }
OptimizingBlockInliner >> inlineIfFalse: message in: block [
	| closure firstSkipped lastSkipped join |
	closure := message arguments first.
	firstSkipped := closure firstBlock.
	self inlineInnerBlocksOf: firstSkipped.
	lastSkipped := firstSkipped lastBlock.
	join := block splitAfter: message.
	block endWithJumpTrueTo: join skipping: firstSkipped if: message receiver.
	lastSkipped endWithJumpTo: join.
	firstSkipped addPredecessor: block.
	join addPredecessor: lastSkipped; addPredecessor: block.
	message dissolve.
	^join
]

{ #category : #unclassified }
OptimizingBlockInliner >> inlineIfTrue: message in: block [
	| closure firstSkipped lastSkipped join |
	closure := message arguments first.
	firstSkipped := closure firstBlock.
	self inlineInnerBlocksOf: firstSkipped.
	lastSkipped := firstSkipped lastBlock.
	join := block splitAfter: message.
	block endWithJumpFalseTo: join skipping: firstSkipped if: message receiver.
	lastSkipped endWithJumpTo: join.
	firstSkipped addPredecessor: block.
	join addPredecessor: lastSkipped; addPredecessor: block.
	message dissolve.
	^join
]

{ #category : #unclassified }
OptimizingBlockInliner >> inlineIfTrueifFalse: message in: block [
	| positive negative firstTrue firstFalse lastTrue lastFalse join |
	positive := message arguments first.
	negative := message arguments second.
	firstTrue := positive firstBlock.
	firstFalse := negative firstBlock.
	self inlineInnerBlocksOf: firstTrue and: firstFalse.
	lastTrue := firstTrue lastBlock.
	lastFalse := firstFalse lastBlock.
	join := block splitAfter: message.
	join insertPhiOf: lastTrue and: lastFalse replacing: message.
	block
		endWithJumpFalseTo: firstFalse
		skipping: firstTrue
		if: message receiver.
	lastTrue endWithJumpTo: join.
	lastFalse endWithJumpTo: join.
	firstTrue addPredecessor: block.
	firstFalse addPredecessor: block.
	join addPredecessor: lastTrue; addPredecessor: lastFalse.
	^join
]

{ #category : #unclassified }
OptimizingBlockInliner >> inlineInnerBlocksOf: basicBlock [
	| currentBlock |
	currentBlock := basicBlock.
	basicBlock instructionsDo: [:instruction | 
		(self shouldInline: instruction)
			ifTrue: [currentBlock := self inline: instruction in: currentBlock]]
]

{ #category : #unclassified }
OptimizingBlockInliner >> inlineInnerBlocksOf: basicBlock1 and: basicBlock2 [
	self inlineInnerBlocksOf: basicBlock1; inlineInnerBlocksOf: basicBlock2
]

{ #category : #unclassified }
OptimizingBlockInliner >> inlineInnerBlocksOf: basicBlock1 and: basicBlock2 and: basicBlock3 [
	self
		inlineInnerBlocksOf: basicBlock1;
		inlineInnerBlocksOf: basicBlock2;
		inlineInnerBlocksOf: basicBlock3
]

{ #category : #unclassified }
OptimizingBlockInliner >> inlineOr: message in: block [
	| closure firstSkipped lastSkipped join |
	closure := message arguments first.
	firstSkipped := closure firstBlock.
	self inlineInnerBlocksOf: firstSkipped.
	lastSkipped := firstSkipped lastBlock.
	join := block splitAfter: message.
	join
		insertPhiOf: message receiver
		at: block
		and: lastSkipped
		replacing: message.
	block endWithJumpTrueTo: join skipping: firstSkipped if: message receiver.
	lastSkipped endWithJumpTo: join.
	firstSkipped addPredecessor: block.
	join addPredecessor: block; addPredecessor: lastSkipped.
	^join
]

{ #category : #unclassified }
OptimizingBlockInliner >> inlineWhileTrue: message in: block [
	| antecedent consequent firstAntecedent firstConsequent lastAntecedent lastConsequent join |
	antecedent := message receiver.
	consequent := message arguments first.
	firstAntecedent := antecedent firstBlock.
	firstConsequent := consequent firstBlock.
	self inlineInnerBlocksOf: firstAntecedent and: firstConsequent.
	lastAntecedent := firstAntecedent lastBlock.
	lastConsequent := firstConsequent lastBlock.
	join := block splitAfter: message.
	block endWithJumpTo: firstAntecedent.
	lastAntecedent
		endWithJumpFalseTo: join
		skipping: firstConsequent
		if: lastAntecedent lastValue.
	lastConsequent endWithJumpTo: firstAntecedent.
	message dissolve.
	firstAntecedent addPredecessor: block; addPredecessor: lastConsequent.
	firstConsequent addPredecessor: lastAntecedent.
	join addPredecessor: lastAntecedent.
	^join
]

{ #category : #unclassified }
OptimizingBlockInliner >> inliners [
	^#(ifTrue: ifFalse: ifTrue:ifFalse: ifFalse:ifTrue: and: or: to:do: whileTrue:)
]

{ #category : #unclassified }
OptimizingBlockInliner >> on: block [
	firstBlock := block
]

{ #category : #private }
OptimizingBlockInliner >> performInlinerFor: messageSend in: block [
	| selector inliner |
	selector := messageSend selector asString copyWithout: $:.
	inliner := #inline , selector capitalized , ':in:'.
	^self perform: inliner asSymbol with: messageSend with: block
]

{ #category : #unclassified }
OptimizingBlockInliner >> shouldInline: anInstruction [
	^anInstruction isMessageSend
		and: [self inliners includes: anInstruction selector]
]
