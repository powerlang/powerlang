"
A base instance of VirtualSmalltalkImage only contains empty classes, nil, true, false,
and barely anything else. I am in charge of adding the Kernel module object to it and the
methods to the classes.
"
Class {
	#name : #RingBasedLMRBootstrapper,
	#superclass : #Object,
	#instVars : [
		'source',
		'dest',
		'nilObj',
		'trueObj',
		'falseObj',
		'behaviors',
		'mapping',
		'stack',
		'closureMethods'
	],
	#category : #'Powerlang-Core-Execution-LMR'
}

{ #category : #'instance creation' }
RingBasedLMRBootstrapper class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #initialization }
RingBasedLMRBootstrapper >> closureCompiledBlock: anSCompiledBlock [
	| method index spec species table s selector m |
	method := anSCompiledBlock method.
	selector := source newSymbol: method selector.
	index := method indexOf: anSCompiledBlock.
	spec := source specs at: method classBinding name.
	species := source speciesFor: spec.
	table := species instanceBehavior methods table.
	2 to: table size by: 2 do: [ :i | 
		s := table basicAt: i.
		s == selector
			ifTrue: [ m := table basicAt: i + 1.
				closureMethods add: m.
				^ m at: index ] ].
	^ self halt
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> convert [
	nilObj := self newMapping: source nil.
	trueObj := self newMapping: source true.
	falseObj := self newMapping: source false.
	dest nil: nilObj true: trueObj false: falseObj.
	self
		map: source nil to: nilObj;
		map: source true to: trueObj;
		map: source false to: falseObj;
		instantiateMetaobjects;
		fixBehaviors;
		convertBootstrapDictionaries;
		convertClosure;
		initializeSymbolTable;
		initializeRuntime.
	^ dest
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> convertBootstrapDictionaries [
	source bootstrapDictionaries do: [ :dict | self convertBootstrapDictionary: dict ]
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> convertBootstrapDictionary: aBootstrapDictionary [
	| class dict converted |
	class := source classes at: aBootstrapDictionary realSpec.
	dict := source runtime sendLocal: #new to: class.
	aBootstrapDictionary
		associations do: [ :assoc | 
			source runtime
				sendLocal: #at:put:
				to: dict
				with:
					{assoc key.
					assoc value} ].
	converted:= self newMapping: dict.
	self map: aBootstrapDictionary to: converted
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> convertClosure [
	| obj |
	[ stack isEmpty ]
		whileFalse: [ obj := stack removeFirst.
			self convertSlotsOf: obj key in: obj value ]
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> convertSlotsOf: ringObj in: lmrObj [
	| mapped block |
	ringObj isPointers
		ifFalse: [ ^ self ].
	ringObj slots
		withIndexDo: [ :slot :index | 
			mapped := mapping at: slot ifAbsentPut: [ self newMapping: slot ].
			lmrObj basicAt: index put: mapped ].
	ringObj isClosure ifFalse: [^self]. block := self closureCompiledBlock: ringObj block.
			mapped := mapping at: block ifAbsentPut: [ self newMapping: block ].
			lmrObj basicAt: 1 put: mapped
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> createLoadAction [
	^ nilObj
]

{ #category : #building }
RingBasedLMRBootstrapper >> fixBehaviors [
	| metaspec behaviorspec mclass mmetaclass |
	self
		initializeBehavior: nilObj spec: source => #UndefinedObject;
		initializeBehavior: trueObj spec: source => #True;
		initializeBehavior: falseObj spec: source => #False.
	metaspec := source => #Metaclass.
	behaviorspec := source => #Behavior.
	source classes values
		with: source metaclasses values
		do: [ :class :metaclass | 
			mclass := mapping at: class.
			mmetaclass := mapping at: metaclass.
			self
				initializeBehavior: mclass spec: metaclass instanceSpec;
				initializeBehavior: mmetaclass spec: metaspec ].
	behaviors
		do: [ :behavior | self initializeBehavior: behavior spec: behaviorspec ]
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> headerFor: aRingObject [
	| behavior |
	behavior := behaviors at: aRingObject spec ifAbsent: nil.
	^ LMRObjectHeader new
		behavior: behavior;
		bytes: aRingObject isBytes
			arrayed: aRingObject spec isVariable
			named: aRingObject spec instSize > 0;
		size: aRingObject size;
		hash: aRingObject headerHash
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> image: aPowertalkRingImage [
	| index |
	source := aPowertalkRingImage.
	index := (source => #Class) allInstVarNames indexOf: 'name'.
	dest classNameIndex: index.
	index := (source => #Class) allInstVarNames indexOf: 'module'.
	dest classModuleIndex: index.
	index := (source => #Metaclass) allInstVarNames indexOf: 'class'.
	dest metaclassInstanceClassIndex: index.
	index := (source => #Species) allInstVarNames
		indexOf: 'instanceVariables'.
	dest speciesIvarsIndex: index.
	index := (source => #Species) allInstVarNames indexOf: 'superclass'.
	dest speciesSuperclassIndex: index.
	index := (source => #Species) allInstVarNames
		indexOf: 'instanceBehavior'.
	dest speciesInstanceBehaviorIndex: index.
	index := (source => #Class) allInstVarNames indexOf: 'classVariables'.
	dest classClassVariablesIndex: index.
	index := (source => #Species) allInstVarNames indexOf: 'format'.
	dest speciesFormatIndex: index.
	index := (source => #Module) allInstVarNames indexOf: 'namespace'.
	dest moduleNamespaceIndex: index.
	index := (source => #Behavior) allInstVarNames indexOf: 'methods'.
	dest behaviorMethodDictionaryIndex: index.
	index := (source => #Behavior) allInstVarNames indexOf: 'next'.
	dest behaviorNextIndex: index.
	index := (source => #Behavior) allInstVarNames indexOf: 'class'.
	dest behaviorClassIndex: index.
	index := (source => #MethodDictionary) allInstVarNames
		indexOf: 'table'.
	dest dictionaryTableIndex: index.
	index := (source => #Closure) allInstVarNames indexOf: 'block'.
	dest closureBlockIndex: index.
	index := (source => #CompiledBlock) allInstVarNames indexOf: 'method'.
	dest blockMethodIndex: index.
	index := (source => #CompiledMethod) allInstVarNames
		indexOf: 'format'.
	dest methodFlagsIndex: index.
	index := (source => #CompiledMethod) allInstVarNames
		indexOf: 'astcodes'.
	dest methodAstcodesIndex: index.
	index := (source => #CompiledMethod) allInstVarNames indexOf: 'class'.
	dest methodClassBindingIndex: index.
	index := (source => #CompiledMethod) allInstVarNames
		indexOf: 'optimizedCode'.
	dest
		methodOptimizedCodeIndex: index;
		methodInstSize: (source => #CompiledMethod) allInstVarNames size
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> initialize [
	dest := PowertalkLMR new.
	mapping := IdentityDictionary new.
	behaviors := IdentityDictionary new.
	stack := OrderedCollection new.
	closureMethods := OrderedCollection new
]

{ #category : #building }
RingBasedLMRBootstrapper >> initializeBehavior: anLMRHeapObject spec: anRGBehavior [
	| behavior |
	behavior := behaviors at: anRGBehavior.
	anLMRHeapObject behavior: behavior
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> initializeEmulationOverrides [
	| classes |
	classes := source vmPrimitivesSpec allExtensionClasses.
	classes
		do: [ :class | 
			class methods do: [ :m | self override: class name with: m ].
			class metaclass methods
				do: [ :m | self override: class metaclass name with: m ] ].
	self removeBootstrapDictionaryNewOverride
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> initializeRuntime [
	| map symbols array method smi block metaclass kernel byteArray string closure behavior |
	symbols := Dictionary new.
	#(+ - < > <= >= = == not)
		do: [ :symbol | 
			map := source newSymbol: symbol.
			symbols at: symbol put: (mapping at: map) ].
	array := mapping at: (source classNamed: #Array).
	byteArray := mapping at: (source classNamed: #ByteArray).
	method := mapping at: (source classNamed: #CompiledMethod).
	block := mapping at: (source classNamed: #CompiledBlock).
	closure := mapping at: (source classNamed: #Closure).
	behavior := mapping at: (source classNamed: #Behavior).
	smi := mapping at: (source classNamed: #SmallInteger).
	string := mapping at: (source classNamed: #String).
	metaclass := mapping at: (source classNamed: #Metaclass).
	kernel := mapping at: source kernel.
	dest
		arrayClass: array;
		byteArrayClass: byteArray;
		methodClass: method;
		blockClass: block;
		closureClass: closure;
		behaviorClass_: behavior;
		smallIntegerClass: smi;
		stringClass: string;
		metaclassClass: metaclass;
		knownSymbols: symbols;
		wordSize: source wordSize;
		initializeInterpreter;
		kernel: kernel.
	self
		prepareClosuresForExecution;
		initializeEmulationOverrides
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> initializeSymbolTable [
	| symbol namespace cvars table mapped |
	symbol := source classNamed: #Symbol.
	namespace := symbol classVariables.
	cvars := namespace at: 1.
	table := cvars at: #SymbolTable.
	mapped := mapping at: table.
	dest symbolTable: mapped
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> instantiateMetaobjects [
	| ibehavior mspecies mbehavior |
	source classes , source metaclasses
		do: [ :species | 
			ibehavior := species instanceBehavior.
			mspecies := self newMapping: species.
			mbehavior := self newBehaviorMapping: ibehavior.
			behaviors at: species instanceSpec put: mbehavior.
			mapping
				at: species put: mspecies;
				at: ibehavior put: mbehavior ]
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> map: aRingObject to: anLMRObject [
	mapping at: aRingObject put: anLMRObject
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> newBehaviorMapping: aRingObject [
	| header mapped |
	header := self headerFor: aRingObject.
	mapped := LMRBehaviorObject new header: header; runtime: dest.
	stack add: aRingObject -> mapped.
	^ mapped
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> newCallback: aNativeCode bytesFrom: aByteArray [
	| code original behavior class |
	code := source newBytesFrom: aByteArray.
	original := code behavior.
	behavior := source newSlots: 'CallbackBehavior'.
	class := original slotNamed: 'class'.
	behavior
		slotNamed: 'class' put: class;
		methods: original methods;
		next: source nil;
		optimizedCode: aNativeCode.
	code behavior: behavior.
	^ code
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> newMapping: aRingObject [
	| header mapped |
	aRingObject isImmediate
		ifTrue: [ ^ LMRSmallInteger new value: aRingObject value ].
	header := self headerFor: aRingObject.
	aRingObject isBytes
		ifTrue: [ ^ LMRByteObject new
				header: header;
				bytes: aRingObject bytes ].
	mapped := LMRSlotObject new header: header.
	stack add: aRingObject -> mapped.
	^ mapped
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> newMethod: anAstcode selector: aSymbol in: classname format: anInteger literals: anArray [
	| method astcodes class selector format |
	method := source newSlots: 'CompiledMethod'.
	astcodes := self transferAstcodesFrom: anAstcode.
	class := source classNamed: classname.
	selector := source newSymbol: aSymbol.
	format := source newInteger: anInteger.
	method
		optimizedCode: source nil;
		astcodes: astcodes;
		class: class;
		selector: selector;
		format: format;
		source: source nil.
	^ method
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> override: classname with: rgMethod [
	| spec species behavior smethod rmethod lmrmethod selector |
	spec := source specs at: classname.
	species := (source speciesFor: spec).
	behavior := mapping at: species instanceBehavior.
	smethod := (SCompiler forClass: species) compile: rgMethod sourceCode.
	rmethod := source transferMethod: smethod in: species. 
	lmrmethod := self newMapping: rmethod.
	self convertClosure.
	selector := dest symbolFromLocal: rgMethod selector.
	dest override: behavior -> selector with: lmrmethod
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> prepareClosuresForExecution [
	| mapped |
	closureMethods
		do: [ :method | mapped := mapping at: method. dest interpreter prepareForExecution: mapped ]
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> removeBootstrapDictionaryNewOverride [
	| spec species behavior selector |
	spec := source specs at: #'Namespace class'.
	species := source speciesFor: spec.
	behavior := mapping at: species instanceBehavior.
	selector := dest symbolFromLocal: #new.
	dest removeOverride: behavior -> selector
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> source: aPowertalkRingImage [
	source := aPowertalkRingImage
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> transferArrayDeep: anArray [
	| copy transferred |
	copy := source newSlots: 'Array' sized: anArray size.
	anArray
		withIndexDo: [ :elem :i | 
			transferred := elem isInteger
				ifTrue: [ source newInteger: elem ]
				ifFalse: [ self transferArrayDeep: elem ].
			copy at: i put: transferred ].
	^ copy
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> transferAstcodesFrom: anArray [
	| copy transferred |
	copy := source newSlots: 'Array' sized: anArray size.
	anArray
		withIndexDo: [ :elem :i | 
			transferred := elem isInteger
				ifTrue: [ source newInteger: elem ]
				ifFalse: [ self transferAstcodesFrom: elem ].
			copy at: i put: transferred ].
	^ copy
]
