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
	TempCount := 9 thru: 16.
	Id := 17 thru: 24.
	CapturesSelf := 1 bitShift: 25 - 1 
]
