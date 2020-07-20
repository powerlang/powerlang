Class {
	#name : #MessageNode,
	#superclass : #ParseNode,
	#instVars : [
		'selector',
		'receiver',
		'arguments',
		'inlined'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #visiting }
MessageNode >> acceptVisitor: visitor [
	^visitor visitMessage: self
]

{ #category : #accessing }
MessageNode >> arguments [
	^arguments
]

{ #category : #accessing }
MessageNode >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #'emitting - inlined' }
MessageNode >> beInlined [
	inlined := true
]

{ #category : #testing }
MessageNode >> hasAssign [
	receiver hasAssign ifTrue: [^true].
	^arguments anySatisfy: [:arg | arg hasAssign]
]

{ #category : #testing }
MessageNode >> hasVolatileArguments [
	^arguments anySatisfy: [:arg | 
		arg isIdentifier
			ifTrue: [arg binding canBeAssigned]
			ifFalse: [arg isBlockNode not andNot: [arg isLiteral]]]
]

{ #category : #testing }
MessageNode >> hasVolatileReceiver [
	^ compiler hasBlocks
		  or: [ receiver isMethodTemporary not ]
		  or: [ arguments anySatisfy: [ :arg | arg hasAssign ] ]
]

{ #category : #testing }
MessageNode >> initialize [
	super initialize.
	inlined := false
]

{ #category : #testing }
MessageNode >> isCascadeMessage [
	^false
]

{ #category : #testing }
MessageNode >> isInlined [
	^inlined
]

{ #category : #testing }
MessageNode >> isMessageNode [
	^true
]

{ #category : #testing }
MessageNode >> needsStrictEvaluationOrder [
	arguments size = 0 ifTrue: [^false].
	receiver isBlockNode ifTrue: [^false].
	receiver isLiteral ifTrue: [^false].
	receiver isSelf ifTrue: [^false].
	receiver isSuper ifTrue: [^false].
	receiver isMethodArgument ifTrue: [^false].
	self hasVolatileReceiver ifFalse: [^false].
	(receiver isImmediate
		and: [arguments conform: [:arg | arg isImmediate or: [arg isBlockNode]]])
		ifTrue: [^false].
	receiver hasAssign ifTrue: [^true].
	^self hasVolatileArguments
]

{ #category : #enumerating }
MessageNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	receiver nodesDo: aBlock includingDeclarations: aBoolean.
	arguments do: [:arg | arg nodesDo: aBlock includingDeclarations: aBoolean].
	selector nodesDo: aBlock includingDeclarations: aBoolean
]

{ #category : #accessing }
MessageNode >> receiver [
	^receiver
]

{ #category : #accessing }
MessageNode >> receiver: node [
	receiver := node
]

{ #category : #accessing }
MessageNode >> selector [
	^selector
]

{ #category : #accessing }
MessageNode >> selector: node [
	selector := node
]

{ #category : #accessing }
MessageNode >> symbol [
	^selector symbol
]
