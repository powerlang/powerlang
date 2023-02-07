Class {
	#name : #SMessage,
	#superclass : #SExpression,
	#instVars : [
		'selector',
		'receiver',
		'arguments',
		'cache',
		'inlined'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SMessage class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeMessage
]

{ #category : #'instance creation' }
SMessage class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #printing }
SMessage >> acceptVisitor: visitor [
	^visitor visitMessage: self
]

{ #category : #accessing }
SMessage >> argumentCount [
	^arguments size
]

{ #category : #printing }
SMessage >> arguments [
	^arguments
]

{ #category : #printing }
SMessage >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #printing }
SMessage >> cache: anSCompiledMethod when: type [
	cache
		ifNil: [ ^ cache := Array with: type with:
			anSCompiledMethod].
	cache := cache
		,
			(Array with: type with: 
			anSCompiledMethod)
]

{ #category : #printing }
SMessage >> cacheUndermessage: aBlockClosure [
	cache := aBlockClosure
]

{ #category : #printing }
SMessage >> cachedUndermessage [
	^cache isBlock ifTrue: [ cache ]
]

{ #category : #printing }
SMessage >> flushCache [
	cache := nil
]

{ #category : #printing }
SMessage >> initialize [
	super initialize.
	arguments := #().
	inlined := false
]

{ #category : #private }
SMessage >> inlined: aBoolean [
	inlined := aBoolean
]

{ #category : #printing }
SMessage >> isInlined [
	^ inlined
]

{ #category : #printing }
SMessage >> isMessage [
	^true
]

{ #category : #printing }
SMessage >> methodFor: requiredType [
	| type |
	cache ifNil: [ ^ nil ].
	1 to: cache size by: 2 do: [ :i | 
		type := cache at: i.
		type == requiredType
			ifTrue: [ ^ cache at: i + 1 ] ].
	^ nil
]

{ #category : #printing }
SMessage >> printOn: aStream indent: anInteger [
	aStream tab: anInteger; nextPutAll: '{MessageId. '; print: selector; nextPutAll: '. '; cr.
	receiver printOn: aStream indent: anInteger + 1.
	aStream nextPutAll: '.'; cr.
	arguments
		do: [:statement | statement printOn: aStream indent: anInteger + 1]
		separatedBy: [aStream nextPutAll: '. '; cr].
	aStream nextPutAll: '}'
]

{ #category : #printing }
SMessage >> receiver [
	^receiver
]

{ #category : #printing }
SMessage >> receiver: anSExpression [
	receiver := anSExpression
]

{ #category : #printing }
SMessage >> registerCacheWith: runtime [
	cache ifNil: [ runtime registerCache: self for: selector ]
]

{ #category : #printing }
SMessage >> selector [
	^selector
]

{ #category : #printing }
SMessage >> selector: aSelector [
	selector := aSelector
]
