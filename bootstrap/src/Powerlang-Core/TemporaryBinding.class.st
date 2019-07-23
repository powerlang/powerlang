Class {
	#name : #TemporaryBinding,
	#superclass : #LocalBinding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #testing }
TemporaryBinding >> assign: aValue within: anInterpreter [
	^anInterpreter temporaryAt: index put: aValue
]

{ #category : #testing }
TemporaryBinding >> isTemporary [
	^true

]
