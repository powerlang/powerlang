Class {
	#name : #SScript,
	#superclass : #SExpression,
	#instVars : [
		'statements'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #printing }
SScript >> printOn: aStream indent: anInteger [
	statements
		do: [ :statement | statement printOn: aStream indent: anInteger + 1 ]
		separatedBy: [ aStream nextPutAll: '.'; cr ]
]

{ #category : #accessing }
SScript >> statements [
	^ statements
]

{ #category : #accessing }
SScript >> statements: aCollection [
	statements := aCollection
]
