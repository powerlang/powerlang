"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OptimizingInstructionFragmenter,
	#superclass : #Object,
	#instVars : [
		'method',
		'messages',
		'firstBlock',
		'abi'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #unclassified }
OptimizingInstructionFragmenter class >> new [
	^self basicNew initialize
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> abi: anAbi [
	abi := anAbi
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> activationRecord [
	^firstBlock firstInstruction
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> doFragment [
	self
		fragmentActivationRecordDeclaration;
		fragmentSelfDeclaration;
		fragmentSpecialABIArguments;
		fragmentNormalArguments.
	firstBlock
		reversePostOrderDo: [:block | self fragmentInstructionsOf: block]
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> firstBlock: aBasicBlock [
	firstBlock := aBasicBlock
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> fragmentActivationRecordDeclaration [
	| declaration implicit |
	declaration := firstBlock firstInstruction.
	implicit := OActivationContext named: #activationRecord.
	implicit source: abi regFP.
	declaration dissolveReplacingWith: implicit
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> fragmentBinaryCommutative: instruction [
	| left right |
	left := instruction receiver.
	right := instruction arguments first.
	right isConstant
		ifTrue: [^self replace: instruction withBinary: left withConstant: right].
	left isConstant
		ifTrue: [^self replace: instruction withBinary: right withConstant: left].
	self replace: instruction withVariable: left with: right
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> fragmentBinaryCompare: instruction [
	| left right new |
	left := instruction receiver.
	right := instruction arguments first.
	right isConstant
		ifTrue: [^self replace: instruction withBinary: left withConstant: right].
	left isConstant ifTrue: [
		new := self replace: instruction withBinary: right withConstant: left.
		^new invertOperation].
	self replace: instruction withVariable: left with: right
]

{ #category : #private }
OptimizingInstructionFragmenter >> fragmentBinaryNonCommutative: instruction [
	| left right |
	left := instruction receiver.
	right := instruction arguments first.
	right isConstant
		ifTrue: [^self replace: instruction withBinary: left withConstant: right].
	self replace: instruction withVariable: left with: right
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> fragmentCallSite: instruction [
	| callsite |
	callsite := OBinaryConstantOperation
		left: self activationRecord
		right: 2
		name: #_basicAt:.
	self activationRecord addUse: callsite at: #left.
	instruction dissolveReplacingWith: callsite
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> fragmentGenericMessage: instruction [
	| arguments new push |
	arguments := instruction arguments.
	new := arguments	withIndexCollect: [:argument :i | 
			push := self insertPush: argument before: instruction.
			push addUse: instruction at: i].
	instruction arguments: new.
	arguments
		do: [:argument | argument removeUse: instruction; dissolveIfUnused].
	firstBlock activationRecord haveFrame
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> fragmentInstructionsOf: block [
	block firstInstruction acceptVisitor: self
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> fragmentNormalArguments [
	| count argument position context |
	count := 0.
	context := firstBlock firstInstruction.
	argument := context next next.
	[argument isDefineArgument] whileTrue: [
		argument := argument next.
		count := count + 1].
	argument := argument prev.
	position := 0.
	[position < count] whileTrue: [| new next |
		argument isUsed
			ifTrue: [
				new := OBinaryConstantOperation
					left: context
					right: position + 3
					name: #_basicAt:.
				context addUse: new at: #left.
				argument dissolveReplacingWith: new.
				argument := new prev]
			ifFalse: [
				next := argument prev.
				argument dissolve.
				argument := next].
		position := position + 1]
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> fragmentNot: instruction [
	| negated |
	negated := instruction receiver halt shallowCopy.
	negated negateOperation.
	negated left addUse: negated at: #left.
	negated right addUse: negated at: #right.
	instruction dissolveReplacingWith: negated.
	instruction receiver dissolveIfUnused
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> fragmentPatchIndirectCallSiteTo: instruction [
	| nativeCode callsite patch |
	nativeCode := instruction arguments first.
	callsite := OBinaryConstantOperation
		left: self activationRecord
		right: 2
		name: #_basicAt:.
	patch := OTernaryOperation
		receiver: callsite
		left: 0
		right: nativeCode
		name: #_basicAt:put:.
	self activationRecord addUse: callsite at: #left.
	callsite addUse: patch at: #receiver.
	nativeCode addUse: patch at: #right.
	instruction dissolveReplacingWith: patch.
	patch beforeInsert: callsite
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> fragmentSelfDeclaration [
	| declaration implicit |
	declaration := firstBlock firstInstruction next.
	implicit := OLoadImplicit named: #self.
	declaration dissolveReplacingWith: implicit
]

{ #category : #private }
OptimizingInstructionFragmenter >> fragmentSpecialABIArguments [
	| literals i actual next load ast names index |
	literals := method literals.
	literals size = 0
		ifTrue: [ ^ self ].
	(literals at: 1) == #savePreviousSelf
		ifTrue: [ firstBlock activationRecord doSavePreviousSelf.
			load := firstBlock firstInstruction
				detect: [ :inst | inst isConstant ].
			load dissolve.
			literals := literals beeCopyFrom: 2 ].
	literals size = 0
		ifTrue: [ ^ self ].
	(literals at: 1) == #specialABIBegin
		ifFalse: [ ^ self ].
	i := 3.
	ast := SCompiler parse: method source lines first in: nil.
	names := ast arguments collect: #name.
	[ (literals at: i) == #specialABIEnd ]
		whileFalse: [ | name register implicit argument receiver regname |
			name := literals at: i.
			regname := literals at: i + 1.
			register := self registerNamed: regname.
			name = #self
				ifTrue: [ receiver := firstBlock firstInstruction
						detect:
							[ :instruction | instruction isLoadImplicit and: [ instruction name = #self ] ].
					receiver source: register ]
				ifFalse: [ implicit := (OLoadImplicit named: name) source: register.
					index := names indexOf: name.
					argument := firstBlock firstInstruction
						detect:
							[ :instruction | instruction isDefineArgument and: [ instruction name = index asString ] ].
					argument dissolveReplacingWith: implicit ].
			i := i + 2 ].
	actual := firstBlock firstInstruction
		detect: [ :inst | inst isConstant ].
	[ next := actual next.
	actual dissolve.
	actual isConstant and: [ actual value == #specialABIEnd ] ]
		whileFalse: [ actual := next ]
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> fragmentTernary: instruction [
	| receiver left right new |
	receiver := instruction receiver.
	left := instruction arguments first.
	right := instruction arguments second.
	new := OTernaryOperation
		receiver: receiver
		left: left
		right: right
		name: instruction selector.
	receiver addUse: new at: #receiver.
	left addUse: new at: #left.
	right addUse: new at: #right.
	self
		ASSERT: (#(_basicAt:put: _basicULongAt:put:     _byteAt:put: _objectAtOffset:put:)
			includes: new name).
	instruction replaceAllUsesWith: right; dissolveReplacingWith: new
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> fragmentTransferControlTo: instruction [
	| receiver machine |
	receiver := instruction receiver.
	machine := instruction arguments first.
	self replace: instruction withVariable: receiver with: machine
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> fragmentUnary: instruction [
	| receiver new |
	receiver := instruction receiver.
	"	receiver isConstant ifTrue: [self halt]."
	new := OUnaryOperation new receiver: receiver; name: instruction selector.
	receiver addUse: new at: #receiver.
	instruction dissolveReplacingWith: new
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> initialize [
	self initializeMessages
]

{ #category : #initialization }
OptimizingInstructionFragmenter >> initializeMessages [
	messages := Dictionary new
		at: #'+' put: #BinaryCommutative:;
		at: #'-' put: #BinaryNonCommutative:;
		at: #'*' put: #BinaryCommutative:;
		at: #'//' put: #BinaryNonCommutative:;
		at: #'<' put: #BinaryCompare:;
		at: #'<=' put: #BinaryCompare:;
		at: #'=' put: #BinaryCompare:;
		at: #'==' put: #BinaryCompare:;
		at: #'~=' put: #BinaryCompare:;
		at: #'!=' put: #BinaryCompare:;
		at: #'>=' put: #BinaryCompare:;
		at: #'>' put: #BinaryCompare:;
		at: #'&' put: #BinaryCommutative:;
		at: #_asNative put: #Unary:;
		at: #_asObject put: #Unary:;
		at: #_asPointer put: #Unary:;
		at: #_asSmallInteger put: #Unary:;
		at: #bitAnd: put: #BinaryCommutative:;
		at: #bitOr: put: #BinaryCommutative:;
		at: #bitShift: put: #BinaryNonCommutative:;
		at: #_byteAt: put: #BinaryNonCommutative:;
		at: #_basicAt: put: #BinaryNonCommutative:;
		at: #_basicULongAt: put: #BinaryNonCommutative:;
		at: #_byteAt:put: put: #Ternary:;
		at: #_basicAt:put: put: #Ternary:;
		at: #_basicULongAt:put: put: #Ternary:;
		at: #_objectAtOffset:put: put: #Ternary:;
		at: #_basicFlags put: #Unary:;
		at: #_basicFlags: put: #BinaryNonCommutative:;
		at: #_smallSize put: #Unary:;
		at: #_smallSize: put: #BinaryNonCommutative:;
		at: #_largeSize put: #Unary:;
		at: #_largeSize: put: #BinaryNonCommutative:;
		at: #_isSmallInteger put: #Unary:;
		at: #_transferControlTo: put: #TransferControlTo:;
		at: #_callSite put: #CallSite:;
		at: #_patchIndirectCallSiteTo: put: #PatchIndirectCallSiteTo:;
		at: #not put: #Not:;
		yourself
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> insertCopyResultAfter: anInstruction [
	| copy |
	copy := OUnaryOperation receiver: anInstruction name: #copyResult.
	anInstruction
		afterInsert: copy;
		replaceAllUsesWith: copy;
		addUse: copy at: #receiver
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> insertPush: anInstruction before: instruction [
	| push |
	push := OUnaryOperation receiver: anInstruction name: #push.
	anInstruction addUse: push at: #receiver.
	instruction beforeInsert: push.
	^push
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> method: anSCompiledMethod [
	method := anSCompiledMethod
]

{ #category : #private }
OptimizingInstructionFragmenter >> registerNamed: regname [
	^abi perform: regname
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> replace: instruction withBinary: left withConstant: right [
	| constant new |
	constant := right value.
	new := OBinaryConstantOperation
		left: left
		right: constant
		name: instruction selector.
	left addUse: new at: #left.
	instruction dissolveReplacingWith: new.
	^new
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> replace: instruction withVariable: left with: right [
	| new |
	new := OBinaryVariableOperation
		left: left
		right: right
		name: instruction selector.
	left addUse: new at: #left.
	right addUse: new at: #right.
	instruction dissolveReplacingWith: new.
	^new
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> selectorFor: name [
	^(#fragment , (messages at: name ifAbsent: [#GenericMessage:])) asSymbol
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> visitBinaryWithConstant: instruction [
	
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> visitBinaryWithVariable: instruction [
	
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> visitDefineArgument: instruction [
	
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> visitJump: instruction [
	
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> visitJumpFalse: instruction [
	
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> visitJumpTrue: instruction [
	
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> visitLoadConstant: instruction [
	
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> visitLoadImplicit: instruction [
	
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> visitMessageSend: instruction [
	| selector |
	selector := self selectorFor: instruction selector.
	self perform: selector with: instruction
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> visitPhi: instruction [
	
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> visitReturn: instruction [
	
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> visitTernary: instruction [
	
]

{ #category : #unclassified }
OptimizingInstructionFragmenter >> visitUnary: instruction [
	
]
