"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #ODominatorTree,
	#superclass : #Object,
	#instVars : [
		'block',
		'dominators',
		'dominated'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
ODominatorTree class >> from: root with: aBlocksCollection dominators: dominators [
	| trees |
	trees := Array
		withAll: (aBlocksCollection collect: [ :block | self new block: block ]).
	(dominators beeCopyFrom: 2)
		withIndexDo: [ :dominator :correspondingIndex | 
			| imm child |
			imm := trees at: dominator.
			child := trees at: correspondingIndex + 1.
			imm addDominated: child ].
	^ trees first
]

{ #category : #unclassified }
ODominatorTree class >> new [
	^self basicNew initialize
]

{ #category : #unclassified }
ODominatorTree >> addDominated: aTree [
	dominated add: aTree
]

{ #category : #unclassified }
ODominatorTree >> allImmediateDominators [
	| result remaining |
	result := Dictionary new.
	remaining := OrderedCollection with: self.
	[remaining isEmpty] whileFalse: [| current |
		current := remaining removeLast.
		current dominated do: [:child | result at: child block put: current block].
		remaining addAll: current dominated].
	^result
]

{ #category : #unclassified }
ODominatorTree >> block [
	^block
]

{ #category : #unclassified }
ODominatorTree >> block: aBasicBlock [
	block := aBasicBlock
]

{ #category : #unclassified }
ODominatorTree >> dominated [
	^dominated
]

{ #category : #unclassified }
ODominatorTree >> dominators [
	^dominators
]

{ #category : #unclassified }
ODominatorTree >> dominators: aTreeCollection [
	dominators := aTreeCollection
]

{ #category : #unclassified }
ODominatorTree >> initialize [
	dominated := OrderedCollection new
]

{ #category : #unclassified }
ODominatorTree >> isImmediateDominatorOf: aBasicBlock [
	^block == self or: [block successors includes: aBasicBlock]
]

{ #category : #unclassified }
ODominatorTree >> noticeDominators [
	dominators
		select: [:tree | tree isImmediateDominatorOf: self]
		thenDo: [:dominator | dominator addDominated: self]
]

{ #category : #unclassified }
ODominatorTree >> printAtLevel: level on: aStream [
	level > 8 ifTrue: [self halt].
	level timesRepeat: [aStream nextPutAll: '--'].
	aStream nextPutAll: block name , String cr.
	dominated
		reject: [:tree | tree == self]
		thenDo: [:tree | tree printAtLevel: level + 1 on: aStream]
]

{ #category : #unclassified }
ODominatorTree >> printOn: aStream [
	self printAtLevel: 1 on: aStream
]
