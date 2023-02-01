Class {
	#name : #MethodLookup,
	#superclass : #Object,
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'meta accessing' }
MethodLookup >> lookup: aSymbol on: aSubject [
	^self subclassResponsibility
]
