Class {
	#name : #PCompiledMethodFlags,
	#superclass : #PSharedPool,
	#classVars : [
		'ArgCount',
		'BlockCount',
		'EnvCount',
		'TempCount'
	],
	#category : #'Powerlang-Core-PST'
}

{ #category : #'class initialization' }
PCompiledMethodFlags class >> initialize [
	ArgCount := 1 thru: 8.
	BlockCount := 8 thru: 16.
	TempCount := 17 thru: 24.
	EnvCount := 25 thru: 31.
]
