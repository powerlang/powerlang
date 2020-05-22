Class {
	#name : #BinaryMessageNativizer,
	#superclass : #Object,
	#instVars : [
		'message',
		'assembler',
		'nativizer',
		'done',
		'failed'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #private }
BinaryMessageNativizer >> argumentAt: index in: environment [
	nativizer argumentAt: index in: environment 
]

{ #category : #private }
BinaryMessageNativizer >> assembler: anAssembler [
	assembler := anAssembler 
]

{ #category : #private }
BinaryMessageNativizer >> failLabel [
	^failed 
]

{ #category : #private }
BinaryMessageNativizer >> inlineEquals [
	done := assembler newLabel.
	failed := assembler newLabel.
	self loadOperands.
	nativizer saveContextSwitchPoint.
	assembler loadTwithR.
	nativizer loadObject: true.
	assembler compareTwithA; jumpIfNotEqualTo: done.
	nativizer loadObject: false.
	assembler @ done.
	nativizer addFallback: [
		assembler @ failed; pushA.
		nativizer emitSend: #'='.
		assembler jumpTo: done] 
]

{ #category : #private }
BinaryMessageNativizer >> inlineIdentityEquals [
	done := assembler newLabel.
	self loadOperands.
	assembler loadTwithR.
	nativizer loadObject: true.
	assembler compareTwithA; jumpIfNotEqualTo: done.
	nativizer loadObject: false.
	assembler @ done 
]

{ #category : #private }
BinaryMessageNativizer >> inlineMessage [
	| selector s |
	s := message selector.
	selector := s isSymbol ifTrue: [s] ifFalse: [nativizer method at: s].
	selector = #'==' ifTrue: [^self inlineIdentityEquals].
	selector = #'=' ifTrue: [^self inlineEquals].
	selector = #'+' ifTrue: [^self inlinePlus].
	selector = #'<' ifTrue: [^self inlineLessThan].
	selector = #'<=' ifTrue: [^self inlineLessEqualThan].
	selector = #'>=' ifTrue: [^self inlineGreaterEqualThan].
	selector = #'>' ifTrue: [^self inlineGreaterThan].
	selector = #'-' ifTrue: [^self inlineMinus].
	selector = #'|' ifTrue: [^self inlineBinaryBitOr].
	selector = #'&' ifTrue: [^self inlineBinaryBitAnd].
	selector = #'>>' ifTrue: [^self inlineBinaryBitShiftLeft].
	selector = #'<<' ifTrue: [^self inlineBinaryBitShiftRight].
	selector = #bitOr: ifTrue: [^self inlineBitOr].
	selector = #bitAnd: ifTrue: [^self inlineBitAnd].
	selector = #bitXor: ifTrue: [^self inlineBitXor].
	selector = #bitShift: ifTrue: [^self inlineBitShift].
	self ASSERT: false 
]

{ #category : #private }
BinaryMessageNativizer >> inlineMinus [
	| overflow |
	done := assembler newLabel.
	failed := assembler newLabel.
	overflow := assembler newLabel.
	self loadOperands.
	nativizer saveContextSwitchPoint.
	assembler
		subAfromR;
		jumpIfOverflowTo: overflow;
		ensureRintegerBit;
		@ done.
	nativizer addFallback: [
		assembler
			@ overflow;
			addAtoR;
			@ failed;
			pushA.
		nativizer emitSend: #'-'.
		assembler jumpTo: done] 
]

{ #category : #private }
BinaryMessageNativizer >> inlinePlus [
	| overflow |
	done := assembler newLabel.
	failed := assembler newLabel.
	overflow := assembler newLabel.
	self loadOperands.
	nativizer saveContextSwitchPoint.
	assembler
		clearRintegerBit;
		addAtoR;
		jumpIfOverflowTo: overflow;
		@ done.
	nativizer addFallback: [
		assembler
			@ overflow;
			subAfromR;
			ensureRintegerBit;
			@ failed;
			pushA.
		nativizer emitSend: #'+'.
		assembler jumpTo: done] 
]

{ #category : #private }
BinaryMessageNativizer >> loadAwithArgument: index env: environment [
	nativizer loadAwithArgument: index env: environment 
]

{ #category : #private }
BinaryMessageNativizer >> loadAwithTemporary: index env: environment [
	nativizer loadAwithTemporary: index env: environment 
]

{ #category : #private }
BinaryMessageNativizer >> loadOperands [
	message opcodes
		do: [:hintcode | hintcode nativizeUsing: assembler for: self] 
]

{ #category : #private }
BinaryMessageNativizer >> loadRvisitingReceiver [
	message receiver acceptVisitor: nativizer 
]

{ #category : #private }
BinaryMessageNativizer >> loadRwithTemporary: index env: environment [
	nativizer temporaryAt: index in: environment
]

{ #category : #private }
BinaryMessageNativizer >> message: aMessageAstcode [
	message := aMessageAstcode 
]

{ #category : #private }
BinaryMessageNativizer >> method [
	^nativizer method 
]

{ #category : #private }
BinaryMessageNativizer >> nativizer: anAstcodeNativizer [
	nativizer := anAstcodeNativizer 
]
