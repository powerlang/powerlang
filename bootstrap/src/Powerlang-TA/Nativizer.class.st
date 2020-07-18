Class {
	#name : #Nativizer,
	#superclass : #Object,
	#instVars : [
		'cg'
	],
	#category : #'Powerlang-TA'
}

{ #category : #'as yet unclassified' }
Nativizer >> applyFixups [
]

{ #category : #initialization }
Nativizer >> initialize [ 
	cg := ARMCodeGenerator new
]

{ #category : #initialization }
Nativizer >> loadRwithSmallInteger: anInteger [
	cg load: "abi regR" 1 withImmediate: "(omf tagSI: anInteger)" (anInteger bitShift: 1) + 1

]

{ #category : #'as yet unclassified' }
Nativizer >> nativeCode [
	^ NativeCode new code: cg code
]

{ #category : #initialization }
Nativizer >> reset [
]

{ #category : #initialization }
Nativizer >> restoreCallerM [
]

{ #category : #initialization }
Nativizer >> restoreCallerSelf [
]

{ #category : #initialization }
Nativizer >> return [

]
