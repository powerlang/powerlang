Class {
	#name : #BootstrapDictionary,
	#superclass : #Object,
	#instVars : [
		'globals'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #accessing }
BootstrapDictionary >> associationAt: aSymbol [
	
	^globals at: aSymbol.
	
]

{ #category : #accessing }
BootstrapDictionary >> associationAt: aSymbol ifAbsent: aBlock [
	^globals at: aSymbol ifAbsent: [^aBlock value ].

]

{ #category : #accessing }
BootstrapDictionary >> at: aSymbol [
	| assoc |
	assoc := globals at: aSymbol.
	^assoc value
]

{ #category : #accessing }
BootstrapDictionary >> at: aSymbol ifAbsent: aBlock [
	| assoc |
	assoc := globals at: aSymbol ifAbsent: [^aBlock value].
	^ assoc value
]

{ #category : #accessing }
BootstrapDictionary >> at: aSymbol put: anAssociation [
	globals at: aSymbol put: anAssociation
]

{ #category : #accessing }
BootstrapDictionary >> initialize [
	globals := Dictionary new
]

{ #category : #accessing }
BootstrapDictionary >> keys [
	^globals keys
]
