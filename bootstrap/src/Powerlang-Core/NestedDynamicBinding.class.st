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
