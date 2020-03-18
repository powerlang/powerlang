Class {
	#name : #TemporaryBinding,
	#superclass : #LocalBinding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #printing }
TemporaryBinding >> description [
	^'temporary ' , name
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
