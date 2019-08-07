Class {
	#name : #KernelResource,
	#superclass : #TestResource,
	#instVars : [
		'kernel'
	],
	#category : #'Powerlang-Tests-Building'
}

{ #category : #accessing }
KernelResource >> get [ 
	^kernel
]

{ #category : #running }
KernelResource >> setUp [
	| repo |
	
	super setUp.
	repo := TonelRepository new directory: '../pst' asFileReference.
  kernel := repo asRingEnvironmentWith: #(kernel).
  kernel clean.
]

{ #category : #running }
KernelResource >> tearDown [
	super tearDown.
	kernel := nil
]
