Class {
	#name : #ObjectMap,
	#superclass : #Object,
	#instVars : [
		'behavior',
		'spec'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #'instance creation' }
ObjectMap class >> new: anRGBehavior [
	^self new: anRGBehavior size: 0
]

{ #category : #'instance creation' }
ObjectMap class >> new: anRGBehavior size: size [
	| flavour |
	self assert: (anRGBehavior isVariable or:[size == 0]).
	
	anRGBehavior name == #SmallInteger ifTrue:[
		flavour := SmallintObjectMap
	] ifFalse:[
		anRGBehavior isBytes ifTrue:[
			flavour := ByteObjectMap
		] ifFalse:[
			flavour := SlotObjectMap
		]
	].
	^flavour new initializeAs: anRGBehavior sized: size
]

{ #category : #accessing }
ObjectMap >> at: index [
	"Return indexed value at given index, starting with 1. This CANNOT be 
	 used for accessing named slots (aka, instance variables), to access 
	 them use #instVarAt:"
	
	self subclassResponsibility  
]

{ #category : #accessing }
ObjectMap >> at: index put: value [
	"Set indexed value at given `index` to `value`. This CANNOT be used for 
	 setting named slots (aka, instance variables), to access them use 
	 #instVarAt:put:"
	
	self subclassResponsibility  
]

{ #category : #accessing }
ObjectMap >> behavior [
	^behavior
]

{ #category : #accessing }
ObjectMap >> behavior: anObjectMap [
	behavior := anObjectMap.
]

{ #category : #initialization }
ObjectMap >> initializeAs: anRGBehavior sized: size [
	self subclassResponsibility
]

{ #category : #testing }
ObjectMap >> isImmediate [ 
	^false
]

{ #category : #accessing }
ObjectMap >> size [
	"Return the size if this object, that this, the value of
	 size field in object header. 
	
	 For slot (pointer) objects, this is a number of slots. 
	 For byte objects, this is a number of bytes. "
	
	self subclassResponsibility 
]

{ #category : #accessing }
ObjectMap >> slotAt: index [
	"Get named slot at given `index`, starting with 1. This CANNOT be used 
	 for accessing indexed slots  (i.e., variable part of array-like objects), 
   to set them use #at:"
	
	self subclassResponsibility  
]

{ #category : #accessing }
ObjectMap >> slotAt: index put: value [
	"Set named slot at given `index` to `value`. This CANNOT be used 
	 for setting indexed slots  (i.e., variable part of array-like objects), 
   to set them use #at:put:"
	
	self subclassResponsibility
]

{ #category : #accessing }
ObjectMap >> slotNamed: name [
	"Get a named slot with given `name`"
	
	| index |
	index := spec allInstVarNames indexOf: name.
	index == 0 ifTrue:[ ^self error: 'No slot named "', name , '"'].
	^ self slotAt: index
]

{ #category : #accessing }
ObjectMap >> slotNamed: name put: value [
	"Set a named slot with given `name` to `value`"
	
	| index |
	index := spec allInstVarNames indexOf: name.
	index == 0 ifTrue: [ ^self error: 'No slot named "', name , '"'	].
	^ self slotAt: index put: value
]

{ #category : #accessing }
ObjectMap >> spec [
	^ spec
]

{ #category : #validation }
ObjectMap >> validate [
	self assert: behavior notNil.
]
