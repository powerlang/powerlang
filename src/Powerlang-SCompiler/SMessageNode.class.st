Class {
	#name : #SMessageNode,
	#superclass : #SParseNode,
	#instVars : [
		'selector',
		'receiver',
		'arguments',
		'inlined'
	],
	#category : #'Powerlang-SCompiler-Parser'
}

{ #category : #visiting }
SMessageNode >> acceptVisitor: visitor [
	^visitor visitMessage: self
]

{ #category : #accessing }
SMessageNode >> arguments [
	^arguments
]

{ #category : #accessing }
SMessageNode >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #'emitting - inlined' }
SMessageNode >> beInlined [
	inlined := true
]

{ #category : #testing }
SMessageNode >> hasAssign [
	receiver hasAssign ifTrue: [^true].
	^arguments anySatisfy: [:arg | arg hasAssign]
]

{ #category : #testing }
SMessageNode >> hasVolatileArguments [
	^arguments anySatisfy: [:arg | 
		arg isIdentifier
			ifTrue: [arg binding canBeAssigned]
			ifFalse: [arg isBlockNode not andNot: [arg isLiteral]]]
]

{ #category : #testing }
SMessageNode >> hasVolatileReceiver [
	^ compiler hasBlocks
		  or: [ receiver isMethodTemporary not ]
		  or: [ arguments anySatisfy: [ :arg | arg hasAssign ] ]
]

{ #category : #testing }
SMessageNode >> initialize [
	super initialize.
	inlined := false
]

{ #category : #testing }
SMessageNode >> isCascadeMessage [
	^false
]

{ #category : #testing }
SMessageNode >> isInlined [
	^inlined
]

{ #category : #testing }
SMessageNode >> isMessageNode [
	^true
]

{ #category : #testing }
SMessageNode >> needsStrictEvaluationOrder [
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
	receiver isMessageNode ifTrue: [ ^true ]. 
	^self hasVolatileArguments
]

{ #category : #enumerating }
SMessageNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	receiver nodesDo: aBlock includingDeclarations: aBoolean.
	arguments do: [:arg | arg nodesDo: aBlock includingDeclarations: aBoolean].
	selector nodesDo: aBlock includingDeclarations: aBoolean
]

{ #category : #accessing }
SMessageNode >> receiver [
	^receiver
]

{ #category : #accessing }
SMessageNode >> receiver: node [
	receiver := node
]

{ #category : #accessing }
SMessageNode >> selector [
	^selector
]

{ #category : #accessing }
SMessageNode >> selector: node [
	selector := node
]

{ #category : #accessing }
SMessageNode >> symbol [
	^selector symbol
]
