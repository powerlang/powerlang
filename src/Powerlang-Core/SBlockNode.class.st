Class {
	#name : #SBlockNode,
	#superclass : #SScriptNode,
	#instVars : [
		'inlined',
		'index',
		'parent'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #visiting }
SBlockNode >> acceptVisitor: visitor [
	^visitor visitBlock: self
]

{ #category : #'emitting - inlined' }
SBlockNode >> beInlined [
	inlined := true.
	arguments do: [:arg | arg binding beInlined]
]

{ #category : #private }
SBlockNode >> buildBlock [
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
SBlockNode >> captureHome [
	scope captureEnvironment: self ast
]

{ #category : #testing }
SBlockNode >> environmentIndexOf: aParseNode [
	^scope environmentIndexOf: aParseNode
]

{ #category : #accessing }
SBlockNode >> index [
	^index
]

{ #category : #accessing }
SBlockNode >> index: aNumber [
	index := aNumber
]

{ #category : #initialization }
SBlockNode >> initialize [
	super initialize.
	inlined := false.
	scope := BlockScope on: self
]

{ #category : #testing }
SBlockNode >> isBlockNode [
	^true
]

{ #category : #testing }
SBlockNode >> isEvaluable [
	^self isNullary
]

{ #category : #testing }
SBlockNode >> isInlined [
	^inlined
]

{ #category : #testing }
SBlockNode >> isNullary [
	^arguments isEmpty
]

{ #category : #accessing }
SBlockNode >> parent [
	^parent
]

{ #category : #accessing }
SBlockNode >> parent: aScriptNode [
	parent := aScriptNode addChild: self
]

{ #category : #accessing }
SBlockNode >> realParent [
	^parent realScript
]

{ #category : #accessing }
SBlockNode >> realScript [
	^inlined ifTrue: [parent realScript] ifFalse: [self]
]

{ #category : #testing }
SBlockNode >> usesHome [
	^inlined
		ifTrue: [children anySatisfy: [:block | block usesHome]]
		ifFalse: [scope capturesHome]
]
