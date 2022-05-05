Class {
	#name : #PowertalkLMR,
	#superclass : #PowertalkRuntime,
	#instVars : [
		'kernel',
		'wordSize',
		'behaviorNextIndex',
		'behaviorMethodDictionaryIndex',
		'behaviorClassIndex',
		'classNameIndex',
		'methodFlagsIndex',
		'symbolTable',
		'maxSMI',
		'minSMI',
		'knownSymbols',
		'arrayClass',
		'metaclassClass',
		'speciesInstanceBehaviorIndex',
		'speciesFormatIndex',
		'methodOptimizedCodeIndex',
		'methodAstcodesIndex',
		'methodInstSize',
		'methodClassBindingIndex',
		'speciesSuperclassIndex',
		'methodClass',
		'smallIntegerClass',
		'blockClass',
		'speciesIvarsIndex',
		'dictionaryTableIndex',
		'classClassVariablesIndex',
		'metaclassInstanceClassIndex',
		'classModuleIndex',
		'moduleNamespaceIndex'
	],
	#pools : [
		'SCompiledBlockFlags',
		'SCompiledMethodFlags'
	],
	#category : #'Powerlang-Core-Execution-LMR'
}

{ #category : #initialization }
PowertalkLMR >> arrayClass: anLMRObject [
	arrayClass := anLMRObject 
]

{ #category : #initialization }
PowertalkLMR >> behaviorClass: anLMRObject [
	^ anLMRObject slotAt: behaviorClassIndex
]

{ #category : #initialization }
PowertalkLMR >> behaviorClassIndex: anInteger [
	behaviorClassIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> behaviorMethodDictionary: anLMRObject [
	^ anLMRObject slotAt: behaviorMethodDictionaryIndex
]

{ #category : #initialization }
PowertalkLMR >> behaviorMethodDictionaryIndex: anInteger [
	behaviorMethodDictionaryIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> behaviorNext: anLMRObject [
	^ anLMRObject slotAt: behaviorNextIndex
]

{ #category : #initialization }
PowertalkLMR >> behaviorNextIndex: anInteger [
	behaviorNextIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> behaviorOf: anLMRObject [
	^anLMRObject isImmediate ifTrue: [ self smallIntegerBehavior ] ifFalse: [anLMRObject behavior]
]

{ #category : #initialization }
PowertalkLMR >> blockArgumentCount: anLMRObject [
	| flags |
	flags := anLMRObject slotAt: methodFlagsIndex.
	^ flags value bitsAt: BlockArgCount
]

{ #category : #initialization }
PowertalkLMR >> blockClass: anLMRObject [
	blockClass := anLMRObject
]

{ #category : #initialization }
PowertalkLMR >> blockTempCount: anLMRObject [
	| flags |
	flags := anLMRObject slotAt: methodFlagsIndex.
	^ flags value bitsAt: BlockTempCount
]

{ #category : #initialization }
PowertalkLMR >> classClassVariablesIndex: anInteger [
	classClassVariablesIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> classIvars: anLMRObject [
	^ anLMRObject slotAt: speciesIvarsIndex
]

{ #category : #initialization }
PowertalkLMR >> classModule: class [
	^ class slotAt: classModuleIndex
]

{ #category : #initialization }
PowertalkLMR >> classModuleIndex: anInteger [
	classModuleIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> className: anLMRObject [
	^ anLMRObject slotAt: classNameIndex
]

{ #category : #initialization }
PowertalkLMR >> classNameIndex: anInteger [
	classNameIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> dictionaryTable: anLMRObject [
	^anLMRObject slotAt: dictionaryTableIndex
]

{ #category : #initialization }
PowertalkLMR >> dictionaryTableIndex: anInteger [
	dictionaryTableIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> doLookup: aSymbol startingAt: aBehavior [
	| behavior m |
	behavior := aBehavior.
	[ m := self methodFor: aSymbol in: behavior.
	m ifNotNil: [ ^m ].
	behavior := self behaviorNext: behavior.
	behavior != nilObj ] whileTrue.
	^ nil
]

{ #category : #initialization }
PowertalkLMR >> isBlock: compiledCode [
	^ (self behaviorClass: compiledCode behavior) ==
	blockClass 
]

{ #category : #initialization }
PowertalkLMR >> isMetaclass: anLMRObject [
	^ (self speciesFor: anLMRObject) == metaclassClass
]

{ #category : #initialization }
PowertalkLMR >> knownSymbols: associations [
	knownSymbols := Dictionary withAll: associations
]

{ #category : #initialization }
PowertalkLMR >> loadAssociationValue: association [
	^ association slotAt: 2.

]

{ #category : #initialization }
PowertalkLMR >> lookupAssociationFor: aSymbol in: dictionary [
	|  table assoc key |
	table := self dictionaryTable: dictionary.
	2 to: table size do: [ :index | 
		assoc := table slotAt: index.
		assoc == nilObj ifFalse: [key := assoc slotAt: 1. key == aSymbol
			ifTrue: [ ^ assoc] ]].
	^ nil
	
]

{ #category : #initialization }
PowertalkLMR >> metaclassClass: anLMRObject [
	metaclassClass := anLMRObject
]

{ #category : #initialization }
PowertalkLMR >> metaclassInstanceClass: anLMRObject [
	^ anLMRObject slotAt: metaclassInstanceClassIndex
]

{ #category : #initialization }
PowertalkLMR >> metaclassInstanceClassIndex: anInteger [
	metaclassInstanceClassIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> method: method literalAt: index [
	^ method slotAt: methodInstSize + index
]

{ #category : #initialization }
PowertalkLMR >> methodArgumentCount: anLMRObject [
	| flags |
	flags := anLMRObject slotAt: methodFlagsIndex.
	^ flags value bitsAt: ArgCount
]

{ #category : #initialization }
PowertalkLMR >> methodAstcodes: anLMRObject [
	^ anLMRObject slotAt: methodAstcodesIndex
]

{ #category : #initialization }
PowertalkLMR >> methodAstcodesIndex: anInteger [
	methodAstcodesIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> methodClass: anLMRObject [
	methodClass := anLMRObject
]

{ #category : #initialization }
PowertalkLMR >> methodClassBinding: anLMRObject [
	^ anLMRObject slotAt: methodClassBindingIndex
]

{ #category : #initialization }
PowertalkLMR >> methodClassBindingIndex: anInteger [
	methodClassBindingIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> methodEnvironmentSize: anLMRObject [
	| flags |
	flags := anLMRObject slotAt: methodFlagsIndex.
	^ flags value bitsAt: EnvCount
]

{ #category : #initialization }
PowertalkLMR >> methodFlagsIndex: anInteger [
	methodFlagsIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> methodFor: aSymbol in: behavior [
	| md table |
	md := self behaviorMethodDictionary: behavior.
	table := self dictionaryTable: md.
	2 to: table size by: 2 do: [:index | (table slotAt: index) == aSymbol ifTrue: [^table slotAt: index + 1]].
	^ nil
]

{ #category : #initialization }
PowertalkLMR >> methodInstSize: anInteger [
	methodInstSize := anInteger
]

{ #category : #initialization }
PowertalkLMR >> methodOptimizedCode: anLMRObject [
	^ anLMRObject slotAt: methodOptimizedCodeIndex
]

{ #category : #initialization }
PowertalkLMR >> methodOptimizedCode: anLMRObject put: anObject [
	^ anLMRObject slotAt: methodOptimizedCodeIndex put: anObject
]

{ #category : #initialization }
PowertalkLMR >> methodOptimizedCodeIndex: anInteger [
	methodOptimizedCodeIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> methodTempCount: anLMRObject [
	| flags |
	flags := anLMRObject slotAt: methodFlagsIndex.
	^ flags value bitsAt: TempCount
]

{ #category : #initialization }
PowertalkLMR >> moduleNamespace: anLMRObject [
	^anLMRObject slotAt: moduleNamespaceIndex

]

{ #category : #initialization }
PowertalkLMR >> moduleNamespaceIndex: anInteger [

	moduleNamespaceIndex := anInteger
]

{ #category : #validating }
PowertalkLMR >> nativizeForLMR [
	| script |
	script := 'nativizeForLMR
	lmr := Kernel loadModule: ''Nativization/LMR''. 
	lmr nativizeLoadedModules'.
	self
		compile: script in: #UndefinedObject;
		sendLocal: #nativizeForLMR to: nilObj
]

{ #category : #initialization }
PowertalkLMR >> newArraySized: anInteger [
	| behavior header |
	behavior := self speciesInstanceBehavior: arrayClass.
	header := LMRObjectHeader new
		behavior: behavior;
		bytes: false arrayed: true named: false;
		size: anInteger;
		hash: 0.
	^ LMRSlotObject new header: header
]

{ #category : #initialization }
PowertalkLMR >> newCompiledMethod [
	| behavior header method |
	behavior := self speciesInstanceBehavior: methodClass.
	header := LMRObjectHeader new
		behavior: behavior;
		bytes: false arrayed: true named: false;
		size: methodInstSize;
		hash: 0.
	method := LMRSlotObject new header: header.
	method slotAt: methodFlagsIndex put: (self newInteger: 0).
	^method
]

{ #category : #initialization }
PowertalkLMR >> newEnvironmentSized: anInteger [
	^ self newArraySized: anInteger
]

{ #category : #initialization }
PowertalkLMR >> newInteger: anInteger [
	anInteger > maxSMI
		ifTrue: [ ^ self newLargePositiveInteger: anInteger ].
	anInteger < minSMI
		ifTrue: [ ^ self newLargeNegativeInteger: anInteger ].

	^ LMRSmallInteger new value: anInteger
]

{ #category : #initialization }
PowertalkLMR >> newSlots: class [
	^self newSlots: class size: 0
]

{ #category : #initialization }
PowertalkLMR >> newSlots: class size: anInteger [
	| ivars behavior header |
	ivars := self speciesInstanceSize: class.
	behavior := self speciesInstanceBehavior: class.
	header := LMRObjectHeader new
		behavior: behavior;
		bytes: false arrayed: false named: true;
		size: ivars + anInteger;
		hash: 0.
	^ LMRSlotObject new header: header
]

{ #category : #initialization }
PowertalkLMR >> newSmallInteger: anInteger [
	^ LMRSmallInteger new value: anInteger
]

{ #category : #initialization }
PowertalkLMR >> nil: n true: t false: f [
	nilObj := n.
	trueObj := t.
	falseObj := f
]

{ #category : #initialization }
PowertalkLMR >> print: anLMRObject on: aStream [
	| species name |
	species := self behaviorClass: anLMRObject behavior.
	name := self speciesLocalName: species.
	name = 'Symbol'
		ifTrue: [ ^ aStream nextPutAll: '<#' , anLMRObject asLocalString , '>' ].
	aStream
		nextPut: $<;
		nextPutAll: name withArticle;
		nextPut: $>
]

{ #category : #initialization }
PowertalkLMR >> printBehavior: anLMRBehavior on: aStream [
	| species name |
	species := self behaviorClass: anLMRBehavior.
	name := self speciesLocalName: species.
	aStream
		nextPutAll: '<' , name , ' instanceBehavior>'
]

{ #category : #validating }
PowertalkLMR >> readKernel [
	| script |
	script := 'readKernel
	| reader |
	reader := Kernel loadModule: ''ImageSegment/Reader''. 
	segment := reader read: ''build/Kernel.ims''.
	^segment'.
	self
		compile: script in: #UndefinedObject;
		sendLocal: #readKernel to: nilObj
]

{ #category : #initialization }
PowertalkLMR >> sexpressionsOf: method [
	| expressions astcodes decoder |
	expressions := self methodOptimizedCode: method.
	expressions == nilObj ifFalse: [ ^expressions ].
	astcodes := self methodAstcodes: method.
	decoder := AstcodeDecoder new
		stream: astcodes bytes readStream;
		method: method; builder: self.
	expressions := decoder decodeMethod.
	self methodOptimizedCode: method put: expressions.
	^expressions
]

{ #category : #initialization }
PowertalkLMR >> smallIntegerBehavior [
	^self speciesInstanceBehavior: smallIntegerClass
]

{ #category : #initialization }
PowertalkLMR >> smallIntegerClass: anLMRObject [
	smallIntegerClass := anLMRObject
]

{ #category : #initialization }
PowertalkLMR >> speciesClassVariables: anLMRObject [
	| class |
	class := self speciesInstanceClass: anLMRObject.
	^class slotAt: classClassVariablesIndex
]

{ #category : #initialization }
PowertalkLMR >> speciesFor: anLMRObject [
	| behavior |
	behavior := self behaviorOf: anLMRObject.
	^self behaviorClass: behavior.


]

{ #category : #initialization }
PowertalkLMR >> speciesFormatIndex: anInteger [
	speciesFormatIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> speciesInstanceBehavior: anLMRObject [
	^anLMRObject slotAt: speciesInstanceBehaviorIndex
]

{ #category : #initialization }
PowertalkLMR >> speciesInstanceBehaviorIndex: anInteger [
	speciesInstanceBehaviorIndex := anInteger 
]

{ #category : #initialization }
PowertalkLMR >> speciesInstanceClass: anLMRObject [
	| metaclass |
	metaclass := self isMetaclass: anLMRObject.
	^ metaclass
		ifTrue: [ self metaclassInstanceClass: anLMRObject ]
		ifFalse: [ anLMRObject ]
]

{ #category : #initialization }
PowertalkLMR >> speciesInstanceSize: anLMRObject [
	^ (anLMRObject slotAt: speciesFormatIndex) bitAnd: 16r7F.
]

{ #category : #initialization }
PowertalkLMR >> speciesIvarsIndex: anInteger [
	speciesIvarsIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> speciesLocalName: species [
	| name class |
	(self isMetaclass: species) ifFalse: [
		name :=self className: species.
		^name asLocalString].
	
	class := self metaclassInstanceClass: species. 
	name := self className: class.
	^ name asLocalString, ' class'
]

{ #category : #initialization }
PowertalkLMR >> speciesModule: species [
	| class |
	(self isMetaclass: species)
		ifFalse: [ ^ self classModule: species ].
	class := self metaclassInstanceClass: species.
	^ self classModule: class
]

{ #category : #initialization }
PowertalkLMR >> speciesSuperclass: anLMRObject [
	^ anLMRObject slotAt: speciesSuperclassIndex
]

{ #category : #initialization }
PowertalkLMR >> speciesSuperclassIndex: anInteger [
	speciesSuperclassIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> staticBindingForIvar: aSymbol in: receiver [
	| class all slots bytes |
	
	class := self speciesFor: receiver.
	all := Array new: 0.
	[ class != nilObj ]
		whileTrue: [ slots := self classIvars: class.
			slots == nilObj
				ifFalse: [ all := slots slots , all ].
			class := self speciesSuperclass: class ].
	bytes := aSymbol bytes.
	all withIndexDo: [ :ivar :index | ivar bytes = bytes ifTrue: [ ^ index ] ].
	^0
]

{ #category : #initialization }
PowertalkLMR >> superBehaviorOf: class [
	| superclass |
	superclass := self speciesSuperclass: class.
	^ self speciesInstanceBehavior: superclass
]

{ #category : #initialization }
PowertalkLMR >> symbolFromLocal: aSymbol [
	| bytes table symbol |
	knownSymbols at: aSymbol ifPresent: [ :s | ^s ].
	bytes := aSymbol asByteArray, #[0].
	table := symbolTable slotAt: 2.
	2 to: table size do: [:i | symbol := table slotAt: i. symbol == nilObj ifFalse: [symbol bytes = bytes ifTrue: [ ^symbol ] ] ].
	self error: 'symbol not found'
]

{ #category : #initialization }
PowertalkLMR >> symbolTable: anLMRObject [
	symbolTable:= anLMRObject
]

{ #category : #initialization }
PowertalkLMR >> wordSize [
	^wordSize
]

{ #category : #initialization }
PowertalkLMR >> wordSize: anInteger [
	wordSize := anInteger.
	maxSMI := (1 bitShift: wordSize * 8 - 2) - 1.
	minSMI := maxSMI negated - 1
]

{ #category : #validating }
PowertalkLMR >> writeKernelAt: anInteger [
	| script |
	script := 'writeKernel
	| writer |
	writer := Kernel loadModule: ''ImageSegment/Writer''. 
	writer write: Kernel at: ' , anInteger asString
		, ' to: ''build/Kernel.ims'''.
	self
		compile: script in: #UndefinedObject;
		sendLocal: #writeKernel to: nilObj
]
