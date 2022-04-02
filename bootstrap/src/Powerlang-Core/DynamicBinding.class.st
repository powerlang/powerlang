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
DynamicBinding >> emitLoadAusing: anAstcodeEncoder [
	anAstcodeEncoder encodeLoadAwithDynamicVar: name
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