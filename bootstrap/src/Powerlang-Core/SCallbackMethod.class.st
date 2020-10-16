Class {
	#name : #SCallbackMethod,
	#superclass : #SCompiledMethod,
	#type : #variable,
	#instVars : [
		'receiver',
		'descriptor'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #accessing }
SCallbackMethod >> descriptor [
	^descriptor
]

{ #category : #accessing }
SCallbackMethod >> descriptor: anFFIDescriptor [
	descriptor := anFFIDescriptor 
]

{ #category : #accessing }
SCallbackMethod >> isCallback [
	^true
]

{ #category : #accessing }
SCallbackMethod >> pragma: anSPragmaNode [
	descriptor := anSPragmaNode info
]
