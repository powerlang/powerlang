"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #X64ABI,
	#superclass : #ABI,
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #accessing }
X64ABI >> bits [
	^64
]

{ #category : #accessing }
X64ABI >> wordSize [
	^8
]

{ #category : #accessing }
X64ABI >> wordSizeShift [
	^3
]
