Class {
	#name : #PstInterpreter,
	#superclass : #SExpressionInterpreter,
	#instVars : [
		'localRuntime'
	],
	#classVars : [
		'underprimitives'
	],
	#pools : [
		'ClosureElementTypes'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'class initialization' }
PstInterpreter class >> initialize [
	"
	self initialize
	"

	underprimitives := #(_basicAt: #_basicAt:put: _byteAt: #_byteAt:put: _smallSize _largeSize _isSmallInteger _basicHash _basicHash:)
]

{ #category : #visiting }
PstInterpreter >> argumentAt: index in: anInteger [
	| env |
	anInteger ifNil: [ ^arguments at: index ].
	env := self environmentFor: anInteger.
	^env at: index.
]

{ #category : #visiting }
PstInterpreter >> captureClosure: anSBlock [
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
PstInterpreter >> dispatch: message to: msgReceiver [
	^ msgReceiver _gate dispatch: message from: self
]

{ #category : #visiting }
PstInterpreter >> dispatchSpecial: message [
	| selector mirror gate |
	selector := message selector.
	gate := message receiver _gate.
	mirror := gate mirror.
	selector == #_isSmallInteger
		ifTrue: [ ^ self subjectOnBoolean: gate handle isInteger in: gate handle runtime].
	selector == #_isLarge
		ifTrue: [ ^ self subjectOnBoolean: mirror reflectsLargeObject in: gate handle runtime].
	selector == #_smallSize
		ifTrue: [ ^ self subjectOnInteger: mirror smallSize in: gate handle runtime ].
	selector == #_largeSize
		ifTrue: [ ^ self subjectOnInteger: mirror largeSize in: gate handle runtime ].
	selector == #_basicFlags
		ifTrue: [ ^ self subjectOnInteger: mirror basicFlags in: gate handle runtime ].
	selector == #_basicHash
		ifTrue: [ ^ self subjectOnInteger: 0 in: gate handle runtime ].
	selector == #_basicHash:
		ifTrue: [ ^ message receiver ].
	self ASSERT: false
]

{ #category : #visiting }
PstInterpreter >> dispatchSuper: message to: msgReceiver [
	^ msgReceiver _gate dispatchSuper: message from: self
]

{ #category : #visiting }
PstInterpreter >> environmentFor: anInteger [
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
PstInterpreter >> falseLiteral [
	^receiver _gate handle runtime false maneuverer.

]

{ #category : #visiting }
PstInterpreter >> gateOnBlock: aPCompiledBlock [
	| runtime closure handle |
	runtime := receiver _gate handle runtime.
	closure := aPCompiledBlock newClosure home: self.
	handle := LocalHandle on: closure within: localRuntime.
	^ closure mirage
]

{ #category : #visiting }
PstInterpreter >> initialize [
	super initialize.
	localRuntime := Runtime forLocalPharo.

]

{ #category : #visiting }
PstInterpreter >> instVarAt: anInteger [
	^receiver _gate slotAt: anInteger
]

{ #category : #visiting }
PstInterpreter >> isSpecial: selector [
	^underprimitives includes: selector
]

{ #category : #visiting }
PstInterpreter >> literal: anObject [
	| handle |
	handle := receiver _gate handleOn: anObject.
	^ self subjectOn: handle
]

{ #category : #visiting }
PstInterpreter >> mirageOnBlock: aPCompiledBlock [
	| runtime handle |
	runtime := receiver _gate handle runtime.
	handle := runtime newClosureHandle: aPCompiledBlock.
	^ handle mirage
]

{ #category : #visiting }
PstInterpreter >> nilLiteral [
	^receiver _gate handle runtime nil maneuverer.

]

{ #category : #visiting }
PstInterpreter >> primitiveClosureValue [
	| closure block sblock prev result interpreter next |
	closure := receiver _gate handle.
	block := closure mirror asClosureMirror block handle oid.
	interpreter := self.
	[ next := interpreter blocks. next includesKey: block] whileFalse: [ interpreter := interpreter parent ].
	sblock := next at: block.
	prev := environment.
	environment := closure.
	result := interpreter visitScript: sblock.
	environment := prev.
	^result
]

{ #category : #visiting }
PstInterpreter >> primitivePrimeFor [
	| num result  |
	num := arguments first _gate handle asLocalInteger.
	result := #(2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103 107 109 113 127 131 137 139 149 151 157 163 167 173 179 181 191 193 197 199 211 223 227 229 233 239 241 251 269 359 479 641 857 1151 1549 2069 2237 2423 2617 2797 2999 3167 3359 3539 3727 3911 4441 4787 5119 5471 5801 6143 6521 6827 7177 7517 7853 8783 9601 10243 10867 11549 12239 12919 13679 14293 15013 15731 17569 19051 20443 21767 23159 24611 25847 27397 28571 30047 31397 35771 38201 40841 43973 46633 48989 51631 54371 57349 60139 62969)
		detect: [ :i | i >= num ].
	^ self subjectOnInteger: result in: receiver _gate handle runtime
]

{ #category : #visiting }
PstInterpreter >> temporaryAt: index in: anInteger [
	| env |
	anInteger ifNil: [ ^ temporaries at: index ].
	env := self environmentFor: anInteger.
	^ env at: index
]

{ #category : #visiting }
PstInterpreter >> temporaryAt: index in: anInteger put: aValue [
	| env |
	anInteger ifNil: [ ^ temporaries	at:index put: aValue ].
	env := self environmentFor: anInteger.
	^ env at: index put: aValue
]

{ #category : #visiting }
PstInterpreter >> trueLiteral [
	^receiver _gate handle runtime true maneuverer.

]

{ #category : #visiting }
PstInterpreter >> visitBlock: anSBlock [
	| closure handle |
	closure := anSBlock isInlined
		ifTrue: [ SCompiledBlock new newClosure home: self ]
		ifFalse: [ self captureClosure: anSBlock].
	blockAstcodes at: closure block put: anSBlock.
	handle := LocalHandle on: closure within: localRuntime.
	^ handle mirage
]

{ #category : #visiting }
PstInterpreter >> visitLiteral: anSLiteral [
	| handle |
	anSLiteral value isInteger ifTrue: [ 
		^self subjectOnInteger: anSLiteral value in: receiver _gate handle runtime ].
	handle := localRuntime handleOn: anSLiteral value.
	^ handle mirage
]

{ #category : #visiting }
PstInterpreter >> visitPrimitive: primitive [
	| gate new left right args rcvr runtime value class |
	returned := true.
	gate := receiver _gate.
	runtime := gate handle runtime.
	primitive = #Behavior
		ifTrue: [ class := runtime bridge globalNamed: gate handle oid spec name.
			^ returnValue := self subjectOn: (gate handleOn: class instanceBehavior)].
	primitive = #UnderSize
		ifTrue: [ ^ returnValue := self subjectOnInteger: gate handle size in: runtime ].
	primitive = #Size
		ifTrue: [ ^ returnValue := self
				subjectOnInteger: gate handle arrayedSize
				in: runtime ].
	primitive = #At
		ifTrue:
			[ value := gate handle at: arguments first _gate handle asLocalInteger.
			^ returnValue := self subjectOn: value].
	primitive = #AtPut
		ifTrue:
			[ value := arguments second.
			gate handle at: arguments first _gate handle asLocalInteger put: value _gate handle oid.
			^ returnValue := value].
	primitive = #New
		ifTrue: [ new := gate handle runtime new: gate handle oid.
			^ returnValue := self subjectOn: new ].
	primitive = #NewSized
		ifTrue: [ new := gate handle runtime
				new: gate handle oid
				sized: arguments first _gate handle asLocalInteger.
			^ returnValue := self subjectOn: new ].
	primitive = #Equal
		ifTrue: [ left := receiver _gate handle oid.
			right := arguments first _gate handle oid.
			^ returnValue := self
				subjectOnBoolean: left == right
				in: localRuntime ].
	primitive = #SMIPlus
		ifTrue: [ left := receiver _gate handle asLocalInteger.
			right := arguments first _gate handle asLocalInteger.
			^ returnValue := self subjectOnInteger: left + right in: runtime ].
	primitive = #SMIMinus
		ifTrue: [ left := receiver _gate handle asLocalInteger.
			right := arguments first _gate handle asLocalInteger.
			^ returnValue := self subjectOnInteger: left - right in: runtime ].
	primitive = #SMITimes
		ifTrue: [ left := receiver _gate handle asLocalInteger.
			right := arguments first _gate handle asLocalInteger.
			^ returnValue := self subjectOnInteger: left * right in: runtime ].
	primitive = #SMIIntDiv
		ifTrue: [ left := receiver _gate handle asLocalInteger.
			right := arguments first _gate handle asLocalInteger.
			^ returnValue := self subjectOnInteger: left // right in: runtime ].
	primitive = #SMIIntQuot
		ifTrue: [ left := receiver _gate handle asLocalInteger.
			right := arguments first _gate handle asLocalInteger.
			^ returnValue := self subjectOnInteger: left \\ right in: runtime ].
	primitive = #SMIGreaterThan
		ifTrue: [ left := receiver _gate handle asLocalInteger.
			right := arguments first _gate handle asLocalInteger.
			^ returnValue := self
				subjectOnBoolean: left > right
				in: localRuntime ].
	primitive = #SmallIntegerBitAnd
		ifTrue: [ left := receiver _gate handle asLocalInteger.
			right := arguments first _gate handle asLocalInteger.
			^ returnValue := self
				subjectOnInteger: (left bitAnd: right)
				in: runtime ].
	primitive = #SMIGreaterEqualThan
		ifTrue: [ left := receiver _gate handle asLocalInteger.
			right := arguments first _gate handle asLocalInteger.
			^ returnValue := self
				subjectOnBoolean: left >= right
				in: localRuntime ].
	primitive = #SMIEqual
		ifTrue: [ left := receiver _gate handle asLocalInteger.
			right := arguments first _gate handle asLocalInteger.
			^ returnValue := self
				subjectOnBoolean: left = right
				in: localRuntime ].
	primitive = #SMINotEqual
		ifTrue: [ left := receiver _gate handle asLocalInteger.
			right := arguments first _gate handle asLocalInteger.
			^ returnValue := self
				subjectOnBoolean: left != right
				in: localRuntime ].
	primitive = #ClosureValue
		ifTrue: [ ^ self primitiveClosureValue ].
	primitive = #ReplaceFromTo
		ifTrue: [ rcvr := receiver _gate handle target.
			args := arguments collect: [ :arg | arg _gate asLocalCollection ].
			rcvr
				perform: #replaceFrom:to:with:startingAt:
				withArguments: args asArray.
			^ returnValue := receiver ].
	primitive = #PrimeFor
		ifTrue: [ ^ self primitivePrimeFor ].
	self ASSERT: false
]

{ #category : #visiting }
PstInterpreter >> visitPrimitiveOld: primitive [
	| gate new left right args rcvr |
	returned := true.
	gate := receiver _gate.
	primitive = #Size
		ifTrue: [ ^ returnValue := self mirageOnInteger: gate mirror size ].
	primitive = #New
		ifTrue: [ new := gate handle runtime new: gate handle oid.
			^ returnValue := self mirageOnObject: new ].
	primitive = #NewSized
		ifTrue: [ new := gate handle target new: arguments first _gate handle target.
			^ returnValue := self mirageOnObject: new ].
	primitive = #SmallIntegerMinus
		ifTrue: [ left := receiver _gate handle target.
			right := arguments first _gate handle target.
			^ returnValue := self mirageOnInteger: left - right ].
	primitive = #SmallIntegerPlus
		ifTrue: [ left := receiver _gate handle asLocalInteger.
			right := arguments first _gate handle asLocalInteger.
			^ returnValue := self mirageOnInteger: left + right ].
	primitive = #SmallIntegerBitAnd
		ifTrue: [ left := receiver _gate handle asLocalInteger.
			right := arguments first _gate handle asLocalInteger.
			^ returnValue := self mirageOnInteger: (left bitAnd: right) ].
	primitive = #SmallIntegerLessOrEqual
		ifTrue: [ left := receiver _gate handle target.
			right := arguments first _gate handle target.
			^ returnValue := self mirageOnBoolean: left <= right ].
	primitive = #SmallIntegerEqual
		ifTrue: [ left := receiver _gate handle asLocalInteger.
			right := arguments first _gate handle asLocalInteger.
			^ returnValue := self mirageOnBoolean: left = right ].
	primitive = #SmallIntegerNotEqual
		ifTrue: [ left := receiver _gate handle asLocalInteger.
			right := arguments first _gate handle asLocalInteger.
			^ returnValue := self mirageOnBoolean: left != right ].
	primitive = #ClosureValue
		ifTrue: [ ^ self primitiveClosureValue ].
	primitive = #ReplaceFromTo
		ifTrue: [ rcvr := receiver _gate handle target.
			args := arguments collect: [ :arg | arg _gate asLocalCollection ].
			rcvr
				perform: #replaceFrom:to:with:startingAt:
				withArguments: args asArray.
			^ returnValue := receiver ].
	self ASSERT: false
]
