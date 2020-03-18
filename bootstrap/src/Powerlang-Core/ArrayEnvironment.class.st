Class {
	#name : #ArrayEnvironment,
	#superclass : #LocalEnvironment,
	#instVars : [
		'index'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #private }
ArrayEnvironment >> environmentType [
	^EnvironmentValue
]

{ #category : #private }
ArrayEnvironment >> index [
	^index
]

{ #category : #private }
ArrayEnvironment >> index: anInteger [
	index := anInteger
]

{ #category : #testing }
ArrayEnvironment >> isIndirect [
	^index notNil
]

{ #category : #testing }
ArrayEnvironment >> isStack [
	^false
]
