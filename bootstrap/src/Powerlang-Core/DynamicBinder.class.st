Class {
	#name : #DynamicBinder,
	#superclass : #IdentifierBinder,
	#instVars : [
		'type'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'instance creation' }
DynamicBinder class >> of: type [
	^self new type: type
]

{ #category : #'instance creation' }
DynamicBinder class >> on: aPoolDictionary [
	| type |
	type := aPoolDictionary isConstant
		ifTrue: [ConstantPoolBinding]
		ifFalse: [PoolVarBinding].
	^self new on: aPoolDictionary type: type
]

{ #category : #'instance creation' }
DynamicBinder class >> on: aDictionary of: type [
	^self new on: aDictionary type: type
]

{ #category : #accessing }
DynamicBinder >> at: aString [
	| key assoc |
	key := self keyFor: aString.
	key ifNil: [ ^nil ].
	assoc := contents associationAt: key ifAbsent: [^nil].
	^type on: assoc
]

{ #category : #accessing }
DynamicBinder >> at: aString ifPresent: aBlock [
	| binding |
	binding := self at: aString.
	^binding notNil ifTrue: [aBlock value: binding]
]

{ #category : #accessing }
DynamicBinder >> at: aString put: anObject [
	| key |
	key := self keyFor: aString.
	self ASSERT: contents !== Smalltalk.
	contents at: key put: anObject
]

{ #category : #accessing }
DynamicBinder >> contents: aDictionary [
	contents := aDictionary
]

{ #category : #private }
DynamicBinder >> keyFor: aString [
	^type usesSymbols ifTrue: [aString existingSymbol] ifFalse: [aString]
]

{ #category : #private }
DynamicBinder >> on: aDictionary type: aClass [
	contents := aDictionary.
	type := aClass
]

{ #category : #accessing }
DynamicBinder >> poolNamed: aSymbol ifPresent: aBlock [
	| pool |
	pool := contents at: aSymbol ifAbsent: nil.
	^pool notNil ifTrue: [aBlock evaluateWith: pool]
]

{ #category : #printing }
DynamicBinder >> printOn: aStream indent: anInteger [
	aStream
		tab: anInteger;
		nextPutAll: 'binder for ';
		nextPutAll: type name;
		nextPutAll: ': '.
	type == GlobalBinding
		ifTrue: [aStream nextPut: $…]
		ifFalse: [contents keys asArray printOn: aStream]
]

{ #category : #accessing }
DynamicBinder >> type: aClass [
	type := aClass
]
