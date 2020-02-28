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

{ #category : #private }
X64ABI >> regA [
	^rdx
]

{ #category : #private }
X64ABI >> regE [
	^rdi
]

{ #category : #private }
X64ABI >> regFP [
	^rbp
]

{ #category : #private }
X64ABI >> regR [
	^rax
]

{ #category : #private }
X64ABI >> regS [
	^rsi
]

{ #category : #private }
X64ABI >> regSP [
	^rsp
]

{ #category : #private }
X64ABI >> regT [
	^rcx
]

{ #category : #accessing }
X64ABI >> wordSize [
	^8
]

{ #category : #accessing }
X64ABI >> wordSizeShift [
	^3
]
