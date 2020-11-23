Class {
	#name : #NativeCode,
	#superclass : #Array,
	#type : #variable,
	#instVars : [
		'machineCode',
		'compiledCode'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #'as yet unclassified' }
NativeCode >> code [
	^machineCode
]

{ #category : #'as yet unclassified' }
NativeCode >> code: bytes [
	machineCode := bytes
]

{ #category : #'as yet unclassified' }
NativeCode >> compiledCode: anObject [
self shouldBeImplemented.
]

{ #category : #'as yet unclassified' }
NativeCode >> disassembledAmd64 [
	^machineCode disassembledAmd64
]
