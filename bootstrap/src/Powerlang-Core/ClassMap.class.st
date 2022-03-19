Class {
	#name : #ClassMap,
	#superclass : #SpeciesMap,
	#category : #'Powerlang-Core-Emulation-Ring'
}

{ #category : #accessing }
ClassMap >> allInstVarNames [
	^ (spec environment at: #Class)allInstVarNames, spec allInstVarNames
]

{ #category : #accessing }
ClassMap >> classVariables [
	^ self slotNamed: #classVariables
]

{ #category : #accessing }
ClassMap >> classVariables: aDictionaryMap [
	^ self slotNamed: #classVariables put: aDictionaryMap
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
ClassMap >> localPools [
	| pools dict name vars |
	dict := Dictionary new.
	vars := self classVariables.
	vars isNil
		ifTrue: [ ^ dict ].
	pools := vars associations
		select: [ :assoc | assoc value isDictionaryMap ].
	pools
		do: [ :assoc | 
			name := assoc key asString.
			dict at: name put: assoc value ].
	^ dict
]

{ #category : #accessing }
ClassMap >> name [
	^instanceSpec name
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
