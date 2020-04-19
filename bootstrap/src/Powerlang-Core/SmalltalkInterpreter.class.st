Class {
	#name : #SmalltalkInterpreter,
	#superclass : #SExpressionInterpreter,
	#instVars : [
		'localRuntime'
	],
	#classVars : [
		'underprimitives'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'class initialization' }
SmalltalkInterpreter class >> initialize [
	"
	self initialize
	"

	underprimitives := #(_basicAt: #_basicAt:put: _byteAt: #_byteAt:put: _smallSize _largeSize _isSmallInteger _basicHash _basicHash:)
]

{ #category : #visiting }
SmalltalkInterpreter >> dispatch: message to: msgReceiver [
	^ msgReceiver _gate dispatch: message from: self
]

{ #category : #visiting }
SmalltalkInterpreter >> dispatchSpecial: message [
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
SmalltalkInterpreter >> dispatchSuper: message to: msgReceiver [
	^ msgReceiver _gate dispatchSuper: message from: self
]

{ #category : #visiting }
SmalltalkInterpreter >> falseLiteral [
	^receiver _gate handle runtime false maneuverer.

]

{ #category : #visiting }
SmalltalkInterpreter >> gateOnBlock: aPCompiledBlock [
	| runtime closure handle |
	runtime := receiver _gate handle runtime.
	closure := aPCompiledBlock newClosure home: self.
	handle := LocalHandle on: closure within: localRuntime.
	^ closure mirage
]

{ #category : #visiting }
SmalltalkInterpreter >> initialize [
	super initialize.
	localRuntime := Runtime forLocalPharo.

]

{ #category : #visiting }
SmalltalkInterpreter >> isSpecial: selector [
	^underprimitives includes: selector
]

{ #category : #visiting }
SmalltalkInterpreter >> literal: anObject [
	| handle |
	handle := receiver _gate handleOn: anObject.
	^ self subjectOn: handle
]

{ #category : #visiting }
SmalltalkInterpreter >> mirageOnBlock: aPCompiledBlock [
	| runtime handle |
	runtime := receiver _gate handle runtime.
	handle := runtime newClosureHandle: aPCompiledBlock.
	^ handle mirage
]

{ #category : #visiting }
SmalltalkInterpreter >> nilLiteral [
	^receiver _gate handle runtime nil maneuverer.

]

{ #category : #visiting }
SmalltalkInterpreter >> primitiveClosureValue [
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
SmalltalkInterpreter >> primitivePrimeFor [
	| num result  |
	num := arguments first _gate handle asLocalInteger.
	result := #(2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103 107 109 113 127 131 137 139 149 151 157 163 167 173 179 181 191 193 197 199 211 223 227 229 233 239 241 251 269 359 479 641 857 1151 1549 2069 2237 2423 2617 2797 2999 3167 3359 3539 3727 3911 4441 4787 5119 5471 5801 6143 6521 6827 7177 7517 7853 8783 9601 10243 10867 11549 12239 12919 13679 14293 15013 15731 17569 19051 20443 21767 23159 24611 25847 27397 28571 30047 31397 35771 38201 40841 43973 46633 48989 51631 54371 57349 60139 62969)
		detect: [ :i | i >= num ].
	^ self subjectOnInteger: result in: receiver _gate handle runtime
]

{ #category : #visiting }
SmalltalkInterpreter >> trueLiteral [
	^receiver _gate handle runtime true maneuverer.

]

{ #category : #visiting }
SmalltalkInterpreter >> visitLiteral: anSLiteral [
	| handle |
	anSLiteral value isInteger ifTrue: [ 
		^self subjectOnInteger: anSLiteral value in: receiver _gate handle runtime ].
	handle := localRuntime handleOn: anSLiteral value.
	^ handle mirage
]

{ #category : #visiting }
SmalltalkInterpreter >> visitPrimitive: primitive [
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
SmalltalkInterpreter >> visitPrimitiveOld: primitive [
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
