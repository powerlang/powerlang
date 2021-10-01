"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #RelocationFixup,
	#superclass : #Object,
	#instVars : [
		'source',
		'target',
		'relative',
		'size'
	],
	#category : #'Powerlang-Core-Assembler'
}

{ #category : #'instance creation' }
RelocationFixup class >> absoluteFrom: source to: target [
	^self new beAbsolute; from: source to: target
]

{ #category : #'instance creation' }
RelocationFixup class >> relativeFrom: source to: target [
	^self new beRelative; from: source to: target
]

{ #category : #accessing }
RelocationFixup >> addressSize [
	^4
]

{ #category : #accessing }
RelocationFixup >> beAbsolute [
	relative := false.
	size := self addressSize
]

{ #category : #accessing }
RelocationFixup >> beRelative [
	relative := true
]

{ #category : #accessing }
RelocationFixup >> from: address1 to: address2 [
	source := address1.
	target := address2
]

{ #category : #testing }
RelocationFixup >> isRelative [
	^relative
]

{ #category : #services }
RelocationFixup >> patch: buffer with: solver [
	| delta address |
	address := solver resolveLabel: target.
	self ASSERT: address notNil.
	relative
		ifTrue: [
			delta := address - source - size.
			size = 1
				ifTrue: [buffer writeByte: delta at: source]
				ifFalse: [buffer writeLong: delta at: source]]
		ifFalse: [buffer writeLong: address at: source]
]

{ #category : #printing }
RelocationFixup >> printOn: aStream [
	aStream
		nextPutAll: self class name;
		nextPut: $:;
		space;
		nextPutAll: target printString
]

{ #category : #services }
RelocationFixup >> relocateBy: delta [
	source := source + delta
]

{ #category : #accessing }
RelocationFixup >> size: anInteger [
	size := anInteger
]

{ #category : #accessing }
RelocationFixup >> target [
	^target
]
