Class {
	#name : #EnumDefWriter,
	#superclass : #DefWriter,
	#instVars : [
		'pool'
	],
	#category : #'Powerlang-Core-Tools'
}

{ #category : #writing }
EnumDefWriter class >> write: pool to: stream [
	^self new
		pool: pool;
		stream: stream;
		write
]

{ #category : #writing }
EnumDefWriter class >> write: pool toFile: filename [
	filename asFileReference writeStreamDo: [ :stream |
		self write: pool to: stream
	]

]

{ #category : #accessing }
EnumDefWriter >> pool [
	^ pool
]

{ #category : #accessing }
EnumDefWriter >> pool: anObject [
	pool := anObject
]

{ #category : #writing }
EnumDefWriter >> write [
	| assocs |
	self 
		writeln:'#ifndef DEFINE_VALUE';
		writeln:'#define DEFINE_VALUE(name, value)';
		writeln:'#endif'.
		
	assocs := pool classPool associations sort: [ :a :b | a value < b value ].
	assocs do: [ :assoc | 
		self write:'DEFINE_VALUE(';
				write: assoc key; 
				write: ', ' ; 
				write: assoc value printString; 
				write: ')'; 
				nl
	].
		
]
