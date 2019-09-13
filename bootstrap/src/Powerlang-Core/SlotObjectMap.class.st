Class {
	#name : #SlotObjectMap,
	#superclass : #ObjectMap,
	#instVars : [
		'slots'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #accessing }
SlotObjectMap >> at: index [
	"Return indexed value at given index, starting with 1. This CANNOT be 
	 used for accessing named slots (aka, instance variables), to access 
	 them use #instVarAt:"
	
	self assert: (index between: 1 and: slots size - spec instSize).
	^slots at: spec instSize + index
]

{ #category : #accessing }
SlotObjectMap >> at: index put: value [
	"Set indexed value at given `index` to `value`. This CANNOT be used for 
	 setting named slots (aka, instance variables), to access them use 
	 #instVarAt:put:"
	self assert: spec isVariable.
	self assert: (index between: 1 and: slots size - spec instSize).
	self assert: (value isKindOf: ObjectMap).
	^slots at: spec instSize + index put: value
]

{ #category : #accessing }
SlotObjectMap >> bodySizeInBytes [
	"Return the size of object body(s) in bytes. 
	 This DOES NOT INCLUDE any passing."
	
	^ self size * self oopSizeInBytes

]

{ #category : #initialization }
SlotObjectMap >> initializeWithDef: anRGBehavior size: size [
	self assert: anRGBehavior notNil.
	self assert: anRGBehavior isPointers.
	self assert:(anRGBehavior isVariable or:[size == 0]).
	
	spec := anRGBehavior.
	slots := Array new: (anRGBehavior instSize + size)
	
	
]

{ #category : #testing }
SlotObjectMap >> isPointers [
	^true
]

{ #category : #accessing }
SlotObjectMap >> size [
	"Return the size if this object, that this, the value of
	 size field in object header. 
	
	 For slot (pointer) objects, this is a number of slots. 
	 For byte objects, this is a number of bytes. "
	
	^ slots size
]

{ #category : #accessing }
SlotObjectMap >> slotAt: index [
	"Get named slot at given `index`, starting with 1. This CANNOT be used 
	 for accessing indexed slots  (i.e., variable part of array-like objects), 
   to set them use #at:"
	
	self assert: (index between: 1 and: spec instSize).
	^slots at: index
]

{ #category : #accessing }
SlotObjectMap >> slotAt: index put: value [
	"Set named slot at given `index` to `value`. This CANNOT be used 
	 for setting indexed slots  (i.e., variable part of array-like objects), 
   to set them use #at:put:"
	
	self assert: (index between: 1 and: spec instSize).
	self assert: (value isKindOf: ObjectMap).
	^slots at: index put: value
]

{ #category : #accessing }
SlotObjectMap >> slots [
	^ slots
]

{ #category : #accessing }
SlotObjectMap >> smallHeaderFlags [
	"Return value of 'flags' field of small header"

	 | variable named small |
	
    variable := spec isVariable ifNil: [ 0 ] ifNotNil: [ 2 ].
    named := spec instSize == 0 ifTrue: [ 0 ] ifFalse: [ 4 ].
    small := self isSmall ifTrue: [ 16r80 ] ifFalse: [ 0 ].
    ^ variable | named | small

]

{ #category : #validation }
SlotObjectMap >> validate [
	super validate.
	slots withIndexDo:[:value :index | self assert: value notNil ]
]
