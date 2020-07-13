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
BinaryMessageNativizer >> inlineBitAnd [
	done := assembler newLabel.
	failed := assembler newLabel.
	self loadOperands.
	nativizer saveContextSwitchPoint.
	assembler
		andRwithA;
		@ done.
	nativizer
		addFallback: [ assembler
				@ failed;
				pushA.
			nativizer emitSend: #bitAnd:.
			assembler jumpTo: done ]
]

{ #category : #private }
BinaryMessageNativizer >> inlineBitAnd: selector [
	done := assembler newLabel.
	failed := assembler newLabel.
	self loadOperands.
	nativizer saveContextSwitchPoint.
	assembler
		andRwithA;
		@ done.
	nativizer
		addFallback: [ assembler
				@ failed;
				pushA.
			nativizer emitSend: selector.
			assembler jumpTo: done ]
]

{ #category : #private }
BinaryMessageNativizer >> inlineBitOr: selector [
	done := assembler newLabel.
	failed := assembler newLabel.
	self loadOperands.
	nativizer saveContextSwitchPoint.
	assembler
		orRwithA;
		@ done.
	nativizer
		addFallback: [ assembler
				@ failed;
				pushA.
			nativizer emitSend: selector.
			assembler jumpTo: done ]
]

{ #category : #private }
BinaryMessageNativizer >> inlineBitXor [
	done := assembler newLabel.
	failed := assembler newLabel.
	self loadOperands.
	nativizer saveContextSwitchPoint.
	assembler
		xorRwithA;
		@ done.
	nativizer
		addFallback: [ assembler
				@ failed;
				pushA.
			nativizer emitSend: #bitXor:.
			assembler jumpTo: done ]
]

{ #category : #private }
BinaryMessageNativizer >> inlineEquals [
	done := assembler newLabel.
	failed := assembler newLabel.
	self loadOperands.
	nativizer saveContextSwitchPoint.
	assembler loadTwithR; loadRwithTrue;
		compareTwithA;
		jumpIfNotEqualTo: done; loadRwithFalse; @ done.
	nativizer
		addFallback: [ assembler
				@ failed;
				pushA.
			nativizer emitSend: #=.
			assembler jumpTo: done ]
]

{ #category : #private }
BinaryMessageNativizer >> inlineGreaterEqualThan [
	done := assembler newLabel.
	failed := assembler newLabel.
	self loadOperands.
	nativizer saveContextSwitchPoint.
	assembler
		loadTwithR;
		loadRwithTrue;
		compareTwithA;
		jumpIfGreaterOrEqualSignedTo: done;
		loadRwithFalse;
		@ done.
	nativizer
		addFallback: [ assembler
				@ failed;
				pushA.
			nativizer emitSend: #<.
			assembler jumpTo: done ]
]

{ #category : #private }
BinaryMessageNativizer >> inlineGreaterThan [
	done := assembler newLabel.
	failed := assembler newLabel.
	self loadOperands.
	nativizer saveContextSwitchPoint.
	assembler
		loadTwithR;
		loadRwithTrue;
		compareTwithA;
		jumpIfGreaterSignedTo: done;
		loadRwithFalse;
		@ done.
	nativizer
		addFallback: [ assembler
				@ failed;
				pushA.
			nativizer emitSend: #<.
			assembler jumpTo: done ]
]

{ #category : #private }
BinaryMessageNativizer >> inlineIdentityEquals [
	done := assembler newLabel.
	self loadOperands.
	assembler loadTwithR; loadRwithTrue;
		compareTwithA;
		jumpIfNotEqualTo: done; loadRwithFalse; @ done
]

{ #category : #private }
BinaryMessageNativizer >> inlineLessEqualThan [
	done := assembler newLabel.
	failed := assembler newLabel.
	self loadOperands.
	nativizer saveContextSwitchPoint.
	assembler
		loadTwithR;
		loadRwithTrue;
		compareTwithA;
		jumpIfLessOrEqualSignedTo: done;
		loadRwithFalse;
		@ done.
	nativizer
		addFallback: [ assembler
				@ failed;
				pushA.
			nativizer emitSend: #<.
			assembler jumpTo: done ]
]

{ #category : #private }
BinaryMessageNativizer >> inlineLessThan [
	done := assembler newLabel.
	failed := assembler newLabel.
	self loadOperands.
	nativizer saveContextSwitchPoint.
	assembler
		loadTwithR;
		loadRwithTrue;
		compareTwithA;
		jumpIfLessSignedTo: done;
		loadRwithFalse;
		@ done.
	nativizer
		addFallback: [ assembler
				@ failed;
				pushA.
			nativizer emitSend: #<.
			assembler jumpTo: done ]
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
	selector = #'*' ifTrue: [^self inlineMultiply].
	selector = #'//' ifTrue: [^self inlineMultiply].
	selector = #'/' ifTrue: [^self inlineMultiply].
	selector = #'\\' ifTrue: [^self inlineMultiply].
	selector = #'|' ifTrue: [^self inlineBitOr: #|].
	selector = #'&' ifTrue: [^self inlineBitAnd: #&].
"	selector = #'>>' ifTrue: [^self inlineBitShiftLeft: #>>].
	selector = #'<<' ifTrue: [^self inlineBitShiftRight: #<<]."
	selector = #bitOr: ifTrue: [^self inlineBitOr: #bitOr:].
	selector = #bitAnd: ifTrue: [^self inlineBitAnd: #bitAnd:].
	selector = #bitXor: ifTrue: [^self inlineBitXor].
"	selector = #bitShift: ifTrue: [^self inlineBitShift]."
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
BinaryMessageNativizer >> inlineMultiply [
	| overflow |
	done := assembler newLabel.
	failed := assembler newLabel.
	overflow := assembler newLabel.
	self loadOperands.	
	nativizer saveContextSwitchPoint.
	assembler
		loadTwithR;
		clearRintegerBit;
		multiplyRbyA;
		jumpIfOverflowTo: overflow;
		ensureRintegerBit;
		@ done.
	nativizer
		addFallback: [ assembler
				@ overflow;
			loadRwithT;
				@ failed;
				pushA.
			nativizer emitSend: #*.
			assembler jumpTo: done ]

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
BinaryMessageNativizer >> loadAwithArgument: index in: environment [
	nativizer loadAwithArgument: index in: environment 
]

{ #category : #private }
BinaryMessageNativizer >> loadAwithTemporary: index in: environment [
	nativizer loadAwithTemporary: index in: environment 
]

{ #category : #private }
BinaryMessageNativizer >> loadOperands [
	message opcodes
		do: [:hintcode | hintcode nativizeUsing: assembler for: self] 
]

{ #category : #private }
BinaryMessageNativizer >> loadRvisitingArgument [
	message arguments first acceptVisitor: nativizer
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
BinaryMessageNativizer >> methodLiteralAt: index [
	^nativizer methodLiteralAt: index
]

{ #category : #private }
BinaryMessageNativizer >> nativizer: anAstcodeNativizer [
	nativizer := anAstcodeNativizer 
]
