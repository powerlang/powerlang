Class {
	#name : #SPoolVarBinding,
	#superclass : #SAssociationBinding,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SPoolVarBinding class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodePoolVar
]

{ #category : #testing }
SPoolVarBinding >> isPoolVar [
	^true
]

{ #category : #evaluating }
SPoolVarBinding >> value [
	^association value
]
