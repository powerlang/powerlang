Class {
	#name : #PowertalkNativeJSEvaluator,
	#superclass : #PowertalkEvaluator,
	#category : #'Powerlang-JS'
}

{ #category : #private }
PowertalkNativeJSEvaluator >> lookup: anSMessage startingAt: aBehavior [
	| method symbol |
	method := anSMessage methodFor: aBehavior.
	method ifNotNil: [ ^method ].
	symbol := anSMessage selector.
			undermessages
				at: symbol
				ifPresent: [ :block | 
					anSMessage cacheUndermessage: block.
					^ block ].
			symbol := runtime symbolFrom: symbol.
			method := runtime lookup: symbol startingAt: aBehavior.
			self ASSERT: method notNil.
			anSMessage
				registerCacheWith: runtime;
				cache: method when: aBehavior.
	^ method
]

{ #category : #private }
PowertalkNativeJSEvaluator >> prepareForExecution: method [
	| code expressions |
	code := runtime methodOptimizedCode: method.
	code == runtime nil
		ifFalse: [ ^ code ].
	expressions := runtime sexpressionsOf: method.
	code := JSSExpressionTranspiler new
		evaluator: self;
		nativize: expressions. 
	runtime methodOptimizedCode: method put: code.
	^ code
]

{ #category : #private }
PowertalkNativeJSEvaluator >> send: anSMessage super: aBoolean to: receiver with: arguments [
	| behavior method code prev result |
	anSMessage cachedUndermessage
		ifNotNil: [ :block | ^ block value: receiver value: arguments ].
	behavior := aBoolean
		ifTrue: [ runtime superBehaviorOf: context classBinding ]
		ifFalse: [ runtime behaviorOf: receiver ].
	method := self lookup: anSMessage startingAt: behavior.
	method class == BlockClosure
		ifTrue: [ ^ method value: receiver value: arguments ].
	self ASSERT: method notNil.
	prev := context.
	context := NativeJSEvaluationContext new
		system: runtime;
		self: receiver;
		arguments: arguments;
		parent: prev;
		method: method.
	code := self prepareForExecution: method.
	result :=  code executeFor: self in: context.
	context := prev.
	^result
]

{ #category : #private }
PowertalkNativeJSEvaluator >> sendLocal: aSymbol to: receiver with: anArray [
	| symbol res message |
	symbol := runtime symbolFromLocal: aSymbol.
	message := SMessage new selector: symbol.
	res := self
		send: message
		super: false
		to: receiver
		with: anArray.
	^ res
]
