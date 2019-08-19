Class {
	#name : #SExpressionInterpreter,
	#superclass : #Object,
	#instVars : [
		'receiver',
		'arguments',
		'temporaries',
		'returned',
		'returnValue',
		'method',
		'blocks',
		'parent'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'instance creation' }
SExpressionInterpreter class >> new [
	^self basicNew initialize
]

{ #category : #'instance creation' }
SExpressionInterpreter class >> on: receiverMirror with: arguments for: method [
	^self new
		receiver: receiverMirror;
		arguments: arguments;
		method: method
]

{ #category : #visiting }
SExpressionInterpreter >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #visiting }
SExpressionInterpreter >> dispatch: message to: msgReceiver [
	^ self subclassResponsibility
]

{ #category : #visiting }
SExpressionInterpreter >> dispatchSpecial: message [
		^self subclassResponsibility 
]

{ #category : #visiting }
SExpressionInterpreter >> evaluate: anSExpression [
	^ self visitMethod: anSExpression
]

{ #category : #visiting }
SExpressionInterpreter >> initialize [
	returned := false.
	temporaries := OrderedCollection new.
	blocks := IdentityDictionary new
]

{ #category : #visiting }
SExpressionInterpreter >> isSpecial: aSelectorMirror [
	^ self subclassResponsibility 
]

{ #category : #accessing }
SExpressionInterpreter >> method: aCompiledMethod [
	method := aCompiledMethod
]

{ #category : #visiting }
SExpressionInterpreter >> parent: anInterpreter [
	parent := anInterpreter
]

{ #category : #visiting }
SExpressionInterpreter >> receiver: anObject [
	receiver := anObject.
	returnValue := anObject
]

{ #category : #visiting }
SExpressionInterpreter >> temporaryAt: index put: aValue [
	^temporaries at: index put: aValue
]

{ #category : #visiting }
SExpressionInterpreter >> visitArgument: anSIdentifier [
	^arguments at: anSIdentifier binding index
]

{ #category : #visiting }
SExpressionInterpreter >> visitAssignment: anSAssignment [
	| result |
	result := anSAssignment expression acceptVisitor: self.
	anSAssignment assignees
		do: [ :identifier | identifier binding assign: result within: self ].
	^result
]

{ #category : #visiting }
SExpressionInterpreter >> visitAssociationVariable: anSIdentifier [
	^ self mirageOnObject: anSIdentifier binding association value
]

{ #category : #visiting }
SExpressionInterpreter >> visitHomeOf: aClosure [
	| block |
	block := blocks
		at: aClosure
		ifAbsent: [^parent visitHomeOf: aClosure].
	^self visitScript: block
]

{ #category : #visiting }
SExpressionInterpreter >> visitIdentifier: anSIdentifier [
	anSIdentifier isSelfOrSuper
		ifTrue: [ ^ receiver ].
	anSIdentifier isLiteral
		ifTrue: [ ^ self visitLiteral: anSIdentifier ].
	anSIdentifier isAssociation
		ifTrue: [ ^ self visitAssociationVariable: anSIdentifier ].
	anSIdentifier isInstVar
		ifTrue: [ ^ self visitInstanceVariable: anSIdentifier ].
	anSIdentifier isArgument
		ifTrue: [ ^ self visitArgument: anSIdentifier ].
	anSIdentifier isTemporary
		ifTrue: [ ^ self visitTemporary: anSIdentifier ].
	self error: 'cannot resolve ' , anSIdentifier
]

{ #category : #visiting }
SExpressionInterpreter >> visitInstanceVariable: anSIdentifier [
	^ receiver _gate slotAt: anSIdentifier binding index
]

{ #category : #visiting }
SExpressionInterpreter >> visitMessage: anSMessage [
	| msgReceiver msgArguments selector message |
	msgReceiver := anSMessage receiver acceptVisitor: self.
	msgArguments := anSMessage arguments
		collect: [ :code | code acceptVisitor: self ].
	selector := anSMessage selector.
	message := MessageSend
		receiver: msgReceiver
		selector: selector
		arguments: msgArguments.
	^ (self isSpecial: selector)
		ifTrue: [ self dispatchSpecial: message ]
		ifFalse: [ self dispatch: message to: msgReceiver]
]

{ #category : #visiting }
SExpressionInterpreter >> visitMethod: anSMethod [
	| primitive |
	primitive := anSMethod primitive.
	primitive ifNotNil: [ ^ self visitPrimitive: primitive ].
	^self visitScript: anSMethod.

]

{ #category : #visiting }
SExpressionInterpreter >> visitReturn: anSReturn [
	returnValue := anSReturn expression acceptVisitor: self.
	returned := true.
	^returnValue
]

{ #category : #visiting }
SExpressionInterpreter >> visitScript: anSScript [
	| result |
	anSScript statements do: [:node | 
		result := node acceptVisitor: self.
		returned ifTrue: [^returnValue]
	].
	^result
]

{ #category : #visiting }
SExpressionInterpreter >> visitTemporary: anSIdentifier [
	^temporaries at: anSIdentifier binding index
]
