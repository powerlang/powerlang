Class {
	#name : #PoolVarBinding,
	#superclass : #AssociationBinding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #testing }
PoolVarBinding >> encodeUsing: anAstcodeEmitter [
	anAstcodeEmitter encodePoolVar: self literal
]

{ #category : #testing }
PoolVarBinding >> isPoolVariableBinding [
	^true
]
