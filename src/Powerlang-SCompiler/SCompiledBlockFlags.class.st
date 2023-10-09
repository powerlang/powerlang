Class {
	#name : #SCompiledBlockFlags,
	#superclass : #PSharedPool,
	#classVars : [
		'BlockArgCount',
		'BlockCapturesHome',
		'BlockCapturesSelf',
		'BlockEnvCount',
		'BlockId',
		'BlockTempCount'
	],
	#category : #'Powerlang-SCompiler-Backend'
}

{ #category : #'class initialization' }
SCompiledBlockFlags class >> initialize [
	BlockArgCount := 1 thru: 6.
	BlockTempCount := 7 thru: 14.
	BlockId := 15 thru: 22.
	BlockCapturesSelf := 1 bitShift: 23 - 1.
	BlockCapturesHome := 1 bitShift: 24 - 1.
	BlockEnvCount := 25 thru: 31
]
