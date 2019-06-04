Class {
	#name : #Binding,
	#superclass : #Object,
	#category : #'Powerlang-PST-Compiling'
}

{ #category : #'as yet unclassified' }
Binding class >> decodeUsing: anAstcodeDecoder [
	self halt
]

{ #category : #testing }
Binding >> assign: aValue within: anInterpreter [
	^self subclassResponsibility
]

{ #category : #testing }
Binding >> isArgument [
	^false

]

{ #category : #testing }
Binding >> isAssociation [
	^false
]

{ #category : #testing }
Binding >> isInstVar [
	^false
]

{ #category : #testing }
Binding >> isLiteral [
	^false

]

{ #category : #testing }
Binding >> isSelf [
	^false
]

{ #category : #testing }
Binding >> isSuper [
	^false
]

{ #category : #testing }
Binding >> isTemporary [
	^false

]
