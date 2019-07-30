Class {
	#name : #MethodSpec,
	#superclass : #Object,
	#instVars : [
		'selector',
		'class',
		'source',
		'category',
		'module',
		'ast'
	],
	#category : #'Powerlang-Core-Specification'
}

{ #category : #'instance creation' }
MethodSpec class >> from: aCompiledMethod in: aCodeCorpus [
	^self new module: aCodeCorpus; loadFromMethod: aCompiledMethod
]

{ #category : #comparing }
MethodSpec >> = aMethodSpec [
	^aMethodSpec class = self class
		and: [aMethodSpec selector == selector]
		and: [aMethodSpec classBinding = class]
]

{ #category : #converting }
MethodSpec >> ast [
	^ast ifNil: [ast := Compiler parseMethod: source in: class]
]

{ #category : #accessing }
MethodSpec >> category [
	^self isExtension
		ifTrue: ['*' , (module name readStream upToLast: $-)]
		ifFalse: [category]
]

{ #category : #accessing }
MethodSpec >> classBinding [
	^class
]

{ #category : #accessing }
MethodSpec >> classname [
	^class name
]

{ #category : #comparing }
MethodSpec >> hash [
	^class name hash hashWith: selector
]

{ #category : #testing }
MethodSpec >> isExtension [
	^class isExtension
]

{ #category : #accessing }
MethodSpec >> loadFromMethod: aCompiledMethod [
	selector := aCompiledMethod selector.
	class := module resolveClass: aCompiledMethod classBinding name.
	source := aCompiledMethod sourceCode.
	category := aCompiledMethod category
]

{ #category : #accessing }
MethodSpec >> module [
	^module
]

{ #category : #accessing }
MethodSpec >> module: aModuleSpec [
	module := aModuleSpec
]

{ #category : #printing }
MethodSpec >> printOn: aStream [
	aStream nextPutAll: class name asString , '>>#' , selector asString
]

{ #category : #services }
MethodSpec >> resolveClass [
	^module resolveClass: class name
]

{ #category : #accessing }
MethodSpec >> selector [
	^selector
]

{ #category : #accessing }
MethodSpec >> selector: aSymbol [
	selector := aSymbol
]

{ #category : #accessing }
MethodSpec >> source [
	^source
]

{ #category : #accessing }
MethodSpec >> source: aString [
	source := aString.
	ast := nil
]

{ #category : #accessing }
MethodSpec >> sourceCode [
	^source
]

{ #category : #accessing }
MethodSpec >> usesInstanceVariableNamed: aString [
	^(self ast variableNamed: aString) notNil
]
