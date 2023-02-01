Class {
	#name : #MirrorLookup,
	#superclass : #MethodLookup,
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'as yet unclassified' }
MirrorLookup >> lookup: aSymbol on: aSubject [
	^aSubject _gate mirror lookup: aSymbol
]
