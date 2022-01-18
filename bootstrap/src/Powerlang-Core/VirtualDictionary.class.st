Class {
	#name : #VirtualDictionary,
	#superclass : #Object,
	#instVars : [
		'constant',
		'cache',
		'nilObj',
		'dictionary',
		'image'
	],
	#category : #'Powerlang-Core-Emulation'
}

{ #category : #'instance creation' }
VirtualDictionary class >> fromPool: aSlotObjectMap [
	| entries  |
	entries := aSlotObjectMap table slots
		select: [ :s | s spec name = #Association ].
	^ self withAll: entries constant: aSlotObjectMap constant asBoolean
]

{ #category : #'instance creation' }
VirtualDictionary class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #'instance creation' }
VirtualDictionary class >> withAll: variables [
	^self withAll: variables constant: false
]

{ #category : #'instance creation' }
VirtualDictionary class >> withAll: variables constant: aBoolean [
	| result |
	result := self new constant: aBoolean.
	variables do: [ :assoc | result add: assoc ].
	^ result
]

{ #category : #accessing }
VirtualDictionary >> add: assocMap [
	cache at: assocMap key asString put: assocMap

]

{ #category : #accessing }
VirtualDictionary >> associationAt: aSymbol [
	^ self associationAt: aSymbol ifAbsent: [ self error: 'symbol not found' ]
]

{ #category : #accessing }
VirtualDictionary >> associationAt: aSymbol ifAbsent: aBlock [
	^cache at: aSymbol ifAbsent: aBlock.

]

{ #category : #accessing }
VirtualDictionary >> associations [
	^ cache values
]

{ #category : #accessing }
VirtualDictionary >> at: aSymbol [
	| assoc |
	assoc := self associationAt: aSymbol.
	^assoc value
]

{ #category : #accessing }
VirtualDictionary >> at: aSymbol ifAbsent: aBlock [
	| assoc |
	assoc := self associationAt: aSymbol ifAbsent: [ ^ aBlock value ].
	^ assoc value
]

{ #category : #accessing }
VirtualDictionary >> at: aSymbol ifPresent: aBlock [
	cache at: aSymbol ifPresent: [ :assoc | ^ aBlock value: assoc value ].
	^ nil
]

{ #category : #accessing }
VirtualDictionary >> at: aSymbol put: anObjectMap [
	| existing new |
	existing := self
		associationAt: aSymbol
		ifAbsent: [ new := image newAssociation: aSymbol -> nil.
			self
				add: new. ^anObjectMap 
				 ].
	^existing value: anObjectMap
]

{ #category : #accessing }
VirtualDictionary >> constant: aBoolean [
	constant := aBoolean
]

{ #category : #accessing }
VirtualDictionary >> do: aBlock [
	^ cache do: aBlock halt
]

{ #category : #accessing }
VirtualDictionary >> image: aVirtualImage [
	image := aVirtualImage
]

{ #category : #accessing }
VirtualDictionary >> includesKey: aSymbol [
	self associationAt: aSymbol ifAbsent: [ ^ false ].
	^ true
]

{ #category : #accessing }
VirtualDictionary >> initialize [
	cache := Dictionary new.
	constant := false
]

{ #category : #accessing }
VirtualDictionary >> isConstant [
	^constant
]

{ #category : #accessing }
VirtualDictionary >> keys [
	^ cache keys
]

{ #category : #accessing }
VirtualDictionary >> lookupAndCache: aSymbol [
	| table assoc |
	table := dictionary table.
	1 to: table size do: [:i | 
		assoc := table slotAt: i. (assoc != nilObj and: [assoc key asLocalSymbol = aSymbol]) ifTrue: [
	^cache at: aSymbol put: assoc ]].
	^nil

]

{ #category : #accessing }
VirtualDictionary >> nilObject: anObjectMap [
	nilObj := anObjectMap
]

{ #category : #accessing }
VirtualDictionary >> valuesDo: aBlock [
	^ self associations do: [:a | aBlock value: a value ]
]
