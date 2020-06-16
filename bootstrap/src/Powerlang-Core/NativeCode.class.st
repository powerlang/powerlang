Class {
	#name : #NativeCode,
	#superclass : #Object,
	#instVars : [
		'code'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #'as yet unclassified' }
NativeCode >> code [
	^code
]

{ #category : #'as yet unclassified' }
NativeCode >> code: bytes [
	code := bytes.

]

{ #category : #'as yet unclassified' }
NativeCode >> disassembledAmd64 [
	^code disassembledAmd64
]
