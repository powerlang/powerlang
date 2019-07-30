Class {
	#name : #TemporaryBinding,
	#superclass : #LocalBinding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #testing }
TemporaryBinding >> assign: aValue within: anInterpreter [
	^anInterpreter temporaryAt: index put: aValue
]

{ #category : #initialization }
TemporaryBinding >> encodeUsing: anAstcodeEncoder [
	anAstcodeEncoder encodeTemporary: index env: environment
]

{ #category : #initialization }
TemporaryBinding >> initialize [
	super initialize.
	environment := StackEnvironment new
]

{ #category : #testing }
TemporaryBinding >> isTemporary [
	^true
]
