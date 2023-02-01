Class {
	#name : #SymbolMap,
	#superclass : #ByteObjectMap,
	#instVars : [
		'symbol'
	],
	#category : #'Powerlang-Core-Execution-Ring'
}

{ #category : #'instance creation' }
SymbolMap class >> new: anRGBehavior symbol: aSymbol [
	| bytes |
	bytes := aSymbol copyWith: Character null.
	^ self new
		initializeAs: anRGBehavior sized: bytes size;
		fillFrom: bytes;
		symbol: aSymbol
]

{ #category : #accessing }
SymbolMap >> asString [
	^ symbol
]

{ #category : #accessing }
SymbolMap >> contentsString [
	^symbol storeString

]

{ #category : #accessing }
SymbolMap >> symbol [
	^symbol
]

{ #category : #accessing }
SymbolMap >> symbol: aSymbol [
	symbol := aSymbol 
]
