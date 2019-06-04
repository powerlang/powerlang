Class {
	#name : #TemporaryBinding,
	#superclass : #LocalBinding,
	#category : #'Powerlang-PST-Compiling'
}

{ #category : #testing }
TemporaryBinding >> assign: aValue within: anInterpreter [
	^anInterpreter temporaryAt: index put: aValue
]

{ #category : #testing }
TemporaryBinding >> isTemporary [
	^true

]
