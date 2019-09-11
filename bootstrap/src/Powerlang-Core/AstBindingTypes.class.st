Class {
	#name : #AstBindingTypes,
	#superclass : #SharedPool,
	#classVars : [
		'ArgumentId',
		'ClassVarId',
		'ConstantPoolId',
		'FalseId',
		'GlobalClassId',
		'GlobalValueId',
		'InstVarId',
		'NilId',
		'PoolVarId',
		'SelfId',
		'SuperId',
		'TemporaryId',
		'TrueId'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #'class initialization' }
AstBindingTypes class >> initialize [
	NilId := 1.
	TrueId := 2.
	FalseId := 3.
	ArgumentId := 4.
	TemporaryId := 5.
	SelfId := 6.
	SuperId := 7.
	InstVarId := 8.
	ClassVarId := 9.
	GlobalValueId := 10.
	GlobalClassId := 11.
	PoolVarId := 12.
	ConstantPoolId := 13.
]
