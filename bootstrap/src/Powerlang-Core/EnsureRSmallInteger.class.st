Class {
	#name : #EnsureRSmallInteger,
	#superclass : #EnsureSmallIntegerOpcode,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #'as yet unclassified' }
EnsureRSmallInteger >> nativizeUsing: anAssembler for: messageNativizer [
	anAssembler
		testIntegerBitOf: anAssembler regR8;
		shortJumpIfZeroTo: messageNativizer failLabel
]
