Class {
	#name : #PoolVarBinding,
	#superclass : #AssociationBinding,
	#category : #'Powerlang-Core-SCompiler-Bindings'
}

{ #category : #testing }
PoolVarBinding >> emitLoadAusing: anAstcodeEncoder [
	anAstcodeEncoder encodeLoadAwithPoolVar: association
]

{ #category : #testing }
PoolVarBinding >> encodeUsing: anAstcodeEmitter [
	anAstcodeEmitter encodePoolVar: self literal
]

{ #category : #testing }
PoolVarBinding >> isPoolVariableBinding [
	^true
]
