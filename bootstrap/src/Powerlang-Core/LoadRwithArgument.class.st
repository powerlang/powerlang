Class {
	#name : #LoadRwithArgument,
	#superclass : #LoadRwithLocal,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #'as yet unclassified' }
LoadRwithArgument >> nativizeUsing: anAssembler for: aBinaryMessageNativizer [
	aBinaryMessageNativizer loadRwithArgument: index env: environment
]
