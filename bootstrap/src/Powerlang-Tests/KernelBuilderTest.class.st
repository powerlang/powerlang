Class {
	#name : #KernelBuilderTest,
	#superclass : #TestCase,
	#instVars : [
		'builder'
	],
	#category : #'Powerlang-Tests-Building'
}

{ #category : #running }
KernelBuilderTest class >> defaultTimeLimit [
	^ 60 seconds
]
