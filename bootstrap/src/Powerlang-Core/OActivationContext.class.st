"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OActivationContext,
	#superclass : #OLoadImplicit,
	#instVars : [
		'hasFrame',
		'temporaries',
		'storesPreviousSelf'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #'instance creation' }
OActivationContext class >> new [
	^self basicNew initialize
]

{ #category : #accessing }
OActivationContext >> doSavePreviousSelf [
	storesPreviousSelf := true
]

{ #category : #accessing }
OActivationContext >> hasFrame [
	^hasFrame
]

{ #category : #accessing }
OActivationContext >> haveFrame [
	hasFrame := true
]

{ #category : #accessing }
OActivationContext >> initialize [
	hasFrame := false.
	storesPreviousSelf := false
]

{ #category : #accessing }
OActivationContext >> savesPreviousSelf [
	^storesPreviousSelf
]

{ #category : #accessing }
OActivationContext >> temporaries [
	^temporaries
]

{ #category : #accessing }
OActivationContext >> temporaries: aNumber [
	temporaries := aNumber.
	aNumber > 0 ifTrue: [self haveFrame]
]
