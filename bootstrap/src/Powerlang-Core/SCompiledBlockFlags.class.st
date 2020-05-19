Class {
	#name : #SCompiledBlockFlags,
	#superclass : #PSharedPool,
	#classVars : [
		'ArgCount',
		'CapturesHome',
		'CapturesSelf',
		'EnvCount',
		'Id',
		'TempCount'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'class initialization' }
SCompiledBlockFlags class >> initialize [
	ArgCount := 1 thru: 6.
	TempCount := 7 thru: 14.
	Id := 15 thru: 22.
	CapturesSelf := 1 bitShift: 23 - 1.
	CapturesHome := 1 bitShift: 24 - 1.
	EnvCount := 25 thru: 31
]
