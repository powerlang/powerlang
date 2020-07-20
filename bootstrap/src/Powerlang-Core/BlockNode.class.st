Class {
	#name : #BlockNode,
	#superclass : #ScriptNode,
	#instVars : [
		'inlined',
		'index',
		'parent'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #visiting }
BlockNode >> acceptVisitor: visitor [
	^visitor visitBlock: self
]

{ #category : #'emitting - inlined' }
BlockNode >> beInlined [
	inlined := true.
	arguments do: [:arg | arg binding beInlined]
]

{ #category : #private }
BlockNode >> buildBlock [
	| block |
	self isInlined ifTrue: [ ^ nil ].
	block := SCompiledBlock new.
	^ block
		  id: index;
		  argumentCount: arguments size;
		  tempCount: scope stackSize;
		  environmentCount: scope environmentSize;
		  capturesSelf: scope capturesSelf;
			capturesHome: scope capturesHome
]

{ #category : #private }
BlockNode >> captureHome [
	scope captureEnvironment: self ast
]

{ #category : #testing }
BlockNode >> environmentIndexOf: aParseNode [
	^scope environmentIndexOf: aParseNode
]

{ #category : #accessing }
BlockNode >> index [
	^index
]

{ #category : #accessing }
BlockNode >> index: aNumber [
	index := aNumber
]

{ #category : #initialization }
BlockNode >> initialize [
	super initialize.
	inlined := false.
	scope := BlockScope on: self
]

{ #category : #testing }
BlockNode >> isBlockNode [
	^true
]

{ #category : #testing }
BlockNode >> isEvaluable [
	^self isNullary
]

{ #category : #testing }
BlockNode >> isInlined [
	^inlined
]

{ #category : #testing }
BlockNode >> isNullary [
	^arguments isEmpty
]

{ #category : #accessing }
BlockNode >> parent [
	^parent
]

{ #category : #accessing }
BlockNode >> parent: aScriptNode [
	parent := aScriptNode addChild: self
]

{ #category : #accessing }
BlockNode >> realParent [
	^parent realScript
]

{ #category : #accessing }
BlockNode >> realScript [
	^inlined ifTrue: [parent realScript] ifFalse: [self]
]

{ #category : #testing }
BlockNode >> usesHome [
	^inlined
		ifTrue: [children anySatisfy: [:block | block usesHome]]
		ifFalse: [scope capturesHome]
]
