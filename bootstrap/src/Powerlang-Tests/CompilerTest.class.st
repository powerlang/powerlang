Class {
	#name : #CompilerTest,
	#superclass : #TestCase,
	#instVars : [
		'env'
	],
	#pools : [
		'AstBindingTypes',
		'AstNodeTypes',
		'ClosureElementTypes'
	],
	#category : #'Powerlang-Tests-SCompiler'
}

{ #category : #running }
CompilerTest >> setUp [
	env := RGEnvironment  new.
]

{ #category : #tests }
CompilerTest >> test_01 [
	| compiler methodInfo |
	
	compiler := Compiler forClass: (Object ensureRingDefinitionIn: env).
	methodInfo := compiler compile: 'perform: aSelector <primitive: Perform> ^self primitiveFailed'.
	self assert: (methodInfo astcodes first) equals: MethodId.
	self assert: (methodInfo astcodes second first) equals: PrimitiveId.
	self assert: (methodInfo literals at: methodInfo astcodes second second) equals: 'Perform'
	
]

{ #category : #tests }
CompilerTest >> test_02 [
	| compiler methodInfo |
	
	compiler := Compiler forClass: (Object ensureRingDefinitionIn: env).
	methodInfo := compiler compile: 'meaningOfLife ^42'.
	self assert: (methodInfo astcodes first) equals: MethodId.
	
]

{ #category : #tests }
CompilerTest >> test_03 [
	| object compiler methodInfo |
	
	object := Object ensureRingDefinitionIn: env.
	compiler := Compiler forClass: object.
	methodInfo := compiler compile: 'clone ^ Object new'.
	self assert: (methodInfo literals contains:[:e|e value = object and:[e key = #Object]]).

	
]

{ #category : #tests }
CompilerTest >> test_04 [
	| object compiler methodInfo |
	
	object := ProtoObject ensureRingDefinitionIn: env.
	compiler := Compiler forClass: object.
	methodInfo := compiler compile: 'perform: aSymbol withArguments: anArray
	| species article |
	<primitive: PerformWithArguments>
	aSymbol isSymbol ifFalse: [
		species := aSymbol class name.
		article := species first isVowel ifTrue: [''an ''] ifFalse: [''a ''].
		^self error: ''perform: expects a Symbol, not '' , article , species].
	^self
		error: self class name , ''>>'' , aSymbol , '' does not expect ''
			, anArray size printString
			, '' arguments'''.


	
]

{ #category : #tests }
CompilerTest >> test_05 [
	| object compiler methodInfo |
	
	object := ProtoObject ensureRingDefinitionIn: env.
	compiler := Compiler forClass: object.
	methodInfo := compiler compile: 'foo self qux. ^12'.
	self assert: methodInfo astcodes size equals: 3.
	self assert: methodInfo astcodes first equals: MethodId.
	self assert: methodInfo astcodes second isArray.
	self assert: methodInfo astcodes third isArray.


	
]
