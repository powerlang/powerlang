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

{ #category : #accessing }
InlinedMessageNativizer >> inlineIfTrue [
	| continue failed first |
	continue := assembler newLabel.
	failed := assembler newLabel.
	end := assembler newLabel.
	message receiver acceptVisitor: nativizer.
	first := false.
	assembler
		compareRwithBoolean: first;
		jumpIfEqualTo: end;
		compareRwithBoolean: first not;
		shortJumpIfNotEqualTo: failed;
		@ continue.
	nativizer
		addFallback: [ assembler @ failed.
			nativizer sendMustBeBoolean.
			assembler jumpTo: continue ].
	message arguments first statements
		do: [ :s | s acceptVisitor: nativizer ].
	assembler @ end
]

{ #category : #accessing }
InlinedMessageNativizer >> inlineMessage [
	| selector |
	selector := nativizer method at: message selector.
	selector = #ifTrue: ifTrue: [^self inlineIfTrue].
	selector = #whileTrue ifTrue: [^self inlineUnitaryWhileTrue].
	self ASSERT: false 
]

{ #category : #accessing }
InlinedMessageNativizer >> inlineUnitaryWhileTrue [
	| continue failed first |
	start := assembler newLabel.
	continue := assembler newLabel.
	failed := assembler newLabel.
	assembler
		alignTo: 16;
		@ start.
	message receiver statements do: [ :s | s acceptVisitor: nativizer ].
	first := true.
	assembler compareRwithBoolean: first;
		jumpIfEqualTo: start;
		compareRwithBoolean: first not;
		shortJumpIfNotEqualTo: failed;
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
