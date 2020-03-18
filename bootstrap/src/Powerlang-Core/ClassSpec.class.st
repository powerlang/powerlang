Class {
	#name : #ClassSpec,
	#superclass : #SpeciesSpec,
	#instVars : [
		'name',
		'supername',
		'classVariables',
		'sharedPools',
		'metaclass'
	],
	#category : #'Powerlang-Core-Specification'
}

{ #category : #'instance creation' }
ClassSpec class >> from: aClass in: aCodeCorpus [
	^self new module: aCodeCorpus; fromClass: aClass
]

{ #category : #'instance creation' }
ClassSpec class >> new [ 
	self halt
]

{ #category : #accessing }
ClassSpec >> allMethods [
	^methods & metaclass methods
]

{ #category : #accessing }
ClassSpec >> allSuperclassesDo: aBlock [
	| s |
	supername isNil ifTrue: [^self].
	s := self superclass.
	aBlock value: s.
	s allSuperclassesDo: aBlock
]

{ #category : #accessing }
ClassSpec >> classPool [
	^classVariables
]

{ #category : #accessing }
ClassSpec >> classVarNamed: aString put: anObject [
	^classVariables at: aString put: anObject
]

{ #category : #accessing }
ClassSpec >> classVarNames [
	^classVariables keys
]

{ #category : #accessing }
ClassSpec >> compiledMethodFor: selector [
	methods detect: [ :m | m selector = selector] ifFound: [ :m | ^m ].
	^self superclass ifNotNil: [:s | s compiledMethodFor: selector ]
]

{ #category : #accessing }
ClassSpec >> configureCompiler: aCompiler [
	
]

{ #category : #accessing }
ClassSpec >> fromClass: aClass [
	name := aClass name.
	supername := aClass superclass asString.
	instanceVariables := aClass instVarNames asOrderedCollection.
	classVariables := aClass classPool.
	sharedPools := aClass sharedPools.
	methods := OrderedCollection new.
	metaclass := MetaclassSpec new classBinding: self; module: module
]

{ #category : #accessing }
ClassSpec >> fromTonel: definitions within: aProjectSpec [
	| declaration method |
	declaration := definitions first.
	instanceVariables := declaration instVarNames.
	supername := declaration superclassName.
	supername = 'nil' ifTrue: [ supername := nil ].
	metaclass := MetaclassSpec new
		classBinding: self;
		module: module;
		instVarNames: declaration classInstVarNames.
	classVariables := Dictionary new.
	declaration classVarNames
		do: [ :var | classVariables at: var put: nil ].
	sharedPools := declaration classVarNames.
	methods := OrderedCollection new.
	definitions asOrderedCollection
		removeFirst;
		do: [ :def | 
			method := MethodSpec fromDef: def in: module.
			methods add: method ]
]

{ #category : #accessing }
ClassSpec >> instanceSide [
	^self
]

{ #category : #accessing }
ClassSpec >> loadMethodsFrom: aClass [
	| meta |
	methods := aClass methodDictionary values asOrderedCollection
		collect: [:m | MethodSpec from: m in: module].
	meta := aClass class methodDictionary values asOrderedCollection
		collect: [:m | MethodSpec from: m in: module].
	metaclass methods: meta
]

{ #category : #accessing }
ClassSpec >> localPools [
	^classVariables select: [:c | c isKindOf: PoolDictionary]
]

{ #category : #accessing }
ClassSpec >> metaMethods [
	^metaclass methods
]

{ #category : #accessing }
ClassSpec >> metaclass [
	^metaclass
]

{ #category : #accessing }
ClassSpec >> name [
	^name
]

{ #category : #accessing }
ClassSpec >> name: aString [
	name := aString
]

{ #category : #printing }
ClassSpec >> printOn: aStream [
	aStream nextPutAll: '<' , name , '>'
]

{ #category : #accessing }
ClassSpec >> sharedPools [
	^sharedPools
]

{ #category : #accessing }
ClassSpec >> superclass [
	supername ifNil: [ ^nil ].
	^module
		resolveClass: supername
		ifAbsent: [module module at: supername asSymbol]
]

{ #category : #accessing }
ClassSpec >> supername [
	^supername
]

{ #category : #accessing }
ClassSpec >> supername: aString [
	supername := aString
]
