Class {
	#name : #SConstantPoolBinding,
	#superclass : #SPoolVarBinding,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SConstantPoolBinding class >> decodeUsing: anAstcodeDecoder [
	^ anAstcodeDecoder decodeConstantPoolVar
]

{ #category : #evaluating }
SConstantPoolBinding >> value [
	^association
]
