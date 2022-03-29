Class {
	#name : #EvaluationContext,
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
		'nonLocalReturn',
		'operands'
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
EvaluationContext class >> initialize [
	"
	self initialize
	"

	Undermessages := #(_basicAt: #_basicAt:put: _bitShiftLeft: _byteAt: #_byteAt:put: _smallSize _largeSize _isSmallInteger _basicHash _basicHash: _smallIntegerByteAt: _uShortAtOffset: _uShortAtOffset:put:)
]

{ #category : #'instance creation' }
EvaluationContext class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #visiting }
EvaluationContext >> argumentAt: index in: anInteger [
	| env |
	anInteger ifNil: [ ^arguments at: index ].
	env := self environmentFor: anInteger.
	^env at: index.
]

{ #category : #visiting }
EvaluationContext >> arguments [
	^arguments
]

{ #category : #visiting }
EvaluationContext >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #visiting }
EvaluationContext >> associationValueAt: anInteger [
	^ (method at: anInteger) value
]

{ #category : #visiting }
EvaluationContext >> associationValueAt: anInteger put: value [
	| association |
	association := (method at: anInteger).
	^association value: value
]

{ #category : #visiting }
EvaluationContext >> backtrace [
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
EvaluationContext >> beBlock [
	isBlock := true
]

{ #category : #visiting }
EvaluationContext >> booleanFor: aBoolean [
	^ aBoolean
		ifTrue: [ system true ]
		ifFalse: [ system false ]
]

{ #category : #visiting }
EvaluationContext >> captureClosure: anSBlock with: block [
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
EvaluationContext >> classBinding [
	^method classBinding
]

{ #category : #visiting }
EvaluationContext >> constPoolValueAt: anInteger [
	^ method at: anInteger
]

{ #category : #visiting }
EvaluationContext >> environment: anObjectMap [
	environment := anObjectMap
]

{ #category : #visiting }
EvaluationContext >> environmentFor: anInteger [
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
EvaluationContext >> evaluate [
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
EvaluationContext >> evaluateBlock: sblock args: anArray [
	" as this block is inlined, we didn't capture parent environment.
	Thus, we don't know if environment is a closure or a method home.
	We unwind to that environment and clean up later if it was a closure. "

	anArray
		with: sblock inlinedArgs
		do: [ :arg :i | temporaries at: i put: arg ].
	^ self visitScript: sblock
]

{ #category : #visiting }
EvaluationContext >> evaluateBlock: sblock args: anArray closure: closure [
	" inlined blocks can only return to their real parent environment.
	Here we complete the non-local return process for them, unwinding
	to the real home environment "

	temporaries := Array new: sblock tempCount.
	environment := closure.
	arguments := anArray.
	^ self visitScript: sblock
]

{ #category : #visiting }
EvaluationContext >> falseLiteral [
	^ system false
]

{ #category : #visiting }
EvaluationContext >> initialize [
	isBlock := false
]

{ #category : #visiting }
EvaluationContext >> instanceVarAt: anInteger [
	^ receiver slotAt: anInteger
]

{ #category : #visiting }
EvaluationContext >> instanceVarAt: index put: aValue [
	^ receiver slotAt: index put: aValue
]

{ #category : #visiting }
EvaluationContext >> isHomeOf: env [
	^ environment == env andNot: [ isBlock ]
]

{ #category : #visiting }
EvaluationContext >> literal: anObject [
	^anObject
]

{ #category : #visiting }
EvaluationContext >> loadAssociationValue: association [
	^system loadAssociationValue: association
]

{ #category : #visiting }
EvaluationContext >> loadNamed: aSymbol [
	^system loadNamed: aSymbol in: receiver
]

{ #category : #visiting }
EvaluationContext >> method [
	^method
]

{ #category : #accessing }
EvaluationContext >> method: anSCompiledMethod [
	method := anSCompiledMethod.
	temporaries := Array new: anSCompiledMethod tempCount
]

{ #category : #visiting }
EvaluationContext >> nilLiteral [
	^ system nil
]

{ #category : #visiting }
EvaluationContext >> parent [
	^parent
]

{ #category : #visiting }
EvaluationContext >> parent: anInterpreter [
	parent := anInterpreter
]

{ #category : #printing }
EvaluationContext >> printOn: aStream [
 self backtrace
				do: [ :frame | 
					frame
						do: [ :elem | elem printOn: aStream ]
						separatedBy: [ aStream nextPutAll: '. ' ].
					aStream cr ]
]

{ #category : #visiting }
EvaluationContext >> receiver [
	^receiver
]

{ #category : #visiting }
EvaluationContext >> receiver: anObject [
	receiver := anObject
]

{ #category : #visiting }
EvaluationContext >> return: anObject [
	self isBlock ifTrue: [ ^environment builder return: anObject ].
	nonLocalReturn value: anObject
]

{ #category : #accessing }
EvaluationContext >> staticBindingFor: aSymbol [
	| symbol |
	symbol := system symbolFrom: aSymbol.
	(self staticBindingForIvar: symbol)
		ifNotNil: [ :b | ^ b ].
	(self staticBindingForCvar: symbol) ifNotNil: [ :b | ^ b ].
	^ self staticBindingForMvar: symbol
]

{ #category : #accessing }
EvaluationContext >> staticBindingForCvar: aSymbol [
	| species cvars class |
	species := system speciesFor: receiver.
	[ cvars := species classVariables.
	cvars isNil ifFalse: [ 
		cvars associationAt: aSymbol ifPresent: [:assoc |
			^ SAssociationBinding new association: assoc ].
	species localPools
		do: [ :pool | 
			pool associationAt: aSymbol ifPresent: [:assoc | 
					class := pool isConstant
						ifTrue: [ SConstantPoolBinding ]
						ifFalse: [ SAssociationBinding ].
					^ class new association: assoc ] ]].
	species := species superclass.
	species isNil ] whileFalse.
	^ nil
]

{ #category : #accessing }
EvaluationContext >> staticBindingForIvar: aSymbol [
	| ivar |
	ivar := receiver allSlotNames indexOf: aSymbol.
	^ ivar > 0
		ifTrue: [ SInstVarBinding new index: ivar ]
]

{ #category : #accessing }
EvaluationContext >> staticBindingForMvar: aSymbol [
	| assoc class |
	class := system speciesFor: receiver.
	assoc := class module namespace
		associationAt: aSymbol
		ifAbsent: [ self error: 'unbound variable: ' , aSymbol asString].
	^ SAssociationBinding new association: assoc
]

{ #category : #services }
EvaluationContext >> storeAssociation: association value: anObject [ 
	system storeAssociation: association value: anObject 

]

{ #category : #visiting }
EvaluationContext >> storeNamed: aSymbol with: anObject [
	^ system storeNamed: aSymbol in: receiver with: anObject
]

{ #category : #visiting }
EvaluationContext >> system: anEmulator [
	system := anEmulator
]

{ #category : #visiting }
EvaluationContext >> temporaryAt: index in: anInteger [
	| env |
	anInteger ifNil: [ ^ temporaries at: index ].
	env := self environmentFor: anInteger.
	^ env at: index
]

{ #category : #visiting }
EvaluationContext >> temporaryAt: index in: anInteger put: aValue [
	| env |
	anInteger ifNil: [ ^ temporaries	at:index put: aValue ].
	env := self environmentFor: anInteger.
	^ env at: index put: aValue
]

{ #category : #visiting }
EvaluationContext >> trueLiteral [
	^system true
]

{ #category : #visiting }
EvaluationContext >> visitAssignment: anSAssignment [
	| result |
	result := anSAssignment expression acceptVisitor: self.
	anSAssignment assignees
		do: [ :identifier | identifier binding assign: result within: self ].
	^result
]

{ #category : #visiting }
EvaluationContext >> visitBlock: anSBlock [
	| block |
	block := anSBlock isInlined
		ifTrue: [ SCompiledBlock new ]
		ifFalse: [ anSBlock compiledCode ].
	^ self captureClosure: anSBlock with: block
]

{ #category : #visiting }
EvaluationContext >> visitCascade: anSCascade [
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
				super: anSCascade receiver isSuper sendSite: msg ].
	^ last
]

{ #category : #visiting }
EvaluationContext >> visitIdentifier: anSIdentifier [
	^anSIdentifier binding valueWithin: self.

]

{ #category : #visiting }
EvaluationContext >> visitLiteral: anSLiteral [
	^ system transferLiteral: anSLiteral value
]

{ #category : #visiting }
EvaluationContext >> visitMessage: anSMessage [
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
		sendSite: anSMessage
]

{ #category : #visiting }
EvaluationContext >> visitMethod: anSMethod [
	| primitive |
	primitive := anSMethod pragma.
	primitive ifNil: [ self visitScript: anSMethod. ^receiver ].
	primitive class == SPragma
		ifTrue: [ primitive := system primitiveFor: anSMethod primitive.
			anSMethod pragma: primitive ].
	^ primitive value
]

{ #category : #visiting }
EvaluationContext >> visitReturn: anSReturn [
	| value |
	value := anSReturn expression acceptVisitor: self.
	^self return: value
]

{ #category : #visiting }
EvaluationContext >> visitScript: anSScript [
	| result |
	result := system nil.
	anSScript statements
		do: [ :node | result := node acceptVisitor: self ].
	^ result
]
