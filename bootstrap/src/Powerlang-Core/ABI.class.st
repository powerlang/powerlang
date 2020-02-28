"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #ABI,
	#superclass : #Object,
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #unclassified }
ABI class >> forIntel: wordSize [
	| class |
	class := wordSize = 4 ifTrue: [X86ABI] ifFalse: [X64ABI].
	^class new
]

{ #category : #unclassified }
ABI >> is32bits [
	^self bits = 32
]

{ #category : #unclassified }
ABI >> is64bits [
	^self bits = 64
]
