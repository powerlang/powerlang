"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OJumpConditional,
	#superclass : #OInstruction,
	#instVars : [
		'variable',
		'target',
		'implicitTarget'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OJumpConditional class >> variable: operation target: explicitTarget implicitTarget: implicitTarget [
	^self new
		variable: operation;
		target: explicitTarget;
		implicitTarget: implicitTarget
]

{ #category : #unclassified }
OJumpConditional >> atOperand: name [
	^variable
]

{ #category : #unclassified }
OJumpConditional >> atOperand: name put: instruction [
	variable := instruction
]

{ #category : #unclassified }
OJumpConditional >> implicitTarget [
	^implicitTarget
]

{ #category : #unclassified }
OJumpConditional >> implicitTarget: aBasicBlock [
	implicitTarget := aBasicBlock
]

{ #category : #unclassified }
OJumpConditional >> isConditionalJump [
	^true
]

{ #category : #unclassified }
OJumpConditional >> isJump [
	^true
]

{ #category : #unclassified }
OJumpConditional >> operandsDo: aBlock [
	aBlock value: variable
]

{ #category : #unclassified }
OJumpConditional >> replaceWithUnconditional: condition in: basicBlock [
	| fixed removed jump |
	self isJumpTrue == condition
		ifTrue: [
			fixed := target.
			removed := implicitTarget]
		ifFalse: [
			fixed := implicitTarget.
			removed := target].
	jump := OJump to: fixed.
	self dissolveReplacingWith: jump.
	removed fullyRemovePredecessor: basicBlock
]

{ #category : #unclassified }
OJumpConditional >> retargetFrom: aBasicBlock to: otherBasicBlock [
	target == aBasicBlock ifTrue: [target := otherBasicBlock].
	implicitTarget == aBasicBlock ifTrue: [implicitTarget := otherBasicBlock]
]

{ #category : #unclassified }
OJumpConditional >> target [
	^target
]

{ #category : #unclassified }
OJumpConditional >> target: aBasicBlock [
	target := aBasicBlock
]

{ #category : #unclassified }
OJumpConditional >> targets [
	^OrderedCollection with: implicitTarget with: target
]

{ #category : #unclassified }
OJumpConditional >> usesResultOf: anInstruction [
	^variable == anInstruction
]

{ #category : #unclassified }
OJumpConditional >> variable [
	^variable
]

{ #category : #unclassified }
OJumpConditional >> variable: operand [
	variable := operand
]
