Class {
	#name : #PowertalkRuntime,
	#superclass : #Object,
	#instVars : [
		'frames',
		'methodCache',
		'overrides',
		'falseObj',
		'trueObj',
		'nilObj',
		'workStack',
		'regR',
		'context',
		'undermessages',
		'primitives'
	],
	#classVars : [
		'Undermessages'
	],
	#pools : [
		'ClosureElementTypes'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #'as yet unclassified' }
PowertalkRuntime class >> undermessages [
	^#(_basicAt: #_basicAt:put: _bitShiftLeft: _byteAt: #_byteAt:put: _smallSize _largeSize _isSmallInteger _basicHash _basicHash: _smallIntegerByteAt: _uShortAtOffset: #_uShortAtOffset:put:)
]

{ #category : #accessing }
PowertalkRuntime >> behaviorOf: anObject [
	^self subclassResponsibility
]

{ #category : #services }
PowertalkRuntime >> booleanFor: aBoolean [
	^ aBoolean
		ifTrue: [ trueObj ]
		ifFalse: [ falseObj ]
]

{ #category : #services }
PowertalkRuntime >> booleanFrom: anObject [
	anObject == falseObj
		ifTrue: [ ^ false ].
	anObject == trueObj
		ifTrue: [ ^ true ].
	self error: 'not a boolean'
]

{ #category : #accessing }
PowertalkRuntime >> evaluateClosure: receiver [ 
^self evaluateClosure: receiver withArgs: { }

]

{ #category : #accessing }
PowertalkRuntime >> evaluateClosure: receiver whileFalse: arg [
	| result |
	[ result := self evaluateClosure: receiver.
	self booleanFrom: result ]
		whileFalse: [ self evaluateClosure: arg ].
	^ receiver
]

{ #category : #accessing }
PowertalkRuntime >> evaluateClosure: receiver whileTrue: arg [
	| result |
	[ result := self evaluateClosure: receiver.
	self booleanFrom: result ] whileTrue: [ self evaluateClosure: arg ].
	^ receiver
]

{ #category : #visiting }
PowertalkRuntime >> evaluateClosure: aPClosure with: anObject [
	 ^self evaluateClosure: aPClosure withArgs: { anObject }
]

{ #category : #visiting }
PowertalkRuntime >> evaluateClosure: aPClosure with: anObject with: anotherObject [
	^ self evaluateClosure: aPClosure withArgs: {anObject. anotherObject}
]

{ #category : #accessing }
PowertalkRuntime >> evaluateClosure: receiver withArgs: arguments [
	^self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> evaluateMethod: anSCompiledMethod [
		| sexpressions |
	sexpressions := self sexpressionsOf: anSCompiledMethod.
		self visitMethod: sexpressions
]

{ #category : #accessing }
PowertalkRuntime >> evaluatePrimitiveHash: receiver [
	| hash |
	hash := receiver headerHash.
	hash = 0
		ifTrue: [ hash := self nextHash.
			receiver headerHash: hash ].
	^ self newInteger: hash
]

{ #category : #initialization }
PowertalkRuntime >> false [
	^ falseObj
]

{ #category : #accessing }
PowertalkRuntime >> frames [
	^ frames
]

{ #category : #initialization }
PowertalkRuntime >> initialize [
	frames := OrderedCollection new.
	methodCache := Dictionary new.
	overrides := Dictionary new
]

{ #category : #initialization }
PowertalkRuntime >> initializeEmulationOverrides [
	self
		override: #Species -> #basicNew with: 'New';
		override: #Species -> #basicNew: with: 'NewSized';
		override: #Species -> #new with: 'New';
		override: #Species -> #new: with: 'NewSized';
		override: #Species -> #primitiveNewBytes: with: 'NewBytes';
		override: #'Float class' -> #new with: 'FloatNew';
		override: #'PoolDictionary class' -> #new with: 'DictionaryNew';
		override: #'Namespace class' -> #new with: 'DictionaryNew';
		override: #ProtoObject -> #_size with: 'UnderSize';
		override: #ProtoObject -> #behavior with: 'Behavior';
		override: #ProtoObject -> #class with: 'Class';
		override: #ProtoObject -> #== with: 'Equal';
		override: #ProtoObject -> #primitiveSize with: 'Size';
		override: #ProtoObject -> #primitiveAt: with: 'At';
		override: #ProtoObject -> #primitiveAt:put: with: 'AtPut';
		override: #ProtoObject -> #basicHash with: 'Hash';
		override: #SmallInteger -> #+ with: 'SMIPlus';
		override: #SmallInteger -> #- with: 'SMIMinus';
		override: #SmallInteger -> #* with: 'SMITimes';
		override: #SmallInteger -> #// with: 'SMIIntDiv';
		override: #SmallInteger -> #\\ with: 'SMIIntQuot';
		override: #SmallInteger -> #bitAnd: with: 'SMIBitAnd';
		override: #SmallInteger -> #bitXor: with: 'SMIBitXor';
		override: #SmallInteger -> #bitShift: with: 'SMIBitShift';
		override: #SmallInteger -> #highBit with: 'SMIHighBit';
		override: #SmallInteger -> #> with: 'SMIGreaterThan';
		override: #SmallInteger -> #>= with: 'SMIGreaterEqualThan';
		override: #SmallInteger -> #= with: 'SMIEqual';
		override: #SmallInteger -> #sizeInBytes with: 'SMISize';
		override: #Closure -> #value with: 'ClosureValue';
		override: #Closure -> #evaluateAtomically with: 'ClosureValue';
		override: #Closure -> #value: with: 'ClosureValueWithArgs';
		override: #Closure -> #value:value: with: 'ClosureValueWithArgs';
		override: #Closure -> #value:value:value:
			with: 'ClosureValueWithArgs';
		override: #Closure -> #evaluateWith: with: 'ClosureValueWithArgs';
		override: #Closure -> #evaluateWith:with:
			with: 'ClosureValueWithArgs';
		override: #Closure -> #whileTrue: with: 'ClosureWhileTrue';
		override: #Closure -> #whileFalse: with: 'ClosureWhileFalse';
		override: #Closure -> #argumentCount with: 'ClosureArgumentCount';
		override: #String -> #replaceFrom:to:with:startingAt:
			with: 'StringReplaceFromToWithStartingAt';
		override: #'HashTable class' -> #primeFor: with: 'PrimeFor'
]

{ #category : #initializing }
PowertalkRuntime >> initializePrimitives [
	primitives := IdentityDictionary new.
	primitives
		at: #Behavior put: self primitiveBehavior;
		at: #Class put: self primitiveClass;
		at: #UnderSize put: self primitiveUnderSize;
		at: #Size put: self primitiveSize;
		at: #At put: self primitiveAt;
		at: #AtPut put: self primitiveAtPut;
		at: #New put: self primitiveNew;
		at: #NewSized put: self primitiveNewSized;
		at: #NewBytes put: self primitiveNewBytes;
		at: #Equal put: self primitiveEqual;
		at: #SMIPlus put: self primitiveSMIPlus;
		at: #SMIMinus put: self primitiveSMIMinus;
		at: #SMITimes put: self primitiveSMITimes;
		at: #SMIIntDiv put: self primitiveSMIIntDiv;
		at: #SMIIntQuot put: self primitiveSMIIntQuot;
		at: #SMIBitAnd put: self primitiveSMIBitAnd;
		at: #SMIBitXor put: self primitiveSMIBitXor;
		at: #SMIBitShift put: self primitiveSMIBitShift;
		at: #SMIHighBit put: self primitiveSMIHighBit;
		at: #SMIGreaterThan put: self primitiveSMIGreaterThan;
		at: #SMIGreaterEqualThan put: self primitiveSMIGreaterEqualThan;
		at: #SMIEqual put: self primitiveSMIEqual;
		at: #SMINotEqual put: self primitiveSMINotEqual;
		at: #SMISize put: self primitiveSMISize;
		at: #ClosureValue put: self primitiveClosureValue;
		at: #ClosureValueWithArgs put: self primitiveClosureValueWithArgs;
		at: #ClosureWhileTrue put: self primitiveClosureWhileTrue;
		at: #ClosureWhileFalse put: self primitiveClosureWhileFalse;
		at: #ClosureArgumentCount put: self primitiveClosureArgumentCount;
		at: #StringReplaceFromToWithStartingAt
			put: self primitiveStringReplaceFromToWithStartingAt;
		at: #FloatNew put: self primitiveFloatNew;
		at: #DictionaryNew put: self primitiveBootstrapDictNew;
		at: #BootstrapDictBeConstant
			put: self primitiveBootstrapDictBeConstant;
		at: #BootstrapDictKeys put: self primitiveBootstrapDictKeys;
		at: #BootstrapDictAt put: self primitiveBootstrapDictAt;
		at: #BootstrapDictAtPut put: self primitiveBootstrapDictAtPut;
		at: #PrimeFor put: self primitivePrimeFor
]

{ #category : #initializing }
PowertalkRuntime >> initializeUndermessages [
	undermessages := IdentityDictionary new.
	undermessages
		at: #_isSmallInteger put: self underprimitiveIsSmallInteger;
		at: #_isLarge put: self underprimitiveIsLarge;
		at: #_smallSize put: self underprimitiveSmallSize;
		at: #_largeSize put: self underprimitiveLargeSize;
		at: #_basicFlags put: self underprimitiveBasicFlags;
		at: #_basicAt: put: self underprimitiveBasicAt;
		at: #_byteAt: put: self underprimitiveByteAt;
		at: #_basicHash put: self underprimitiveBasicHash;
		at: #_basicHash: put: self underprimitiveBasicHashPut;
		at: #_smallIntegerByteAt:
			put: self underprimitiveSmallIntegerByteAt;
		at: #_bitShiftLeft: put: self underprimitiveBitShiftLeft;
		at: #_uShortAtOffset: put: self underprimitiveUShortAtOffset;
		at: #_uShortAtOffset:put: put: self underprimitiveUShortAtOffsetPut
]

{ #category : #accessing }
PowertalkRuntime >> isClosure: anObjectMap [
	^ self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> lookup: aSymbol startingAt: aBehavior [
	^methodCache at: aSymbol -> aBehavior ifAbsentPut: [ self doLookup: aSymbol startingAt: aBehavior ]
]

{ #category : #accessing }
PowertalkRuntime >> lookup: aSymbol startingAt: aBehavior sendSite: anSMessage [
	| method |
	method := anSMessage methodFor: aBehavior.
	method
		ifNil: [ 
					undermessages at: aSymbol ifPresent: [:block | anSMessage cacheUndermessage: block. ^block ].
			method := self lookup: aSymbol startingAt: aBehavior.
			anSMessage cache: method when: aBehavior ].
	^ method
]

{ #category : #accessing }
PowertalkRuntime >> newBootstrapDictionaryOf: receiver [
	^ self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> newBytesOf: receiver sized: size [
	^ self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> newEnvironmentSized: anInteger [
	^self subclassResponsibility

]

{ #category : #accessing }
PowertalkRuntime >> newInteger: anInteger [
	^self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> newOf: receiver sized: size [
	^ self subclassResponsibility

]

{ #category : #accessing }
PowertalkRuntime >> newSlotsOf: receiver [
^self subclassResponsibility
]

{ #category : #initialization }
PowertalkRuntime >> nil [
	^nilObj
	
]

{ #category : #accessing }
PowertalkRuntime >> override: assoc with: primitiveName [
	^self subclassResponsibility

]

{ #category : #accessing }
PowertalkRuntime >> popFrame [
	frames removeLast.
	frames isEmpty ifFalse: [ context := frames last ]
]

{ #category : #primitives }
PowertalkRuntime >> primitiveAt [
	| receiver index value |
	^[ receiver := context receiver.  index := context arguments first value.
			value := receiver at: index.
			 receiver isBytes
				ifTrue: [ self newInteger: value ]
				ifFalse: [ value ] ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveAtPut [
	| arguments index |
	^ [ arguments := context arguments.
	index := arguments first value.
	context receiver at: index put: arguments second ]
]

{ #category : #primitives }
PowertalkRuntime >> primitiveBehavior [
	| receiver |
	^[ receiver := context receiver. receiver isImmediate
				ifTrue: [ self smallintBehavior ]
				ifFalse: [ receiver behavior ] ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveBootstrapDictAt [
	| string |
	^[ string := context arguments first asString.
	 context receiver at: string ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveBootstrapDictAtPut [
	| string |
	^[ string := context arguments first asString.
			 context receiver at: string put: context arguments second ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveBootstrapDictBeConstant [
	^[ context receiver beConstant ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveBootstrapDictKeys [
	^[ context receiver keys ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveBootstrapDictNew [
	^ [ self newBootstrapDictionaryOf: context receiver ]
]

{ #category : #primitives }
PowertalkRuntime >> primitiveClass [
	^[ self speciesFor: context receiver ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveClosureArgumentCount [
	^ [ self newInteger: context receiver block argumentCount ]
]

{ #category : #primitives }
PowertalkRuntime >> primitiveClosureValue [
	^ [ self evaluateClosure: context receiver ]
]

{ #category : #primitives }
PowertalkRuntime >> primitiveClosureValueWithArgs [
	^[ self evaluateClosure: context receiver withArgs: context arguments ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveClosureWhileFalse [
	^[ self
				evaluateClosure: context receiver
				whileFalse: context arguments first ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveClosureWhileTrue [
	^[ self evaluateClosure: context receiver whileTrue: context arguments first ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveEqual [
	^ [ 
	self booleanFor: context receiver = context arguments first ]
]

{ #category : #primitives }
PowertalkRuntime >> primitiveFloatNew [
	^[ self newBytesOf: context receiver sized: 8 ].

]

{ #category : #accessing }
PowertalkRuntime >> primitiveFor: aSymbol [
	^primitives at: aSymbol
]

{ #category : #primitives }
PowertalkRuntime >> primitiveNew [
	^[ self newSlotsOf: context receiver ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveNewBytes [
	| size |
	^[ size := context arguments first value.
			self newBytesOf: context receiver sized: size ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveNewSized [
	| size |
	^[ size := context arguments first value.
			self newOf: context receiver sized: size ].

]

{ #category : #primitives }
PowertalkRuntime >> primitivePrimeFor [
	^[ self evaluatePrimitivePrimeFor: context arguments first value ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveSMIBitAnd [
	^[ self newInteger: (context receiver value bitAnd: context arguments first value) ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveSMIBitShift [
	^[ self newInteger: (context receiver value bitShift: context arguments first value) ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveSMIBitXor [
	^[ self newInteger: (context receiver value bitXor: context arguments first value) ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveSMIEqual [
	^[ self booleanFor: context receiver value = context arguments first value ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveSMIGreaterEqualThan [
	^[ self booleanFor: context receiver value >= context arguments first value ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveSMIGreaterThan [
	^[ self booleanFor: context receiver value > context arguments first value ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveSMIHighBit [
	^[ self newInteger: context receiver value highBit ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveSMIIntDiv [
	^[ self newInteger: context receiver value // context arguments first value ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveSMIIntQuot [
	^[ self newInteger: context receiver value \\ context arguments first value ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveSMIMinus [
	^[ self newInteger: context receiver value - context arguments first value ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveSMINotEqual [
	^[ self booleanFor: context receiver value != context arguments first value ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveSMIPlus [
	^[ self newInteger: context receiver value + context arguments first value ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveSMISize [
	^[ self newInteger: context receiver value bytesCount ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveSMITimes [
	^[ self newInteger: context receiver value * context arguments first value ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveSize [
	^[ self newInteger: context receiver arrayedSize ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveStringReplaceFromToWithStartingAt [
	| receiver arguments |
	^[ receiver := context receiver. arguments := context arguments. receiver bytes
				replaceFrom: arguments first value
				to: arguments second value
				with:  arguments third bytes
				startingAt: arguments fourth value.
			 receiver ].

]

{ #category : #primitives }
PowertalkRuntime >> primitiveUnderSize [
	^[ self newInteger: context receiver size ].

]

{ #category : #accessing }
PowertalkRuntime >> pushFrame: anEvaluationContext [
	frames addLast: anEvaluationContext.
	context := anEvaluationContext 
]

{ #category : #accessing }
PowertalkRuntime >> removeBootstrapDictionaryOverrides [
self
		removeOverride: #'PoolDictionary class' -> #new;
		removeOverride: #'Namespace class' -> #new

]

{ #category : #accessing }
PowertalkRuntime >> send: aSymbol to: receiver with: arguments super: aBoolean [
	^self send: aSymbol to: receiver with: arguments super: aBoolean sendSite: SMessage new

]

{ #category : #accessing }
PowertalkRuntime >> send: aSymbol to: receiver with: arguments super: aBoolean sendSite: anSMessage [
	| behavior method environment frame size |
	anSMessage cachedUndermessage ifNotNil: [ :block | ^ block value: receiver value: arguments ].
	behavior := aBoolean
		ifTrue: [ self superBehavior ]
		ifFalse: [ self behaviorOf: receiver ].
	method := self
		lookup: aSymbol
		startingAt: behavior
		sendSite: anSMessage.
	method class == BlockClosure
		ifTrue: [ ^ method value: receiver value: arguments ].
	self ASSERT: method notNil.
	size := self methodEnvironmentSize: method.
	environment := self newEnvironmentSized: size.
	frame := EvaluationContext new
		receiver: receiver;
		arguments: arguments;
		environment: environment;
		method: method;
		system: self.
	^ frame evaluate
]

{ #category : #accessing }
PowertalkRuntime >> sendLocal: aSymbol to: receiver [
	^ self sendLocal: aSymbol to: receiver with: {}
]

{ #category : #accessing }
PowertalkRuntime >> sendLocal: aSymbol to: receiver with: anArray [
	| symbol res |

	symbol := self symbolFromLocal: aSymbol.
	res := self
		send: symbol
		to: receiver
		with: anArray
		super: false.
	frames isEmpty
		ifFalse: [ self halt ].
	^res
]

{ #category : #accessing }
PowertalkRuntime >> sexpressionsOf: anSCompiledMethod [
self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> speciesFor: anObject [
	^ self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> superBehavior [
	^ self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> symbolFrom: anObject [
	^anObject
]

{ #category : #initialization }
PowertalkRuntime >> symbolFromLocal: aSymbol [
	^self subclassResponsibility
]

{ #category : #initialization }
PowertalkRuntime >> true [
	^ trueObj
]

{ #category : #underprimitives }
PowertalkRuntime >> underprimitiveBasicAt [
	^ [ :receiver :arguments | receiver slots at: arguments first value ]
]

{ #category : #accessing }
PowertalkRuntime >> underprimitiveBasicFlags [
	^ [ :receiver :arguments | self newInteger: receiver headerFlags ]
]

{ #category : #accessing }
PowertalkRuntime >> underprimitiveBasicHash [
	^ [ :receiver :arguments | self newInteger: receiver headerHash ]
]

{ #category : #accessing }
PowertalkRuntime >> underprimitiveBasicHashPut [
	^ [ :receiver :arguments | receiver headerHash: arguments first value ]
]

{ #category : #accessing }
PowertalkRuntime >> underprimitiveBitShiftLeft [
	| result |
	^ [ :receiver :arguments | result := receiver value
		bitShift: arguments first value.
	self newInteger: result ]
]

{ #category : #accessing }
PowertalkRuntime >> underprimitiveByteAt [
	| result |
	^ [:receiver :arguments |  result :=  receiver bytes
		at:  arguments first value.
	self newInteger: result ]
]

{ #category : #accessing }
PowertalkRuntime >> underprimitiveIsLarge [
	^ [ :receiver :arguments | self booleanFor: receiver isSmall not ]
]

{ #category : #accessing }
PowertalkRuntime >> underprimitiveIsSmallInteger [
	^ [ :receiver :arguments | self booleanFor: receiver isImmediate ]
]

{ #category : #accessing }
PowertalkRuntime >> underprimitiveLargeSize [
	^ [ :receiver :arguments | 
	receiver isSmall
		ifTrue: [ self error ].
	self newInteger: receiver size ]
]

{ #category : #accessing }
PowertalkRuntime >> underprimitiveSmallIntegerByteAt [
	| result |
	^ [ :receiver :arguments | result := receiver value
		byteAt: context arguments first value.
	self newInteger: result ]
]

{ #category : #accessing }
PowertalkRuntime >> underprimitiveSmallSize [
	^ [ :receiver :arguments | 
	receiver isSmall
		ifFalse: [ self error ].
	self newInteger: receiver size ]
]

{ #category : #accessing }
PowertalkRuntime >> underprimitiveUShortAtOffset [
	| result |
	^ [:receiver :arguments |  result := receiver bytes
		unsignedShortAt: context arguments first value + 1.
	self newInteger: result ]
]

{ #category : #accessing }
PowertalkRuntime >> underprimitiveUShortAtOffsetPut [
	| value  |
	^ [ :receiver :arguments | 
	value := arguments second.
	context receiver bytes
		unsignedShortAt: arguments first value + 1
		put: value value.
	value ]
]

{ #category : #accessing }
PowertalkRuntime >> unwind: environment returning: value [
	| home frame |
	home := (self isClosure: environment)
		ifTrue: [ self halt.
			environment at: 1 ]
		ifFalse: [ environment ].
	frames size to: 1 by: -1 do: [ :i | 
		frame := frames at: i.
		(frame isHomeOf: home)
			ifTrue: [ frames removeLast: frames size - i + 1. frames isEmpty ifFalse: [ context := frames last ].
				^ value ] ].
	self error: 'frame not found'
]
