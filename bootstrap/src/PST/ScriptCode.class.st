Class {
	#name : #ScriptCode,
	#superclass : #Astcode,
	#instVars : [
		'statements'
	],
	#category : #'PST-Compiling'
}

{ #category : #printing }
ScriptCode >> printOn: aStream [
	statements do: [:statement | 
		statement printOn: aStream] separatedBy: [ aStream nextPutAll: '. ']
]

{ #category : #accessing }
ScriptCode >> statements [
	^ statements
]

{ #category : #accessing }
ScriptCode >> statements: aCollection [
	statements := aCollection
]
