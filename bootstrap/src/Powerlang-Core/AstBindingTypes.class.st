Class {
	#name : #AstBindingTypes,
	#superclass : #PSharedPool,
	#classVars : [
		'ArgumentId',
		'ClassVarId',
		'ConstantPoolId',
		'EnsureAisSmallIntegerId',
		'EnsureRisSmallIntegerId',
		'FalseId',
		'GlobalClassId',
		'GlobalValueId',
		'InstVarId',
		'LoadAvisitingArgumentId',
		'LoadAwithArgumentId',
		'LoadAwithClassVarId',
		'LoadAwithFalseId',
		'LoadAwithGlobalId',
		'LoadAwithInstVarId',
		'LoadAwithLiteralId',
		'LoadAwithNilId',
		'LoadAwithSelfId',
		'LoadAwithTemporaryId',
		'LoadAwithTrueId',
		'LoadRvisitingReceiverId',
		'LoadRwithArgumentId',
		'LoadRwithClassVarId',
		'LoadRwithFalseId',
		'LoadRwithGlobalId',
		'LoadRwithInstVarId',
		'LoadRwithLiteralId',
		'LoadRwithNilId',
		'LoadRwithSelfId',
		'LoadRwithTemporaryId',
		'LoadRwithTrueId',
		'NilId',
		'PoolVarId',
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
	InstVarId := 8.
	ClassVarId := 9.
	GlobalValueId := 10.
	GlobalClassId := 11.
	PoolVarId := 12.
	ConstantPoolId := 13.
	LoadRwithSelfId := 20.
	LoadAwithSelfId := 21.
	LoadRwithInstVarId := 22.
	LoadAwithInstVarId := 23.
	LoadRvisitingReceiverId := 24.
	LoadAvisitingArgumentId := 25.
	LoadRwithLiteralId := 26.
	LoadAwithLiteralId := 27.
	EnsureRisSmallIntegerId := 28.
	EnsureAisSmallIntegerId := 29.
	LoadRwithArgumentId := 30.
	LoadAwithArgumentId := 31.
	LoadRwithTemporaryId := 32.
	LoadAwithTemporaryId := 33.
	LoadRwithNilId := 34.
	LoadAwithNilId := 35.
	LoadRwithFalseId := 36.
	LoadAwithFalseId := 37.
	LoadRwithTrueId := 38.
	LoadAwithTrueId := 39.
	LoadRwithGlobalId := 40.
	LoadAwithGlobalId := 41.
	LoadRwithClassVarId := 42.
	LoadAwithClassVarId := 43.
	PushRid := 44.
	PopRid := 45
]
