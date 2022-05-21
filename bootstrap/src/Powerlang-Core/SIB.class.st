"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #SIB,
	#superclass : #OctalStructure,
	#category : #'Powerlang-Core-Assembly-Intel-Tools'
}

{ #category : #accessing }
SIB >> base [
	^self lo
]

{ #category : #accessing }
SIB >> base: anInteger [
	self lo: anInteger
]

{ #category : #accessing }
SIB >> baseRegister: aRegister [
	self base: aRegister index
]

{ #category : #accessing }
SIB >> index [
	^self mid
]

{ #category : #accessing }
SIB >> index: anInteger [
	self mid: anInteger
]

{ #category : #accessing }
SIB >> indexRegister: aRegister [
	self index: aRegister index
]

{ #category : #accessing }
SIB >> scale [
	^self hi
]

{ #category : #accessing }
SIB >> scale: anInteger [
	self hi: anInteger
]

{ #category : #accessing }
SIB >> scaleFactor: s [
	| index |
	index := #[1 2 4 8] indexOf: s.
	self scale: index - 1
]
