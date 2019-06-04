Class {
	#name : #AstcodeInterpreter,
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
	#category : #'Powerlang-PST-Metaphysics'
}

{ #category : #'instance creation' }
AstcodeInterpreter class >> new [
	^self basicNew initialize
]

{ #category : #'instance creation' }
AstcodeInterpreter class >> on: receiverMirror with: arguments for: method [
	^self new
		receiver: receiverMirror;
		arguments: arguments;
		method: method
]

{ #category : #visiting }
AstcodeInterpreter >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #visiting }
AstcodeInterpreter >> dispatch: message to: msgReceiver [
	^ self subclassResponsibility
]

{ #category : #visiting }
AstcodeInterpreter >> dispatchSpecial: message [
		^self subclassResponsibility 
]

{ #category : #visiting }
AstcodeInterpreter >> evaluate: anAstcode [
	^self visitMethod: anAstcode
]

{ #category : #visiting }
AstcodeInterpreter >> initialize [
	returned := false.
	temporaries := OrderedCollection new.
	blocks := IdentityDictionary new
]

{ #category : #visiting }
AstcodeInterpreter >> isSpecial: aSelectorMirror [
	^ self subclassResponsibility 
]

{ #category : #accessing }
AstcodeInterpreter >> method: aCompiledMethod [
	method := aCompiledMethod
]

{ #category : #visiting }
AstcodeInterpreter >> parent: anInterpreter [
	parent := anInterpreter
]

{ #category : #visiting }
AstcodeInterpreter >> receiver: anObject [
	receiver := anObject.
	returnValue := anObject
]

{ #category : #visiting }
AstcodeInterpreter >> temporaryAt: index put: aValue [
	^temporaries at: index put: aValue
]

{ #category : #visiting }
AstcodeInterpreter >> visitArgument: anIdentifierCode [
	^arguments at: anIdentifierCode binding index
]

{ #category : #visiting }
AstcodeInterpreter >> visitAssignment: anAssignmentCode [
	| result |
	result := anAssignmentCode expression acceptVisitor: self.
	anAssignmentCode assignees
		do: [ :identifier | identifier binding assign: result within: self ].
	^result
]

{ #category : #visiting }
AstcodeInterpreter >> visitAssociationVariable: anIdentifierCode [
	| handle |
	handle := method literalAt: anIdentifierCode binding index.
	^self mirageOnLocalHandle: handle asAssociationMirror value
]

{ #category : #visiting }
AstcodeInterpreter >> visitHomeOf: aClosure [
	| block |
	block := blocks
		at: aClosure
		ifAbsent: [^parent visitHomeOf: aClosure].
	^self visitScript: block
]

{ #category : #visiting }
AstcodeInterpreter >> visitIdentifier: anIdentifierCode [
	anIdentifierCode isSelfOrSuper
		ifTrue: [ ^ receiver ].
	anIdentifierCode isLiteral
		ifTrue: [ ^ self visitLiteral: anIdentifierCode ].
	anIdentifierCode isAssociation
		ifTrue: [ ^ self visitAssociationVariable: anIdentifierCode ].
	anIdentifierCode isInstVar
		ifTrue: [ ^ self visitInstanceVariable: anIdentifierCode ].
	anIdentifierCode isArgument
		ifTrue: [ ^ self visitArgument: anIdentifierCode ].
	anIdentifierCode isTemporary
		ifTrue: [ ^ self visitTemporary: anIdentifierCode ].
	self error: 'cannot resolve ' , anIdentifierCode
]

{ #category : #visiting }
AstcodeInterpreter >> visitInstanceVariable: anIdentifierCode [
	^ receiver _gate getInstVarAt: anIdentifierCode binding index
]

{ #category : #visiting }
AstcodeInterpreter >> visitLiteral: anIdentifierCode [
	| handle |
	handle := method at: anIdentifierCode binding index.
	^ handle mirror
]

{ #category : #visiting }
AstcodeInterpreter >> visitMessage: aMessageCode [
	| msgReceiver msgArguments selector message |
	msgReceiver := aMessageCode receiver acceptVisitor: self.
	msgArguments := aMessageCode arguments
		collect: [ :code | code acceptVisitor: self ].
	selector := method at: aMessageCode selector.
	message := Message
		selector: selector
		arguments: msgArguments.
	^ (self isSpecial: selector)
		ifTrue: [ self dispatchSpecial: message ]
		ifFalse: [ self dispatch: message to: msgReceiver]
]

{ #category : #visiting }
AstcodeInterpreter >> visitMethod: aMethodCode [
	^self visitScript: aMethodCode

]

{ #category : #visiting }
AstcodeInterpreter >> visitReturn: aReturnNode [
	returnValue := aReturnNode expression acceptVisitor: self.
	returned := true.
	^returnValue
]

{ #category : #visiting }
AstcodeInterpreter >> visitScript: aScriptCode [
	| result |
	aScriptCode statements do: [:node | 
		returned ifTrue: [returnValue].
		result := node acceptVisitor: self].
	^result
]

{ #category : #visiting }
AstcodeInterpreter >> visitTemporary: anIdentifierCode [
	^temporaries at: anIdentifierCode binding index
]
