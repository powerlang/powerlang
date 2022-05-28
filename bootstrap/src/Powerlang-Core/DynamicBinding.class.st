Class {
	#name : #DynamicBinding,
	#superclass : #Binding,
	#classVars : [
		'Default'
	],
	#category : #'Powerlang-Core-SCompiler-Bindings'
}

{ #category : #accessing }
DynamicBinding class >> default [
	^Default ifNil: [Default := self new name: '<unresolved>']
]

{ #category : #testing }
DynamicBinding >> beReferencedFrom: aScriptNode [
	"a dynamic binding could refer to an ivar, so we have to be conservative"
	aScriptNode useSelf
]

{ #category : #testing }
DynamicBinding >> encodeUsing: anAstcodeEmitter [
	anAstcodeEmitter encodeDynamicVar: name
]

{ #category : #testing }
DynamicBinding >> isDynamic [
	^true
]

{ #category : #testing }
DynamicBinding >> literal [
	^name asSymbol
]
