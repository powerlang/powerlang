Class {
	#name : #ClassVarBinding,
	#superclass : #AssociationBinding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'as yet unclassified' }
ClassVarBinding class >> decodeUsing: anAstcodeDecoder [
	^ anAstcodeDecoder decodeClassVar
]

{ #category : #printing }
ClassVarBinding >> printOn: aStream [
	aStream nextPutAll: 'ClassVarId'
]
