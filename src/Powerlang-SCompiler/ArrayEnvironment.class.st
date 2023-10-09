Class {
	#name : #ArrayEnvironment,
	#superclass : #LocalEnvironment,
	#instVars : [
		'index'
	],
	#category : #'Powerlang-SCompiler-Bindings'
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
ArrayEnvironment >> isCurrent [
	^index isNil
]

{ #category : #testing }
ArrayEnvironment >> isIndirect [
	^self isCurrent not
]

{ #category : #testing }
ArrayEnvironment >> isStack [
	^false
]
