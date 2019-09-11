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
	self assert: (methodInfo astcodes second) equals: PrimitiveId.
	self assert: (methodInfo literals at: methodInfo astcodes third) equals: 'Perform'
	
]

{ #category : #tests }
CompilerTest >> test_02 [
	| compiler methodInfo |
	
	compiler := Compiler forClass: (Object ensureRingDefinitionIn: env).
	methodInfo := compiler compile: 'meaningOfLife ^42'.
	self assert: (methodInfo astcodes first) equals: MethodId.
	
]
