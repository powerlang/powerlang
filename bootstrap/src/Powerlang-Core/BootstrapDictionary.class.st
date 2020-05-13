Class {
	#name : #BootstrapDictionary,
	#superclass : #Object,
	#instVars : [
		'globals'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #'instance creation' }
BootstrapDictionary class >> withAll: variables [
	| result |
	result := self new.
	variables do: [ :v | result at: v name put: v association ].
	^result
]

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
BootstrapDictionary >> do: aBlock [
	^globals do: aBlock
]

{ #category : #accessing }
BootstrapDictionary >> initialize [
	globals := Dictionary new
]

{ #category : #accessing }
BootstrapDictionary >> keys [
	^globals keys
]
