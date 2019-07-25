Class {
	#name : #DelimiterToken,
	#superclass : #SymbolicToken,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #converting }
DelimiterToken >> asSelectorNode [
	^compiler selectorNode symbol: value asString; stretch: stretch
]

{ #category : #evaluating }
DelimiterToken >> beCharacter [
	value := value isCharacter ifTrue: [value] ifFalse: [value first]
]

{ #category : #testing }
DelimiterToken >> endsExpression [
	^value = $. or: [value = $]] or: [value = $)] or: [value = $}]
]

{ #category : #testing }
DelimiterToken >> isAssignment [
	^self is: #':='
]

{ #category : #testing }
DelimiterToken >> isDelimiter [
	^true
]

{ #category : #evaluating }
DelimiterToken >> value: aString [
	super value: aString asSymbol
]
