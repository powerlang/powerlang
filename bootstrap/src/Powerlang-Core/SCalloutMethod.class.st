Class {
	#name : #SCalloutMethod,
	#superclass : #SCompiledMethod,
	#type : #variable,
	#instVars : [
		'descriptor',
		'symbol',
		'address'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #constants }
SCalloutMethod >> pragma: anSPragmaNode [
	descriptor := anSPragmaNode info.
	symbol := anSPragmaNode name
]
