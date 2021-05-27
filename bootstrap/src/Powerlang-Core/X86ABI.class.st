"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #X86ABI,
	#superclass : #ABI,
	#pools : [
		'Registers'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #accessing }
X86ABI >> bits [
	^32
]

{ #category : #accessing }
X86ABI >> regA [
	^edx
]

{ #category : #accessing }
X86ABI >> regE [
	^edi
]

{ #category : #accessing }
X86ABI >> regFP [
	^ebp
]

{ #category : #accessing }
X86ABI >> regR [
	^eax
]

{ #category : #accessing }
X86ABI >> regS [
	^esi
]

{ #category : #accessing }
X86ABI >> regSP [
	^esp
]

{ #category : #accessing }
X86ABI >> regT [
	^ecx
]

{ #category : #accessing }
X86ABI >> wordSize [
	^4
]

{ #category : #accessing }
X86ABI >> wordSizeShift [
	^2
]
