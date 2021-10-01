"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OptimizingLivenessAnalysis,
	#superclass : #Object,
	#instVars : [
		'firstBlock',
		'liveIn',
		'liveOut',
		'loops',
		'pressures',
		'expirations'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #'instance creation' }
OptimizingLivenessAnalysis class >> new [
	^self basicNew initialize
]

{ #category : #private }
OptimizingLivenessAnalysis >> analyzeLiveness [
	| changed all |
	liveIn := Dictionary new.
	pressures := Dictionary new.
	expirations := Dictionary new.
	changed := true.
	all := firstBlock withSuccessorsPostOrder.
	[changed] whileTrue: [
		changed := false.
		all do: [:block | changed := (self analyzeLivenessOf: block) or: changed]].
	all do: [:block | self computeExpirationsAt: block]
]

{ #category : #private }
OptimizingLivenessAnalysis >> analyzeLivenessOf: block [
	| alive last changed pressure |
	self haltWhen: block hash = 46528.
	alive := self gatherAliveAfter: block.
	self
		haltWhen: (alive
			anySatisfy: [:value | value printString
				beginsWith: '[53422] [jump to #45650]']).
	pressure := pressures at: block ifAbsentPut: [0].
	last := block lastInstruction.
	last realReverseDo: [:instr | | presure |
		instr operandsDo: [:value | 
			self haltWhen: (value printString beginsWith: '[53422] [jump to #45650]').
			alive addIfAbsent: value].
		alive removeIfPresent: instr.
		pressure := presure max: alive size].
	block phis reverseDo: [:phi | alive removeIfPresent: phi].
	pressures at: block put: pressure.
	changed := true.
	liveIn
		at: block ifPresent: [:prev | changed := prev size != alive size];
		at: block put: alive.
	^changed
]

{ #category : #private }
OptimizingLivenessAnalysis >> computeExpirationsAt: block [
	| alive last |
	alive := self gatherAliveAfter: block.
	last := block lastInstruction.
	last isConditionalJump ifTrue: [
		block successors do: [:succ | | real leftover |
			real := liveIn at: succ.
			leftover := alive rejectAll: real.
			leftover do: [:val | self kill: val at: succ firstInstruction]]].
	last realReverseDo: [:instr | self computeExpirationsAt: instr with: alive]
]

{ #category : #private }
OptimizingLivenessAnalysis >> computeExpirationsAt: instruction with: alive [
	instruction operandsDo: [:value | 
		(alive includes: value) ifFalse: [self kill: value at: instruction].
		alive addIfAbsent: value].
	(alive includes: instruction)
		ifTrue: [alive remove: instruction]
		ifFalse: [self kill: instruction at: instruction]
]

{ #category : #private }
OptimizingLivenessAnalysis >> does: operand dieAt: instruction [
	| dying |
	dying := expirations at: instruction ifAbsent: [^false].
	^dying includes: operand
]

{ #category : #private }
OptimizingLivenessAnalysis >> firstBlock: aBlock [
	firstBlock := aBlock
]

{ #category : #private }
OptimizingLivenessAnalysis >> gatherAliveAfter: block [
	| incoming extra |
	incoming := block successors
		gather: [:succ | liveIn at: succ ifAbsent: [OrderedCollection new]].
	extra := block successors gather: [:succ | succ phiValuesComingFrom: block].
	^(incoming , extra) withoutDuplicates
]

{ #category : #private }
OptimizingLivenessAnalysis >> initialize [
	
]

{ #category : #private }
OptimizingLivenessAnalysis >> kill: value at: instruction [
	| collection |
	collection := expirations
		at: instruction
		ifAbsentPut: [OrderedCollection new].
	collection addIfAbsent: value
]

{ #category : #initialization }
OptimizingLivenessAnalysis >> liveInOf: block [
	^liveIn at: block
]

{ #category : #private }
OptimizingLivenessAnalysis >> loops: aDictionary [
	loops := aDictionary
]

{ #category : #initialization }
OptimizingLivenessAnalysis >> maxPressureIn: loopBlocks [
	| all |
	all := loopBlocks collect: [:block | pressures at: block].
	^all max
]
