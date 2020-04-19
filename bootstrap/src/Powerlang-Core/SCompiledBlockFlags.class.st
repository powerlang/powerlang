Class {
	#name : #SCompiledBlockFlags,
	#superclass : #PSharedPool,
	#classVars : [
		'ArgCount',
		'CapturesSelf',
		'EnvCount',
		'Id',
		'TempCount'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'class initialization' }
SCompiledBlockFlags class >> initialize [
	ArgCount := 1 thru: 8.
	TempCount := 9 thru: 16.
	Id := 17 thru: 24.
	CapturesSelf := 1 bitShift: 25 - 1.
	EnvCount := 26 thru: 31.

]
