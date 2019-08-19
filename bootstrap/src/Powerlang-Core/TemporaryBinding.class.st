Class {
	#name : #TemporaryBinding,
	#superclass : #LocalBinding,
	#category : #'Powerlang-Core-SCompiler'
}

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
