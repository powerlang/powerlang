Class {
	#name : #PoolVarBinding,
	#superclass : #AssociationBinding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #testing }
PoolVarBinding >> encodeUsing: anAstcodeEmitter [
	anAstcodeEmitter encodePoolVar: association
]

{ #category : #testing }
PoolVarBinding >> isPoolVariableBinding [
	^true
]
