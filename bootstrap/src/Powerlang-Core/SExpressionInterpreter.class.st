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
		'parent',
		'gateBuilder',
		'blockAstcodes',
		'environment'
	],
	#pools : [
		'ClosureElementTypes'
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
SExpressionInterpreter >> argumentAt: index in: anInteger [
	| env |
	anInteger ifNil: [ ^arguments at: index ].
	env := self environmentFor: anInteger.
	^env at: index.
]

{ #category : #visiting }
SExpressionInterpreter >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #visiting }
SExpressionInterpreter >> captureClosure: anSBlock [
	| closure s i type env arg |
	closure := anSBlock compiledCode newClosure home: self.
	s := anSBlock capturedVariables readStream.
	i := 1.
	[ s atEnd ]
		whileFalse: [ type := s next.
			type = Self
				ifTrue: [ closure at: i put: receiver ].
			type = Environment
				ifTrue: [ closure at: i put: environment].
			type = EnvironmentValue
				ifTrue: [ env := environment at: s next.
					closure at: i put: env ].
			type = LocalArgument
				ifTrue: [ arg := arguments at: s next.
					closure at: i put: arg ].
			i := i + 1 ].
	^ closure
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
SExpressionInterpreter >> environmentFor: anInteger [
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
SExpressionInterpreter >> evaluate: anSCompiledMethod [
	method := anSCompiledMethod.
	^ self visitMethod: anSCompiledMethod sexpressions
]

{ #category : #visiting }
SExpressionInterpreter >> evaluateBlock: aPClosure [
	^self evaluateBlock: aPClosure withArgs: {}
]

{ #category : #visiting }
SExpressionInterpreter >> evaluateBlock: aPClosure with: anObject [
	 ^self evaluateBlock: aPClosure withArgs: { anObject }
]

{ #category : #visiting }
SExpressionInterpreter >> evaluateBlock: aPClosure with: anObject with: anotherObject [
	^ self evaluateBlock: aPClosure withArgs: {anObject. anotherObject}
]

{ #category : #visiting }
SExpressionInterpreter >> evaluateBlock: aPClosure withArgs: anArray [
	| oldArgs oldTemps oldEnv block sblock result |
	block := aPClosure block.
	sblock := blockAstcodes at: block.
	sblock isInlined ifTrue: [
			 anArray with: sblock inlinedArgs do: [:arg :i | temporaries at: i put: arg].
			^ self visitScript: sblock ].
	oldArgs := arguments.
	oldTemps := temporaries.
	oldEnv := environment.
	arguments := anArray.
	temporaries := Array new: block tempCount.
	environment := aPClosure.
	result := self visitScript: sblock.
	environment := oldEnv.
	temporaries := oldTemps.
	arguments := oldArgs.
	^ result
]

{ #category : #visiting }
SExpressionInterpreter >> initialize [
	returned := false.
	blockAstcodes := IdentityDictionary new
]

{ #category : #visiting }
SExpressionInterpreter >> instVarAt: anInteger [
	^receiver _gate slotAt: anInteger
]

{ #category : #visiting }
SExpressionInterpreter >> instVarAt: index put: aValue [
	^ receiver _gate handle slotAt: index put: aValue _gate handle oid
]

{ #category : #visiting }
SExpressionInterpreter >> isSpecial: aSelectorMirror [
	^ self subclassResponsibility 
]

{ #category : #visiting }
SExpressionInterpreter >> method [
	^method
]

{ #category : #accessing }
SExpressionInterpreter >> method: aCompiledMethod [
	method := aCompiledMethod.
	temporaries := Array new: aCompiledMethod tempCount.
]

{ #category : #visiting }
SExpressionInterpreter >> mirageOnBoolean: aBoolean [
	| runtime handle |
	runtime := receiver _gate handle runtime.
	handle := aBoolean ifTrue: [runtime true] ifFalse: [runtime false].
	^ handle mirage
]

{ #category : #visiting }
SExpressionInterpreter >> mirageOnInteger: anInteger [
	| runtime handle |
	runtime := receiver _gate handle runtime.
	handle := runtime integerHandle: anInteger.
	^ handle mirage
]

{ #category : #visiting }
SExpressionInterpreter >> mirageOnObject: anObject [
	anObject isSmallInteger ifTrue: [ ^ self mirageOnInteger: anObject ].
	self ASSERT: false
]

{ #category : #visiting }
SExpressionInterpreter >> parent [
	^parent
]

{ #category : #visiting }
SExpressionInterpreter >> parent: anInterpreter [
	parent := anInterpreter
]

{ #category : #printing }
SExpressionInterpreter >> printOn: aStream [
	aStream
		nextPutAll: self class name withArticle;
		cr;
		print: method classBinding;
		nextPutAll: '>>';
		print: method selector;
		cr.
	aStream
		nextPutAll: 'rcvr -> ';
		print: receiver _gate handle;
		cr.
	arguments
		withIndexDo: [ :a :i | 
			aStream
				nextPutAll: 'arg ';
				print: i;
				nextPutAll: ' -> ';
				print: a _gate;
				cr ].
	aStream nextPutAll: method source
]

{ #category : #visiting }
SExpressionInterpreter >> receiver [
	^receiver
]

{ #category : #visiting }
SExpressionInterpreter >> receiver: anObject [
	receiver := anObject.
	returnValue := anObject
]

{ #category : #visiting }
SExpressionInterpreter >> subjectOn: anObjectHandle [
	^ anObjectHandle maneuverer
]

{ #category : #visiting }
SExpressionInterpreter >> subjectOnBoolean: aBoolean in: aRuntime [
	| t f |
	^ aBoolean
		ifTrue: [ t := aRuntime true. t oid = true ifTrue: [ t mirage] ifFalse: [ t maneuverer  ] ]
		ifFalse: [ f := aRuntime false. f oid = false ifTrue: [ f mirage ] ifFalse: [ f maneuverer]] 
]

{ #category : #visiting }
SExpressionInterpreter >> subjectOnInteger: anInteger in: aRuntime [
	^ (aRuntime integerHandle: anInteger) maneuverer
]

{ #category : #visiting }
SExpressionInterpreter >> subjectOnObject: anObjectHandle [
	^ anObjectHandle maneuverer
]

{ #category : #visiting }
SExpressionInterpreter >> subjectOnObjectOk: anObjectHandle [
	^ self maneuvererOn: anObjectHandle
]

{ #category : #visiting }
SExpressionInterpreter >> temporaryAt: index in: anInteger [
	| env |
	anInteger ifNil: [ ^ temporaries at: index ].
	env := self environmentFor: anInteger.
	^ env at: index
]

{ #category : #visiting }
SExpressionInterpreter >> temporaryAt: index in: anInteger put: aValue [
	| env |
	anInteger ifNil: [ ^ temporaries	at:index put: aValue ].
	env := self environmentFor: anInteger.
	^ env at: index put: aValue
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
SExpressionInterpreter >> visitBlock: anSBlock [
	| closure handle |
	closure := anSBlock isInlined
		           ifTrue: [ SCompiledBlock new newClosure home: self ]
		           ifFalse: [ self captureClosure: anSBlock ].
	blockAstcodes at: closure block put: anSBlock.
	self halt.
	"	handle := LocalHandle on: closure within: localRuntime."
	^ handle mirage
]

{ #category : #visiting }
SExpressionInterpreter >> visitIdentifier: anSIdentifier [
	^anSIdentifier binding valueWithin: self.

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
	 (self isSpecial: selector)
		ifTrue: [ ^self dispatchSpecial: message ].
	anSMessage receiver isSuper ifTrue: [^self dispatchSuper: message to: msgReceiver].
	^self dispatch: message to: msgReceiver
]

{ #category : #visiting }
SExpressionInterpreter >> visitMethod: anSMethod [
	| primitive value |
	primitive := anSMethod primitive.
	primitive ifNotNil: [ ^ self visitPrimitive: primitive ].
	environment := Array new: method environmentCount.
	value := self visitScript: anSMethod.
	^returned ifTrue: [ value ] ifFalse: [ receiver ]
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
