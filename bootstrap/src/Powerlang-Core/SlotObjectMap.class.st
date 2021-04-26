Class {
	#name : #SlotObjectMap,
	#superclass : #ObjectMap,
	#instVars : [
		'slots',
		'hash'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #'instance creation' }
SlotObjectMap class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #'instance creation' }
SlotObjectMap class >> new: anRGBehavior size: size withAll: value [
	| obj |
	obj := self new: anRGBehavior size: size.
	^obj atAllPut: value; yourself
	
]

{ #category : #accessing }
SlotObjectMap >> allInstVarNames [
	| c |
	^ spec properties
		at: #allInstVarNames
		ifAbsentPut: [ spec isMeta
				ifTrue: [ c := spec environment at: #Class.
					c allInstVarNames , spec allInstVarNames ]
				ifFalse: [ spec allInstVarNames ] ]
]

{ #category : #accessing }
SlotObjectMap >> arrayedSize [
	"
	 Return the size of the arrayed part of this object, that this,
	 the value of size field in object header minus the instSize. 
	"

	^ self size - self instSize
]

{ #category : #accessing }
SlotObjectMap >> asBoolean [
	spec name = #True ifTrue: [ ^true ].	spec name = #False ifTrue: [ ^false ].
		self ASSERT: false
]

{ #category : #accessing }
SlotObjectMap >> at: index [
	"Return indexed value at given index, starting with 1. This CANNOT be 
	 used for accessing named slots (aka, instance variables), to access 
	 them use #instVarAt:"
	
	self assert: (index between: 1 and: slots size - self instSize).
	^slots at: self instSize + index
]

{ #category : #accessing }
SlotObjectMap >> at: index put: value [
	"Set indexed value at given `index` to `value`. This CANNOT be used for 
	 setting named slots (aka, instance variables), to access them use 
	 #instVarAt:put:"
	self assert: spec isVariable.
	self assert: (index between: 1 and: slots size - self instSize).
	self assert: (value isKindOf: ObjectMap).
	^slots at: self instSize + index put: value
]

{ #category : #initialization }
SlotObjectMap >> atAllPut: value [
	slots atAllPut: value
]

{ #category : #accessing }
SlotObjectMap >> basicAt: index [
	"Return indexed value at given raw index, starting with 1"

	self assert: (index between: 1 and: slots size).
	^ slots at: index
]

{ #category : #accessing }
SlotObjectMap >> bodySizeInBytes [	
	^ self sizeInBytes

]

{ #category : #accessing }
SlotObjectMap >> doesNotUnderstand: aMessage [
	| sel ivars |
	sel := aMessage selector.
	ivars := self allInstVarNames.
	sel isUnary
		ifTrue: [ (ivars includes: sel)
				ifTrue: [ ^ self slotNamed: sel ] ].
	(sel isKeyword and: [ sel numArgs == 1 ])
		ifTrue: [ sel := sel allButLast.
			(ivars includes: sel)
				ifTrue: [ ^ self slotNamed: sel put: aMessage arguments first ] ].
	^ super doesNotUnderstand: aMessage
]

{ #category : #testing }
SlotObjectMap >> headerFlags [
	| variable named small |
	variable := spec isVariable ifTrue: [2] ifFalse: [0].
	named := spec instSize == 0 ifTrue: [0] ifFalse: [4].
	small := self isSmall ifTrue: [16r80] ifFalse: [0].
	^ variable | named | small
]

{ #category : #testing }
SlotObjectMap >> headerHash [
	^hash
]

{ #category : #testing }
SlotObjectMap >> headerHash: anInteger [
	hash := anInteger
]

{ #category : #testing }
SlotObjectMap >> initialize [
	hash := 0
]

{ #category : #initialization }
SlotObjectMap >> initializeAs: anRGBehavior sized: size [
	self assert: anRGBehavior notNil.
	self assert: anRGBehavior isPointers.
	self assert: (anRGBehavior isVariable or: [ size == 0 ]).
	spec := anRGBehavior.
	slots := Array new: self instSize + size
]

{ #category : #accessing }
SlotObjectMap >> instSize [
	| c |
	^ spec properties at: #instSize ifAbsentPut: [spec isMeta
		ifTrue: [ c := spec environment at: #Class.
			
			c instSize + spec instSize ]
		ifFalse: [ spec instSize ]]
]

{ #category : #accessing }
SlotObjectMap >> isPointers [
	^true
]

{ #category : #accessing }
SlotObjectMap >> printOn: aStream [
	aStream
		nextPutAll: '<<';
		nextPutAll: spec name withArticle;
		nextPutAll: '>>'
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
SlotObjectMap >> sizeInBytes [	
	^ self size * self wordSize

]

{ #category : #accessing }
SlotObjectMap >> slotAt: index [
	"Get named slot at given `index`, starting with 1. This CANNOT be used 
	 for accessing indexed slots  (i.e., variable part of array-like objects), 
   to set them use #at:"
	
	self assert: (index between: 1 and: self instSize).
	^slots at: index
]

{ #category : #accessing }
SlotObjectMap >> slotAt: index put: value [
	"Set named slot at given `index` to `value`. This CANNOT be used 
	 for setting indexed slots  (i.e., variable part of array-like objects), 
   to set them use #at:put:"
	
	self assert: (index between: 1 and: self instSize).
	self assert: (value isKindOf: ObjectMap).
	^slots at: index put: value
]

{ #category : #accessing }
SlotObjectMap >> slots [
	^slots
]

{ #category : #accessing }
SlotObjectMap >> slotsDo: aBlock [
	slots do: aBlock
]

{ #category : #validation }
SlotObjectMap >> validate [
	super validate.
	slots withIndexDo:[:value :index | self assert: value notNil ]
]

{ #category : #accessing }
SlotObjectMap >> value [
	| message |
	(self allInstVarNames includes: #value) ifFalse: [ ^super value ].
	message := Message selector: #value.
	^ self doesNotUnderstand: message
]
