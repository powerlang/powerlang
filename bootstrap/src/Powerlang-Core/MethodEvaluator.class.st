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
		'returned',
		'returnValue',
		'closures',
		'blockAstcodes',
		'system'
	],
	#classVars : [
		'Undermessages'
	],
	#pools : [
		'ClosureElementTypes'
	],
	#category : #'Powerlang-Core-Emulation'
}

{ #category : #'instance creation' }
MethodEvaluator class >> initialize [
	"
	self initialize
	"

	Undermessages := #(_basicAt: #_basicAt:put: _bitShiftLeft: _byteAt: #_byteAt:put: _smallSize _largeSize _isSmallInteger _basicHash _basicHash: _smallIntegerByteAt:)
]

{ #category : #'instance creation' }
MethodEvaluator class >> new [
	^self basicNew initialize
]

{ #category : #visiting }
MethodEvaluator >> argumentAt: index in: anInteger [
	| env |
	anInteger ifNil: [ ^arguments at: index ].
	env := self environmentFor: anInteger.
	^env at: index.
]

{ #category : #visiting }
MethodEvaluator >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #visiting }
MethodEvaluator >> association: association put: value [
	^ association value: value
]

{ #category : #visiting }
MethodEvaluator >> blockOf: anObjectMap [
	closures at: anObjectMap ifPresent: [:block | ^block ].
	parent blockOf: anObjectMap
]

{ #category : #visiting }
MethodEvaluator >> booleanFor: aBoolean [
	^ aBoolean
		ifTrue: [ system trueObject ] ifFalse: [system falseObject]

]

{ #category : #visiting }
MethodEvaluator >> captureClosure: anSBlock from: block [
	| closure s i type env arg |
	closure := system newNamed: #Closure size: block environmentCount.
	closures at: closure put: block.
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

{ #category : #visiting }
MethodEvaluator >> closures [
	^closures
]

{ #category : #dispatching }
MethodEvaluator >> dispatch: aMethod with: aMessage [
	| interpreter |
	interpreter := self class new
		receiver: aMessage receiver;
		arguments: aMessage arguments;
		method: aMethod;
		runtime: system;
		parent: self.
	^ interpreter evaluate: aMethod
]

{ #category : #visiting }
MethodEvaluator >> dispatchUndermessage: message [
	| selector recv args result |
	selector := message selector.
	recv := message receiver.
	args := message arguments.
	selector == #_isSmallInteger
		ifTrue: [ ^ self booleanFor: recv isImmediate ].
	selector == #_isLarge
		ifTrue: [ ^ self booleanFor: recv isSmall not ].
	selector == #_smallSize
		ifTrue: [ ^ self
				integerFor:
					(recv isSmall
						ifTrue: [ recv size ]
						ifFalse: [ self error ]) ].
	selector == #_largeSize
		ifTrue: [ ^ self
				integerFor:
					(recv isSmall
						ifTrue: [ self error ]
						ifFalse: [ recv size ]) ].
	selector == #_basicFlags
		ifTrue: [ ^ self integerFor: recv headerFlags ].
	selector == #_basicAt:
		ifTrue: [ ^ recv slots at: args first value ].
	selector == #_byteAt:
		ifTrue: [ result := recv bytes at: args first value.
			^self integerFor: result ].
	selector == #_basicHash
		ifTrue: [ ^ self integerFor: recv headerHash ].
	selector == #_basicHash:
		ifTrue: [ recv headerHash: args first value.
			^ recv ].
	selector == #_smallIntegerByteAt:
		ifTrue: [ result := recv value byteAt: args first value.
			^ self integerFor: result ].
	selector == #_bitShiftLeft:
		ifTrue: [ result := recv value bitShift: args first value.
			(result isKindOf: LargeInteger) ifTrue: [ self halt ]. 
			^ self integerFor: result ].
	self ASSERT: false
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
MethodEvaluator >> evaluate: sexpressions [
	^ self visitMethod: sexpressions
]

{ #category : #visiting }
MethodEvaluator >> evaluateBlock: aPClosure [
	^self evaluateBlock: aPClosure withArgs: {}
]

{ #category : #visiting }
MethodEvaluator >> evaluateBlock: aPClosure with: anObject [
	 ^self evaluateBlock: aPClosure withArgs: { anObject }
]

{ #category : #visiting }
MethodEvaluator >> evaluateBlock: aPClosure with: anObject with: anotherObject [
	^ self evaluateBlock: aPClosure withArgs: {anObject. anotherObject}
]

{ #category : #visiting }
MethodEvaluator >> evaluateBlock: closure withArgs: anArray [
	| oldArgs oldTemps oldEnv block sblock result |
	block := self blockOf: closure.
	sblock := blockAstcodes at: block.
	sblock isInlined
		ifTrue: [ anArray
				with: sblock inlinedArgs
				do: [ :arg :i | temporaries at: i put: arg ].
			^ self visitScript: sblock ].
	oldArgs := arguments.
	oldTemps := temporaries.
	oldEnv := environment.
	arguments := anArray.
	temporaries := Array new: block tempCount.
	environment := closure.
	result := self visitScript: sblock.
	environment := oldEnv.
	temporaries := oldTemps.
	arguments := oldArgs.
	^ result
]

{ #category : #visiting }
MethodEvaluator >> evaluatePrimitive: primitive [
	| index size argument |
	returned := true.
	primitive = #Behavior
		ifTrue: [ ^ receiver behavior ].
	primitive = #UnderSize
		ifTrue: [ ^ self integerFor: receiver size ].
	primitive = #Size
		ifTrue: [ ^ self integerFor: receiver arrayedSize ].
	primitive = #At
		ifTrue: [ index := arguments first value.
			^ receiver at: index ].
	primitive = #AtPut
		ifTrue: [ index := arguments first value.
			^ receiver at: index put: arguments second ].
	primitive = #New
		ifTrue: [ ^ system new: receiver spec ].
	primitive = #NewSized
		ifTrue: [ size := arguments first value.
			^ system new: receiver spec size: size ].
	primitive = #NewBytes
		ifTrue: [ size := arguments first value.
			^ system newBytes: receiver spec size: size ].
	primitive = #Equal
		ifTrue: [ argument := arguments first.
			^ self
				booleanFor:
					(receiver == argument
						or: [ receiver isImmediate
								and: [ argument isImmediate and: [ receiver value = argument value ] ] ]) ].
	primitive = #SMIPlus
		ifTrue: [ ^ self integerFor: receiver value + arguments first value ].
	primitive = #SMIMinus
		ifTrue: [ ^ self integerFor: receiver value - arguments first value ].
	primitive = #SMITimes
		ifTrue: [ ^ self integerFor: receiver value * arguments first value ].
	primitive = #SMIIntDiv
		ifTrue: [ ^ self integerFor: receiver value // arguments first value ].
	primitive = #SMIIntQuot
		ifTrue: [ ^ self integerFor: receiver value \\ arguments first value ].
	primitive = #SMIBitAnd
		ifTrue: [ ^ self integerFor: (receiver value bitAnd: arguments first value) ].
	primitive = #SMIBitXor
		ifTrue: [ ^ self integerFor: (receiver value bitXor: arguments first value) ].
	primitive = #SMIBitShift
		ifTrue:
			[ ^ self integerFor: (receiver value bitShift: arguments first value) ].
	primitive = #SMIGreaterThan
		ifTrue: [ ^ self booleanFor: receiver value > arguments first value ].
	primitive = #SMIGreaterEqualThan
		ifTrue: [ ^ self booleanFor: receiver value >= arguments first value ].
	primitive = #SMIEqual
		ifTrue: [ ^ self booleanFor: receiver value = arguments first value ].
	primitive = #SMINotEqual
		ifTrue: [ ^ self booleanFor: receiver value != arguments first value ].
	primitive = #ClosureValue
		ifTrue: [ ^ self evaluatePrimitiveClosureValue ].
	primitive = #ClosureValueWithArgs
		ifTrue: [ ^ self evaluatePrimitiveClosureValueWithArgs ].
	primitive = #ClosureWhileTrue
		ifTrue: [ ^ self evaluatePrimitiveClosureWhileTrue ].
	primitive = #ClosureWhileFalse
		ifTrue: [ ^ self evaluatePrimitiveClosureWhileFalse ].
	primitive = #ClosureArgumentCount
		ifTrue: [ ^ self evaluatePrimitiveClosureArgumentCount ].
	primitive = #StringReplaceFromToWithStartingAt
		ifTrue: [ receiver bytes
				replaceFrom: arguments first value
				to: arguments second value
				with: arguments third bytes
				startingAt: arguments fourth value.
			^ receiver ].
	primitive = #PrimeFor
		ifTrue: [ ^ self evaluatePrimitivePrimeFor ].
	self ASSERT: false
]

{ #category : #visiting }
MethodEvaluator >> evaluatePrimitiveClosureArgumentCount [
	| interpreter block |
	interpreter := self homeOf: receiver.
	block := interpreter blockOf: receiver.
	^self integerFor: block argumentCount
]

{ #category : #visiting }
MethodEvaluator >> evaluatePrimitiveClosureValue [
	| interpreter |
	interpreter := self homeOf: receiver.
	^ interpreter evaluateBlock: receiver
]

{ #category : #visiting }
MethodEvaluator >> evaluatePrimitiveClosureValueWithArgs [
	| interpreter |
	interpreter := self homeOf: receiver.
	^ interpreter evaluateBlock: receiver withArgs: arguments
]

{ #category : #visiting }
MethodEvaluator >> evaluatePrimitiveClosureWhileFalse [
	| homeR result arg homeA |
	homeR := self homeOf: receiver.
	arg := arguments first.
	homeA := self homeOf: arg.
	[ result := homeR evaluateBlock: receiver.
	system booleanFrom: result ] whileFalse: [ homeA evaluateBlock: arg ].
	^ receiver
]

{ #category : #visiting }
MethodEvaluator >> evaluatePrimitiveClosureWhileTrue [
	| homeR result arg homeA |
	homeR := self homeOf: receiver.
	arg := arguments first.
	homeA := self homeOf: arg.
	[ result := homeR evaluateBlock: receiver.
	system booleanFrom: result ] whileTrue: [ homeA evaluateBlock: arg ].
	^ receiver
]

{ #category : #visiting }
MethodEvaluator >> evaluatePrimitiveHash [
	| hash |
	hash := receiver headerHash.
	hash = 0 ifTrue: [ hash := system nextHash. receiver headerHash: hash ].
	^ self integerFor: hash
]

{ #category : #visiting }
MethodEvaluator >> evaluatePrimitivePrimeFor [
	| num result |
	num := arguments first value.
	result := #(2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103 107 109 113 127 131 137 139 149 151 157 163 167 173 179 181 191 193 197 199 211 223 227 229 233 239 241 251 269 359 479 641 857 1151 1549 2069 2237 2423 2617 2797 2999 3167 3359 3539 3727 3911 4441 4787 5119 5471 5801 6143 6521 6827 7177 7517 7853 8783 9601 10243 10867 11549 12239 12919 13679 14293 15013 15731 17569 19051 20443 21767 23159 24611 25847 27397 28571 30047 31397 35771 38201 40841 43973 46633 48989 51631 54371 57349 60139 62969)
		detect: [ :i | i >= num ].
	^ self integerFor: result
]

{ #category : #visiting }
MethodEvaluator >> falseLiteral [
	^ system falseObject
]

{ #category : #visiting }
MethodEvaluator >> homeOf: closure [
	| interpreter |
	interpreter := self.
	[ interpreter closures includesKey: receiver ]
		whileFalse: [ interpreter := interpreter parent ].
	^interpreter

]

{ #category : #visiting }
MethodEvaluator >> initialize [
	returned := false.
	blockAstcodes := IdentityDictionary new.
	closures := IdentityDictionary new
]

{ #category : #visiting }
MethodEvaluator >> instVarAt: anInteger [
	^ receiver slotAt: anInteger
]

{ #category : #visiting }
MethodEvaluator >> instVarAt: index put: aValue [
	^ receiver slotAt: index put: aValue 
]

{ #category : #visiting }
MethodEvaluator >> integerFor: anInteger [
	^ system newSmallInteger: anInteger
]

{ #category : #visiting }
MethodEvaluator >> isUndermessage: selector [
	^ Undermessages includes: selector
]

{ #category : #visiting }
MethodEvaluator >> literal: anObject [
	^anObject
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
	^ system nilObject
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
	aStream
		nextPutAll: self class name withArticle;
		cr;
		print: method classBinding;
		nextPutAll: '>>';
		print: method selector;
		cr.
	aStream
		nextPutAll: 'rcvr -> ';
		print: receiver;
		cr.
	arguments
		withIndexDo: [ :a :i | 
			aStream
				nextPutAll: 'arg ';
				print: i;
				nextPutAll: ' -> ';
				print: a;
				cr ].
	aStream nextPutAll: method source
]

{ #category : #visiting }
MethodEvaluator >> receiver [
	^receiver
]

{ #category : #visiting }
MethodEvaluator >> receiver: anObject [
	receiver := anObject.
	returnValue := anObject
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
	^system trueObject
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
	| block closure |
	block := anSBlock isInlined
		ifTrue: [ SCompiledBlock new ]
		ifFalse: [ anSBlock compiledCode ].
	closure := self captureClosure: anSBlock from: block.
	blockAstcodes at: block put: anSBlock.
	^ closure
]

{ #category : #visiting }
MethodEvaluator >> visitCascade: anSCascade [
	| recv args selector message last |
	recv := anSCascade receiver acceptVisitor: self.
	anSCascade messages do: [ :msg | args := msg arguments
		collect: [ :code | code acceptVisitor: self ].
	selector := system symbolFrom: msg selector.
	message := MessageSend
		receiver: recv
		selector: selector
		arguments: args.
	(self isUndermessage: selector)
		ifTrue: [ ^ self dispatchUndermessage: message ].
	last :=  system send: message super: anSCascade receiver isSuper from: self].
	^last
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
	| recv args selector message |
	recv := anSMessage receiver acceptVisitor: self.
	args := anSMessage arguments
		collect: [ :code | code acceptVisitor: self ].
	selector := system symbolFrom: anSMessage selector.
	message := MessageSend
		receiver: recv
		selector: selector
		arguments: args.
	(self isUndermessage: selector)
		ifTrue: [ ^ self dispatchUndermessage: message ].
	^ system send: message super: anSMessage receiver isSuper from: self
]

{ #category : #visiting }
MethodEvaluator >> visitMethod: anSMethod [
	| primitive value |
	primitive := anSMethod primitive.
	primitive ifNotNil: [ ^ self evaluatePrimitive: primitive ].
	environment := system newNamed: #Array size: method environmentCount.
	value := self visitScript: anSMethod.
	^ returned
		ifTrue: [ value ]
		ifFalse: [ receiver ]
]

{ #category : #visiting }
MethodEvaluator >> visitReturn: anSReturn [
	returnValue := anSReturn expression acceptVisitor: self.
	returned := true.
	^returnValue
]

{ #category : #visiting }
MethodEvaluator >> visitScript: anSScript [
	| result |
	anSScript statements do: [:node | 
		result := node acceptVisitor: self.
		returned ifTrue: [^returnValue]
	].
	^result
]

{ #category : #visiting }
MethodEvaluator >> visitTemporary: anSIdentifier [
	^temporaries at: anSIdentifier binding index
]
