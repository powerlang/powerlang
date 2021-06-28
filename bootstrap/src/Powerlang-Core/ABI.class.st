"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #ABI,
	#superclass : #Object,
	#category : #'Powerlang-Core-Assembler'
}

{ #category : #unclassified }
ABI class >> currentClass [
	| host |
	
	host := Smalltalk host.
	host = 'x86_64-linux-gnu' ifTrue:[ ^SysVX64ABI ].
	host = 'x86_64-darwin' ifTrue:[ ^SysVX64ABI ].
	host = 'x86_64-win32' ifTrue:[ ^WinX64ABI ].
	
	self error:'Unssuported host: ', host.
]

{ #category : #unclassified }
ABI class >> forCurrent [
	^self currentClass new
]

{ #category : #unclassified }
ABI >> is32bits [
	^self bits = 32
]

{ #category : #unclassified }
ABI >> is64bits [
	^self bits = 64
]
