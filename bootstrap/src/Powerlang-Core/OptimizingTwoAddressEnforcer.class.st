"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OptimizingTwoAddressEnforcer,
	#superclass : #Object,
	#instVars : [
		'allocation',
		'firstBlock'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> allocation: aDictionary [
	allocation := aDictionary
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> convert: instruction copyingLeftInto: dest [
	| load |
	load := OUnaryOperation receiver: instruction left name: #copy.
	instruction left addUse: load at: #receiver.
	instruction beforeInsert: load; left: load.
	allocation at: load put: dest
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> convert: instruction copyingReceiverInto: dest [
	| load |
	load := OUnaryOperation receiver: instruction receiver name: #copy.
	instruction receiver
		addUse: load at: #receiver;
		removeUse: instruction.
	instruction beforeInsert: load; receiver: load.
	allocation at: load put: dest
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> doEnforce [
	firstBlock
		withSuccessorsDo: [:block | block firstInstruction acceptVisitor: self]
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> firstBlock: block [
	firstBlock := block
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> insertCopy: instruction rightInto: dest [
	| load |
	load := OUnaryOperation receiver: instruction right name: #copy.
	instruction addUse: load at: #receiver.
	instruction afterInsert: load.
	allocation at: load put: dest
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> invertMinus: minus with: left with: right [
	| negate |
	negate := OUnaryOperation receiver: minus right name: #negate.
	minus beforeInsert: negate.
	allocation at: negate put: right.
	minus right
		removeUse: minus;
		addUse: negate at: #receiver.
	negate addUse: minus at: #right.
	minus right: negate; name: #'+'; swapOperands
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> visitBinaryWithConstant: instruction [
	| left dest |
	(#(_basicAt: _smallSize:) includes: instruction name) ifTrue: [^self].
	left := allocation at: instruction left.
	dest := allocation at: instruction.
	left == dest ifTrue: [^self].
	self convert: instruction copyingLeftInto: dest
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> visitBinaryWithVariable: instruction [
	| left right dest temp |
	left := allocation at: instruction left.
	right := allocation at: instruction right.
	dest := allocation at: instruction ifAbsent: [^self].
	left == dest ifTrue: [^self].
	right == dest ifTrue: [
		(#(< <= = == > >= _transferControlTo: _basicAt: _byteAt: _basicFlags: _smallSize: _extendedFlags:)
			includes: instruction name)
			ifTrue: [^self].
		instruction name == #'-'
			ifTrue: [^self invertMinus: instruction with: left with: right].
		(#(+ bitAnd: bitOr: &  ) includes: instruction name)
			ifTrue: [
				temp := instruction left.
				instruction left: instruction right.
				^instruction right: temp]
			ifFalse: [self halt]].
	self convert: instruction copyingLeftInto: dest
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> visitJump: instruction [
	
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> visitJumpFalse: instruction [
	
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> visitJumpTrue: instruction [
	
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> visitLoadConstant: instruction [
	
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> visitLoadImplicit: instruction [
	
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> visitMessageSend: instruction [
	
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> visitNullary: instruction [
	
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> visitPhi: instruction [
	
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> visitReturn: instruction [
	
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> visitTernary: instruction [
	| receiver left right dest |
	(#(_basicAt:put: _basicULongAt:put: _byteAt:put: _objectAtOffset:put:)
		includes: instruction name)
		ifTrue: [^self].
	receiver := allocation at: instruction receiver.
	left := allocation at: instruction left.
	right := allocation at: instruction right.
	dest := allocation at: instruction.
	right == dest ifTrue: [^self halt].
	self insertCopy: instruction rightInto: dest
]

{ #category : #unclassified }
OptimizingTwoAddressEnforcer >> visitUnary: instruction [
	| receiver dest |
	(#(_asNative _asObject _asPointer _asSmallInteger)
		includes: instruction name)
		ifFalse: [^self].
	receiver := allocation at: instruction receiver.
	dest := allocation at: instruction.
	receiver == dest ifTrue: [^self].
	self convert: instruction copyingReceiverInto: dest
]
