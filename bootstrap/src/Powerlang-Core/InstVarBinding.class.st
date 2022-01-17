Class {
	#name : #InstVarBinding,
	#superclass : #Binding,
	#instVars : [
		'index'
	],
	#category : #'Powerlang-Core-SCompiler-Bindings'
}

{ #category : #actions }
InstVarBinding >> beReferencedFrom: aScriptNode [
	aScriptNode useSelf
]

{ #category : #private }
InstVarBinding >> emitLoadAusing: anAstcodeEncoder [
	anAstcodeEncoder encodeLoadAwithInstVar: index
]

{ #category : #actions }
InstVarBinding >> encodeUsing: anAstcodeEmitter [
	anAstcodeEmitter encodeInstVar: index
]

{ #category : #accessing }
InstVarBinding >> index [
	^index
]

{ #category : #accessing }
InstVarBinding >> index: aNumber [
	index := aNumber
]

{ #category : #testing }
InstVarBinding >> isInstVar [
	^true
]
