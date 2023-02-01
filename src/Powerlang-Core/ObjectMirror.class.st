Class {
	#name : #ObjectMirror,
	#superclass : #Mirror,
	#category : #'Powerlang-Core-Mirrors'
}

{ #category : #comparing }
ObjectMirror >> = anObject [
	^self class = anObject class and: [handle = anObject handle]
]

{ #category : #nativizing }
ObjectMirror >> _gate [
	^self
]

{ #category : #'meta accessing' }
ObjectMirror >> asAssociationMirror [
	^self associationMirrorOn: handle
]

{ #category : #'meta accessing' }
ObjectMirror >> asBehaviorMirror [
	^self behaviorMirrorOn: handle
]

{ #category : #'meta accessing' }
ObjectMirror >> asBlockMirror [
	^ self compiledBlockMirrorOn: handle
]

{ #category : #'meta accessing' }
ObjectMirror >> asByteArray [
	^self bytes
]

{ #category : #'meta accessing' }
ObjectMirror >> asClassMirror [
	^self classMirrorOn: handle
]

{ #category : #'meta accessing' }
ObjectMirror >> asClosureMirror [
	^ self closureMirrorOn: handle
]

{ #category : #'meta accessing' }
ObjectMirror >> asDictionaryMirror [
	^self dictionaryMirrorOn: handle
]

{ #category : #'meta accessing' }
ObjectMirror >> asLocalArray [
	| size |
	size := self size.
	^(1 to: size) collect: [:i | self slotAt: i]
]

{ #category : #'meta accessing' }
ObjectMirror >> asLocalInteger [
	^handle asLocalInteger
]

{ #category : #'meta accessing' }
ObjectMirror >> asLocalString [
	^handle asLocalString
]

{ #category : #'meta accessing' }
ObjectMirror >> asMethodMirror [
	^self compiledMethodMirrorOn: handle
]

{ #category : #'meta accessing' }
ObjectMirror >> asSpeciesMirror [
	^(self speciesMirrorOn: handle) reflectsMetaclass
		ifTrue: [self metaclassMirrorOn: handle]
		ifFalse: [self classMirrorOn: handle]
]

{ #category : #'meta accessing' }
ObjectMirror >> asStringMirror [
	^self
]

{ #category : #'meta accessing' }
ObjectMirror >> asSubject [
	^handle mirage
]

{ #category : #private }
ObjectMirror >> at: index [
	| slot |
	slot := self reflectedClass instSize + index.
	^self slotAt: slot
]

{ #category : #testing }
ObjectMirror >> basicFlags [
	^handle basicFlags
]

{ #category : #'meta accessing' }
ObjectMirror >> bytes [
	^handle asLocalBytes
]

{ #category : #'as yet unclassified' }
ObjectMirror >> contains: anAddress [
	^anAddress >= handle oid and: [anAddress < (handle oid + self size)]
]

{ #category : #'meta accessing' }
ObjectMirror >> dispatch: aMessage from: parentInterpreter [
	| method interpreter |
	method := self lookup: aMessage selector.
	method ifNil: [ self ASSERT: false ].
	interpreter := parentInterpreter class
		on: self
		with: aMessage arguments
		for: method.
	^ interpreter
		parent: parentInterpreter;
		evaluate: method
]

{ #category : #'meta accessing' }
ObjectMirror >> do: aBlock [
	1 to: self size do: [:index | | slot |
		slot := self slotAt: index.
		aBlock value: slot]
]

{ #category : #nativizing }
ObjectMirror >> equals: anotherObject [
	^ (anotherObject isKindOf: self class)
		and: [ handle = anotherObject handle ]
]

{ #category : #private }
ObjectMirror >> getInstVarAt: index [
	^self slotAt: index
]

{ #category : #private }
ObjectMirror >> getInstVarNamed: name [
	| index |
	index := handle indexOf: name for: self.
	index = 0 ifTrue: [self error: 'instance variable not found'].
	^self slotAt: index
]

{ #category : #comparing }
ObjectMirror >> hash [
	^ handle hash
]

{ #category : #'meta accessing' }
ObjectMirror >> invoke: method with: arguments [
	| interpreter |
	interpreter := SmalltalkInterpreter on: self with: arguments for: method.
	^ interpreter evaluate: method
]

{ #category : #testing }
ObjectMirror >> largeSize [
	^handle largeSize
]

{ #category : #'meta accessing' }
ObjectMirror >> localClassname [
	^self reflectedClass localName
]

{ #category : #testing }
ObjectMirror >> localDeepCopy [
	self reflectsInteger
		ifTrue: [ ^ self asLocalInteger ].
	^ (1 to: self size)
		collect: [ :i | | slot |
			slot := self slotAt: i.
			slot localDeepCopy ]
]

{ #category : #printing }
ObjectMirror >> localDescription [
	| class name |
	self reflectsInteger
		ifTrue: [ ^ 'int ' , self asLocalInteger printString ].
	^ [ class := self reflectedClass.
	name := class localName.
	(name = 'String' or: [ name = 'Symbol' ])
		ifTrue: [ ^ name , ' <' , self asLocalString , '>' ].
	name withArticle]
		on: StorageReadError
		do: [ self printString , '(could not be read)' ]
]

{ #category : #nativizing }
ObjectMirror >> lookup: aSelector [
	^self reflectedBehavior compiledMethodFor: aSelector
]

{ #category : #converting }
ObjectMirror >> mirage [
	^handle mirage
]

{ #category : #printing }
ObjectMirror >> printOn: aStream [
	| description |
	self reflectsInteger
		ifTrue: [ ^ aStream
				nextPutAll: 'SMI (';
				print: self asLocalInteger;
				nextPut: $) ].
	description := [ self reflectedClass localName withArticle ]
		on: Error
		do: [ 'broken class' ].
	aStream
		nextPutAll:
			self class name withArticle , '(' , handle printString , ', '
				, description , ')'
]

{ #category : #'meta accessing' }
ObjectMirror >> reflectedBehavior [
	| behavior |
	behavior := handle getBehavior.
	^self behaviorMirrorOn: behavior
]

{ #category : #'meta accessing' }
ObjectMirror >> reflectedClass [
	^handle getClass
]

{ #category : #nativizing }
ObjectMirror >> reflectsBytesObject [
	^handle isBytes
]

{ #category : #nativizing }
ObjectMirror >> reflectsInteger [
	^handle isInteger
]

{ #category : #nativizing }
ObjectMirror >> reflectsLargeObject [
	^handle isLarge
]

{ #category : #testing }
ObjectMirror >> reflectsMethodDictionary [
	^false
]

{ #category : #nativizing }
ObjectMirror >> reflectsNil [
	^handle = handle nilObject
]

{ #category : #private }
ObjectMirror >> setInstVarAt: index with: value [
	^ self slotAt: index put: value
]

{ #category : #testing }
ObjectMirror >> size [
	^handle size - self reflectedClass instSize
]

{ #category : #'meta accessing' }
ObjectMirror >> slotAt: index [
	| slot |
	slot := handle slotAt: index.
	^self objectMirrorOn: slot
]

{ #category : #'meta accessing' }
ObjectMirror >> slotAt: index put: value [
	handle slotAt: index put: value _gate handle oid.
	^ value
]

{ #category : #private }
ObjectMirror >> slotOf: species named: name [
	| index |
	index := handle indexOf: name inStructureOf: species name asSymbol.
	^self slotAt: index
]

{ #category : #testing }
ObjectMirror >> slotSize [
	^ handle size
]

{ #category : #private }
ObjectMirror >> structure [
	^handle structureOf: self structureType
]

{ #category : #private }
ObjectMirror >> structureType [
	^self subclassResponsibility
]
