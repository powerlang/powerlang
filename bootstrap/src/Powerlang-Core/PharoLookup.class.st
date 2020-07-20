Class {
	#name : #PharoLookup,
	#superclass : #MethodLookup,
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'meta accessing' }
PharoLookup >> lookup: aSymbol on: aSubject [
	^ aSubject _gate handle oid class lookupSelector: aSymbol
]
