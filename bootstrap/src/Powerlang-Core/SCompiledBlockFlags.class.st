Class {
	#name : #SCompiledBlockFlags,
	#superclass : #PSharedPool,
	#classVars : [
		'BlockArgCount',
		'BlockEnvCount',
		'BlockTempCount',
		'CapturesHome',
		'CapturesSelf',
		'Id'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'class initialization' }
SCompiledBlockFlags class >> initialize [
	BlockArgCount := 1 thru: 6.
	BlockTempCount := 7 thru: 14.
	Id := 15 thru: 22.
	CapturesSelf := 1 bitShift: 23 - 1.
	CapturesHome := 1 bitShift: 24 - 1.
	BlockEnvCount := 25 thru: 31
]
