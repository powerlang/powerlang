Class {
	#name : #LoadRwithTemporary,
	#superclass : #LoadRwithLocal,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #'as yet unclassified' }
LoadRwithTemporary >> nativizeUsing: anAssembler for: aBinaryMessageNativizer [
	aBinaryMessageNativizer loadRwithTemporary: index env: environment
]
