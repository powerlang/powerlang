Class {
	#name : #BootstrapDictionary,
	#superclass : #Object,
	#instVars : [
		'globals',
		'constant'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #'instance creation' }
BootstrapDictionary class >> withAll: variables [
	^self withAll: variables constant: false
]

{ #category : #'instance creation' }
BootstrapDictionary class >> withAll: variables constant: aBoolean [
	| result |
	result := self new constant: aBoolean.
	variables do: [ :assoc | result at: assoc key asString put: assoc ].
	^ result
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
BootstrapDictionary >> associations [
	^ globals values
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
BootstrapDictionary >> constant: aBoolean [
	constant := aBoolean
]

{ #category : #accessing }
BootstrapDictionary >> do: aBlock [
	^globals do: aBlock
]

{ #category : #accessing }
BootstrapDictionary >> initialize [
	globals := Dictionary new.
	constant := false
]

{ #category : #accessing }
BootstrapDictionary >> isConstant [
	^constant
]

{ #category : #accessing }
BootstrapDictionary >> keys [
	^globals keys
]
