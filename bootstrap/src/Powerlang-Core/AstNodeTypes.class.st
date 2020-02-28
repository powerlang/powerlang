Class {
	#name : #AstNodeTypes,
	#superclass : #PSharedPool,
	#classVars : [
		'AssignmentId',
		'BlockId',
		'BraceId',
		'CascadeId',
		'IdentifierId',
		'LiteralId',
		'MessageId',
		'MethodId',
		'PragmaId',
		'ReturnId'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #'class initialization' }
AstNodeTypes class >> initialize [
	MethodId := 1.
	BlockId := 2.
	IdentifierId := 3.
	LiteralId := 4.
	MessageId := 5.
	CascadeId := 6.
	BraceId := 7.
	AssignmentId := 8.
	ReturnId := 9.
	PragmaId := 10
]
