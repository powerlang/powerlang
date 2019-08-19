Class {
	#name : #MessageInliner,
	#superclass : #Object,
	#instVars : [
		'message'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #transforming }
MessageInliner >> inline: aMessageNode [
	| s |
	message := aMessageNode.
	message receiver isSuper ifTrue: [^self].
	(message isCascadeMessage and: [message receiver isBlockNode])
		ifTrue: [^self].
	s := message selector value.
	s == #ifTrue: ifTrue: [^self inlineConditional].
	s == #ifFalse: ifTrue: [^self inlineConditional].
	s == #ifNotNil: ifTrue: [^self inlineIfNotNil].
]

{ #category : #inlining }
MessageInliner >> inlineConditional [
	| arguments |
	arguments := message arguments.
	arguments size >= 1 ifFalse: [^self].
	arguments do: [:arg | arg isEvaluable ifFalse: [^self]].
	message beInlined.
	arguments select: #isBlockNode thenDo: #beInlined
]

{ #category : #inlining }
MessageInliner >> inlineIfNotNil [
	| arguments arg |
	arguments := message arguments.
	arguments size = 1 ifFalse: [^self].
	arg := arguments first.
	(arg isEvaluable or: [arg isBlockNode and: [arg arguments size = 1]])
		ifFalse: [^self].
	message beInlined.
	arg isBlockNode ifTrue: [arg beInlined]
]
