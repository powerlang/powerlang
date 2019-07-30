Class {
	#name : #PCompiledBlockFlags,
	#superclass : #SharedPool,
	#classVars : [
		'ArgCount',
		'CapturesSelf',
		'Id',
		'TempCount'
	],
	#category : #'Powerlang-Core-PST'
}

{ #category : #'class initialization' }
PCompiledBlockFlags class >> initialize [
	ArgCount := 1 thru: 8.
	TempCount := 9 to: 16.
	Id := 17 to: 24.
	CapturesSelf := 1 bitShift: 25 - 1 
]
