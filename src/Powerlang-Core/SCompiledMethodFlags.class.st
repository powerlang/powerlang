Class {
	#name : #SCompiledMethodFlags,
	#superclass : #PSharedPool,
	#classVars : [
		'ArgCount',
		'BlockCount',
		'CapturesSelf',
		'Debuggable',
		'EnvCount',
		'HasEnvironment',
		'HasFrame',
		'TempCount'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'class initialization' }
SCompiledMethodFlags class >> initialize [
	ArgCount := 1 thru: 6.
	BlockCount := 7 thru: 13.
	TempCount := 14 thru: 21.
	CapturesSelf := 1 bitShift: 22 - 1.
	HasEnvironment := 1 bitShift: 23 - 1.
	HasFrame := 1 bitShift: 24 - 1.
	Debuggable := 1 bitShift: 25 - 1.
	EnvCount := 26 thru: 31
]
