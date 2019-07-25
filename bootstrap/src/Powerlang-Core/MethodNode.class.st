Class {
	#name : #MethodNode,
	#superclass : #ScriptNode,
	#instVars : [
		'selector',
		'pragma'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #inquiries }
MethodNode >> header [
	"
	(Object >> #printOn:) ast header
	"
	| interval |
	interval := selector stretch.
	arguments notEmpty
		ifTrue: [interval := interval start thru: arguments last stretch end].
	^compiler sourceCode copyFrom: interval start to: interval end
]

{ #category : #testing }
MethodNode >> isHeadless [
	^selector isNil
]

{ #category : #enumerating }
MethodNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	(aBoolean and: [selector notNil]) ifTrue: [aBlock evaluateWith: selector]
]

{ #category : #accessing }
MethodNode >> selector [
	^selector value
]

{ #category : #accessing }
MethodNode >> selector: aSelectorNode [
	selector := aSelectorNode
]

{ #category : #accessing }
MethodNode >> selectorNode [
	^selector
]
