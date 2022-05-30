Class {
	#name : #PowertalkRecursiveInterpreter,
	#superclass : #PowertalkInterpreter,
	#category : #'Powerlang-Core-Execution'
}

{ #category : #visiting }
PowertalkRecursiveInterpreter >> evaluateClosure: receiver whileFalse: arg [
	| result |
	[ result := self evaluateClosure: receiver.
	self booleanFrom: result ]
		whileFalse: [ self evaluateClosure: arg ].
	^ receiver
]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> evaluateClosure: receiver whileTrue: arg [
	| result |
	[ result := self evaluateClosure: receiver.
	self booleanFrom: result ] whileTrue: [ self evaluateClosure: arg ].
	^ receiver
]

{ #category : #private }
PowertalkRecursiveInterpreter >> evaluateClosure: closure withArgs: arguments [
	| frame sblock result |
	frame := closure builder.
	sblock := closure executionTree.
	context := frame copy
		beBlock;
		parent: context;
		initializeForBlock: sblock args: arguments closure: closure.
	result := nilObj.
	sblock statements do: [ :node | result := node acceptVisitor: self ].
	^ result
]

{ #category : #services }
PowertalkRecursiveInterpreter >> evaluateMethodStatements: anSMethod [
	| last result |
	last := nil.
	anSMethod statements
		do: [ :node | 
			last := node.
			result := node acceptVisitor: self ].
	^ (last notNil and: [ last isReturn ])
		ifTrue: [ result ]
		ifFalse: [ context self ]
]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> hasFinished [
	^context isNil
]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> initializePrimitives [ 
	super initializePrimitives.
	primitives 
		at: #ClosureWhileTrue put: self primitiveClosureWhileTrue;
		at: #ClosureWhileFalse put: self primitiveClosureWhileFalse
]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> primitiveClosureWhileFalse [
	^ [ self
		evaluateClosure: context self
		whileFalse: context arguments first ]
]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> primitiveClosureWhileTrue [
	^ [ self
		evaluateClosure: context self
		whileTrue: context arguments first ]
]

{ #category : #initializing }
PowertalkRecursiveInterpreter >> runtime: aPowertalkRuntime [
	super runtime: aPowertalkRuntime.
	aPowertalkRuntime
		override: #Closure -> #whileTrue: withPrimitive: 'ClosureWhileTrue';
		override: #Closure -> #whileFalse: withPrimitive: 'ClosureWhileFalse'
]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> send: aSymbol to: receiver with: arguments super: aBoolean [
	^self send: aSymbol to: receiver with: arguments super: aBoolean sendSite: SMessage new

]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> send: aSymbol to: receiver with: arguments super: aBoolean sendSite: anSMessage [
	| behavior method environment size |
	anSMessage cachedUndermessage
		ifNotNil: [ :block | ^ block value: receiver value: arguments ].
	behavior := aBoolean
		ifTrue: [ runtime superBehaviorOf: context classBinding ]
		ifFalse: [ runtime behaviorOf: receiver ].
	method := self
		lookup: aSymbol
		startingAt: behavior
		sendSite: anSMessage.
	method class == BlockClosure
		ifTrue: [ ^ method value: receiver value: arguments ].
	self ASSERT: method notNil.
	size := runtime methodEnvironmentSize: method.
	environment := runtime newEnvironmentSized: size.
	context := RecursiveLinkedEvaluationContext new
		self: receiver;
		arguments: arguments;
		environment: environment;
		parent: context;
		method: method;
		system: runtime.
	^ context evaluateFor: self
]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> sendLocal: aSymbol to: receiver with: anArray [
	| symbol res |
	symbol := runtime symbolFromLocal: aSymbol.
	res := self
		send: symbol
		to: receiver
		with: anArray
		super: false.
	^ res
]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> visitAssignment: anSAssignment [
	| result |
	result := anSAssignment expression acceptVisitor: self.
	anSAssignment assignees
		do: [ :identifier | identifier binding assign: result within: context ].
	^ result
]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> visitBlock: anSBlock [
	^ context captureClosure: anSBlock
]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> visitCascade: anSCascade [
	| recv args  last |
	recv := anSCascade receiver acceptVisitor: self.
	anSCascade messages
		do: [ :msg | 
			args := msg arguments collect: [ :code | code acceptVisitor: self ].
			last := self
				send: msg selector
				to: recv
				with: args
				super: anSCascade receiver isSuper
				sendSite: msg ].
	^ last
]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> visitIdentifier: anSIdentifier [
	^ anSIdentifier binding valueWithin: context
]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> visitLiteral: anSLiteral [
	^ runtime literalFor: anSLiteral value
]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> visitMessage: anSMessage [
	| recv args |
	recv := anSMessage receiver acceptVisitor: self.
	args := anSMessage arguments
		collect: [ :code | code acceptVisitor: self ].
	^ self
		send: anSMessage selector
		to: recv
		with: args
		super: anSMessage receiver isSuper
		sendSite: anSMessage
]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> visitMethod: anSMethod [
	| primitive |
	primitive := anSMethod pragma.
	primitive ifNil: [ ^ self evaluateMethodStatements: anSMethod ].
	primitive class == SPragma
		ifTrue: [ primitive := self primitiveFor: anSMethod primitive.
			anSMethod pragma: primitive ].
	^ primitive value
]

{ #category : #visiting }
PowertalkRecursiveInterpreter >> visitReturn: anSReturn [
	| value |
	value := anSReturn expression acceptVisitor: self.
	^context return: value
]
