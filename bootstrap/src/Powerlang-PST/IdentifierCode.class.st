Class {
	#name : #IdentifierCode,
	#superclass : #Astcode,
	#instVars : [
		'binding'
	],
	#category : #'Powerlang-PST-Compiling'
}

{ #category : #'as yet unclassified' }
IdentifierCode class >> decodeUsing: anAstcodeDecoder [
	^ anAstcodeDecoder decodeIdentifier
]

{ #category : #accessing }
IdentifierCode >> binding [
	^binding
]

{ #category : #accessing }
IdentifierCode >> binding: aBinding [
	binding := aBinding
]

{ #category : #testing }
IdentifierCode >> isIdentifier [
	^true
]

{ #category : #printing }
IdentifierCode >> printOn: aStream [
	aStream nextPutAll: '{IdentifierId. '.
	binding printOn: aStream.
	aStream nextPutAll: '}'
]
