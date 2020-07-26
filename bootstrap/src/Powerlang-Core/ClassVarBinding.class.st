Class {
	#name : #ClassVarBinding,
	#superclass : #AssociationBinding,
	#category : #'Powerlang-Core-SCompiler-Bindings'
}

{ #category : #testing }
ClassVarBinding >> emitLoadAusing: anAstcodeEncoder [
	anAstcodeEncoder encodeLoadAwithClassVar: association
]

{ #category : #testing }
ClassVarBinding >> encodeUsing: anAstcodeEmitter [
	anAstcodeEmitter encodeClassVar: association
]

{ #category : #testing }
ClassVarBinding >> isClassVariable [
	^true
]
