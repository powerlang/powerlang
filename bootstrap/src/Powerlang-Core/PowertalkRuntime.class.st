Class {
	#name : #PowertalkRuntime,
	#superclass : #Object,
	#instVars : [
		'methodCache',
		'falseObj',
		'trueObj',
		'nilObj',
		'interpreter'
	],
	#pools : [
		'ClosureElementTypes'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #accessing }
PowertalkRuntime >> behaviorOf: anObject [
	^self subclassResponsibility
]

{ #category : #services }
PowertalkRuntime >> booleanFor: aBoolean [
	^ aBoolean
		ifTrue: [ trueObj ]
		ifFalse: [ falseObj ]
]

{ #category : #services }
PowertalkRuntime >> booleanFrom: anObject [
	anObject == falseObj
		ifTrue: [ ^ false ].
	anObject == trueObj
		ifTrue: [ ^ true ].
	self error: 'not a boolean'
]

{ #category : #accessing }
PowertalkRuntime >> evaluatePrimitiveHash: receiver [
	| hash |
	hash := receiver headerHash.
	hash = 0
		ifTrue: [ hash := self nextHash.
			receiver headerHash: hash ].
	^ self newInteger: hash
]

{ #category : #initialization }
PowertalkRuntime >> false [
	^ falseObj
]

{ #category : #initialization }
PowertalkRuntime >> initialize [
	methodCache := Dictionary new
]

{ #category : #initialization }
PowertalkRuntime >> initializeInterpreter [
	"interpreter := PowertalkIterativeTreeInterpreter new runtime: self"
	"interpreter := PowertalkIterativeLinearInterpreter new runtime: self"
	interpreter := PowertalkRecursiveInterpreter new runtime: self
]

{ #category : #accessing }
PowertalkRuntime >> instanceVarOf: receiver at: anInteger [
	^ receiver slotAt: anInteger
]

{ #category : #accessing }
PowertalkRuntime >> instanceVarOf: receiver at: anInteger put: value [
	^ receiver slotAt: anInteger put: value
]

{ #category : #initialization }
PowertalkRuntime >> interpreter [
	^interpreter
]

{ #category : #accessing }
PowertalkRuntime >> isClosure: anObjectMap [
	^ self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> literalFor: anObject [
	^anObject
]

{ #category : #accessing }
PowertalkRuntime >> lookup: aSymbol startingAt: aBehavior [
	^methodCache at: aSymbol -> aBehavior ifAbsentPut: [ self doLookup: aSymbol startingAt: aBehavior ]
]

{ #category : #accessing }
PowertalkRuntime >> methodEnvironmentSize: anObject [
	^self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> newBootstrapDictionaryOf: receiver [
	^ self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> newBytesOf: receiver sized: size [
	^ self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> newClosure: anInteger [
	^ self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> newEnvironmentSized: anInteger [
	^self subclassResponsibility

]

{ #category : #accessing }
PowertalkRuntime >> newInteger: anInteger [
	^self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> newOf: receiver sized: size [
	^ self subclassResponsibility

]

{ #category : #accessing }
PowertalkRuntime >> newSlotsOf: receiver [
^self subclassResponsibility
]

{ #category : #initialization }
PowertalkRuntime >> nil [
	^nilObj
	
]

{ #category : #accessing }
PowertalkRuntime >> override: assoc with: primitiveName [
	^self subclassResponsibility

]

{ #category : #accessing }
PowertalkRuntime >> sendLocal: aSymbol to: receiver [
	^ self sendLocal: aSymbol to: receiver with: {}
]

{ #category : #accessing }
PowertalkRuntime >> sendLocal: aSymbol to: receiver with: anArray [
	^interpreter sendLocal: aSymbol to: receiver with: anArray
]

{ #category : #accessing }
PowertalkRuntime >> sexpressionsOf: anSCompiledMethod [
self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> speciesFor: anObject [
	^ self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> symbolFrom: anObject [
	^anObject
]

{ #category : #initialization }
PowertalkRuntime >> symbolFromLocal: aSymbol [
	^self subclassResponsibility
]

{ #category : #initialization }
PowertalkRuntime >> true [
	^ trueObj
]
