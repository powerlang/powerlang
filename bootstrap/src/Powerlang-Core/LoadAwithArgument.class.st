Class {
	#name : #LoadAwithArgument,
	#superclass : #LoadAwithLocal,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #accessing }
LoadAwithArgument >> nativizeUsing: anAssembler for: aBinaryMessageNativizer [
	aBinaryMessageNativizer loadAwithArgument: index in: environment
]
