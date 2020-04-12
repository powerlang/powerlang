Class {
	#name : #MirrorLookup,
	#superclass : #Lookup,
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'as yet unclassified' }
MirrorLookup >> lookup: aSymbol on: aSubject [
	^aSubject _gate mirror lookup: aSymbol
]
