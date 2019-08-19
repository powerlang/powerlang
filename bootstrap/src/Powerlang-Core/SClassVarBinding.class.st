Class {
	#name : #SClassVarBinding,
	#superclass : #SAssociationBinding,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SClassVarBinding class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeClassVar
]

{ #category : #testing }
SClassVarBinding >> isClassVar [
	^true
]
