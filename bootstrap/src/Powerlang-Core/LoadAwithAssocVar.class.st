Class {
	#name : #LoadAwithAssocVar,
	#superclass : #LoadAwithLiteralVar,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #accessing }
LoadAwithAssocVar >> nativizeUsing: anAssembler for: messageNativizer [
	| i |
	i := messageNativizer methodLiteralIndexFrom: index.
	anAssembler
		loadAwithMindex: i;
		loadAwithAindex: 2
]
