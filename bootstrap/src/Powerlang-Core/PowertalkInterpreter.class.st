Class {
	#name : #PowertalkInterpreter,
	#superclass : #Object,
	#instVars : [
		'runtime',
		'falseObj',
		'trueObj',
		'nilObj',
		'context',
		'undermessages',
		'primitives',
		'messageCount'
	],
	#pools : [
		'ClosureElementTypes'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #'as yet unclassified' }
PowertalkInterpreter class >> undermessages [
	^#(_basicAt: #_basicAt:put: _bitShiftLeft: _byteAt: #_byteAt:put: _smallSize _largeSize _isSmallInteger _basicHash _basicHash: _smallIntegerByteAt: _uShortAtOffset: #_uShortAtOffset:put:)
]

{ #category : #services }
PowertalkInterpreter >> booleanFor: aBoolean [
	^ aBoolean
		ifTrue: [ trueObj ]
		ifFalse: [ falseObj ]
]

{ #category : #services }
PowertalkInterpreter >> booleanFrom: anObject [
	anObject == falseObj
		ifTrue: [ ^ false ].
	anObject == trueObj
		ifTrue: [ ^ true ].
	self error: 'not a boolean'
]

{ #category : #accessing }
PowertalkInterpreter >> context [
	^ context 
]

{ #category : #accessing }
PowertalkInterpreter >> context: anEvaluationContext [ 
	context := anEvaluationContext
]

{ #category : #initializing }
PowertalkInterpreter >> convertPrimitives [
	| original |
	original := primitives.
	primitives := IdentityDictionary new.
	original
		keysAndValuesDo:
			[ :symbol :block | primitives at: (runtime symbolFromLocal: symbol) put: block ]
]

{ #category : #initializing }
PowertalkInterpreter >> convertUndermessages [
	| original |
	original := undermessages.
	undermessages := IdentityDictionary new.
	original keysAndValuesDo: [ :symbol :block | undermessages at: (runtime symbolFromLocal: symbol) put: block ]

]

{ #category : #accessing }
PowertalkInterpreter >> evaluateClosure: receiver [
	^ self evaluateClosure: receiver withArgs: #()
]

{ #category : #visiting }
PowertalkInterpreter >> evaluateClosure: aPClosure with: anObject [
	 ^self evaluateClosure: aPClosure withArgs: { anObject }
]

{ #category : #visiting }
PowertalkInterpreter >> evaluateClosure: aPClosure with: anObject with: anotherObject [
	^ self evaluateClosure: aPClosure withArgs: {anObject. anotherObject}
]

{ #category : #private }
PowertalkInterpreter >> evaluateClosure: receiver withArgs: arguments [
	^self subclassResponsibility
]

{ #category : #accessing }
PowertalkInterpreter >> evaluatePrimitiveHash: receiver [
	| hash |
	hash := receiver headerHash.
	hash = 0
		ifTrue: [ hash := self nextHash.
			receiver headerHash: hash ].
	^ runtime newInteger: hash
]

{ #category : #initialization }
PowertalkInterpreter >> false [
	^ falseObj
]

{ #category : #initialization }
PowertalkInterpreter >> initialize [

	messageCount := 0
]

{ #category : #initializing }
PowertalkInterpreter >> initializePrimitives [
	primitives := IdentityDictionary new.
	primitives
		at: #Behavior put: self primitiveBehavior;
		at: #SetBehavior put: self primitiveSetBehavior;
		at: #Class put: self primitiveClass;
		at: #UnderHash put: self primitiveUnderHash;
		at: #UnderIsBytes put: self primitiveUnderIsBytes;
		at: #UnderPointersSize put: self primitiveUnderPointersSize;
		at: #UnderSize put: self primitiveUnderSize;
		at: #Size put: self primitiveSize;
		at: #Hash put: self primitiveHash;
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
		at: #ClosureArgumentCount put: self primitiveClosureArgumentCount;
		at: #StringReplaceFromToWithStartingAt
			put: self primitiveStringReplaceFromToWithStartingAt;
		at: #FloatNew put: self primitiveFloatNew;
		at: #DictionaryNew put: self primitiveBootstrapDictNew;
		at: #FlushDispatchCaches put: self primitiveFlushDispatchCaches;
		at: #BootstrapDictBeConstant
			put: self primitiveBootstrapDictBeConstant;
		at: #BootstrapDictKeys put: self primitiveBootstrapDictKeys;
		at: #BootstrapDictAt put: self primitiveBootstrapDictAt;
		at: #BootstrapDictAtPut put: self primitiveBootstrapDictAtPut;
		at: #BootstrapLoadModule put: self primitiveBootstrapLoadModule;
		at: #PrimeFor put: self primitivePrimeFor
]

{ #category : #initializing }
PowertalkInterpreter >> initializeUndermessages [
	undermessages := IdentityDictionary new.
	undermessages
		at: #_isSmallInteger put: self underprimitiveIsSmallInteger;
		at: #_isLarge put: self underprimitiveIsLarge;
		at: #_smallSize put: self underprimitiveSmallSize;
		at: #_largeSize put: self underprimitiveLargeSize;
		at: #_basicFlags put: self underprimitiveBasicFlags;
		at: #_basicAt: put: self underprimitiveBasicAt;
		at: #_byteAt: put: self underprimitiveByteAt;
		at: #_byteAt:put: put: self underprimitiveByteAtPut;
		at: #_basicHash put: self underprimitiveBasicHash;
		at: #_basicHash: put: self underprimitiveBasicHashPut;
		at: #_smallIntegerByteAt:
			put: self underprimitiveSmallIntegerByteAt;
		at: #_bitShiftLeft: put: self underprimitiveBitShiftLeft;
		at: #_primitiveULongAtOffset: put: self underprimitiveULongAtOffset;
		at: #_primitiveULongAtOffset:put:
			put: self underprimitiveULongAtOffsetPut;
		at: #_uShortAtOffset: put: self underprimitiveUShortAtOffset;
		at: #_uShortAtOffset:put: put: self underprimitiveUShortAtOffsetPut;
		at: #_smiPlus: put: self underprimitiveSMIPlus;
		at: #_smiMinus: put: self underprimitiveSMIMinus;
		at: #_smiTimes: put: self underprimitiveSMITimes;
		at: #_smiLowerThan: put: self underprimitiveSMILowerThan;
		at: #_smiLowerEqualThan: put: self underprimitiveSMILowerEqualThan;
		at: #_smiGreaterThan: put: self underprimitiveSMIGreaterThan;
		at: #_smiGreaterEqualThan:
			put: self underprimitiveSMIGreaterEqualThan;
		at: #_smiEquals: put: self underprimitiveSMIEquals;
		at: #_identityEquals: put: self underprimitiveIdentityEquals;
		at: #_leadingZeroBitCount
			put: self underprimitiveLeadingZeroBitCount;
		at: #_quotientTowardZero:
			put: self underprimitiveSMIQuotientTowardZero;
		at: #_remainderTowardZero:
			put: self underprimitiveSMIRemainderTowardZero;
		at: #_bitShiftLeft: put: self underprimitiveSMIBitShiftLeft;
		at: #_bitShiftRight: put: self underprimitiveSMIBitShiftRight;
		at: #_smiBitAnd: put: self underprimitiveSMIBitAnd;
		at: #_smiBitOr: put: self underprimitiveSMIBitOr;
		at: #_halt put: self underprimitiveHalt
]

{ #category : #accessing }
PowertalkInterpreter >> isIdentical: anObject to: anotherObject [
	^ anObject == anotherObject
		or: [ anObject isImmediate
				and: [ anotherObject isImmediate
						and: [ anObject value = anotherObject value ] ] ]
]

{ #category : #accessing }
PowertalkInterpreter >> lookup: aSymbol startingAt: aBehavior sendSite: anSMessage [
	| method symbol |
	method := anSMessage methodFor: aBehavior.
	method
		ifNil: [ undermessages
				at: aSymbol
				ifPresent: [ :block | 
					anSMessage cacheUndermessage: block.
					^ block ].
			symbol := runtime symbolFrom: aSymbol.
			method := runtime lookup: symbol startingAt: aBehavior.
			self ASSERT: method notNil.
			anSMessage
				registerCacheWith: runtime;
				cache: method when: aBehavior ].
	^ method
]

{ #category : #initialization }
PowertalkInterpreter >> nil [
	^nilObj
	
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveAt [
	| receiver index value |
	^ [ receiver := context self.
	index := context firstArgument value.
	value := receiver at: index.
	receiver isBytes
		ifTrue: [ runtime newInteger: value ]
		ifFalse: [ value ] ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveAtPut [
	| index |
	^ [ index := context firstArgument value.
	context self at: index put: context secondArgument ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveBehavior [
	| receiver |
	^ [ receiver := context self.
	receiver isImmediate
		ifTrue: [ self smallintBehavior ]
		ifFalse: [ receiver behavior ] ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveBootstrapDictAt [
	| string |
	^ [ string := context firstArgument asString.
	context self at: string ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveBootstrapDictAtPut [
	| string |
	^ [ string := context firstArgument asString.
	context self at: string put: context secondArgument ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveBootstrapDictBeConstant [
	^ [ context self beConstant ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveBootstrapDictKeys [
	^ [ context self keys ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveBootstrapDictNew [
	^ [ runtime newBootstrapDictionaryOf: context self ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveBootstrapLoadModule [
	^ [ runtime loadModule: context firstArgument]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveClass [
	^ [ runtime speciesFor: context self ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveClosureArgumentCount [
	^ [ runtime newInteger: context self block argumentCount ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveClosureValue [
	^ [ self evaluateClosure: context self ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveClosureValueWithArgs [
	^ [ self
		evaluateClosure: context self
		withArgs: context methodArguments ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveEqual [
	^ [ runtime booleanFor: context self = context firstArgument ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveFloatNew [
	^ [ runtime newBytesOf: context self sized: 8 ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveFlushDispatchCaches [
	^ [ runtime
		flushDispatchCache: context self
		in: context firstArgument ]
]

{ #category : #accessing }
PowertalkInterpreter >> primitiveFor: aSymbol [
	^primitives at: aSymbol
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveHash [
	^ [ runtime newInteger: (runtime hashFor: context self) ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveNew [
	^ [ runtime newSlotsOf: context self ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveNewBytes [
	| size |
	^ [ size := context firstArgument value.
	runtime newBytesOf: context self sized: size ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveNewObjectHeap [
	^ [ runtime newObjectHeap ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveNewSized [
	| size |
	^ [ size := context firstArgument value.
	runtime newOf: context self sized: size ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitivePrimeFor [
	^ [ self primitivePrimeFor: context firstArgument value ]
]

{ #category : #accessing }
PowertalkInterpreter >> primitivePrimeFor: anInteger [
	| result |

	result := #(2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103 107 109 113 127 131 137 139 149 151 157 163 167 173 179 181 191 193 197 199 211 223 227 229 233 239 241 251 269 359 479 641 857 1151 1549 2069 2237 2423 2617 2797 2999 3167 3359 3539 3727 3911 4441 4787 5119 5471 5801 6143 6521 6827 7177 7517 7853 8783 9601 10243 10867 11549 12239 12919 13679 14293 15013 15731 17569 19051 20443 21767 23159 24611 25847 27397 28571 30047 31397 35771 38201 40841 43973 46633 48989 51631 54371 57349 60139 62969)
		detect: [ :i | i >= anInteger ].
	^ runtime newInteger: result
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSMIBitAnd [
	^ [ runtime
		newInteger:
			(context self value
				bitAnd: (runtime integerFrom: context firstArgument)) ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSMIBitOr [
	^ [ runtime
		newInteger:
			(context self value
				bitOr: (runtime integerFrom: context firstArgument)) ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSMIBitShift [
	^ [ runtime
		newInteger:
			(context self value
				bitShift: (runtime integerFrom: context firstArgument)) ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSMIBitXor [
	^ [ runtime
		newInteger:
			(context self value
				bitXor: (runtime integerFrom: context firstArgument)) ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSMIEqual [
	^ [ runtime
		booleanFor: (
			context self value = 
				context firstArgument value) ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSMIGreaterEqualThan [
	^ [ runtime
		booleanFor:
			context self value
				>= (runtime integerFrom: context firstArgument) ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSMIGreaterThan [
	^ [ runtime
		booleanFor: context self value > (runtime integerFrom: context firstArgument) ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSMIHighBit [
	^ [ runtime newInteger: context self value highBit ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSMIIntDiv [
	^ [ runtime
		newInteger:
			context self value
				// (runtime integerFrom: context firstArgument ) ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSMIIntQuot [
	^ [ runtime
		newInteger:
			context self value
				\\ (runtime integerFrom: context firstArgument) ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSMIMinus [
	^ [ runtime
		newInteger:
			context self value
				- (runtime integerFrom: context firstArgument) ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSMINotEqual [
	^ [ runtime
		booleanFor:
			context self value
				!= (runtime integerFrom: context firstArgument) ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSMIPlus [
	^ [ runtime
		newInteger:
			context self value
				+ (runtime integerFrom: context firstArgument) ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSMISize [
	^ [ runtime newInteger: context self value bytesCount ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSMITimes [
	^ [ runtime
		newInteger:
			context self value
				* (runtime integerFrom: context firstArgument) ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSetBehavior [
	| receiver |
	^ [ receiver := context self.
	receiver behavior: context firstArgument.
	receiver ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveSize [
	^ [ runtime newInteger: (runtime arrayedSizeOf: context self) ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveStringReplaceFromToWithStartingAt [
	| receiver |
	^ [ receiver := context self.
	receiver bytes
		replaceFrom: context firstArgument value
		to: context secondArgument value
		with: context thirdArgument bytes
		startingAt: context fourthArgument value.
	receiver ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveUnderHash [
	^ [ runtime newInteger: context self headerHash ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveUnderIsBytes [
	^ [ runtime booleanFor: context self isBytes ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveUnderPointersSize [
	^ [ runtime newInteger: context self pointersSize ]
]

{ #category : #primitives }
PowertalkInterpreter >> primitiveUnderSize [
	^ [ runtime newInteger: context self size ]
]

{ #category : #initializing }
PowertalkInterpreter >> runtime [
	^runtime

]

{ #category : #initializing }
PowertalkInterpreter >> runtime: aPowertalkRuntime [
	runtime := aPowertalkRuntime.
	nilObj := runtime nil.
	trueObj := runtime true.
	falseObj := runtime false.
	self
		initializeUndermessages;
		initializePrimitives; convertUndermessages ; convertPrimitives 
]

{ #category : #accessing }
PowertalkInterpreter >> sendLocal: aSymbol to: receiver [
	^ self sendLocal: aSymbol to: receiver with: {}
]

{ #category : #accessing }
PowertalkInterpreter >> stackSize [
	^context framesCount
]

{ #category : #initialization }
PowertalkInterpreter >> true [
	^ trueObj
]

{ #category : #underprimitives }
PowertalkInterpreter >> underprimitiveBasicAt [
	^ [ :receiver :arguments | receiver slots at: arguments first value ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveBasicFlags [
	^ [ :receiver :arguments | runtime newInteger: receiver headerFlags ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveBasicHash [
	^ [ :receiver :arguments | runtime newInteger: receiver headerHash ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveBasicHashPut [
	^ [ :receiver :arguments | receiver headerHash: arguments first value ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveBitShiftLeft [
	| result |
	^ [ :receiver :arguments | 
	result := receiver value bitShift: arguments first value.
	runtime newInteger: result ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveByteAt [
	| result |
	^ [ :receiver :arguments | 
	result := receiver bytes at: arguments first value.
	runtime newInteger: result ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveByteAtPut [

	^ [ :receiver :arguments | 
	receiver bytes
		at: arguments first value
		put: arguments second value.
	arguments second ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveHalt [
	^ [ :receiver :arguments | self halt ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveIdentityEquals [
	^ [ :receiver :arguments | runtime booleanFor: (self isIdentical: receiver to: arguments first)]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveIsLarge [
	^ [ :receiver :arguments | runtime booleanFor: receiver isSmall not ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveIsSmallInteger [
	^ [ :receiver :arguments | runtime booleanFor: receiver isImmediate ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveLargeSize [
	^ [ :receiver :arguments | 
	receiver isSmall
		ifTrue: [ self error ].
	runtime newInteger: receiver size ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveLeadingZeroBitCount [
	^ [ :receiver :arguments | 
	runtime
		newInteger: (self
		underprimitiveLeadingZeroBitCount: receiver value) ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveLeadingZeroBitCount: anInteger [
	^ anInteger < 0
		ifTrue: [ 0 ]
		ifFalse: [ runtime wordSize * 8 - anInteger highBit ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSMIBitAnd [
	^ [ :receiver :arguments | runtime newInteger: (receiver value bitAnd: arguments first value) ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSMIBitOr [
	^ [ :receiver :arguments | runtime newInteger: (receiver value bitOr: arguments first value) ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSMIBitShiftLeft [
	^ [ :receiver :arguments | runtime newInteger: receiver value << arguments first value ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSMIBitShiftRight [
	^ [ :receiver :arguments | 
	runtime
		newInteger: (receiver value >> arguments first value) ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSMIEquals [
	^ [ :receiver :arguments | runtime booleanFor: receiver value = arguments first value ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSMIGreaterEqualThan [
	^ [ :receiver :arguments | runtime booleanFor: receiver value >= arguments first value ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSMIGreaterThan [
	^ [ :receiver :arguments | runtime booleanFor: receiver value > arguments first value ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSMILowerEqualThan [
	^ [ :receiver :arguments | runtime booleanFor: receiver value <= arguments first value ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSMILowerThan [
	^ [ :receiver :arguments | runtime booleanFor: receiver value < arguments first value ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSMIMinus [
	^ [ :receiver :arguments | runtime newInteger: receiver value - arguments first value ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSMIPlus [
	^ [ :receiver :arguments | runtime newInteger: receiver value + arguments first value ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSMIQuotientTowardZero [
	^ [ :receiver :arguments | runtime newInteger: (receiver value quo: arguments first value) ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSMIRemainderTowardZero [
	^ [ :receiver :arguments | runtime newInteger: (receiver value \\ arguments first value) ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSMITimes [
	^ [ :receiver :arguments | runtime newInteger: receiver value * arguments first value ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSmallIntegerByteAt [
	| result |
	^ [ :receiver :arguments | 
	result := receiver value byteAt: arguments first value.
	runtime newInteger: result ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveSmallSize [
	^ [ :receiver :arguments | 
	receiver isSmall
		ifFalse: [ self error ].
	runtime newInteger: receiver size ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveULongAtOffset [
	| result |
	^ [ :receiver :arguments | 
	result := receiver bytes unsignedLongAt: arguments second value + 1.
	runtime newInteger: result ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveULongAtOffsetPut [
	| value |
	^ [ :receiver :arguments | 
	value := arguments second.
	receiver bytes
		unsignedLongAt: arguments first value + 1
		put: value value.
	value ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveUShortAtOffset [
	| result |
	^ [ :receiver :arguments | 
	result := receiver bytes
		unsignedShortAt: arguments second value + 1.
	runtime newInteger: result ]
]

{ #category : #accessing }
PowertalkInterpreter >> underprimitiveUShortAtOffsetPut [
	| value |
	^ [ :receiver :arguments | 
	value := arguments second.
	receiver bytes
		unsignedShortAt: arguments first value + 1
		put: value value.
	value ]
]
