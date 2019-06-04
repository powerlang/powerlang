Class {
	#name : #MethodDictionaryMirror,
	#superclass : #ObjectMirror,
	#category : #'Powerlang-PST-Mirrors'
}

{ #category : #accessing }
MethodDictionaryMirror >> at: i [
	^self contents at: i
]

{ #category : #nativizing }
MethodDictionaryMirror >> compiledMethodFor: aSymbol [
	| selector |
	selector := aSymbol asString.
	self do: [:sym :method | sym asLocalString = selector ifTrue: [^method]].
	^nil
]

{ #category : #'as yet unclassified' }
MethodDictionaryMirror >> contents [
	^self getInstVarNamed: #table
]

{ #category : #testing }
MethodDictionaryMirror >> contentsSize [
	^self contents size
]

{ #category : #testing }
MethodDictionaryMirror >> do: aBlock [
	1 to: self contentsSize by: 2 do: [:i | | current |
		current := self at: i.
		current reflectsNil ifFalse: [| method |
			method := self at: i + 1.
			aBlock value: current value: method asMethodMirror]]
]

{ #category : #printing }
MethodDictionaryMirror >> printOn: aStream [
	aStream nextPutAll: 'a MDMirror (' ; nextPutAll: handle printString ; nextPut: $)
]

{ #category : #testing }
MethodDictionaryMirror >> reflectsMethodDictionary [
	^true
]

{ #category : #testing }
MethodDictionaryMirror >> structureType [
	^#MethodDictionary
]

{ #category : #testing }
MethodDictionaryMirror >> tally [
	^self getInstVarNamed: #tally
]
