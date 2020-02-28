"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #X86ABI,
	#superclass : #ABI,
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #accessing }
X86ABI >> bits [
	^32
]

{ #category : #accessing }
X86ABI >> wordSize [
	^4
]

{ #category : #accessing }
X86ABI >> wordSizeShift [
	^2
]
