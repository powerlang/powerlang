Class {
	#name : #NestedDynamicBinding,
	#superclass : #DynamicBinding,
	#instVars : [
		'parent'
	],
	#category : #'Powerlang-Core-SCompiler-Bindings'
}

{ #category : #testing }
NestedDynamicBinding >> encodeUsing: anAstcodeEmitter [
	anAstcodeEmitter encodeNestedDynamicVar: name
]

{ #category : #testing }
NestedDynamicBinding >> literal [
	^name collect: [ :n | n asSymbol]
]

{ #category : #testing }
NestedDynamicBinding >> printNameOn: aStream [
	name do: [ :n | aStream nextPutAll: n ] separatedBy: [ aStream nextPut: $. ]
]
