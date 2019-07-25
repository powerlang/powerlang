Class {
	#name : #BlockNode,
	#superclass : #ScriptNode,
	#instVars : [
		'parent'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #testing }
BlockNode >> isBlockNode [
	^true
]

{ #category : #accessing }
BlockNode >> parent [
	^parent
]

{ #category : #accessing }
BlockNode >> parent: aScriptNode [
	parent := aScriptNode addChild: self
]
