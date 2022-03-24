Class {
	#name : #BootstrapDictionaryMap,
	#superclass : #ObjectMap,
	#instVars : [
		'image',
		'assocs',
		'realSpec',
		'constant'
	],
	#category : #'Powerlang-Core-Execution-Ring'
}

{ #category : #accessing }
BootstrapDictionaryMap >> associations [
	^ assocs values
]

{ #category : #accessing }
BootstrapDictionaryMap >> at: aSymbol [
	^self
		at: aSymbol
		ifAbsent: [ self error: aSymbol , ' was not found in dictionary' ]
]

{ #category : #accessing }
BootstrapDictionaryMap >> at: aSymbol ifAbsent: aBlock [
	| assoc |
	assoc := assocs
		at: aSymbol
		ifAbsent: [ ^ aBlock value ].
	^ assoc value
]

{ #category : #accessing }
BootstrapDictionaryMap >> at: aSymbol ifPresent: aBlock [
	| value |
	value := self at: aSymbol ifAbsent: [ ^ nil ].
	^ aBlock value: value
]

{ #category : #accessing }
BootstrapDictionaryMap >> at: aSymbol put: anObject [
	| s assoc value |
	assoc := assocs
		at: aSymbol
		ifAbsentPut: [ s := image newSymbol: aSymbol.
			assoc := image newAssociation: s -> image nil ].
	value := image transferLiteralDeep: anObject.
	assoc value: value .
	^ value
]

{ #category : #accessing }
BootstrapDictionaryMap >> beConstant [
	constant := true
]

{ #category : #accessing }
BootstrapDictionaryMap >> image: aPowertalkRingImage [
	image := aPowertalkRingImage
]

{ #category : #accessing }
BootstrapDictionaryMap >> includesKey: aSymbol [
	^assocs includesKey: aSymbol
]

{ #category : #accessing }
BootstrapDictionaryMap >> initialize [
	assocs := Dictionary new.
	constant := false
]

{ #category : #accessing }
BootstrapDictionaryMap >> initializeAs: anRGBehavior [
	spec := anRGBehavior
]

{ #category : #accessing }
BootstrapDictionaryMap >> isConstant [
	^ constant
]

{ #category : #accessing }
BootstrapDictionaryMap >> isDictionaryMap [ 
	^ true
]

{ #category : #accessing }
BootstrapDictionaryMap >> keys [
	| keys |
	keys := assocs values collect: #key.
	^image newArray: keys
]

{ #category : #accessing }
BootstrapDictionaryMap >> realSpec [
	^realSpec
]

{ #category : #accessing }
BootstrapDictionaryMap >> realSpec: anRGBehavior [
	realSpec := anRGBehavior 
]
