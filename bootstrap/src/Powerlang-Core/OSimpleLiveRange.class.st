"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OSimpleLiveRange,
	#superclass : #OLiveRange,
	#instVars : [
		'definition',
		'uses',
		'definitionBlock',
		'usesBlocks',
		'isSpilled'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #'instance creation' }
OSimpleLiveRange class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #unclassified }
OSimpleLiveRange >> addUseFrom: operation at: block [
	uses add: operation -> block
]

{ #category : #unclassified }
OSimpleLiveRange >> allDefinitions [
	^OrderedCollection with: definition
]

{ #category : #unclassified }
OSimpleLiveRange >> allUses [
	^uses collect: #key
]

{ #category : #unclassified }
OSimpleLiveRange >> anyDefinition [
	^definition
]

{ #category : #unclassified }
OSimpleLiveRange >> beSpilled [
	isSpilled := true
]

{ #category : #unclassified }
OSimpleLiveRange >> clearUses [
	uses := OrderedCollection new
]

{ #category : #unclassified }
OSimpleLiveRange >> definedAt: operation in: block [
	definition := operation.
	definitionBlock := block
]

{ #category : #unclassified }
OSimpleLiveRange >> definition: operation [
	definition := operation
]

{ #category : #unclassified }
OSimpleLiveRange >> definitionAndUses [
	^OrderedCollection with: definition -> definitionBlock withAll: uses
]

{ #category : #unclassified }
OSimpleLiveRange >> definitionsWithBlocksDo: aBlock [
	aBlock value: definition value: definitionBlock
]

{ #category : #unclassified }
OSimpleLiveRange >> endsAt: operation [
	^uses isEmpty
]

{ #category : #unclassified }
OSimpleLiveRange >> expirationPoints [
	| associations |
	associations := uses
		reject: [:operation | definition
			livesAfter: operation key
			orOutOf: operation value].
	^associations collect: #key
]

{ #category : #unclassified }
OSimpleLiveRange >> initialize [
	uses := OrderedCollection new.
	isSpilled := false
]

{ #category : #unclassified }
OSimpleLiveRange >> isLiveAt: aBlock [
	^definition livesAfter: aBlock firstInstruction prev orOutOf: aBlock
]

{ #category : #unclassified }
OSimpleLiveRange >> isSpilled [
	^isSpilled
]

{ #category : #unclassified }
OSimpleLiveRange >> isUnused [
	^uses isEmpty
]

{ #category : #unclassified }
OSimpleLiveRange >> printOn: aStream [
	aStream nextPutAll: 'LR of: ' , definition printString
]

{ #category : #unclassified }
OSimpleLiveRange >> simpleRanges [
	^OrderedCollection with: self
]

{ #category : #unclassified }
OSimpleLiveRange >> startsAt: operation [
	^definition == operation
]

{ #category : #unclassified }
OSimpleLiveRange >> uses [
	^uses
]

{ #category : #unclassified }
OSimpleLiveRange >> usesWithBlocks [
	^uses
]

{ #category : #unclassified }
OSimpleLiveRange >> usesWithBlocksDo: aBlock [
	uses
		do: [:association | aBlock value: association key value: association value]
]
