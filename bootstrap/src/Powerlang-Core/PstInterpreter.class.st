Class {
	#name : #PstInterpreter,
	#superclass : #SExpressionInterpreter,
	#instVars : [
		'localRuntime',
		'environment'
	],
	#classVars : [
		'underprimitives'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'class initialization' }
PstInterpreter class >> initialize [
	"
	self initialize
	"
	underprimitives := #(_basicAt: _basicAt:put: _byteAt: _byteAt:put: _smallSize _largeSize _isSmallInteger)
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
	selector == #_isLarge
		ifTrue: [ ^ self mirageOnBoolean: mirror reflectsLargeObject ].
	selector == #_smallSize
		ifTrue: [ ^ self mirageOnInteger: mirror smallSize ].
	selector == #_largeSize
		ifTrue: [ ^ self mirageOnInteger: mirror largeSize ].
	selector == #_basicFlags
		ifTrue: [ ^ self mirageOnInteger: mirror basicFlags ].
	self ASSERT: false
]

{ #category : #visiting }
PstInterpreter >> homeOf: aClosure [ 
	^blocks at: aClosure ifAbsent: [parent homeOf: aClosure]
]

{ #category : #visiting }
PstInterpreter >> initialize [
	super initialize.
	localRuntime := Runtime forLocalPharo.

]

{ #category : #visiting }
PstInterpreter >> isSpecial: selector [
	^underprimitives includes: selector
]

{ #category : #visiting }
PstInterpreter >> mirageOnBlock: aPCompiledBlock [
	| runtime handle |
	runtime := receiver _gate handle runtime.
	handle := runtime newClosureHandle: aPCompiledBlock.
	^ handle mirage
]

{ #category : #visiting }
PstInterpreter >> mirageOnBoolean: aBoolean [
	| runtime handle |
	runtime := receiver _gate handle runtime.
	handle := aBoolean ifTrue: [runtime true] ifFalse: [runtime false].
	^ handle mirage
]

{ #category : #visiting }
PstInterpreter >> mirageOnInteger: anInteger [
	| runtime handle |
	runtime := receiver _gate handle runtime.
	handle := runtime integerHandle: anInteger.
	^ handle mirage
]

{ #category : #visiting }
PstInterpreter >> mirageOnObject: anObject [
	anObject isSmallInteger ifTrue: [ ^ self mirageOnInteger: anObject ].
	self ASSERT: false
]

{ #category : #visiting }
PstInterpreter >> primitiveClosureValue [
	| closure block sblock prev result |
	closure := receiver _gate handle.
	block := closure mirror asClosureMirror block handle oid.
	sblock := blocks at: block.
	prev := environment.
	environment := closure.
	result := self visitScript: sblock.
	environment := prev.
	^result
]

{ #category : #visiting }
PstInterpreter >> visitBlock: anSBlock [
	| block |
	block := anSBlock isInlined
		ifTrue: [ PCompiledBlock new ]
		ifFalse: [ self ASSERT: false ].
	blocks at: block put: anSBlock.
	^ self mirageOnBlock: block
]

{ #category : #visiting }
PstInterpreter >> visitLiteral: anSLiteral [
	| handle |
	handle := localRuntime handleOn: anSLiteral value.
	^ handle mirage
]

{ #category : #visiting }
PstInterpreter >> visitPrimitive: primitive [
	| gate new left right args rcvr |
	returned := true.
	gate := receiver _gate.
	primitive = #Size
		ifTrue: [ ^ returnValue := self mirageOnInteger: gate mirror size ].
	primitive = #NewSize
		ifTrue: [ new := gate handle target new: arguments first _gate handle target.
			^ returnValue := self mirageOnInteger: new ].
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
	primitive = #ClosureValue ifTrue: [ self primitiveClosureValue ].
	primitive = #ReplaceFromTo
		ifTrue: [ rcvr := receiver _gate handle target.
			args := arguments collect: [ :arg | arg _gate asLocalCollection ].
			rcvr
				perform: #replaceFrom:to:with:startingAt:
				withArguments: args asArray.
			^ returnValue := receiver ].
	self ASSERT: false
]
