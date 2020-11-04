Class {
	#name : #InlinedMessageNativizer,
	#superclass : #Object,
	#instVars : [
		'message',
		'assembler',
		'nativizer',
		'start',
		'end'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #accessing }
InlinedMessageNativizer >> assembler: anAssembler [
	assembler := anAssembler 
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineAnd [
	| skip conditions |
	skip := assembler newLabel.
	conditions := Array
		with: message receiver
		withAll: message arguments allButLast.
	conditions do: [ :c | self inlineAndCondition: c skip: skip ].
	message arguments last statements
		do: [ :s | s acceptVisitor: nativizer ].
	assembler @ skip
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineAndCondition: anSExpression skip: skip [
	| retry failed |
	retry := assembler newLabel.
	failed := assembler newLabel.
	anSExpression acceptVisitor: nativizer.
	assembler
		@ retry;
		compareRwithFalse;
		jumpIfEqualTo: skip;
		compareRwithTrue;
		jumpIfNotEqualTo: failed.
	nativizer
		addFallback: [ assembler @ failed.
			nativizer sendMustBeBoolean.
			assembler jumpTo: retry ]
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineAndNot [
	| skip conditions |
	skip := assembler newLabel.
	conditions := Array
		with: message receiver
		withAll: message arguments allButLast.
	conditions do: [ :c | self inlineAndCondition: c skip: skip ].
	message arguments last statements
		do: [ :s | s acceptVisitor: nativizer ].
	self negateBoolean.
assembler		@ skip
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineBinaryWhile: aBoolean [
	| retry failed block continue |
	start := assembler newLabel.
	retry := assembler newLabel.
	failed := assembler newLabel.
	block := assembler newLabel.
	continue := assembler newLabel.
	assembler
		alignTo: 16;
		@ start.
	message receiver statements do: [ :s | s acceptVisitor: nativizer ].
	assembler
		@ retry;
		compareRwithBoolean: aBoolean;
		jumpIfEqualTo: block;
		compareRwithBoolean: aBoolean not;
		jumpIfNotEqualTo: failed;
		@ block.
	message arguments first statements
		do: [ :s | s acceptVisitor: nativizer ].
	assembler
		jumpTo: start;
		@ continue.
	nativizer
		addFallback: [ assembler @ failed.
			nativizer sendMustBeBoolean.
			assembler jumpTo: retry ]
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineBranchIf: aBoolean [
	| retry failed first second |
	retry := assembler newLabel.
	failed := assembler newLabel.
	end := assembler newLabel.
	message receiver acceptVisitor: nativizer.
	first := aBoolean not.
	second := aBoolean.
	assembler
		@ retry;
		loadAwithR;
		loadRwithNil;
		compareAwithBoolean: first;
		jumpIfEqualTo: end;
		compareAwithBoolean: second;
		jumpIfNotEqualTo: failed.
	message arguments first statements
		do: [ :s | s acceptVisitor: nativizer ].
	assembler @ end.
	nativizer
		addFallback: [ assembler @ failed; loadRwithA.
			nativizer sendMustBeBoolean.
			assembler jumpTo: retry ]
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineBranchIfNil: aBoolean [

	end := assembler newLabel.
	message receiver acceptVisitor: nativizer.
	assembler
		compareRwithNil.
	aBoolean
		ifTrue: [ assembler jumpIfNotEqualTo: end ]
		ifFalse: [ assembler jumpIfEqualTo: end ].
	message arguments first acceptVisitor: nativizer.
	assembler @ end
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineBranchIfNilIfNotNil: aBoolean [
	| second |
	second := assembler newLabel.
	end := assembler newLabel.
	message receiver acceptVisitor: nativizer.
	assembler compareRwithNil.
	aBoolean
		ifTrue: [ assembler jumpIfNotEqualTo: second ]
		ifFalse: [ assembler jumpIfEqualTo: second ].
	message arguments first acceptVisitor: nativizer.
	assembler
		jumpTo: end;
		@ second.
	message arguments first acceptVisitor: nativizer.
	assembler @ end
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineIfTrueIfFalse: aBoolean [
	| retry other failed first second |
	retry := assembler newLabel.
	other := assembler newLabel.
	failed := assembler newLabel.
	end := assembler newLabel.
	message receiver acceptVisitor: nativizer.
	first := aBoolean not.
	second := aBoolean.
	assembler
		@ retry;
		compareRwithBoolean: first;
		jumpIfEqualTo: other;
		compareRwithBoolean: second;
		jumpIfNotEqualTo: failed.
	message arguments first statements
		do: [ :s | s acceptVisitor: nativizer ].
	assembler
		jumpTo: end;
		@ other.
	message arguments second statements
		do: [ :s | s acceptVisitor: nativizer ].
	assembler @ end.
	nativizer
		addFallback: [ assembler @ failed.
			nativizer sendMustBeBoolean.
			assembler jumpTo: retry ]
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineMessage [
	| selector |
	selector := message selector.
	selector = #ifTrue:
		ifTrue: [ ^ self inlineBranchIf: true ].
	selector = #ifFalse:
		ifTrue: [ ^ self inlineBranchIf: false ].
	selector = #ifNil:
		ifTrue: [ ^ self inlineBranchIfNil: true ].
	selector = #ifNotNil:
		ifTrue: [ ^ self inlineBranchIfNil: false ].
	selector = #ifNil:ifNotNil:
		ifTrue: [ ^ self inlineBranchIfNilIfNotNil: true ].
	selector = #ifNil:ifNotNil:
		ifTrue: [ ^ self inlineBranchIfNilIfNotNil: false ].
	selector = #ifTrue:ifFalse:
		ifTrue: [ ^ self inlineIfTrueIfFalse: true ].
	selector = #ifFalse:ifTrue:
		ifTrue: [ ^ self inlineIfTrueIfFalse: false ].
	selector = #whileTrue
		ifTrue: [ ^ self inlineUnitaryWhile: true ].
	selector = #whileFalse
		ifTrue: [ ^ self inlineUnitaryWhile: false ].
	selector = #whileTrue:
		ifTrue: [ ^ self inlineBinaryWhile: true ].
	selector = #whileFalse:
		ifTrue: [ ^ self inlineBinaryWhile: false ].
	selector = #repeat
		ifTrue: [ ^ self inlineRepeat ].
	selector = #to:do:
		ifTrue: [ ^ self inlineToDo ].
	selector = #to:by:do:
		ifTrue: [ ^ self inlineToByDo].
	selector = #timesRepeat:
		ifTrue: [ ^ self inlineTimesRepeat ].
	(selector beginsWith: #or:)
		ifTrue: [ ^ self inlineOr ].
	(selector beginsWith: #and:)
		ifTrue: [ ^ self inlineAnd ].
	selector = #andNot:
		ifTrue: [ ^ self inlineAndNot ].
	selector = #orNot:
		ifTrue: [ ^ self inlineOrNot ].
	self ASSERT: false
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineOr [
	| skip conditions |
	skip := assembler newLabel.
	conditions := Array
		with: message receiver
		withAll: message arguments allButLast.
	conditions do: [ :c | self inlineOrCondition: c skip: skip ].
	message arguments last statements
		do: [ :s | s acceptVisitor: nativizer ].
	assembler @ skip
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineOrBlock: b skip: skip [
	| retry failed |
	retry := assembler newLabel.
	failed := assembler newLabel.
	b statements acceptVisitor: nativizer.
	assembler
		@ retry;
		compareRwithTrue;
		jumpIfEqualTo: skip;
		compareRwithFalse;
		jumpIfNotEqualTo: failed.
	nativizer
		addFallback: [ assembler @ failed.
			nativizer sendMustBeBoolean.
			assembler jumpTo: retry ]
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineOrCondition: anSExpression skip: skip [
	| retry failed |
	retry := assembler newLabel.
	failed := assembler newLabel.
	
	anSExpression acceptVisitor: nativizer.
	assembler
		@ retry;
		compareRwithTrue;
		jumpIfEqualTo: skip;
		compareRwithFalse;
		jumpIfNotEqualTo: failed.
	nativizer
		addFallback: [ assembler @ failed.
			nativizer sendMustBeBoolean.
			assembler jumpTo: retry ]
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineOrNot [
	| skip conditions |
	skip := assembler newLabel.
	conditions := Array
		with: message receiver
		withAll: message arguments allButLast.
	conditions do: [ :c | self inlineOrCondition: c skip: skip ].
	message arguments last statements
		do: [ :s | s acceptVisitor: nativizer ].
	self negateBoolean.
	assembler @ skip
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineRepeat [
	start := assembler newLabel.
	assembler
		alignTo: 16;
		@ start.
	message receiver statements do: [ :s | s acceptVisitor: nativizer ].
	assembler jumpTo: start
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineTimesRepeat [
	| head block continue nonInteger nonDecrementable current |
	head := assembler newLabel.
	block := assembler newLabel.
	continue := assembler newLabel.
	nonInteger := assembler newLabel.
	nonDecrementable := assembler newLabel.
	message receiver acceptVisitor: nativizer.
	current := nativizer pushR.
	assembler
		alignTo: 16;
		@ head;
		testIntegerBitOf: assembler regR8;
		jumpIfZeroTo: nonInteger;
		compareRwithSmallInteger: 0;
		jumpIfLessOrEqualSignedTo: continue;
		@ block.
	message arguments first statements
		do: [ :s | s acceptVisitor: nativizer ].
	nativizer loadRwithStack: current.
	assembler
		testIntegerBitOf: assembler regR8;
		jumpIfZeroTo: nonDecrementable;
		subFromRconstant: 2.
	nativizer storeRInStack: current.
	assembler
		jumpTo: head;
		@ continue.
	nativizer
		addFallback: [ assembler
				@ nonDecrementable;
				pushSmallInteger: 1.
			nativizer
				emitSend: #-;
				storeRInStack: current.
			assembler jumpTo: head ];
		addFallback: [ assembler
				@ nonInteger;
				pushSmallInteger: 0.
			nativizer emitSend: #>.
			assembler
				compareRwithTrue;
				jumpIfEqualTo: block;
				jumpTo: continue ]
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineToByDo [
	| head block continue nonInteger nonIncrementable overflow current limit by increment |
	head := assembler newLabel.
	block := assembler newLabel.
	continue := assembler newLabel.
	nonInteger := assembler newLabel.
	nonIncrementable := assembler newLabel.
	overflow := assembler newLabel.
	message receiver acceptVisitor: nativizer.
	current := message arguments third inlinedArgs first.
	nativizer temporaryInStackAtPut: current.
	message arguments first acceptVisitor: nativizer.
	limit := nativizer pushR.
	assembler loadAwithR.
	nativizer temporaryInStackAt: current.
	assembler
		alignTo: 16;
		@ head;
		testIntegerBitOf: assembler regA8;
		jumpIfZeroTo: nonInteger;
		testIntegerBitOf: assembler regR8;
		jumpIfZeroTo: nonInteger;
		compareRwithA.
	by := message arguments second value.
	by > 0
		ifTrue: [ assembler jumpIfGreaterSignedTo: continue ]
		ifFalse: [ assembler jumpIfLessSignedTo: continue ].
	increment := (assembler smallInteger: by) - 1.
	assembler @ block.
	message arguments third statements
		do: [ :s | s acceptVisitor: nativizer ].
	nativizer temporaryInStackAt: current.
	assembler
		testIntegerBitOf: assembler regR8;
		jumpIfZeroTo: nonIncrementable;
		addRconstant: increment;
		jumpIfOverflowTo: overflow.
	nativizer
		temporaryInStackAtPut: current;
		loadAwithStack: limit.
	assembler
		jumpTo: head;
		@ continue.
	nativizer
		addFallback: [ assembler
				@ overflow;
				subFromRconstant: increment;
				@ nonIncrementable;
				pushSmallInteger: 1.
			nativizer
				emitSend: #+;
				temporaryInStackAtPut: current;
				loadAwithStack: limit.
			assembler jumpTo: head ];
		addFallback: [ assembler
				@ nonInteger;
				pushA.
			nativizer emitSend: #<=.
			assembler
				compareRwithTrue;
				jumpIfEqualTo: block;
				jumpTo: continue ]
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineToDo [
	| head block continue nonInteger nonIncrementable overflow current limit |
	head := assembler newLabel.
	block := assembler newLabel.
	continue := assembler newLabel.
	nonInteger := assembler newLabel.
	nonIncrementable := assembler newLabel.
	overflow := assembler newLabel.
	message receiver acceptVisitor: nativizer.
	current := message arguments second inlinedArgs first.
	nativizer temporaryInStackAtPut: current.
	message arguments first acceptVisitor: nativizer.
	limit := nativizer pushR.
	assembler loadAwithR.
	nativizer temporaryInStackAt: current.
	assembler
		alignTo: 16;
		@ head;
		testIntegerBitOf: assembler regA8;
		jumpIfZeroTo: nonInteger;
		testIntegerBitOf: assembler regR8;
		jumpIfZeroTo: nonInteger;
		compareRwithA;
		jumpIfGreaterOrEqualSignedTo: continue;
		@ block.
	message arguments second statements
		do: [ :s | s acceptVisitor: nativizer ].
	nativizer temporaryInStackAt: current.
	assembler
		testIntegerBitOf: assembler regA8;
		jumpIfZeroTo: nonIncrementable;
		addRconstant: 2;
		jumpIfOverflowTo: overflow.
	nativizer
		temporaryInStackAtPut: current;
		loadAwithStack: limit.
	assembler
		jumpTo: head;
		@ continue.
	nativizer
		addFallback: [ assembler
				@ overflow;
				subFromRconstant: 2;
				@ nonIncrementable;
				pushSmallInteger: 1.
			nativizer
				emitSend: #+;
				temporaryInStackAtPut: current;
				loadAwithStack: limit.
			assembler jumpTo: head ];
		addFallback: [ assembler
				@ nonInteger;
				pushA.
			nativizer emitSend: #<=.
			assembler
				compareRwithTrue;
				jumpIfEqualTo: block;
				jumpTo: continue ]
]

{ #category : #nativizing }
InlinedMessageNativizer >> inlineUnitaryWhile: aBoolean [
	| continue failed |
	start := assembler newLabel.
	continue := assembler newLabel.
	failed := assembler newLabel.
	assembler
		alignTo: 16;
		@ start.
	message receiver statements do: [ :s | s acceptVisitor: nativizer ].
	assembler
		compareRwithBoolean: aBoolean;
		jumpIfEqualTo: start;
		compareRwithBoolean: aBoolean not;
		jumpIfNotEqualTo: failed;
		@ continue.
	nativizer
		addFallback: [ assembler @ failed.
			nativizer sendMustBeBoolean.
			assembler jumpTo: continue ]
]

{ #category : #accessing }
InlinedMessageNativizer >> message: aMessageAstcode [
	message := aMessageAstcode 
]

{ #category : #accessing }
InlinedMessageNativizer >> nativizer: anAstcodeNativizer [
	nativizer := anAstcodeNativizer 
]

{ #category : #nativizing }
InlinedMessageNativizer >> negateBoolean [
		| retry failed done |
	retry := assembler newLabel.
	failed := assembler newLabel.
		done := assembler newLabel.
	assembler
		@ retry;
		loadAwithR;
		loadRwithFalse;
		compareRwithA;
		jumpIfEqualTo: done;
		loadRwithTrue;
		compareRwithA;
		jumpIfNotEqualTo: failed; @done.
	nativizer
		addFallback: [ assembler @ failed.
			nativizer sendMustBeBoolean.
			assembler jumpTo: retry ]
]
