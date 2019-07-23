Class {
	#name : #ObjectMap,
	#superclass : #Object,
	#instVars : [
		'behavior'
	],
	#classVars : [
		'WordSize'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #'class initialization' }
ObjectMap class >> initialize [
	WordSize := 8
]

{ #category : #accessing }
ObjectMap >> behavior [
	^behavior
]

{ #category : #accessing }
ObjectMap >> behavior: anObjectMap [
	behavior := anObjectMap
]

{ #category : #printing }
ObjectMap >> classname [
	| class string |
	class := self klass
		ifNil: [ ^'no-class' ].
	string := class at: 'name' ifAbsent: [^'broken-class' ].
	^string contents
]

{ #category : #accessing }
ObjectMap >> headerByteSize [
	^ self isSmall
		ifTrue: [ 8 ]
		ifFalse: [ 16 ]
]

{ #category : #accessing }
ObjectMap >> isBytes [
	^false
]

{ #category : #testing }
ObjectMap >> isImmediate [
	^ false
]

{ #category : #accessing }
ObjectMap >> isSmall [
	^self size < 256
]

{ #category : #accessing }
ObjectMap >> klass [
	^behavior ifNotNil: [behavior at: 'class' ifAbsent: nil]
]

{ #category : #printing }
ObjectMap >> printOn: aStream [
	behavior ifNil: [ ^ aStream nextPutAll: '[ no-behavior ' ].
	aStream
		nextPutAll: '[';
		nextPutAll: self typeString;
		nextPutAll: ' '
]

{ #category : #accessing }
ObjectMap >> size [
	^ self subclassResponsibility
]

{ #category : #accessing }
ObjectMap >> smallSizeField [
	| size |
	size := self size.
	^ size < 256
		ifTrue: [ size ]
		ifFalse: [ 0 ]
]

{ #category : #printing }
ObjectMap >> typeString [
	| classname |
	classname := self classname.
	^ classname first isVowel
		ifTrue: [ 'an ' , classname ]
		ifFalse: [ 'a ' , classname ]
]
