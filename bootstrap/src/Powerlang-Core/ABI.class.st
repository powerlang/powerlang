"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.

`ABI` seems to serve two different purposes:

 i) provide support for calling (native) function with system
	calling convention for given architecture and OS combination

ii) provide mapping for real machine registers to 'IR' registers
	(such as A, R, M and so on).

However, the (ii) mapping is also (!) defined in CodeGenerator class.
So I (JV) think we need to model calling convention separately from
machone to IR register mapping and, perhaps, have two calling 
conventions for system and nativized code.

"
Class {
	#name : #ABI,
	#superclass : #Object,
	#category : #'Powerlang-Core-Assembler'
}

{ #category : #unclassified }
ABI >> is32bits [
	^self bits = 32
]

{ #category : #unclassified }
ABI >> is64bits [
	^self bits = 64
]
