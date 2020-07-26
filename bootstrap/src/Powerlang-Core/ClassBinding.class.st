Class {
	#name : #ClassBinding,
	#superclass : #GlobalBinding,
	#category : #'Powerlang-Core-SCompiler-Bindings'
}

{ #category : #testing }
ClassBinding >> encodeUsing: anAstcodeEncoder [
	anAstcodeEncoder encodeClassBinding: association
]

{ #category : #testing }
ClassBinding >> isClassBinding [
	^true
]
