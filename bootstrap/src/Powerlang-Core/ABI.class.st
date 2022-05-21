"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.

`ABI` seems to serve two different purposes:

 i) provide support for calling (native) function with system
	calling convention for given architecture and OS combination

ii) provide fixed mapping from 'IR' registers (such as A, R, M and so on)
	to real machine registers

"
Class {
	#name : #ABI,
	#superclass : #Object,
	#category : #'Powerlang-Core-Assembly'
}

{ #category : #unclassified }
ABI >> is32bits [
	^self bits = 32
]

{ #category : #unclassified }
ABI >> is64bits [
	^self bits = 64
]

{ #category : #'registers - IR' }
ABI >> regA [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
ABI >> regE [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
ABI >> regFP [
	^ self subclassResponsibility
]

{ #category : #'registers - IR' }
ABI >> regFalse [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
ABI >> regG [
	^ self subclassResponsibility
]

{ #category : #'registers - IR' }
ABI >> regIP [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
ABI >> regM [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
ABI >> regNil [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
ABI >> regR [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
ABI >> regS [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
ABI >> regSP [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
ABI >> regT [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
ABI >> regTrue [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
ABI >> regV [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
ABI >> regX0 [
	^ self subclassResponsibility
]

{ #category : #'registers - IR' }
ABI >> regX1 [
	^ self subclassResponsibility
]
