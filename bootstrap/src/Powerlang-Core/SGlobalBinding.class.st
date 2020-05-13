Class {
	#name : #SGlobalBinding,
	#superclass : #SAssociationBinding,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SGlobalBinding class >> decodeUsing: anAstcodeDecoder [
	^ anAstcodeDecoder decodeGlobalBinding
]
