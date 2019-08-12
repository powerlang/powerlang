Class {
	#name : #ObjectMap,
	#superclass : #Object,
	#instVars : [
		'behavior',
		'behaviorDef'
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
	^flavour new initializeWithDef: anRGBehavior size: size
]

{ #category : #accessing }
ObjectMap >> at: index [
	"Return indexed value at given index, starting with 1. This CANNOT be 
	 used for accessing named slots (aka, instance variables), to access 
	 them use #instVarAt:"
	
	self shouldNotImplement  
]

{ #category : #accessing }
ObjectMap >> at: index put: value [
	"Set indexed value at given `index` to `value`. This CANNOT be used for 
	 setting named slots (aka, instance variables), to access them use 
	 #instVarAt:put:"
	
	self shouldNotImplement  
]

{ #category : #accessing }
ObjectMap >> behavior [
	^behavior
]

{ #category : #accessing }
ObjectMap >> behavior: anObjectMap [
	behavior := anObjectMap.
]

{ #category : #accessing }
ObjectMap >> behaviorDef [
	^ behaviorDef
]

{ #category : #'reflective operations' }
ObjectMap >> doesNotUnderstand: aMessage [ 
	| sel |
	
	sel := aMessage selector.
	sel isUnary ifTrue:[
		(behaviorDef allInstVarNames includes: sel) ifTrue:[
			^self slotNamed: sel.
		].
	].
	(sel isKeyword and:[sel numArgs == 1])  ifTrue:[
		sel := sel allButLast.
		(behaviorDef allInstVarNames includes: sel) ifTrue:[
			^self slotNamed: sel put: aMessage arguments first.
		].		
	].
	^ super doesNotUnderstand: aMessage 

]

{ #category : #initialization }
ObjectMap >> initializeWithDef: anRGBehavior size: size [
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
	
	self shouldNotImplement  
]

{ #category : #accessing }
ObjectMap >> slotAt: index put: value [
	"Set named slot at given `index` to `value`. This CANNOT be used 
	 for setting indexed slots  (i.e., variable part of array-like objects), 
   to set them use #at:put:"
	
	self shouldNotImplement  
]

{ #category : #accessing }
ObjectMap >> slotNamed: name [
	"Get a named slot with given `name`"
	
	| index |
	
	index := behaviorDef allInstVarNames indexOf: name.
	index == 0 ifTrue:[
		self error: 'No slot named ''', name , ''''.
		^self.		
	].
	^ self slotAt: index
]

{ #category : #accessing }
ObjectMap >> slotNamed: name put: value [
	"Set a named slot with given `name` to `value`"
	
	| index |
	
	index := behaviorDef allInstVarNames indexOf: name.
	index == 0 ifTrue:[
		self error: 'No slot named ''', name , ''''.
		^self.		
	].
	^ self slotAt: index put: value
]

{ #category : #validation }
ObjectMap >> validate [
	self assert: behavior notNil.
]
