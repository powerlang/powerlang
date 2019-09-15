Class {
	#name : #DefWriter,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'Powerlang-Core-Tools'
}

{ #category : #utilities }
DefWriter >> nl [
	stream 
		nextPut: Character cr;
		nextPut: Character lf
]

{ #category : #accessing }
DefWriter >> stream [
	^ stream
]

{ #category : #accessing }
DefWriter >> stream: anObject [
	stream := anObject
]

{ #category : #writing }
DefWriter >> write [
	self subclassResponsibility 
]

{ #category : #utilities }
DefWriter >> write: aString [
	stream nextPutAll: aString.
]

{ #category : #utilities }
DefWriter >> writeln: aString [
	self write: aString.
	self nl.
]
