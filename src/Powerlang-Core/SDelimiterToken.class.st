Class {
	#name : #SDelimiterToken,
	#superclass : #SSymbolicToken,
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #converting }
SDelimiterToken >> asSelectorNode [
	^compiler selectorNode symbol: value asString; stretch: stretch
]

{ #category : #evaluating }
SDelimiterToken >> beCharacter [
	value := value isCharacter ifTrue: [value] ifFalse: [value first]
]

{ #category : #testing }
SDelimiterToken >> endsExpression [
	^value = $. or: [value = $]] or: [value = $)] or: [value = $}]
]

{ #category : #testing }
SDelimiterToken >> isAssignment [
	^self is: #':='
]

{ #category : #testing }
SDelimiterToken >> isDelimiter [
	^true
]

{ #category : #evaluating }
SDelimiterToken >> value: aString [
	super value: aString asSymbol
]
