Class {
	#name : #EvaluationContext,
	#superclass : #Object,
	#instVars : [
		'parent',
		'method',
		'receiver',
		'arguments',
		'temporaries',
		'environment',
		'system',
		'isBlock'
	],
	#classVars : [
		'Undermessages'
	],
	#pools : [
		'ClosureElementTypes'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #'instance creation' }
EvaluationContext class >> initialize [
	"
	self initialize
	"

	Undermessages := #(_basicAt: #_basicAt:put: _bitShiftLeft: _byteAt: #_byteAt:put: _smallSize _largeSize _isSmallInteger _basicHash _basicHash: _smallIntegerByteAt: _uShortAtOffset: _uShortAtOffset:put:)
]

{ #category : #'instance creation' }
EvaluationContext class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #visiting }
EvaluationContext >> argumentAt: index in: anInteger [
	| env |
	anInteger ifNil: [ ^arguments at: index ].
	env := self environmentFor: anInteger.
	^env at: index.
]

{ #category : #visiting }
EvaluationContext >> arguments [
	^arguments
]

{ #category : #visiting }
EvaluationContext >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #visiting }
EvaluationContext >> backtrace [
	| bt next |
	bt := OrderedCollection new.
	next := self.
	([ next notNil and: [next method notNil]])
		whileTrue: [ bt
				add:
					{next method signature.
					next receiver} , next arguments.
			next := next parent ].
	^ bt
]

{ #category : #visiting }
EvaluationContext >> beBlock [
	isBlock := true
]

{ #category : #visiting }
EvaluationContext >> captureClosure: anSBlock [
	| block closure s i type env arg |
	block := anSBlock compiledCode.
	closure := system newClosure: block environmentCount.
	closure
		block: block;
		astcodes: anSBlock;
		builder: self.
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

{ #category : #services }
EvaluationContext >> classBinding [
	^method classBinding
]

{ #category : #accessing }
EvaluationContext >> environment [
	^ environment
]

{ #category : #visiting }
EvaluationContext >> environment: anObject [
	environment := anObject
]

{ #category : #visiting }
EvaluationContext >> environmentFor: anInteger [
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
EvaluationContext >> false [
	^ system false
]

{ #category : #accessing }
EvaluationContext >> firstArgument [
	^arguments at: 1
]

{ #category : #accessing }
EvaluationContext >> fourthArgument [
	^ arguments at: 4
]

{ #category : #accessing }
EvaluationContext >> framesCount [
	| current result |
	current := self.
	result := 0.
	[ current notNil ]
		whileTrue: [ result := result + 1.
			current := current parent ].
	^ result
]

{ #category : #visiting }
EvaluationContext >> home [
	| frame searched |
	isBlock ifFalse: [ ^self ].
	frame := parent.
	searched := (system isClosure: environment) ifTrue: [ environment builder environment] ifFalse: [ environment ].
	[frame notNil] whileTrue: [ frame environment == searched ifTrue: [^frame home]. frame := frame parent.].
self error: 'cannot return from this closure'
]

{ #category : #visiting }
EvaluationContext >> initialize [
	isBlock := false
]

{ #category : #visiting }
EvaluationContext >> initializeForBlock: sblock args: anArray closure: closure [
	"When the block is not inlined, closure becomes the environment of the new context.
	But when it is inlined, the environment is the one of the builder, which is already
	set because we copied from the builder frame."


	sblock isInlined
		ifTrue: [ anArray
				with: sblock inlinedArgs
				do: [ :arg :i | temporaries at: i put: arg ] ]
		ifFalse: [ temporaries := Array new: sblock tempCount.
			arguments := anArray.
			environment := closure. ]
]

{ #category : #visiting }
EvaluationContext >> instanceVarAt: index [
	^ system instanceVarOf: receiver at: index
]

{ #category : #visiting }
EvaluationContext >> instanceVarAt: index put: aValue [
	^ system instanceVarOf: receiver at: index put: aValue
]

{ #category : #visiting }
EvaluationContext >> isBlock [
	^isBlock
	
]

{ #category : #visiting }
EvaluationContext >> isHomeOf: env [
	^ environment == env andNot: [ isBlock ]
]

{ #category : #visiting }
EvaluationContext >> literal: anObject [
	^anObject
]

{ #category : #services }
EvaluationContext >> loadAssociationValue: anObject [
	^system loadAssociationValue: anObject
]

{ #category : #visiting }
EvaluationContext >> method [
	^method
]

{ #category : #accessing }
EvaluationContext >> method: anSCompiledMethod [
	method := anSCompiledMethod.
	temporaries := Array new: anSCompiledMethod tempCount
]

{ #category : #visiting }
EvaluationContext >> nil [
	^ system nil
]

{ #category : #visiting }
EvaluationContext >> parent [
	^parent
]

{ #category : #visiting }
EvaluationContext >> parent: anEvaluationContext [
	parent := anEvaluationContext.
	(isBlock not and: [self framesCount > 1000])
		ifTrue: [ self halt ].
]

{ #category : #printing }
EvaluationContext >> printOn: aStream [
 self backtrace
				do: [ :frame | 
					frame
						do: [ :elem | elem printOn: aStream ]
						separatedBy: [ aStream nextPutAll: '. ' ].
					aStream cr ]
]

{ #category : #visiting }
EvaluationContext >> receiver [
	^receiver
]

{ #category : #visiting }
EvaluationContext >> receiver: anObject [
	receiver := anObject
]

{ #category : #accessing }
EvaluationContext >> secondArgument [
	^ arguments at: 2
]

{ #category : #visiting }
EvaluationContext >> staticBindingFor: aSymbol [
	| symbol |
	symbol := system symbolFrom: aSymbol.
	(self staticBindingForIvar: symbol) ifNotNil: [ :b | ^ b ].
	(self staticBindingForCvar: symbol) ifNotNil: [ :b | ^ b ].
	^ self staticBindingForMvar: symbol
]

{ #category : #accessing }
EvaluationContext >> staticBindingForCvar: aSymbol [
	| species cvars class |
	species := system speciesFor: receiver.
	[ cvars := species classVariables.
	cvars isNil ifFalse: [ 
		cvars associationAt: aSymbol ifPresent: [:assoc |
			^ SAssociationBinding new association: assoc ].
	species localPools
		do: [ :pool | 
			pool associationAt: aSymbol ifPresent: [:assoc | 
					class := pool isConstant
						ifTrue: [ SConstantPoolBinding ]
						ifFalse: [ SAssociationBinding ].
					^ class new association: assoc ] ]].
	species := species superclass.
	species isNil ] whileFalse.
	^ nil
]

{ #category : #accessing }
EvaluationContext >> staticBindingForIvar: aSymbol [
	| ivar |
	ivar := receiver allSlotNames indexOf: aSymbol.
	^ ivar > 0
		ifTrue: [ SInstVarBinding new index: ivar ]
]

{ #category : #accessing }
EvaluationContext >> staticBindingForMvar: aSymbol [
	| assoc class |
	class := system speciesFor: receiver.
	assoc := class module namespace
		associationAt: aSymbol
		ifAbsent: [ self error: 'unbound variable: ' , aSymbol asString].
	^ SAssociationBinding new association: assoc
]

{ #category : #services }
EvaluationContext >> storeAssociation: association value: anObject [ 
	system storeAssociation: association value: anObject 
]

{ #category : #visiting }
EvaluationContext >> system: aPowertalkRuntime [
	system := aPowertalkRuntime
]

{ #category : #visiting }
EvaluationContext >> temporaryAt: index in: anInteger [
	| env |
	anInteger ifNil: [ ^ temporaries at: index ].
	env := self environmentFor: anInteger.
	^ env at: index
]

{ #category : #visiting }
EvaluationContext >> temporaryAt: index in: anInteger put: aValue [
	| env |
	anInteger ifNil: [ ^ temporaries	at:index put: aValue ].
	env := self environmentFor: anInteger.
	^ env at: index put: aValue
]

{ #category : #accessing }
EvaluationContext >> thirdArgument [
	^ arguments at: 3
]

{ #category : #visiting }
EvaluationContext >> true [
	^ system true
]
