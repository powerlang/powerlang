Class {
	#name : #SlotObjectMap,
	#superclass : #ObjectMap,
	#instVars : [
		'slots',
		'arrayed'
	],
	#category : #'Powerlang-PST-Building'
}

{ #category : #accessing }
SlotObjectMap >> add: anObjectMap [
	arrayed ifNil: [ arrayed := OrderedCollection new ].
	arrayed add: anObjectMap
]

{ #category : #accessing }
SlotObjectMap >> arrayed [
^arrayed
]

{ #category : #accessing }
SlotObjectMap >> at: slotname [
	^slots at: slotname
]

{ #category : #accessing }
SlotObjectMap >> at: slotname ifAbsent: aBlock [
	^ slots at: slotname ifAbsent: aBlock
]

{ #category : #accessing }
SlotObjectMap >> at: slotname put: aBootstrappedObject [
	^slots at: slotname put: aBootstrappedObject
]

{ #category : #printing }
SlotObjectMap >> flagsField [
	| variable named small |
	variable := arrayed ifNil: [ 0 ] ifNotNil: [ 2 ].
	named := slots isEmpty
		ifTrue: [ 0 ]
		ifFalse: [ 4 ].
	small := self isSmall
		ifTrue: [ 16r80 ]
		ifFalse: [ 0 ].
	^ variable | named | small
]

{ #category : #accessing }
SlotObjectMap >> initialize [
	slots := OrderedDictionary new
]

{ #category : #printing }
SlotObjectMap >> printOn: aStream [

	(self printSpecialsOn: aStream)
		ifTrue: [ ^ self ].
	super printOn: aStream.
	aStream nextPut: ${.
	slots keysAndValuesDo: [ :name :slot | 
			aStream crtab;
				nextPutAll: name;
				nextPutAll: ' -> ';
				nextPutAll: slot typeString ]
.
	aStream nextPut: $}.
	arrayed
		ifNotNil: [ slots ifNotEmpty: [ aStream nextPutAll: ' ' ].
			arrayed asArray printOn: aStream ].
	aStream nextPutAll: ']'
]

{ #category : #printing }
SlotObjectMap >> printSpecialsOn: aStream [
	| classname |
	classname := self classname.
	classname = 'UndefinedObject'
		ifTrue: [ aStream nextPutAll: '[nil]'.^true ].
	classname = 'True'
		ifTrue: [ aStream nextPutAll: '[true]'.^true ].
	classname = 'False'
		ifTrue: [ aStream nextPutAll: '[false]' . ^true].
		^false
]

{ #category : #accessing }
SlotObjectMap >> size [
	| variable |
	variable := arrayed ifNil: [ 0 ] ifNotNil: [ arrayed size ].
	^ slots size + variable
]

{ #category : #accessing }
SlotObjectMap >> slotByteSize [
	^self size * WordSize
]

{ #category : #accessing }
SlotObjectMap >> slots [
	^slots
]
