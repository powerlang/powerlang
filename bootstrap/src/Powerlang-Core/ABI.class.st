"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #ABI,
	#superclass : #Object,
	#pools : [
		'Registers'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #unclassified }
ABI class >> currentClass [
	| platform |
	platform := OSPlatform current.
	platform isWin64 ifTrue: [ ^WinX64ABI ].
	(platform isUnix64 or: platform isMacOSX) ifTrue: [ ^SysVX64ABI ].
	self ASSERT: false.
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
