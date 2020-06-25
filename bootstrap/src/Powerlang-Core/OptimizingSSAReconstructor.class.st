"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OptimizingSSAReconstructor,
	#superclass : #Object,
	#instVars : [
		'firstBlock',
		'variable',
		'reloads',
		'idoms',
		'iteratedFrontiers',
		'insertedPhis',
		'blocks'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #initialization }
OptimizingSSAReconstructor >> definitionInBlockFrom: instruction [
	instruction
		reverseDo: [:current | (variable == current
			or: [reloads includes: current])
			ifTrue: [^current]].
	^nil
]

{ #category : #initialization }
OptimizingSSAReconstructor >> firstBlock: block [
	firstBlock := block.
	idoms := firstBlock dominatorTree allImmediateDominators
]

{ #category : #initialization }
OptimizingSSAReconstructor >> insertPhiAt: block [
	^insertedPhis at: block ifAbsentPut: [| arguments phi predecessors |
		predecessors := block predecessors.
		arguments := predecessors collect: [:pred | | search |
			search := pred lastInstruction.
			self reachingDefinitionFrom: search at: pred].
		phi := OPhi withAll: arguments in: predecessors.
		arguments with: predecessors do: [:var :pred | var addUse: phi at: pred].
		block addFront: phi.
		phi]
]

{ #category : #initialization }
OptimizingSSAReconstructor >> reachingDefinitionFrom: instruction at: block [
	| current search |
	current := block.
	search := instruction.
	[| def |
		def := self definitionInBlockFrom: search.
		def ifNotNil: [^def].
		(iteratedFrontiers includes: current) ifTrue: [^self insertPhiAt: current].
		current := idoms at: current.
		search := current lastInstruction] repeat
]

{ #category : #initialization }
OptimizingSSAReconstructor >> reconstructSSA [
	| frontiers reloadBlocks uses |
	frontiers := firstBlock dominanceFrontiersUsing: idoms.
	reloadBlocks := reloads collect: [:reload | blocks at: reload].
	iteratedFrontiers := firstBlock
		iteratedDominanceFrontiersOf: reloadBlocks
		using: frontiers.
	uses := variable allUses.
	uses do: [:use | | search block def user |
		user := use user.
		user isPhi
			ifTrue: [
				block := use name.
				search := use name lastInstruction]
			ifFalse: [
				block := blocks at: user.
				search := user prev].
		def := self reachingDefinitionFrom: search at: block.
		use disolveReplacingWith: def]
]

{ #category : #initialization }
OptimizingSSAReconstructor >> setupFor: anInstruction with: redefinitions [
	| users |
	insertedPhis := Dictionary new.
	variable := anInstruction.
	reloads := redefinitions.
	blocks := Dictionary new.
	users := variable allUses collect: #user.
	firstBlock withSuccessorsDo: [:block | 
		block instructionsDo: [:instr | 
			((reloads includes: instr) or: [users includes: instr])
				ifTrue: [blocks at: instr put: block]]]
]
