"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OptimizingNativizer,
	#superclass : #Object,
	#instVars : [
		'method',
		'firstBlock',
		'messageLinker',
		'inlinedMethods',
		'abi'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #unclassified }
OptimizingNativizer class >> new [
	^self basicNew initialize
]

{ #category : #unclassified }
OptimizingNativizer class >> on: aCompiledMethod [
	^self new method: aCompiledMethod
]

{ #category : #unclassified }
OptimizingNativizer >> abi: anAbi [
	abi := anAbi
]

{ #category : #allocation }
OptimizingNativizer >> allocate [
	| allocator |
	allocator := OptimizingRegisterAllocator new
		abi: abi;
		firstBlock: firstBlock.
	^allocator doAllocation
]

{ #category : #unclassified }
OptimizingNativizer >> assembleUsing: allocation [
	| assembler |
	assembler := OptimizingCodeEmitter new
		method: method;
		abi: abi;
		allocation: allocation;
		messageLinker: messageLinker.
	assembler assembleFrom: firstBlock.
	^assembler nativeCode
]

{ #category : #unclassified }
OptimizingNativizer >> bindVariables [
	| binder |
	binder := OptimizingVariableBinder new abi: abi.
	binder doBindingFrom: firstBlock
]

{ #category : #unclassified }
OptimizingNativizer >> decompose [
	self
		inlineBlocks;
		verifyPredecessors;
		inlineMethods;
		verifyPredecessors;
		unifyReturns;
		verifyPredecessors;
		bindVariables
]

{ #category : #private }
OptimizingNativizer >> defaultInlinedMethods [
	^ NativizationEnvironment primitiveObjectMethods
		,
			((OrderedCollection new
				add: Object >> #byteAtValid:;
				add: Object >> #byteAtValid:put:;
				add: ProtoObject >> #objectAtValid:;
				add: ProtoObject >> #objectAtValid:put:;
				add: Object >> #basicObjectIndexOf:;
				add: Object >> #primitiveAt:put:;
				add: ProtoObject >> #behavior;
				add: ProtoObject >> #class;
				add: Species >> #instSize;
				add: Species >> #_instancesAreArrayed;
				add: Species >> #_instancesHavePointers;
				add: Species >> #memory;
				add: Species >> #instanceBehavior;
				add: Species >> #primitiveNew;
				add: Species >> #primitiveNew:;
				add: ProtoObject >> #primitiveAt:;
				add: ProtoObject >> #_cachedLookup:;
				add: ProtoObject >> #_cachedLookup:in:;
				add: CompiledMethod >> #prepareForExecution;
				add: CompiledMethod >> #isNativized;
				add: CompiledMethod >> #nativeCode;
				add: CompiledMethod >> #blockCount;
				add: CompiledMethod >> #literalIndexFrom:;
				add: CompiledBlock >> #argumentCount;
				add: CompiledBlock >> #blockNumber;
				add: CompiledBlock >> #blockCode;
				add: CompiledBlock >> #method;
				add: NativeCode >> #code;
				add: NativeCode >> #isFresh;
				add: CharacterArray >> #characterAtValid:;
				add: GCSpace >> #commitedLimit;
				add: GCSpace >> #nextFree;
				add: GCSpace >> #nextFree:;
				yourself) )
]

{ #category : #unclassified }
OptimizingNativizer >> eliminateDeadPhis [
	OptimizingPhiSimplification new processFrom: firstBlock
]

{ #category : #unclassified }
OptimizingNativizer >> enforceTwoAddressCodeUsing: allocation [
	| enforcer |
	enforcer := OptimizingTwoAddressEnforcer new
		allocation: allocation;
		firstBlock: firstBlock.
	^enforcer doEnforce
]

{ #category : #unclassified }
OptimizingNativizer >> firstBlock [
	^firstBlock
]

{ #category : #unclassified }
OptimizingNativizer >> fragmentInstructions [
	| binder |
	binder := OptimizingInstructionFragmenter new abi: abi.
	binder
		fragmentArgumentsIn: firstBlock with: method;
		fragmentInstructionsFrom: firstBlock
]

{ #category : #unclassified }
OptimizingNativizer >> initialize [
	inlinedMethods := self defaultInlinedMethods
]

{ #category : #unclassified }
OptimizingNativizer >> inlineBlocks [
	OptimizingBlockInliner new on: firstBlock; doInline
]

{ #category : #unclassified }
OptimizingNativizer >> inlineMethods [
	(OptimizingMethodInliner on: firstBlock)
		abi: abi;
		methods: self inlinedMethods;
		inlineAllMessages
]

{ #category : #private }
OptimizingNativizer >> inlinedMethods [
	^inlinedMethods
]

{ #category : #private }
OptimizingNativizer >> inlinedMethods: aCollection [
	inlinedMethods := aCollection
]

{ #category : #unclassified }
OptimizingNativizer >> irFor: aCompiledMethod [
	| visitor ir cm |
	visitor := OptimizingVisitor new.
	cm := (NativizationEnvironment class
		isUndermethod: aCompiledMethod selector)
		ifTrue: [ ProtoObject >> aCompiledMethod selector ]
		ifFalse: [ aCompiledMethod ].
	ir := visitor visit: cm parseTree.
	^ ir
]

{ #category : #unclassified }
OptimizingNativizer >> messageLinker: aMessageLinker [
	messageLinker := aMessageLinker
]

{ #category : #unclassified }
OptimizingNativizer >> method: aCompiledMethod [
	method := aCompiledMethod.
	firstBlock := self irFor: aCompiledMethod
]

{ #category : #unclassified }
OptimizingNativizer >> nativeCode [
	^self nativize
]

{ #category : #nativizing }
OptimizingNativizer >> nativize [
	| allocation |
	allocation := self
		decompose;
		fragmentInstructions;
		simplifyCFG;
		removeRedundantCode;
		simplifyCFG;
		splitCriticalEdges;
		transformToCSSA;
		allocate.
	^self
		enforceTwoAddressCodeUsing: allocation;
		simplifyCFG;
		assembleUsing: allocation
]

{ #category : #unclassified }
OptimizingNativizer >> removeRedundantCode [
	OptimizingValueNumbering new workFrom: firstBlock
]

{ #category : #unclassified }
OptimizingNativizer >> selectInstructions [
	| allocator |
	allocator := OptimizingInstructionSelector new firstBlock: firstBlock.
	^allocator doSelection
]

{ #category : #unclassified }
OptimizingNativizer >> simplifyCFG [
	OptimizingCFGSimplifier new cleanFrom: firstBlock
]

{ #category : #unclassified }
OptimizingNativizer >> splitCriticalEdges [
	firstBlock splitAllCriticalEdges
]

{ #category : #allocation }
OptimizingNativizer >> transformToCSSA [
	| transformer |
	transformer := OptimizingCSSATransformer new firstBlock: firstBlock.
	transformer applyTransformation
]

{ #category : #unclassified }
OptimizingNativizer >> unifyReturns [
	firstBlock unifyReturns
]

{ #category : #unclassified }
OptimizingNativizer >> verifyPredecessors [
	firstBlock verifyAllPredecessorsSanity
]
