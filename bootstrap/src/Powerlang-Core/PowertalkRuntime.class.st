Class {
	#name : #PowertalkRuntime,
	#superclass : #Object,
	#instVars : [
		'frames',
		'undermessages',
		'methodCache',
		'overrides',
		'falseObj',
		'trueObj',
		'nilObj'
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
PowertalkRuntime >> classFor: anObject [
	^self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> evaluateClosure: receiver [ 
^self evaluateClosure: receiver withArgs: { }

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
PowertalkRuntime >> evaluatePrimitive: primitive in: frame [
	| receiver arguments index size argument value string |
	receiver := frame receiver.
	arguments := frame arguments.
	primitive == #Behavior
		ifTrue: [ ^ receiver isImmediate
				ifTrue: [ self smallintBehavior ]
				ifFalse: [ receiver behavior ] ].
	primitive == #Class
		ifTrue: [ ^ self speciesFor: receiver ].
	primitive == #UnderSize
		ifTrue: [ ^ self newInteger: receiver size ].
	primitive == #Size
		ifTrue: [ ^ self newInteger: receiver arrayedSize ].
	primitive == #At
		ifTrue: [ index := arguments first value.
			value := receiver at: index.
			^ receiver isBytes
				ifTrue: [ self newInteger: value ]
				ifFalse: [ value ] ].
	primitive == #AtPut
		ifTrue: [ index := arguments first value.
			^ receiver at: index put: arguments second ].
	primitive == #New
		ifTrue: [ ^ self newSlotsOf: receiver ].
	primitive == #NewSized
		ifTrue: [ size := arguments first value.
			^ self newOf: receiver sized: size ].
	primitive == #NewBytes
		ifTrue: [ size := arguments first value.
			^ self newBytesOf: receiver sized: size ].
	primitive == #Equal
		ifTrue: [ argument := arguments first.
			^ self booleanFor: receiver = argument ].
	primitive == #SMIPlus
		ifTrue: [ ^ self newInteger: receiver value + arguments first value ].
	primitive == #SMIMinus
		ifTrue: [ ^ self newInteger: receiver value - arguments first value ].
	primitive == #SMITimes
		ifTrue: [ ^ self newInteger: receiver value * arguments first value ].
	primitive == #SMIIntDiv
		ifTrue: [ ^ self newInteger: receiver value // arguments first value ].
	primitive == #SMIIntQuot
		ifTrue: [ ^ self newInteger: receiver value \\ arguments first value ].
	primitive == #SMIBitAnd
		ifTrue: [ ^ self newInteger: (receiver value bitAnd: arguments first value) ].
	primitive == #SMIBitXor
		ifTrue: [ ^ self newInteger: (receiver value bitXor: arguments first value) ].
	primitive == #SMIBitShift
		ifTrue:
			[ ^ self newInteger: (receiver value bitShift: arguments first value) ].
	primitive == #SMIHighBit
		ifTrue: [ ^ self newInteger: receiver value highBit ].
	primitive == #SMIGreaterThan
		ifTrue: [ ^ self booleanFor: receiver value > arguments first value ].
	primitive == #SMIGreaterEqualThan
		ifTrue: [ ^ self booleanFor: receiver value >= arguments first value ].
	primitive == #SMIEqual
		ifTrue: [ ^ self booleanFor: receiver value = arguments first value ].
	primitive == #SMINotEqual
		ifTrue: [ ^ self booleanFor: receiver value != arguments first value ].
	primitive == #SMISize
		ifTrue: [ ^ self newInteger: receiver value bytesCount ].
	primitive == #ClosureValue
		ifTrue: [ ^ self evaluatePrimitiveClosureValue: receiver ].
	primitive == #ClosureValueWithArgs
		ifTrue: [ ^ self evaluateClosure: receiver withArgs: arguments ].
	primitive == #ClosureWhileTrue
		ifTrue:
			[ ^ self evaluatePrimitiveClosure: receiver whileTrue: arguments first ].
	primitive == #ClosureWhileFalse
		ifTrue: [ ^ self
				evaluatePrimitiveClosure: receiver
				whileFalse: arguments first ].
	primitive == #ClosureArgumentCount
		ifTrue: [ ^ self evaluatePrimitiveClosureArgumentCount: receiver ].
	primitive == #StringReplaceFromToWithStartingAt
		ifTrue: [ receiver bytes
				replaceFrom: arguments first value
				to: arguments second value
				with: arguments third bytes
				startingAt: arguments fourth value.
			^ receiver ].
	primitive == #FloatNew
		ifTrue: [ ^ self newBytesOf: receiver sized: 8 ].
	primitive == #DictionaryNew
		ifTrue: [ ^ self newBootstrapDictionaryOf: receiver ].
	primitive == #BootstrapDictBeConstant
		ifTrue: [ ^ receiver beConstant ].
	primitive == #BootstrapDictKeys
		ifTrue: [ ^ receiver keys ].
	primitive == #BootstrapDictAt
		ifTrue: [ string := arguments first asString.
			^ receiver at: string ].
	primitive == #BootstrapDictAtPut
		ifTrue: [ string := arguments first asString.
			^ receiver at: string put: arguments second ].
	primitive == #PrimeFor
		ifTrue: [ ^ self evaluatePrimitivePrimeFor: arguments first value ].
	self ASSERT: false
]

{ #category : #accessing }
PowertalkRuntime >> evaluatePrimitiveClosure: receiver whileFalse: arg [
	| result |
	[ result := self evaluateClosure: receiver.
	self booleanFrom: result ]
		whileFalse: [ self evaluateClosure: arg ].
	^ receiver
]

{ #category : #accessing }
PowertalkRuntime >> evaluatePrimitiveClosure: receiver whileTrue: arg [
	| result |
	[ result := self evaluateClosure: receiver.
	self booleanFrom: result ] whileTrue: [ self evaluateClosure: arg ].
	^ receiver
]

{ #category : #accessing }
PowertalkRuntime >> evaluatePrimitiveClosureArgumentCount: receiver [
	^ self subclassResponsibility
]

{ #category : #accessing }
PowertalkRuntime >> evaluatePrimitiveClosureValue: receiver [
	^ self evaluateClosure: receiver withArgs: {}.

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

{ #category : #accessing }
PowertalkRuntime >> evaluateUnderprimitive: selector with: recv with: args [
	| result |
	selector == #_isSmallInteger
		ifTrue: [ ^ self booleanFor: recv isImmediate ].
	selector == #_isLarge
		ifTrue: [ ^ self booleanFor: recv isSmall not ].
	selector == #_smallSize
		ifTrue: [ ^ self
				newInteger:
					(recv isSmall
						ifTrue: [ recv size ]
						ifFalse: [ self error ]) ].
	selector == #_largeSize
		ifTrue: [ ^ self
				newInteger:
					(recv isSmall
						ifTrue: [ self error ]
						ifFalse: [ recv size ]) ].
	selector == #_basicFlags
		ifTrue: [ ^ self newInteger: recv headerFlags ].
	selector == #_basicAt:
		ifTrue: [ ^ recv slots at: args first value ].
	selector == #_byteAt:
		ifTrue: [ result := recv bytes at: args first value.
			^ self newInteger: result ].
	selector == #_basicHash
		ifTrue: [ ^ self newInteger: recv headerHash ].
	selector == #_basicHash:
		ifTrue: [ recv headerHash: args first value.
			^ recv ].
	selector == #_smallIntegerByteAt:
		ifTrue: [ result := recv value byteAt: args first value.
			^ self newInteger: result ].
	selector == #_bitShiftLeft:
		ifTrue: [ result := recv value bitShift: args first value.
			^ self newInteger: result ].
	selector == #_uShortAtOffset:
		ifTrue: [ ^ result := self
				newInteger: (recv bytes unsignedShortAt: args first value + 1) ].
	selector == #_uShortAtOffset:put:
		ifTrue: [ result := args second.
			recv bytes unsignedShortAt: args first value + 1 put: result value.
			^ result ].
	self ASSERT: false
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

{ #category : #accessing }
PowertalkRuntime >> isClosure: anObjectMap [
	^ self subclassResponsibility
]

{ #category : #testing }
PowertalkRuntime >> isUndermessage: selector [
	^ undermessages includes: selector
]

{ #category : #accessing }
PowertalkRuntime >> lookup: aSymbol startingAt: aBehavior [
	^methodCache at: aSymbol -> aBehavior ifAbsentPut: [ self doLookup: aSymbol startingAt: aBehavior ]
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
	frames removeLast
]

{ #category : #accessing }
PowertalkRuntime >> pushFrame: aMethodEvaluator [
	frames addLast: aMethodEvaluator
]

{ #category : #accessing }
PowertalkRuntime >> removeBootstrapDictionaryOverrides [
self
		removeOverride: #'PoolDictionary class' -> #new;
		removeOverride: #'Namespace class' -> #new

]

{ #category : #accessing }
PowertalkRuntime >> send: aSymbol to: receiver with: arguments super: aBoolean [
	| behavior method environment frame size |
	(self isUndermessage: aSymbol)
		ifTrue: [ ^ self
				evaluateUnderprimitive: aSymbol
				with: receiver
				with: arguments ].
	behavior := aBoolean
		ifTrue: [ self superBehavior]
		ifFalse: [ self behaviorOf: receiver ].
	method := self lookup: aSymbol startingAt: behavior.
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
			ifTrue: [ frames removeLast: frames size - i + 1. ^ value ]. ].
	self error: 'frame not found'
]
