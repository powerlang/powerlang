"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #ModRM,
	#superclass : #OctalStructure,
	#category : #'Powerlang-Core-Assembler-Intel-Tools'
}

{ #category : #'instance creation' }
ModRM class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #private }
ModRM >> beRR [
	self mod: 2r11
]

{ #category : #initialization }
ModRM >> initialize [
	byte := 0
]

{ #category : #accessing }
ModRM >> mod [
	^self hi
]

{ #category : #accessing }
ModRM >> mod: anInteger [
	self hi: anInteger
]

{ #category : #accessing }
ModRM >> opcode [
	^self reg
]

{ #category : #accessing }
ModRM >> opcode: anInteger [
	self reg: anInteger
]

{ #category : #accessing }
ModRM >> reg [
	^self mid
]

{ #category : #accessing }
ModRM >> reg: aRegister [
	| mid |
	mid := aRegister isInteger
		ifTrue: [aRegister]
		ifFalse: [aRegister index \\ 8].
	self mid: mid
]

{ #category : #accessing }
ModRM >> rm [
	^self lo
]

{ #category : #accessing }
ModRM >> rm: anInteger [
	self lo: anInteger
]
