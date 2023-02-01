Class {
	#name : #AstBindingTypes,
	#superclass : #PSharedPool,
	#classVars : [
		'ArgumentId',
		'DynamicVarId',
		'FalseId',
		'NestedDynamicVarId',
		'NilId',
		'PopRid',
		'PushRid',
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
	DynamicVarId := 14.
	NestedDynamicVarId := 15.
	PushRid := 50.
	PopRid := 51
]
