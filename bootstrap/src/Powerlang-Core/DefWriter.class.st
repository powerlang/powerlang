Class {
	#name : #DefWriter,
	#superclass : #Object,
	#instVars : [
		'objects',
		'stream'
	],
	#category : #'Powerlang-Core-Tools'
}

{ #category : #writing }
DefWriter class >> write: objects to: stream [
	^self new
		objects: objects;
		stream: stream;
		write
]

{ #category : #writing }
DefWriter class >> write: objects toFile: filename [
	filename asFileReference writeStreamDo: [ :stream |
		self write: objects to: stream
	]

]

{ #category : #utilities }
DefWriter >> nl [
	stream 
		nextPut: Character cr;
		nextPut: Character lf
]

{ #category : #accessing }
DefWriter >> objects [
	^ objects
]

{ #category : #accessing }
DefWriter >> objects: anObject [
	objects := anObject
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
	objects do:[:each | self write1: each]
]

{ #category : #writing }
DefWriter >> write1: object [
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
