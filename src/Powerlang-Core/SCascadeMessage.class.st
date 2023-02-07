Class {
	#name : #SCascadeMessage,
	#superclass : #SExpression,
	#instVars : [
		'selector',
		'arguments',
		'cascade',
		'cache'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SCascadeMessage class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeCascadeMessage
]

{ #category : #accessing }
SCascadeMessage >> acceptVisitor: visitor [
	^ visitor visitCascadeMessage: self
]

{ #category : #accessing }
SCascadeMessage >> argumentCount [
	^arguments size
]

{ #category : #accessing }
SCascadeMessage >> arguments [
	^arguments
]

{ #category : #accessing }
SCascadeMessage >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #accessing }
SCascadeMessage >> cache: anSCompiledMethod when: type [
	cache ifNil: [ ^ cache := Array with: type with: anSCompiledMethod ].
	cache := cache , (Array with: type with: anSCompiledMethod)
]

{ #category : #accessing }
SCascadeMessage >> cacheUndermessage: aBlockClosure [
	cache := aBlockClosure
]

{ #category : #accessing }
SCascadeMessage >> cachedUndermessage [
	^ cache isBlock
		ifTrue: [ cache ]
]

{ #category : #accessing }
SCascadeMessage >> cascade [ ^
	cascade
]

{ #category : #accessing }
SCascadeMessage >> cascade: anSCascade [
	cascade := anSCascade
]

{ #category : #accessing }
SCascadeMessage >> flushCache [
	cache := nil
]

{ #category : #accessing }
SCascadeMessage >> isCascadeMessage [
	^true
]

{ #category : #accessing }
SCascadeMessage >> methodFor: requiredType [
	| type |
	cache ifNil: [ ^ nil ].
	1 to: cache size by: 2 do: [ :i | 
		type := cache at: i.
		type == requiredType
			ifTrue: [ ^ cache at: i + 1 ] ].
	^ nil
]

{ #category : #accessing }
SCascadeMessage >> receiver [
	^cascade receiver
]

{ #category : #accessing }
SCascadeMessage >> registerCacheWith: runtime [
	cache ifNil: [ runtime registerCache: self for: selector ]
]

{ #category : #accessing }
SCascadeMessage >> selector [
	^selector
]

{ #category : #accessing }
SCascadeMessage >> selector: aSymbol [
	selector := aSymbol
]
