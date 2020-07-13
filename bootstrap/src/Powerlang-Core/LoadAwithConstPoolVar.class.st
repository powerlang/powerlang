Class {
	#name : #LoadAwithConstPoolVar,
	#superclass : #LoadAwithLiteralVar,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #accessing }
LoadAwithConstPoolVar >> nativizeUsing: anAssembler for: messageNativizer [
	| literal |
	literal := messageNativizer methodLiteralAt: index.
	anAssembler loadAwithLiteral: literal
]
