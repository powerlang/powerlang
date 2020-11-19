Class {
	#name : #NativizationEnvironment,
	#superclass : #Object,
	#instVars : [
		'optimizedMethods',
		'invokedMethods',
		'inlinedMethods',
		'messageLinker',
		'globals',
		'writeBarrier',
		'abi',
		'safepointCheck',
		'cachedNativizer',
		'busy'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #private }
NativizationEnvironment class >> forTesting [
	^ self forTesting: VirtualSmalltalkImage kernelSpec
]

{ #category : #private }
NativizationEnvironment class >> forTesting: anRGEnvironment [ 
	^ self new spec: anRGEnvironment
]

{ #category : #accessing }
NativizationEnvironment class >> globalNames [
	^ #(Lookup LookupSuper WriteBarrier Safepoint SmallIntegerBehavior Invoke DebuggableLookup DebuggableLookupSuper)
]

{ #category : #accessing }
NativizationEnvironment class >> indexOfGlobal: aSymbol [
	^self globalNames
		indexOf: aSymbol
		ifAbsent: [self error: 'global not found']
]

{ #category : #initialization }
NativizationEnvironment >> abi [
	^ abi 
]

{ #category : #initialization }
NativizationEnvironment >> abi: anAbi [
	abi := anAbi 
]

{ #category : #initialization }
NativizationEnvironment >> addLinker: aLinker [
	messageLinker add: aLinker
]

{ #category : #initialization }
NativizationEnvironment >> be32bits [
	abi := X86ABI new 
]

{ #category : #initialization }
NativizationEnvironment >> completeInitialization [
	cachedNativizer := self newExpressionNativizer 
]

{ #category : #initialization }
NativizationEnvironment >> globalNamed: aSymbol [
	| index |
	index := self class indexOfGlobal: aSymbol.
	^globals at: index
]

{ #category : #initialization }
NativizationEnvironment >> globalNamed: aSymbol put: anObject [
	| index |
	index := self class indexOfGlobal: aSymbol.
	globals at: index put: anObject
]

{ #category : #accessing }
NativizationEnvironment >> globals [
	^globals
]

{ #category : #accessing }
NativizationEnvironment >> globals: anArray [
	globals := anArray
]

{ #category : #initialization }
NativizationEnvironment >> initialize [
	busy := false.
	abi := ABI forCurrent.
	optimizedMethods := OrderedCollection new.
	invokedMethods := OrderedCollection new.
	inlinedMethods := OrderedCollection new.
	messageLinker := CompositeMessageLinker new
		add: InlineMessageLinker new.
	globals := Array new: self class globalNames size.

]

{ #category : #initialization }
NativizationEnvironment >> inlinedMethods [
	^inlinedMethods
]

{ #category : #initialization }
NativizationEnvironment >> inlinedMethods: aCollection [
	inlinedMethods := aCollection
]

{ #category : #accessing }
NativizationEnvironment >> invokeStub [
	| index |
	index := self class indexOfGlobal: #Invoke.
	^(globals at: index) code
]

{ #category : #initialization }
NativizationEnvironment >> invokedMethods [
	^invokedMethods
]

{ #category : #initialization }
NativizationEnvironment >> invokedMethods: aCollection [
	invokedMethods := aCollection asOrderedCollection 
]

{ #category : #accessing }
NativizationEnvironment >> lookup [
	| index |
	index := self class indexOfGlobal: #Lookup.
	^globals at: index
]

{ #category : #accessing }
NativizationEnvironment >> lookupDebuggableStub [
	| index |
	index := self class indexOfGlobal: #DebuggableLookup.
	^(globals at: index) code
]

{ #category : #accessing }
NativizationEnvironment >> lookupStub [
	| index |
	index := self class indexOfGlobal: #Lookup.
	^(globals at: index) code
]

{ #category : #accessing }
NativizationEnvironment >> lookupSuper [
	| index |
	index := self class indexOfGlobal: #LookupSuper.
	^ globals at: index
]

{ #category : #accessing }
NativizationEnvironment >> lookupSuperDebuggableStub [
	| index |
	index := self class indexOfGlobal: #DebuggableLookupSuper.
	^(globals at: index) code
]

{ #category : #accessing }
NativizationEnvironment >> lookupSuperStub [
	| index |
	index := self class indexOfGlobal: #LookupSuper.
	^(globals at: index) code
]

{ #category : #accessing }
NativizationEnvironment >> messageLinker [
	^ messageLinker
]

{ #category : #initialization }
NativizationEnvironment >> messageLinker: aLinker [
	messageLinker := aLinker 
]

{ #category : #accessing }
NativizationEnvironment >> methodNativizer [
	^ cachedNativizer 
]

{ #category : #services }
NativizationEnvironment >> monomorphicCache [
	| asm lookup next |
	asm := TemplateAssembler64 new.
	asm wordSize: abi wordSize.
	lookup := asm newLabel.
	asm
		loadTwithAindex: 3;
		loadSwithGlobal: #SmallIntegerBehavior.
	next := asm labeledNonIntegerBitTestOfR.
	asm
		loadLongSwithRindex: 0;
		@ next;
		compareSwithTindex: 1;
		shortJumpIfNotEqualTo: lookup;
		loadMwithTindex: 2;
		jumpToMindex: 1;
		@ lookup;
		loadMwithGlobal: #Lookup;
		jumpToMindex: 1;
		applyFixups.
	^ asm nativeCode code
]

{ #category : #services }
NativizationEnvironment >> nativize: aCompiledMethod [
	^ (self shouldOptimize: aCompiledMethod)
		  ifTrue: [ self nativizeOptimizing: aCompiledMethod ]
		  ifFalse: [ self nativizeWithoutOptimizing: aCompiledMethod ] 
]

{ #category : #services }
NativizationEnvironment >> nativizeOptimizing: anSCompiledMethod [
	^self optimizingNativizer
		method: anSCompiledMethod;
		nativize 
]

{ #category : #services }
NativizationEnvironment >> nativizeWithoutOptimizing: aCompiledMethod [
	| method |
	method := self
		nativizerDuring: [ :nativizer | nativizer nativize: aCompiledMethod ].
	^ method 
]

{ #category : #initialization }
NativizationEnvironment >> nativizerDuring: aBlock [
	^ busy
		  ifFalse: [ 
			  busy := true.
			  [ aBlock value: cachedNativizer ] ensure: [ busy := false ] ]
		  ifTrue: [ 
			  | old |
			  old := cachedNativizer. 
			  [ 
			  cachedNativizer := self newExpressionNativizer.
			  aBlock value: cachedNativizer ] ensure: [ cachedNativizer := old ] ]
]

{ #category : #initialization }
NativizationEnvironment >> newExpressionNativizer [
	^ SExpressionNativizer new environment: self
]

{ #category : #initialization }
NativizationEnvironment >> optimizedMethods [
	^optimizedMethods
]

{ #category : #initialization }
NativizationEnvironment >> optimizedMethods: aCollection [
	optimizedMethods := aCollection
]

{ #category : #initialization }
NativizationEnvironment >> optimizingNativizer [
	^OptimizingNativizer new environment: self
]

{ #category : #services }
NativizationEnvironment >> polymorphicCache [
	| asm smi case2 case3 case4 case5 case6 case7 lookup |
	asm := TemplateAssembler64 new.
	asm wordSize: abi wordSize.
	smi := asm newLabel.
	case2 := asm newLabel.
	case3 := asm newLabel.
	case4 := asm newLabel.
	case5 := asm newLabel.
	case6 := asm newLabel.
	case7 := asm newLabel.
	lookup := asm newLabel.
	asm loadTwithAindex: 3.
	smi := asm labeledNonIntegerBitTestOfR.
	asm
		loadLongSwithRindex: 0;
		compareSwithTindex: 1;
		shortJumpIfNotEqualTo: case2;
		loadMwithTindex: 2;
		jumpToMindex: 1;
		@ case2;
		compareSwithTindex: 3;
		shortJumpIfNotEqualTo: case3;
		loadMwithTindex: 4;
		jumpToMindex: 1;
		@ case3;
		compareSwithTindex: 5;
		shortJumpIfNotEqualTo: case4;
		loadMwithTindex: 6;
		jumpToMindex: 1;
		@ case4;
		compareSwithTindex: 7;
		shortJumpIfNotEqualTo: case5;
		loadMwithTindex: 8;
		jumpToMindex: 1;
		@ case5;
		compareSwithTindex: 9;
		shortJumpIfNotEqualTo: case6;
		loadMwithTindex: 10;
		jumpToMindex: 1;
		@ case6;
		compareSwithTindex: 11;
		shortJumpIfNotEqualTo: case7;
		loadMwithTindex: 12;
		jumpToMindex: 1;
		@ case7;
		compareSwithTindex: 13;
		shortJumpIfNotEqualTo: lookup;
		loadMwithTindex: 14;
		jumpToMindex: 1;
		@ lookup;
		loadMwithGlobal: #Lookup;
		jumpToMindex: 1;
		@ smi;
		loadMwithTindex: 15;
		jumpToMindex: 1;
		applyFixups.
	^ asm nativeCode code
]

{ #category : #accessing }
NativizationEnvironment >> safepoint [
	| index |
	index := self class indexOfGlobal: #Safepoint.
	^(globals at: index) code
]

{ #category : #initialization }
NativizationEnvironment >> safepointCheck: anObject [
	safepointCheck := anObject 
]

{ #category : #initialization }
NativizationEnvironment >> sexpressionOffsetsOf: code [
	| method |
	method := code method.
	(self shouldOptimize: method) ifTrue: [ ^ #(  ) ].
	^ self nativizerDuring: [ :nativizer | 
		  method nativeCode ifNotNil: [ method := method copy ]. 
		  nativizer compile: method.
		  nativizer sexpressionOffsetsOf: code ]
]

{ #category : #initialization }
NativizationEnvironment >> shouldInline: aSymbol [
	^ inlinedMethods anySatisfy: [ :m | m selector = aSymbol ]
]

{ #category : #'*Powerlang-Core-OCompiler' }
NativizationEnvironment >> shouldOptimize: method [
	| selector classname |
	selector := method selector.
	classname := method classBinding name.
	^ optimizedMethods anySatisfy: [:m | m selector = selector and: [ m classBinding name = classname ]  ]
]

{ #category : #initialization }
NativizationEnvironment >> wordSize [
	^ abi wordSize 
]

{ #category : #initialization }
NativizationEnvironment >> wordSizeShift [
	^ abi wordSizeShift 
]

{ #category : #initialization }
NativizationEnvironment >> writeBarrier [
	^writeBarrier
]

{ #category : #initialization }
NativizationEnvironment >> writeBarrier: anSCompiledMethod [
	writeBarrier := anSCompiledMethod.
	invokedMethods add: writeBarrier 
]
