Class {
	#name : #SCalloutMethod,
	#superclass : #SCompiledMethod,
	#type : #variable,
	#instVars : [
		'descriptor',
		'symbol',
		'address'
	],
	#category : #'Powerlang-SCompiler-Backend'
}

{ #category : #constants }
SCalloutMethod >> pragma: anSPragmaNode [
	descriptor := anSPragmaNode info.
	symbol := anSPragmaNode name
]
