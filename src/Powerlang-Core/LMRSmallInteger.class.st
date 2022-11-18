Class {
	#name : #LMRSmallInteger,
	#superclass : #LMRObject,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-Execution-LMR'
}

{ #category : #comparing }
LMRSmallInteger >> = anObject [
	anObject class == self class
		ifFalse: [ ^ false ].
	^ value = anObject value
]

{ #category : #accessing }
LMRSmallInteger >> hash [
	^value hash
]

{ #category : #accessing }
LMRSmallInteger >> isImmediate [
	^true
]

{ #category : #accessing }
LMRSmallInteger >> printOn: aStream [
	aStream
		nextPut: $<;
		print: value;
		nextPut: $>
]

{ #category : #accessing }
LMRSmallInteger >> value [
	^value
]

{ #category : #accessing }
LMRSmallInteger >> value: anInteger [
	value := anInteger
]
