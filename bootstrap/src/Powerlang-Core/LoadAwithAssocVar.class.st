Class {
	#name : #LoadAwithAssocVar,
	#superclass : #LoadAwithLiteralVar,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #accessing }
LoadAwithAssocVar >> nativizeUsing: anAssembler for: messageNativizer [
	| assoc |
	assoc := messageNativizer methodLiteralAt: index.
	anAssembler
		loadAwithLiteral: assoc;
		loadAwithAindex: 2
]
