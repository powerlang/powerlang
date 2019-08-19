Class {
	#name : #MethodSpec,
	#superclass : #Object,
	#instVars : [
		'selector',
		'class',
		'source',
		'category',
		'module',
		'compiled'
	],
	#category : #'Powerlang-Core-Specification'
}

{ #category : #'instance creation' }
MethodSpec class >> from: aCompiledMethod in: aCodeCorpus [
	^self new module: aCodeCorpus; loadFromMethod: aCompiledMethod
]

{ #category : #'instance creation' }
MethodSpec class >> fromDef: anMCMethodDefinition in: aCodeCorpus [
	^self new module: aCodeCorpus; loadFromDefinition: anMCMethodDefinition
]

{ #category : #comparing }
MethodSpec >> = aMethodSpec [
	^aMethodSpec class = self class
		and: [aMethodSpec selector == selector]
		and: [aMethodSpec classBinding = class]
]

{ #category : #converting }
MethodSpec >> ast [
	^Compiler parse: source in: class

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

{ #category : #accessing }
MethodSpec >> initializeLocalPool [
	| ast pool assignment cascade elements |
	ast := self ast.
	assignment := ast statements detect: [ :s | 
		s isAssign and: [ s assignees first binding isClassVariable ] ].
	cascade := ast statements detect: [ :s | 
		s isCascade and: [ s receiver binding isClassVariable ] ].
	elements := cascade messages select: [ :s | s symbol = #at:put: ].
	pool := PoolDictionary new.
	elements 	do: [ :s | pool at: s arguments first value put: s arguments second value ].
	self resolveClass classVarNamed: assignment assignees first name put: pool 
]

{ #category : #testing }
MethodSpec >> isExtension [
	^class isExtension
]

{ #category : #accessing }
MethodSpec >> loadFromDefinition: anMCMethodDefinition [
	selector := anMCMethodDefinition selector.
	class := module resolveClass: anMCMethodDefinition className.
	source := anMCMethodDefinition source.
	category := anMCMethodDefinition category.
	category = 'pool initialization' ifTrue: [ self initializeLocalPool ]
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

{ #category : #converting }
MethodSpec >> sexpressions [
	compiled ifNil: [compiled := Compiler compile: source in: class].
	^compiled sexpressions
]

{ #category : #accessing }
MethodSpec >> source [
	^source
]

{ #category : #accessing }
MethodSpec >> source: aString [
	source := aString.
	compiled := nil
]

{ #category : #accessing }
MethodSpec >> sourceCode [
	^source
]

{ #category : #accessing }
MethodSpec >> usesInstanceVariableNamed: aString [
	^(self ast variableNamed: aString) notNil
]
