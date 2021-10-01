"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OptimizingBraunAllocator,
	#superclass : #Object,
	#instVars : [
		'firstBlock',
		'currentBlock',
		'loops',
		'liveness',
		'allocationEntry',
		'allocationExit',
		'distancesExit',
		'spillExit',
		'currentlyAvailable',
		'currentlySpilled',
		'temporaries',
		'amountOfRegisters',
		'scheduledSpills',
		'scheduledReloads',
		'blocksDone',
		'deferredCouplings'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #'instance creation' }
OptimizingBraunAllocator class >> new [
	^self basicNew initialize
]

{ #category : #initialization }
OptimizingBraunAllocator >> activationRecord [
	^firstBlock firstInstruction
]

{ #category : #initialization }
OptimizingBraunAllocator >> allocationEntry [
	^allocationEntry
]

{ #category : #initialization }
OptimizingBraunAllocator >> amountOfRegisters [
	^amountOfRegisters
]

{ #category : #initialization }
OptimizingBraunAllocator >> amountOfRegisters: amount [
	amountOfRegisters := amount
]

{ #category : #initialization }
OptimizingBraunAllocator >> areEqual: last and: distances [
	last size = distances size ifFalse: [^false].
	last keysAndValuesDo: [:key :value | | other |
		other := distances at: key ifAbsent: [^false].
		other = value ifFalse: [^false]].
	^true
]

{ #category : #initialization }
OptimizingBraunAllocator >> clobbersOneRegister: inst [
	^((inst isJump or: [inst isUnaryOperation and: [inst name == #push]])
		or: [inst isTernaryOperation and: [inst name = #_basicAt:put:]]) not
]

{ #category : #initialization }
OptimizingBraunAllocator >> computeEntryRegistersOf: block [
	(self isLoopHead: block)
		ifTrue: [self initLoopHeader: block]
		ifFalse: [self initUsual: block]
]

{ #category : #initialization }
OptimizingBraunAllocator >> computeLiveness [
	liveness := OptimizingLivenessAnalysis new
		firstBlock: firstBlock;
		loops: loops;
		analyzeLiveness
]

{ #category : #initialization }
OptimizingBraunAllocator >> computeLoops [
	loops := firstBlock allLoops
]

{ #category : #initialization }
OptimizingBraunAllocator >> computeTemporaryIndexes [
	| index |
	index := 1.
	scheduledSpills do: [:value | 
		temporaries at: value put: index.
		index := index + 1].
	self activationRecord temporaries: index - 1
]

{ #category : #initialization }
OptimizingBraunAllocator >> computeUseDistanceOf: instruction number: index using: distances [
	instruction operandsDo: [:operand | distances at: operand put: index].
	distances removeKey: instruction ifAbsent: []
]

{ #category : #initialization }
OptimizingBraunAllocator >> computeUseDistances [
	| distancesEntry changed |
	distancesEntry := IdentityDictionary new.
	changed := true.
	[changed] whileTrue: [
		changed := false.
		firstBlock withSuccessorsPostOrder
			do: [:block | changed := (self
				computeUseDistancesOf: block
				using: distancesEntry)
				or: changed]]
]

{ #category : #initialization }
OptimizingBraunAllocator >> computeUseDistancesOf: block using: distancesEntry [
	| distances index length |
	distances := IdentityDictionary new.
	length := block length.
	block successors do: [:succ | | incoming |
		incoming := distancesEntry at: succ ifAbsent: [Dictionary new].
		incoming keysAndValuesDo: [:operand :distance | | previous |
			previous := distances at: operand ifAbsent: Number infinity.
			distances at: operand put: (previous min: distance + length)].
		succ phisDo: [:phi | | operand previous |
			operand := phi atOperand: block.
			previous := distances at: operand ifAbsent: Number infinity.
			distances at: operand put: (previous min: length)]].
	distancesExit
		at: block
		ifPresent: [:last | (self areEqual: last and: distances) ifTrue: [^false]].
	distancesExit at: block put: distances copy.
	index := block indexOf: block lastInstruction.
	block lastInstruction realReverseDo: [:instruction | 
		self computeUseDistanceOf: instruction number: index using: distances.
		index := index - 1].
	distancesEntry at: block put: distances.
	^true
]

{ #category : #initialization }
OptimizingBraunAllocator >> couple: block withPredecessor: predecessor [
	| predecessors wentry oldSentry predWexit predSexit newSentry difference |
	predecessors := block predecessors intersection: blocksDone.
	predecessors removeIfPresent: block.
	wentry := allocationEntry at: block.
	oldSentry := (predecessors gather: [:pred | spillExit at: pred])
		intersection: wentry.
	predWexit := allocationExit at: predecessor.
	predSexit := spillExit at: predecessor.
	newSentry := (oldSentry , predSexit) withoutDuplicates intersection: wentry.
	(wentry rejectAll: predWexit) do: [:value | 
		(block phis includes: value)
			ifFalse: [self scheduleReload: value before: predecessor lastInstruction]].
	(newSentry rejectAll: predSexit) do: [:value | self scheduleSpillFor: value].
	difference := newSentry rejectAll: oldSentry.
	predecessors do: [:pred | | sexit |
		sexit := spillExit at: pred.
		(difference rejectAll: sexit) do: [:value | self scheduleSpillFor: value]]
]

{ #category : #initialization }
OptimizingBraunAllocator >> coupleWithPredecessors: block [
	| predecessors |
	predecessors := block predecessors intersection: blocksDone.
	currentlySpilled := (predecessors gather: [:pred | spillExit at: pred])
		intersection: currentlyAvailable.
	predecessors do: [:pred | | wexit sexit |
		wexit := allocationExit at: pred.
		(currentlyAvailable rejectAll: wexit) do: [:value | 
			(block phis includes: value)
				ifFalse: [self scheduleReload: value before: pred lastInstruction]].
		sexit := spillExit at: pred.
		(currentlySpilled rejectAll: sexit)
			do: [:value | self scheduleSpillFor: value]]
]

{ #category : #initialization }
OptimizingBraunAllocator >> deferCouplingOf: block [
	deferredCouplings add: block
]

{ #category : #initialization }
OptimizingBraunAllocator >> doAllocation [
	| redefinitions |
	self computeLoops; computeLiveness; computeUseDistances.
	firstBlock withSuccessorsPostOrder reverseDo: [:block | 
		currentBlock := block.
		self
			computeEntryRegistersOf: block;
			coupleWithPredecessors: block;
			spillAsBeladyIn: block.
		blocksDone add: block.
		block successors
			do: [:succ | (blocksDone includes: succ)
				ifTrue: [self couple: succ withPredecessor: block]]].
	redefinitions := self computeTemporaryIndexes; insertSpillsAndReloads.
	self reconstructSSA: redefinitions
]

{ #category : #initialization }
OptimizingBraunAllocator >> firstBlock [
	^firstBlock
]

{ #category : #initialization }
OptimizingBraunAllocator >> firstBlock: aBlock [
	firstBlock := aBlock
]

{ #category : #initialization }
OptimizingBraunAllocator >> initLoopHeader: block [
	| loop available candidates liveThrough pressure freeLoop extra |
	loop := loops at: block.
	available := (block phis , (self liveInOf: block)) withoutDuplicates.
	candidates := self subsetOf: available usedIn: loop.
	liveThrough := available rejectAll: candidates.
	candidates size < self amountOfRegisters
		ifTrue: [
			pressure := self maxPressureIn: loop.
			freeLoop := self amountOfRegisters - pressure + liveThrough size.
			self sortByUseDistance: liveThrough in: block firstInstruction.
			extra := liveThrough copyTo: freeLoop]
		ifFalse: [
			self sortByUseDistance: candidates in: block firstInstruction.
			candidates := candidates copyTo: self amountOfRegisters.
			extra := OrderedCollection new].
	currentlyAvailable := (candidates , extra) withoutDuplicates.
	allocationEntry at: block put: currentlyAvailable copy
]

{ #category : #initialization }
OptimizingBraunAllocator >> initUsual: block [
	| frequencies take max chosen candidates |
	frequencies := Dictionary new.
	take := OrderedCollection new.
	candidates := OrderedCollection new.
	max := block predecessors size.
	block predecessors do: [:pred | | wend |
		wend := allocationExit at: pred.
		wend do: [:value | | previous var |
			var := (block isPhiArgument: value)
				ifTrue: [
					(self is: value liveAt: block firstNonPhi) ifTrue: [
						previous := frequencies at: value ifAbsent: [0].
						frequencies at: value put: previous + 1.
						candidates addIfAbsent: value.
						(frequencies at: value) = max ifTrue: [
							candidates removeIfPresent: value.
							take addIfAbsent: value]].
					block phiWithArgument: value]
				ifFalse: [value].
			previous := frequencies at: var ifAbsent: [0].
			frequencies at: var put: previous + 1.
			candidates addIfAbsent: var.
			(frequencies at: var) = max ifTrue: [
				candidates removeIfPresent: var.
				take addIfAbsent: var]]].
	candidates := self selectAliveIn: candidates at: block firstInstruction.
	self sortByUseDistance: candidates in: block firstInstruction.
	take := self selectAliveIn: take at: block firstInstruction.
	chosen := candidates truncateTo: self amountOfRegisters - take size.
	take addAll: chosen.
	currentlyAvailable := take withoutDuplicates.
	allocationEntry at: block put: currentlyAvailable copy
]

{ #category : #initialization }
OptimizingBraunAllocator >> initialize [
	currentlyAvailable := OrderedCollection new.
	currentlySpilled := OrderedCollection new.
	amountOfRegisters := 5.
	scheduledReloads := OrderedCollection new.
	scheduledSpills := OrderedCollection new.
	blocksDone := Set new.
	allocationEntry := Dictionary new.
	allocationExit := Dictionary new.
	distancesExit := IdentityDictionary new.
	spillExit := Dictionary new.
	temporaries := Dictionary new.
	deferredCouplings := Set new
]

{ #category : #initialization }
OptimizingBraunAllocator >> insertReloadOf: value before: user [
	| stack index reload |
	stack := self activationRecord.
	index := self temporaryIndexOf: value.
	reload := OBinaryConstantOperation
		left: stack
		right: index
		name: #_basicAt:.
	stack addUse: reload at: #left.
	user
		beforeInsert: reload;
		replaceUsesOf: value with: reload.
	^reload
]

{ #category : #initialization }
OptimizingBraunAllocator >> insertSpillOf: value [
	| stack index store |
	stack := self activationRecord.
	index := self temporaryIndexOf: value.
	store := OTernaryOperation
		receiver: stack
		left: index
		right: value
		name: #_basicAt:put:.
	stack addUse: store at: #receiver.
	value addUse: store at: #right.
	value lastPhi afterInsert: store.
	liveness kill: store at: store
]

{ #category : #initialization }
OptimizingBraunAllocator >> insertSpillsAndReloads [
	| redefinitions |
	scheduledSpills do: [:value | self insertSpillOf: value].
	redefinitions := Dictionary new.
	scheduledReloads do: [:association | | value user reload collection |
		value := association key.
		user := association value.
		reload := self insertReloadOf: value before: user.
		collection := redefinitions at: value ifAbsentPut: [OrderedCollection new].
		collection add: reload].
	^redefinitions
]

{ #category : #initialization }
OptimizingBraunAllocator >> is: value liveAt: instruction [
	^(self useDistanceFrom: instruction to: value) != Number infinity
]

{ #category : #initialization }
OptimizingBraunAllocator >> isLoopHead: block [
	^loops includesKey: block
]

{ #category : #initialization }
OptimizingBraunAllocator >> limitAt: inst to: limit [
	| stack |
	self sortByUseDistance: currentlyAvailable in: inst.
	stack := self activationRecord.
	(currentlyAvailable includes: stack)
		ifTrue: [currentlyAvailable remove: stack; addFirst: stack].
	currentlyAvailable from: limit + 1 to: currentlyAvailable size do: [:value | 
		((currentlySpilled includes: value) not
			and: [(self useDistanceFrom: inst to: value) != Number infinity])
			ifTrue: [self scheduleSpillFor: value].
		currentlySpilled removeIfPresent: value].
	currentlyAvailable := currentlyAvailable truncateTo: limit
]

{ #category : #initialization }
OptimizingBraunAllocator >> liveInOf: block [
	^liveness liveInOf: block
]

{ #category : #accessing }
OptimizingBraunAllocator >> liveness [
	^liveness
]

{ #category : #initialization }
OptimizingBraunAllocator >> maxPressureIn: loop [
	^liveness maxPressureIn: loop
]

{ #category : #initialization }
OptimizingBraunAllocator >> reconstructSSA: reloads [
	| reconstructor |
	reconstructor := OptimizingSSAReconstructor new firstBlock: firstBlock.
	reloads
		keysAndValuesDo: [:variable :redefinitions | reconstructor
			setupFor: variable with: redefinitions;
			reconstructSSA]
]

{ #category : #initialization }
OptimizingBraunAllocator >> scheduleReload: value before: user [
	self haltWhen: value printString = '[send #classField to {#_basicAt:}]'.
	scheduledReloads add: value -> user
]

{ #category : #initialization }
OptimizingBraunAllocator >> scheduleSpillFor: value [
	scheduledSpills addIfAbsent: value
]

{ #category : #initialization }
OptimizingBraunAllocator >> selectAliveIn: collection at: instruction [
	^collection select: [:value | self is: value liveAt: instruction]
]

{ #category : #initialization }
OptimizingBraunAllocator >> sortByUseDistance: candidates in: inst [
	| stack |
	candidates
		sortBy: [:a :b | (self useDistanceFrom: inst to: a)
			< (self useDistanceFrom: inst to: b)].
	stack := self activationRecord.
	(candidates includes: stack)
		ifTrue: [candidates remove: stack; addFirst: stack]
]

{ #category : #initialization }
OptimizingBraunAllocator >> spillAsBeladyIn: block [
	| k |
	k := self amountOfRegisters.
	block realInstructionsDo: [:inst | | missing |
		missing := (inst operands rejectAll: currentlyAvailable)
			select: [:arg | self clobbersOneRegister: arg].
		missing do: [:use | 
			currentlyAvailable addIfAbsent: use.
			currentlySpilled addIfAbsent: use].
		self limitAt: inst to: k.
		inst isMessageSend ifTrue: [self limitAt: inst to: 1].
		(self clobbersOneRegister: inst) ifTrue: [
			self limitAt: inst next to: k - 1.
			currentlyAvailable add: inst].
		missing do: [:value | self scheduleReload: value before: inst]].
	allocationExit at: block put: currentlyAvailable copy.
	spillExit at: block put: currentlySpilled copy
]

{ #category : #initialization }
OptimizingBraunAllocator >> subsetOf: available usedIn: loop [
	"
	todo
	"
	^available
]

{ #category : #initialization }
OptimizingBraunAllocator >> temporaryIndexOf: value [
	^-1 - (temporaries at: value)
]

{ #category : #initialization }
OptimizingBraunAllocator >> useDistanceFrom: inst to: anotherInst [
	| near distances |
	near := inst useDistanceTo: anotherInst.
	^near = Number infinity
		ifTrue: [
			distances := distancesExit at: currentBlock.
			distances at: anotherInst ifAbsent: [Number infinity]]
		ifFalse: [near]
]
