Class {
	#name : #PowertalkEvaluator,
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
PowertalkEvaluator class >> undermessages [
	^#(_basicAt: #_basicAt:put: _bitShiftLeft: _byteAt: #_byteAt:put: _smallSize _largeSize _isSmallInteger _basicHash _basicHash: _smallIntegerByteAt: _uShortAtOffset: #_uShortAtOffset:put:)
]

{ #category : #services }
PowertalkEvaluator >> booleanFor: aBoolean [
	^ aBoolean
		ifTrue: [ trueObj ]
		ifFalse: [ falseObj ]
]

{ #category : #services }
PowertalkEvaluator >> booleanFrom: anObject [
	anObject == falseObj
		ifTrue: [ ^ false ].
	anObject == trueObj
		ifTrue: [ ^ true ].
	self error: 'not a boolean'
]

{ #category : #accessing }
PowertalkEvaluator >> context [
	^ context 
]

{ #category : #accessing }
PowertalkEvaluator >> context: anEvaluationContext [ 
	context := anEvaluationContext
]

{ #category : #initializing }
PowertalkEvaluator >> convertPrimitives [
	| original |
	original := primitives.
	primitives := IdentityDictionary new.
	original
		keysAndValuesDo:
			[ :symbol :block | primitives at: (runtime symbolFromLocal: symbol) put: block ]
]

{ #category : #initializing }
PowertalkEvaluator >> convertUndermessages [
	| original |
	original := undermessages.
	undermessages := IdentityDictionary new.
	original keysAndValuesDo: [ :symbol :block | undermessages at: (runtime symbolFromLocal: symbol) put: block ]

]

{ #category : #accessing }
PowertalkEvaluator >> evaluateClosure: receiver [
	^ self evaluateClosure: receiver withArgs: #()
]

{ #category : #visiting }
PowertalkEvaluator >> evaluateClosure: aPClosure with: anObject [
	 ^self evaluateClosure: aPClosure withArgs: { anObject }
]

{ #category : #visiting }
PowertalkEvaluator >> evaluateClosure: aPClosure with: anObject with: anotherObject [
	^ self evaluateClosure: aPClosure withArgs: {anObject. anotherObject}
]

{ #category : #private }
PowertalkEvaluator >> evaluateClosure: receiver withArgs: arguments [
	^self subclassResponsibility
]

{ #category : #accessing }
PowertalkEvaluator >> evaluatePrimitiveHash: receiver [
	| hash |
	hash := receiver headerHash.
	hash = 0
		ifTrue: [ hash := self nextHash.
			receiver headerHash: hash ].
	^ runtime newInteger: hash
]

{ #category : #initialization }
PowertalkEvaluator >> false [
	^ falseObj
]

{ #category : #initialization }
PowertalkEvaluator >> initialize [

	messageCount := 0
]

{ #category : #initializing }
PowertalkEvaluator >> initializePrimitives [

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
		at: #SMIBitOr put: self primitiveSMIBitOr;
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
		at: #BootstrapFixOverrides put: self primitiveBootstrapFixOverrides;
		at: #PrimeFor put: self primitivePrimeFor;
		at: #FlushFromCaches put: self primitiveFlushFromCaches 
]

{ #category : #initializing }
PowertalkEvaluator >> initializeUndermessages [
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
PowertalkEvaluator >> isIdentical: anObject to: anotherObject [
	^ anObject == anotherObject
		or: [ anObject isImmediate
				and: [ anotherObject isImmediate
						and: [ anObject value = anotherObject value ] ] ]
]

{ #category : #accessing }
PowertalkEvaluator >> lookup: aSymbol startingAt: aBehavior sendSite: anSMessage [
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
			method isNil ifTrue: [PowertalkEvaluatorError signal: symbol asString , ' not found in ', aBehavior asString on: context].
			anSMessage
				registerCacheWith: runtime;
				cache: method when: aBehavior ].
	^ method
]

{ #category : #initialization }
PowertalkEvaluator >> nil [
	^nilObj
	
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveAt [
	| receiver index value |
	^ [ receiver := context self.
	index := context firstArgument value.
	value := receiver at: index.
	receiver isBytes
		ifTrue: [ runtime newInteger: value ]
		ifFalse: [ value ] ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveAtPut [
	| index |
	^ [ index := context firstArgument value.
	context self at: index put: context secondArgument ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveBehavior [
	| receiver |
	^ [ receiver := context self.
	receiver isImmediate
		ifTrue: [ self smallintBehavior ]
		ifFalse: [ receiver behavior ] ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveBootstrapDictAt [
	| string |
	^ [ string := context firstArgument asString.
	context self at: string ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveBootstrapDictAtPut [
	| string |
	^ [ string := context firstArgument asString.
	context self at: string put: context secondArgument ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveBootstrapDictBeConstant [
	^ [ context self beConstant ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveBootstrapDictKeys [
	^ [ context self keys ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveBootstrapDictNew [
	^ [ runtime newBootstrapDictionaryOf: context self ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveBootstrapFixOverrides [
	^ [ runtime fixOverrides ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveBootstrapLoadModule [
	^ [ runtime loadModule: context firstArgument]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveClass [
	^ [ runtime speciesFor: context self ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveClosureArgumentCount [
	^ [ runtime newInteger: context self block argumentCount ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveClosureValue [
	^ [ self evaluateClosure: context self ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveClosureValueWithArgs [
	^ [ self
		evaluateClosure: context self
		withArgs: context methodArguments ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveEqual [
	^ [ runtime booleanFor: context self = context firstArgument ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveFloatNew [
	^ [ runtime newBytesOf: context self sized: 8 ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveFlushDispatchCaches [
	^ [ runtime
		flushDispatchCache: context self
		in: context firstArgument ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveFlushFromCaches [

	^ [ runtime flushDispatchCache: (runtime methodSelector: context self)]
]

{ #category : #accessing }
PowertalkEvaluator >> primitiveFor: aSymbol [
	^primitives at: aSymbol
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveHash [
	^ [ runtime newInteger: (runtime hashFor: context self) ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveNew [
	^ [ runtime newSlotsOf: context self ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveNewBytes [
	| size |
	^ [ size := context firstArgument value.
	runtime newBytesOf: context self sized: size ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveNewObjectHeap [
	^ [ runtime newObjectHeap ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveNewSized [
	| size |
	^ [ size := context firstArgument value.
	runtime newOf: context self sized: size ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitivePrimeFor [
	^ [ self primitivePrimeFor: context firstArgument value ]
]

{ #category : #accessing }
PowertalkEvaluator >> primitivePrimeFor: anInteger [
	| result |

	result := #(2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103 107 109 113 127 131 137 139 149 151 157 163 167 173 179 181 191 193 197 199 211 223 227 229 233 239 241 251 269 359 479 641 857 1151 1549 2069 2237 2423 2617 2797 2999 3167 3359 3539 3727 3911 4441 4787 5119 5471 5801 6143 6521 6827 7177 7517 7853 8783 9601 10243 10867 11549 12239 12919 13679 14293 15013 15731 17569 19051 20443 21767 23159 24611 25847 27397 28571 30047 31397 35771 38201 40841 43973 46633 48989 51631 54371 57349 60139 62969)
		detect: [ :i | i >= anInteger ].
	^ runtime newInteger: result
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSMIBitAnd [
	^ [ runtime
		newInteger:
			(context self value
				bitAnd: (runtime integerFrom: context firstArgument)) ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSMIBitOr [
	^ [ runtime
		newInteger:
			(context self value
				bitOr: (runtime integerFrom: context firstArgument)) ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSMIBitShift [
	^ [ runtime
		newInteger:
			(context self value
				bitShift: (runtime integerFrom: context firstArgument)) ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSMIBitXor [
	^ [ runtime
		newInteger:
			(context self value
				bitXor: (runtime integerFrom: context firstArgument)) ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSMIEqual [
	^ [ runtime
		booleanFor: (
			context self value = 
				context firstArgument value) ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSMIGreaterEqualThan [
	^ [ runtime
		booleanFor:
			context self value
				>= (runtime integerFrom: context firstArgument) ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSMIGreaterThan [
	^ [ runtime
		booleanFor: context self value > (runtime integerFrom: context firstArgument) ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSMIHighBit [
	^ [ runtime newInteger: context self value highBit ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSMIIntDiv [
	^ [ runtime
		newInteger:
			context self value
				// (runtime integerFrom: context firstArgument ) ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSMIIntQuot [
	^ [ runtime
		newInteger:
			context self value
				\\ (runtime integerFrom: context firstArgument) ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSMIMinus [
	^ [ runtime
		newInteger:
			context self value
				- (runtime integerFrom: context firstArgument) ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSMINotEqual [
	^ [ runtime
		booleanFor:
			context self value
				!= (runtime integerFrom: context firstArgument) ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSMIPlus [
	^ [ runtime
		newInteger:
			context self value
				+ (runtime integerFrom: context firstArgument) ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSMISize [
	^ [ runtime newInteger: context self value bytesCount ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSMITimes [
	^ [ runtime
		newInteger:
			context self value
				* (runtime integerFrom: context firstArgument) ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSetBehavior [
	| receiver |
	^ [ receiver := context self.
	receiver behavior: context firstArgument.
	receiver ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveSize [
	^ [ runtime newInteger: (runtime arrayedSizeOf: context self) ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveStringReplaceFromToWithStartingAt [
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
PowertalkEvaluator >> primitiveUnderHash [
	^ [ runtime newInteger: context self headerHash ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveUnderIsBytes [
	^ [ runtime booleanFor: context self isBytes ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveUnderPointersSize [
	^ [ runtime newInteger: context self pointersSize ]
]

{ #category : #primitives }
PowertalkEvaluator >> primitiveUnderSize [
	^ [ runtime newInteger: context self size ]
]

{ #category : #initializing }
PowertalkEvaluator >> runtime [
	^runtime

]

{ #category : #initializing }
PowertalkEvaluator >> runtime: aPowertalkRuntime [
	runtime := aPowertalkRuntime.
	nilObj := runtime nil.
	trueObj := runtime true.
	falseObj := runtime false.
	self
		initializeUndermessages;
		initializePrimitives; convertUndermessages ; convertPrimitives 
]

{ #category : #accessing }
PowertalkEvaluator >> sendLocal: aSymbol to: receiver [
	^ self sendLocal: aSymbol to: receiver with: {}
]

{ #category : #accessing }
PowertalkEvaluator >> stackSize [
	^context framesCount
]

{ #category : #initialization }
PowertalkEvaluator >> true [
	^ trueObj
]

{ #category : #underprimitives }
PowertalkEvaluator >> underprimitiveBasicAt [
	^ [ :receiver :arguments | receiver slots at: arguments first value ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveBasicFlags [
	^ [ :receiver :arguments | runtime newInteger: receiver headerFlags ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveBasicHash [
	^ [ :receiver :arguments | runtime newInteger: receiver headerHash ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveBasicHashPut [
	^ [ :receiver :arguments | receiver headerHash: arguments first value ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveBitShiftLeft [
	| result |
	^ [ :receiver :arguments | 
	result := receiver value bitShift: arguments first value.
	runtime newInteger: result ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveByteAt [
	| result |
	^ [ :receiver :arguments | 
	result := receiver bytes at: arguments first value.
	runtime newInteger: result ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveByteAtPut [

	^ [ :receiver :arguments | 
	receiver bytes
		at: arguments first value
		put: arguments second value.
	arguments second ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveHalt [
	^ [ :receiver :arguments | self halt ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveIdentityEquals [
	^ [ :receiver :arguments | runtime booleanFor: (self isIdentical: receiver to: arguments first)]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveIsLarge [
	^ [ :receiver :arguments | runtime booleanFor: receiver isSmall not ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveIsSmallInteger [
	^ [ :receiver :arguments | runtime booleanFor: receiver isImmediate ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveLargeSize [
	^ [ :receiver :arguments | 
	receiver isSmall
		ifTrue: [ self error ].
	runtime newInteger: receiver size ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveLeadingZeroBitCount [
	^ [ :receiver :arguments | 
	runtime
		newInteger: (self
		underprimitiveLeadingZeroBitCount: receiver value) ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveLeadingZeroBitCount: anInteger [
	^ anInteger < 0
		ifTrue: [ 0 ]
		ifFalse: [ runtime wordSize * 8 - anInteger highBit ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSMIBitAnd [
	^ [ :receiver :arguments | runtime newInteger: (receiver value bitAnd: arguments first value) ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSMIBitOr [
	^ [ :receiver :arguments | runtime newInteger: (receiver value bitOr: arguments first value) ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSMIBitShiftLeft [
	^ [ :receiver :arguments | runtime newInteger: receiver value << arguments first value ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSMIBitShiftRight [
	^ [ :receiver :arguments | 
	runtime
		newInteger: (receiver value >> arguments first value) ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSMIEquals [
	^ [ :receiver :arguments | runtime booleanFor: receiver value = arguments first value ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSMIGreaterEqualThan [
	^ [ :receiver :arguments | runtime booleanFor: receiver value >= arguments first value ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSMIGreaterThan [
	^ [ :receiver :arguments | runtime booleanFor: receiver value > arguments first value ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSMILowerEqualThan [
	^ [ :receiver :arguments | runtime booleanFor: receiver value <= arguments first value ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSMILowerThan [
	^ [ :receiver :arguments | runtime booleanFor: receiver value < arguments first value ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSMIMinus [
	^ [ :receiver :arguments | runtime newInteger: receiver value - arguments first value ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSMIPlus [
	^ [ :receiver :arguments | runtime newInteger: receiver value + arguments first value ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSMIQuotientTowardZero [
	^ [ :receiver :arguments | runtime newInteger: (receiver value quo: arguments first value) ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSMIRemainderTowardZero [
	^ [ :receiver :arguments | runtime newInteger: (receiver value \\ arguments first value) ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSMITimes [
	^ [ :receiver :arguments | runtime newInteger: receiver value * arguments first value ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSmallIntegerByteAt [
	| result |
	^ [ :receiver :arguments | 
	result := receiver value byteAt: arguments first value.
	runtime newInteger: result ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveSmallSize [
	^ [ :receiver :arguments | 
	receiver isSmall
		ifFalse: [ self error ].
	runtime newInteger: receiver size ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveULongAtOffset [
	| result |
	^ [ :receiver :arguments | 
	result := receiver bytes unsignedLongAt: arguments second value + 1.
	runtime newInteger: result ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveULongAtOffsetPut [
	| value |
	^ [ :receiver :arguments | 
	value := arguments second.
	receiver bytes
		unsignedLongAt: arguments first value + 1
		put: value value.
	value ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveUShortAtOffset [
	| result |
	^ [ :receiver :arguments | 
	result := receiver bytes
		unsignedShortAt: arguments second value + 1.
	runtime newInteger: result ]
]

{ #category : #accessing }
PowertalkEvaluator >> underprimitiveUShortAtOffsetPut [
	| value |
	^ [ :receiver :arguments | 
	value := arguments second.
	receiver bytes
		unsignedShortAt: arguments first value + 1
		put: value value.
	value ]
]
