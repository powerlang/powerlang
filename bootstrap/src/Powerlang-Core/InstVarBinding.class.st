Class {
	#name : #InstVarBinding,
	#superclass : #Binding,
	#instVars : [
		'index'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #testing }
InstVarBinding >> assign: aValue within: anInterpreter [
	^ anInterpreter receiver _gate setInstVarAt: index with: aValue
]

{ #category : #actions }
InstVarBinding >> beReferencedFrom: aScriptNode [
	aScriptNode useSelf
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
