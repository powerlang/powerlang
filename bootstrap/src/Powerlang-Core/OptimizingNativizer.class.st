"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OptimizingNativizer,
	#superclass : #Object,
	#instVars : [
		'environment',
		'method',
		'firstBlock'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #allocation }
OptimizingNativizer >> allocate [
	| allocator |
	allocator := OptimizingRegisterAllocator new
		abi: environment abi;
		firstBlock: firstBlock.
	^ allocator doAllocation
]

{ #category : #unclassified }
OptimizingNativizer >> assembleUsing: allocation [
	^OptimizingCodeEmitter new
		method: method;
		abi: environment abi;
		allocation: allocation;
		messageLinker: environment messageLinker;
		assembleFrom: firstBlock
]

{ #category : #unclassified }
OptimizingNativizer >> bindVariables [
	| binder |
	binder := OptimizingVariableBinder new abi: environment abi.
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
OptimizingNativizer >> environment: aNativizationEnvironment [
	environment := aNativizationEnvironment
]

{ #category : #unclassified }
OptimizingNativizer >> firstBlock [
	^firstBlock
]

{ #category : #unclassified }
OptimizingNativizer >> fragmentInstructions [
	OptimizingInstructionFragmenter new
		abi: environment abi;
		method: method;
		firstBlock: firstBlock;
		doFragment
]

{ #category : #unclassified }
OptimizingNativizer >> inlineBlocks [
	OptimizingBlockInliner new on: firstBlock; doInline
]

{ #category : #unclassified }
OptimizingNativizer >> inlineMethods [
	OptimizingMethodInliner new
		environment: environment;
		firstBlock: firstBlock;
		inlineAllMessages
]

{ #category : #unclassified }
OptimizingNativizer >> irFor: anSCompiledMethod [
	| visitor ir |
	visitor := OptimizingVisitor new method: anSCompiledMethod.
	ir := visitor visit: anSCompiledMethod sexpressions.
	^ ir
]

{ #category : #unclassified }
OptimizingNativizer >> method: anSCompiledMethod [
	method := anSCompiledMethod.
	firstBlock := self irFor: anSCompiledMethod
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
	^ self
		enforceTwoAddressCodeUsing: allocation;
		simplifyCFG;
		assembleUsing: allocation
]

{ #category : #unclassified }
OptimizingNativizer >> removeRedundantCode [
	OptimizingValueNumbering new workFrom: firstBlock
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
