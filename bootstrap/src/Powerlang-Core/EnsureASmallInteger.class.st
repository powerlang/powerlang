Class {
	#name : #EnsureASmallInteger,
	#superclass : #EnsureSmallIntegerOpcode,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #'as yet unclassified' }
EnsureASmallInteger >> nativizeUsing: anAssembler for: messageNativizer [
	anAssembler
		testIntegerBitOf: anAssembler regA8;
		shortJumpIfZeroTo: messageNativizer failLabel
]
