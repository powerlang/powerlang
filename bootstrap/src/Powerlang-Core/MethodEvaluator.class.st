Class {
	#name : #MethodEvaluator,
	#superclass : #Object,
	#instVars : [
		'parent',
		'method',
		'receiver',
		'arguments',
		'temporaries',
		'environment',
		'system',
		'isBlock',
		'nonLocalReturn'
	],
	#classVars : [
		'Undermessages'
	],
	#pools : [
		'ClosureElementTypes'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #'instance creation' }
MethodEvaluator class >> initialize [
	"
	self initialize
	"

	Undermessages := #(_basicAt: #_basicAt:put: _bitShiftLeft: _byteAt: #_byteAt:put: _smallSize _largeSize _isSmallInteger _basicHash _basicHash: _smallIntegerByteAt: _uShortAtOffset: _uShortAtOffset:put:)
]

{ #category : #'instance creation' }
MethodEvaluator class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #visiting }
MethodEvaluator >> argumentAt: index in: anInteger [
	| env |
	anInteger ifNil: [ ^arguments at: index ].
	env := self environmentFor: anInteger.
	^env at: index.
]

{ #category : #visiting }
MethodEvaluator >> arguments [
	^arguments
]

{ #category : #visiting }
MethodEvaluator >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #visiting }
MethodEvaluator >> associationValueAt: anInteger [
	^ (method at: anInteger) value
]

{ #category : #visiting }
MethodEvaluator >> associationValueAt: anInteger put: value [
	| association |
	association := (method at: anInteger).
	^association value: value
]

{ #category : #visiting }
MethodEvaluator >> backtrace [
	| bt next |
	bt := OrderedCollection new.
	next := self.
	[ next notNil ]
		whileTrue: [ bt
				add:
					{next method signature.
					next receiver} , next arguments.
			next := next parent ].
	^ bt
]

{ #category : #visiting }
MethodEvaluator >> beBlock [
	isBlock := true
]

{ #category : #visiting }
MethodEvaluator >> booleanFor: aBoolean [
	^ aBoolean
		ifTrue: [ system true ]
		ifFalse: [ system false ]
]

{ #category : #visiting }
MethodEvaluator >> captureClosure: anSBlock with: block [
	| closure s i type env arg |
	closure := system image newClosure: block environmentCount.
	closure
		block: block;
		astcodes: anSBlock;
		builder: self.
	s := anSBlock capturedVariables readStream.
	i := 1.
	[ s atEnd ]
		whileFalse: [ type := s next.
			type = Self
				ifTrue: [ closure at: i put: receiver ].
			type = Environment
				ifTrue: [ closure at: i put: environment ].
			type = EnvironmentValue
				ifTrue: [ env := environment at: s next.
					closure at: i put: env ].
			type = LocalArgument
				ifTrue: [ arg := arguments at: s next.
					closure at: i put: arg ].
			i := i + 1 ].
	^ closure
]

{ #category : #services }
MethodEvaluator >> classBinding [
	^method classBinding
]

{ #category : #visiting }
MethodEvaluator >> constPoolValueAt: anInteger [
	^ method at: anInteger
]

{ #category : #visiting }
MethodEvaluator >> environment: anObjectMap [
	environment := anObjectMap
]

{ #category : #visiting }
MethodEvaluator >> environmentFor: anInteger [
	"
	-1: inlined argument.
	 0: current env.
 	>0: index of env in current env. "

	anInteger = 0
		ifTrue: [ ^ environment ].
	anInteger = -1
		ifTrue: [ ^ temporaries ].
	^ environment at: anInteger
]

{ #category : #visiting }
MethodEvaluator >> evaluate [
	| result sexpressions |
	nonLocalReturn := [ :value |
		 ^ system unwind: environment returning: value ].
	"system frames size > 8 ifTrue: [self halt]."
	system pushFrame: self.
	sexpressions := system sexpressionsOf: method.
	result := self visitMethod: sexpressions.
	system popFrame.
	^ result
]

{ #category : #visiting }
MethodEvaluator >> evaluateBlock: sblock args: anArray [
	" as this block is inlined, we didn't capture parent environment.
	Thus, we don't know if environment is a closure or a method home.
	We unwind to that environment and clean up later if it was a closure. "

	anArray
		with: sblock inlinedArgs
		do: [ :arg :i | temporaries at: i put: arg ].
	^ self visitScript: sblock
]

{ #category : #visiting }
MethodEvaluator >> evaluateBlock: sblock args: anArray closure: closure [
	" inlined blocks can only return to their real parent environment.
	Here we complete the non-local return process for them, unwinding
	to the real home environment "

	temporaries := Array new: sblock tempCount.
	environment := closure.
	arguments := anArray.
	^ self visitScript: sblock
]

{ #category : #visiting }
MethodEvaluator >> falseLiteral [
	^ system false
]

{ #category : #visiting }
MethodEvaluator >> initialize [
	isBlock := false
]

{ #category : #visiting }
MethodEvaluator >> instanceVarAt: anInteger [
	^ receiver slotAt: anInteger
]

{ #category : #visiting }
MethodEvaluator >> instanceVarAt: index put: aValue [
	^ receiver slotAt: index put: aValue
]

{ #category : #visiting }
MethodEvaluator >> isHomeOf: env [
	^ environment == env andNot: [ isBlock ]
]

{ #category : #visiting }
MethodEvaluator >> literal: anObject [
	^anObject
]

{ #category : #visiting }
MethodEvaluator >> loadNamed: aSymbol [
	^system loadNamed: aSymbol in: receiver
]

{ #category : #visiting }
MethodEvaluator >> method [
	^method
]

{ #category : #accessing }
MethodEvaluator >> method: anSCompiledMethod [
	method := anSCompiledMethod.
	temporaries := Array new: anSCompiledMethod tempCount
]

{ #category : #visiting }
MethodEvaluator >> nilLiteral [
	^ system nil
]

{ #category : #visiting }
MethodEvaluator >> parent [
	^parent
]

{ #category : #visiting }
MethodEvaluator >> parent: anInterpreter [
	parent := anInterpreter
]

{ #category : #printing }
MethodEvaluator >> printOn: aStream [
 self backtrace
				do: [ :frame | 
					frame
						do: [ :elem | elem printOn: aStream ]
						separatedBy: [ aStream nextPutAll: '. ' ].
					aStream cr ]
]

{ #category : #visiting }
MethodEvaluator >> receiver [
	^receiver
]

{ #category : #visiting }
MethodEvaluator >> receiver: anObject [
	receiver := anObject
]

{ #category : #visiting }
MethodEvaluator >> return: anObject [
	self isBlock ifTrue: [ ^environment builder return: anObject ].
	nonLocalReturn value: anObject
]

{ #category : #visiting }
MethodEvaluator >> storeNamed: aSymbol with: anObject [
	^ system storeNamed: aSymbol in: receiver with: anObject
]

{ #category : #visiting }
MethodEvaluator >> system: anEmulator [
	system := anEmulator
]

{ #category : #visiting }
MethodEvaluator >> temporaryAt: index in: anInteger [
	| env |
	anInteger ifNil: [ ^ temporaries at: index ].
	env := self environmentFor: anInteger.
	^ env at: index
]

{ #category : #visiting }
MethodEvaluator >> temporaryAt: index in: anInteger put: aValue [
	| env |
	anInteger ifNil: [ ^ temporaries	at:index put: aValue ].
	env := self environmentFor: anInteger.
	^ env at: index put: aValue
]

{ #category : #visiting }
MethodEvaluator >> trueLiteral [
	^system true
]

{ #category : #visiting }
MethodEvaluator >> visitArgument: anSIdentifier [
	^arguments at: anSIdentifier binding index
]

{ #category : #visiting }
MethodEvaluator >> visitAssignment: anSAssignment [
	| result |
	result := anSAssignment expression acceptVisitor: self.
	anSAssignment assignees
		do: [ :identifier | identifier binding assign: result within: self ].
	^result
]

{ #category : #visiting }
MethodEvaluator >> visitBlock: anSBlock [
	| block |
	block := anSBlock isInlined
		ifTrue: [ SCompiledBlock new ]
		ifFalse: [ anSBlock compiledCode ].
	^ self captureClosure: anSBlock with: block
]

{ #category : #visiting }
MethodEvaluator >> visitCascade: anSCascade [
	| recv args selector last |
	recv := anSCascade receiver acceptVisitor: self.
	anSCascade messages
		do: [ :msg | 
			args := msg arguments collect: [ :code | code acceptVisitor: self ].
			selector := system symbolFrom: msg selector.
			last := system
				send: selector
				to: recv
				with: args
				super: anSCascade receiver isSuper ].
	^ last
]

{ #category : #visiting }
MethodEvaluator >> visitIdentifier: anSIdentifier [
	^anSIdentifier binding valueWithin: self.

]

{ #category : #visiting }
MethodEvaluator >> visitLiteral: anSLiteral [
	^ system transferLiteral: anSLiteral value
]

{ #category : #visiting }
MethodEvaluator >> visitMessage: anSMessage [
	| recv args selector |
	recv := anSMessage receiver acceptVisitor: self.
	args := anSMessage arguments
		collect: [ :code | code acceptVisitor: self ].
	selector := system symbolFrom: anSMessage selector.
	self ASSERT: selector !== #error:.
	^ system
		send: selector
		to: recv
		with: args
		super: anSMessage receiver isSuper
]

{ #category : #visiting }
MethodEvaluator >> visitMethod: anSMethod [
	| primitive |
	primitive := anSMethod primitive.
	^ primitive
		ifNil: [ self visitScript: anSMethod. receiver ]
		ifNotNil: [ system evaluatePrimitive: primitive in: self ]
]

{ #category : #visiting }
MethodEvaluator >> visitReturn: anSReturn [
	| value |
	value := anSReturn expression acceptVisitor: self.
	^self return: value
]

{ #category : #visiting }
MethodEvaluator >> visitScript: anSScript [
	| result |
	result := system nil.
	anSScript statements
		do: [ :node | result := node acceptVisitor: self ].
	^ result
]

{ #category : #visiting }
MethodEvaluator >> visitTemporary: anSIdentifier [
	^temporaries at: anSIdentifier binding index
]
