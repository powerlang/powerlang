Class {
	#name : #LoadAwithTemporary,
	#superclass : #LoadAwithLocal,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #accessing }
LoadAwithTemporary >> nativizeUsing: anAssembler for: aBinaryMessageNativizer [
	aBinaryMessageNativizer loadAwithTemporary: index in: environment
]
