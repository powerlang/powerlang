Class {
	#name : #PharoLookup,
	#superclass : #Lookup,
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'meta accessing' }
PharoLookup >> lookup: aSymbol on: aSubject [
	^ aSubject _gate handle oid class lookupSelector: aSymbol
]
