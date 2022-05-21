"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OctalStructure,
	#superclass : #Object,
	#instVars : [
		'byte'
	],
	#category : #'Powerlang-Core-Assembly-Intel-Tools'
}

{ #category : #'instance creation' }
OctalStructure class >> new [
	^super new initialize
]

{ #category : #accessing }
OctalStructure >> hi [
	^byte bitShift: -6
]

{ #category : #accessing }
OctalStructure >> hi: anInteger [
	| bits |
	self ASSERT: anInteger < 4.
	bits := anInteger bitShift: 6.
	byte := (byte bitAnd: 2r111111) bitOr: bits
]

{ #category : #private }
OctalStructure >> lo [
	^byte bitAnd: 7
]

{ #category : #private }
OctalStructure >> lo: anInteger [
	self ASSERT: anInteger < 8.
	byte := (byte bitAnd: 2r11111000) bitOr: anInteger
]

{ #category : #accessing }
OctalStructure >> mid [
	^(byte bitShift: -3) bitAnd: 7
]

{ #category : #accessing }
OctalStructure >> mid: anInteger [
	| bits |
	self ASSERT: anInteger < 8.
	bits := anInteger bitShift: 3.
	byte := (byte bitAnd: 2r11000111) bitOr: bits
]

{ #category : #accessing }
OctalStructure >> on: anInteger [
	byte := anInteger
]

{ #category : #printing }
OctalStructure >> printOn: aStream [
	| hi mid lo |
	hi := self hi printPaddedWith: $0 to: 2 base: 2.
	mid := self mid printPaddedWith: $0 to: 3 base: 2.
	lo := self lo printPaddedWith: $0 to: 3 base: 2.
	aStream
		nextPutAll: hi;
		nextPut: $.;
		nextPutAll: mid;
		nextPut: $.;
		nextPutAll: lo
]

{ #category : #accessing }
OctalStructure >> value [
	^byte
]
