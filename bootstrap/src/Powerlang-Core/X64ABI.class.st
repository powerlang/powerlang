"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #X64ABI,
	#superclass : #ABI,
	#pools : [
		'Registers'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #accessing }
X64ABI >> bits [
	^64
]

{ #category : #'registers - IR' }
X64ABI >> regA [
	^rdx
]

{ #category : #'registers - IR' }
X64ABI >> regE [
	^rdi
]

{ #category : #'registers - IR' }
X64ABI >> regFP [
	^rbp
]

{ #category : #'registers - IR' }
X64ABI >> regFalse [
	^ r14
]

{ #category : #'registers - IR' }
X64ABI >> regG [
	^r15
]

{ #category : #'registers - IR' }
X64ABI >> regIP [
	^ rip
]

{ #category : #'registers - IR' }
X64ABI >> regM [
	^rbx
]

{ #category : #'registers - IR' }
X64ABI >> regNil [
	^ r12
]

{ #category : #'registers - IR' }
X64ABI >> regR [
	^rax
]

{ #category : #'registers - IR' }
X64ABI >> regS [
	^rsi
]

{ #category : #'registers - IR' }
X64ABI >> regSP [
	^rsp
]

{ #category : #'registers - IR' }
X64ABI >> regT [
	^rcx
]

{ #category : #'registers - IR' }
X64ABI >> regTrue [
	^ r13
]

{ #category : #'registers - IR' }
X64ABI >> regV [
	^r11
]

{ #category : #'registers - IR' }
X64ABI >> regX0 [
	^xmm0
]

{ #category : #'registers - IR' }
X64ABI >> regX1 [
	^xmm1
]

{ #category : #accessing }
X64ABI >> wordSize [
	^8
]

{ #category : #accessing }
X64ABI >> wordSizeShift [
	^3
]
