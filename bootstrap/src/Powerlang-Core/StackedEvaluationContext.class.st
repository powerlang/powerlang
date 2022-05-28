Class {
	#name : #StackedEvaluationContext,
	#superclass : #EvaluationContext,
	#instVars : [
		'stack',
		'regSP',
		'regBP',
		'regM',
		'regS',
		'regE',
		'pc'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #initialization }
StackedEvaluationContext >> argumentAt: anInteger [
	| args |
	args := self isBlock ifTrue: [ system blockArgumentCount: regM ] ifFalse: [ system methodArgumentCount: regM ].
	^stack at: regBP + 1 + (args - anInteger + 1)
]

{ #category : #initialization }
StackedEvaluationContext >> argumentAt: index in: environmentIndex [
	environmentIndex ifNil: [ ^ self argumentAt: index ].
	^self environment: environmentIndex at: index.

]

{ #category : #initialization }
StackedEvaluationContext >> arguments [
	| count |
	self halt.
	count := system argumentCountOf: regM.
	^ (count to: 1 by: -1) collect: [ :i | self argumentAt: i ]
]

{ #category : #services }
StackedEvaluationContext >> backtrace [
	| result bp code receiver |
	result := OrderedCollection new.
	bp := regBP.
	[ bp != 0 ]
		whileTrue: [ code := stack at: bp - 2.
			receiver := stack at: bp - 1.
			result add: {code. receiver}.
			bp := stack at: bp ].
	^ result
]

{ #category : #initialization }
StackedEvaluationContext >> buildClosureFrameFor: receiver code: code environment: environment [
	| temps |
	temps := system blockTempCount: code.
	self buildFrameFor: receiver code: code environment: environment temps: temps
]

{ #category : #initialization }
StackedEvaluationContext >> buildFrameFor: receiver code: code environment: environment temps: temps [
	regS := receiver.
	regM := code.
	self
		push: pc;
		push: regBP.
	regBP := regSP.
	regBP < 100 ifTrue: [ self error: 'stack overflow' ].
	self
		push: receiver;
		push: code;
		push: regE;
		push: environment.
	regE := environment.
	pc := 0.
	temps timesRepeat: [ self push: self nil ]
]

{ #category : #initialization }
StackedEvaluationContext >> buildMethodFrameFor: receiver code: code environment: environment [
	| temps |
	temps := system methodTempCount: code.
	self
		buildFrameFor: receiver
		code: code
		environment: environment
		temps: temps
]

{ #category : #services }
StackedEvaluationContext >> dropOperands: anInteger [
	regSP := regSP + anInteger
]

{ #category : #initialization }
StackedEvaluationContext >> environment [
	^regE
]

{ #category : #initialization }
StackedEvaluationContext >> environment: environmentIndex at: index [
	"
	-1: inlined argument.
	 0: current env.
 	>0: index of env in current env. "

	| env |
	environmentIndex = -1
		ifTrue: [ ^ self stackTemporaryAt: index ].
	env := environmentIndex = 0
		ifTrue: [ regE ]
		ifFalse: [ regE at: environmentIndex ].
	^ env at: index
]

{ #category : #initialization }
StackedEvaluationContext >> environment: environmentIndex at: index put: value [
	"
	-1: inlined argument.
	 0: current env.
 	>0: index of env in current env. "

	| env |
	environmentIndex = -1
		ifTrue: [ ^ self stackTemporaryAt: index put: value ].
	env := environmentIndex = 0
		ifTrue: [ regE ]
		ifFalse: [ regE at: environmentIndex ].
	^ env at: index put: value
]

{ #category : #initialization }
StackedEvaluationContext >> firstArgument [
	^ self argumentAt: 1
]

{ #category : #initialization }
StackedEvaluationContext >> fourthArgument [
	^ self argumentAt: 4
]

{ #category : #initialization }
StackedEvaluationContext >> hasFinished [
	^ (stack at: regBP) = 0
]

{ #category : #initialization }
StackedEvaluationContext >> incRegPC [
	^pc := pc + 1
]

{ #category : #initialization }
StackedEvaluationContext >> initialize [

	super initialize.
	stack := Array new: 64 * 1024.
	regSP := stack size + 1.
	regBP := 0.
	pc := 0.

]

{ #category : #initialization }
StackedEvaluationContext >> isBlock [
	^ system isBlock: regM
]

{ #category : #initialization }
StackedEvaluationContext >> method [
	^ self isBlock
		ifTrue: [ regM method ]
		ifFalse: [ regM ]
]

{ #category : #initialization }
StackedEvaluationContext >> method: anSCompiledMethod [
	regM := anSCompiledMethod

]

{ #category : #initialization }
StackedEvaluationContext >> methodArguments [
	| count |
	count := system methodArgumentCount: regM.
	^ (count to: 1 by: -1) collect: [ :i | self argumentAt: i ]
]

{ #category : #initialization }
StackedEvaluationContext >> operandAt: anInteger [
	^ stack at: regSP + anInteger
]

{ #category : #initialization }
StackedEvaluationContext >> pop [
	| result |
	result := stack at: regSP.
	regSP := regSP + 1.
	^result

]

{ #category : #initialization }
StackedEvaluationContext >> popFrame [
	regSP := regBP.
	regE := stack at: regBP - 3.
	regBP := self pop.
	regM := stack at: regBP - 2.
	regS := stack at: regBP - 1.
	pc := self pop
]

{ #category : #initialization }
StackedEvaluationContext >> popOperand [
	^self pop
]

{ #category : #initialization }
StackedEvaluationContext >> popOperands: anInteger [
	| result |
	anInteger = 0
		ifTrue: [ ^ #() ].
	result := Array new: anInteger.
	anInteger to: 1 by: -1 do: [ :i | result at: i put: self pop ].
	^ result
]

{ #category : #initialization }
StackedEvaluationContext >> printOn: aStream [
	| slot |
	regSP to: regBP + 3 do: [ :i | slot := stack at: i. aStream nextPutAll: i hex; nextPutAll: ' -> '; print: slot;cr ].
	aStream nextPutAll: '...'; cr.

super printOn: aStream
]

{ #category : #initialization }
StackedEvaluationContext >> printStack [
	^String
		streamContents: [ :stream | 
			| slot |
			regSP to: stack size do: [ :i | 
				slot := stack at: i.
				stream
					nextPutAll: i hex;
					nextPutAll: ' -> ';
					print: slot;
					cr ] ]
]

{ #category : #initialization }
StackedEvaluationContext >> push: anObject [
	anObject ifNil: [ self halt ].
	regSP := regSP - 1.
	stack at: regSP put: anObject
]

{ #category : #initialization }
StackedEvaluationContext >> pushOperand: anObject [
	anObject ifNil: [ self halt ].
	regSP := regSP - 1.
	stack at: regSP put: anObject
]

{ #category : #initialization }
StackedEvaluationContext >> receiver [
	^ regS
]

{ #category : #accessing }
StackedEvaluationContext >> regM [
	^ regM
]

{ #category : #accessing }
StackedEvaluationContext >> regPC [
	^pc
]

{ #category : #accessing }
StackedEvaluationContext >> regPC: anInteger [ 
	pc := anInteger
]

{ #category : #services }
StackedEvaluationContext >> reserveStackSlots: anInteger [
	regSP := regSP - anInteger
]

{ #category : #initialization }
StackedEvaluationContext >> restart [
	| nilObj |
	nilObj := system nil.
	regBP - self tempOffset to: regSP by: -1 do: [ :i | stack at: i put: nilObj ].
	pc := 1
]

{ #category : #initialization }
StackedEvaluationContext >> secondArgument [
	^ self argumentAt: 2
]

{ #category : #initialization }
StackedEvaluationContext >> self [
	^ regS
]

{ #category : #initialization }
StackedEvaluationContext >> stackTemporaryAt: index [
	^ stack at: regBP - self tempOffset - index
]

{ #category : #initialization }
StackedEvaluationContext >> stackTemporaryAt: index put: value [
	^ stack at: regBP - self tempOffset - index put: value
]

{ #category : #initialization }
StackedEvaluationContext >> system: aPowertalkRuntime [
	super system: aPowertalkRuntime.
	regE := regS := system nil
]

{ #category : #initialization }
StackedEvaluationContext >> tempOffset [ 
"should be 2 or 4 if we had methods without environment"
	^4
]

{ #category : #initialization }
StackedEvaluationContext >> temporaryAt: index in: environmentIndex [
	environmentIndex ifNil: [ ^ self stackTemporaryAt: index].
	^ self environment: environmentIndex at: index
]

{ #category : #initialization }
StackedEvaluationContext >> temporaryAt: index in: environmentIndex put: value [
	environmentIndex ifNil: [ ^ self stackTemporaryAt: index put: value ].
	^ self environment: environmentIndex at: index put: value
]

{ #category : #initialization }
StackedEvaluationContext >> thirdArgument [
	^ self argumentAt: 3
]

{ #category : #initialization }
StackedEvaluationContext >> unwind [
	| home bp environment |
	home := system closureHome: self environment.
	home == system nil ifTrue: [ self error: 'cannot return because closure has no home' ].
	bp := regBP.
	[ bp != 0 ]
		whileTrue: [ environment := stack at: bp - 4.
			environment == home
				ifTrue: [ regBP := bp.
					^ self popFrame ].
			bp := stack at: bp ].
	self error: 'cannot return from this closure'
]
