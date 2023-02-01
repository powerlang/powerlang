Class {
	#name : #ClassMap,
	#superclass : #SpeciesMap,
	#category : #'Powerlang-Core-Execution-Ring'
}

{ #category : #accessing }
ClassMap >> allInstVarNames [
	^ (spec environment at: #Class)allInstVarNames, spec allInstVarNames
]

{ #category : #accessing }
ClassMap >> computeAllSlotNames [
	| c |
	c := spec environment at: #Class.
	^slotNames := c allInstVarNames , spec allInstVarNames
]

{ #category : #accessing }
ClassMap >> instanceSide [
	^ self
]

{ #category : #accessing }
ClassMap >> name [
	^instanceSpec name
]

{ #category : #accessing }
ClassMap >> namespaces [
	^ self slotNamed: #namespaces
]

{ #category : #accessing }
ClassMap >> namespaces: array [
	^ self slotNamed: #namespaces put: array
]

{ #category : #accessing }
ClassMap >> printOn: aStream [
	aStream
		nextPutAll: '<<';
		nextPutAll: self name asString;
		nextPutAll: '>>'
]

{ #category : #accessing }
ClassMap >> withAllSuperclasses [
	^self superclass isNil ifTrue: [ OrderedCollection with: self ]
		ifFalse: [self superclass withAllSuperclasses
				addFirst: self;
				yourself ]
]
