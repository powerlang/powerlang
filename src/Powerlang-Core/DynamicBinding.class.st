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

{ #category : #accessing }
DynamicBinding class >> named: aString [
	| index first second |
	index := aString indexOf: $..
	index = 0 ifTrue: [ ^self new name: aString ].
	first := aString copyFrom: 1 to: index - 1.
	second := aString copyFrom: index + 1 to: aString size.
	^NestedDynamicBinding new name: { first. second }
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
