Class {
	#name : #DictionaryMirror,
	#superclass : #ObjectMirror,
	#category : #'Powerlang-PST-Mirrors'
}

{ #category : #accessing }
DictionaryMirror >> at: i [
	^self contents at: i
]

{ #category : #private }
DictionaryMirror >> at: key using: transform [
	self do: [:k :value | (transform value: k) = key ifTrue: [^value]].
	^nil
]

{ #category : #accessing }
DictionaryMirror >> contents [
	^self getInstVarNamed: #table
]

{ #category : #accessing }
DictionaryMirror >> contentsSize [
	^self contents size
]

{ #category : #enumerating }
DictionaryMirror >> do: aBlock [
	1 to: self contentsSize do: [:i | | current |
		current := self at: i.
		current reflectsNil ifFalse: [| mirror |
			mirror := current asAssociationMirror.
			aBlock value: mirror key value: mirror value]]
]

{ #category : #private }
DictionaryMirror >> structureType [
	^#Dictionary
]
