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
RingBasedLMRBootstrapper >> => aSymbol [
	| classmap |
	classmap := source classNamed: aSymbol.
	^mapping at: classmap
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
RingBasedLMRBootstrapper >> createNewBlock: sblock [
	| format transferred method literal tliteral |
	format := dest newInteger: sblock format.
	transferred := dest
		sendLocal: #new:
		to: self => #CompiledBlock
		with: {(dest newInteger: sblock size)}.
	method := mapping at: sblock method.
	dest
		sendLocal: #format: to: transferred with: {format};
		sendLocal: #method: to: transferred with: {method}.
	1 to: sblock size do: [ :i | 
		literal := sblock at: i.
		tliteral := self transferLiteral: literal.
		transferred at: i put: tliteral ].
	^ transferred
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> createNewClassFrom: spec [
	| superclass metaclass class instanceBehavior classBehavior ivars |
	superclass := self => spec superclass name.
	metaclass := dest
		sendLocal: #newSubclassOf:
		to: self => #Class
		with: {superclass}.
	class := dest sendLocal: #instanceClass to: metaclass.
	dest sendLocal: #name: to: class with: {(dest newString: spec name)}.
	ivars := self transferLiteral: spec instVarNames.
	dest sendLocal: #instVarNames: to: class with:  { ivars }.
	instanceBehavior := dest sendLocal: #instanceBehavior to: class.
	classBehavior := dest sendLocal: #instanceBehavior to: metaclass.
	behaviors
		at: spec put: instanceBehavior;
		at: spec metaclass put: classBehavior.
	spec methods do: [ :m | self createNewMethod: m in: class ].
	spec metaclass methods
		do: [ :m | self createNewMethod: m in: metaclass ].
	^ class
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> createNewMethod: m in: species [
	| smethod size transferred astcodes selector format tliteral md |
	smethod := SCompiler new compile: m sourceCode.
	smethod classBinding: species.
	size := dest newInteger: smethod size.
	transferred := dest
		sendLocal: #new:
		to: self => #CompiledMethod
		with: {size}.
	mapping at: smethod put: transferred.
	astcodes := dest newByteArray: smethod astcodes.
	selector := dest addSymbol: smethod selector.
	format := dest newInteger: smethod format.
	dest
		sendLocal: #astcodes: to: transferred with: {astcodes};
		sendLocal: #classBinding: to: transferred with: {species};
		sendLocal: #selector: to: transferred with: {selector};
		sendLocal: #format: to: transferred with: {format}.
	smethod withIndexDo: [ :literal :i | 
		tliteral := self transferLiteral: literal.
		transferred at: i put: tliteral ].
	md := dest sendLocal: #methodDictionary to: species.
	dest
		sendLocal: #at:put:
		to: md
		with:
			{selector.
			transferred}.
	^ transferred
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> createNewModule: spec with: classes [
	| behavior class module |
	behavior := behaviors at: spec.
	class := dest behaviorClass: behavior.
	module := dest sendLocal: #new to: class.
	dest sendLocal: #bindKernelExports to: module.
	classes
		do: [ :c | 
			dest
				sendLocal: #addClass: to: module with: {c};
				sendLocal: #module: to: c with: {module} ].
	^ module
]

{ #category : #paths }
RingBasedLMRBootstrapper >> findModulePath: moduleName [
	| parts path candidates dir |
	parts := '.' split: moduleName.
	path := ('/' join: parts) asFileReference path.
	candidates := self rootDirectory allDirectoriesMatching: parts first.
	candidates do: [:match | 
		dir := match parent / path pathString.
		dir exists ifTrue: [ 	^dir relativeTo: self rootDirectory asAbsolute ]].
	self error: 'module ' , moduleName , ' couldn''t be found'

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
	dest bootstrapper: self.
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
	index := (source => #Class) allInstVarNames indexOf: 'namespaces'.
	dest classNamespacesIndex: index.
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
	| map symbols array method smi block metaclass kernel byteArray string closure behavior lpi lni |
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
	lpi := mapping at: (source classNamed: #LargePositiveInteger).
	lni := mapping at: (source classNamed: #LargeNegativeInteger).
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
		largePositiveIntegerClass: lpi;
		largeNegativeIntegerClass: lni;
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
	| symbol namespaces cvars table mapped |
	symbol := source classNamed: #Symbol.
	namespaces := symbol namespaces.
	cvars := namespaces at: 1.
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
RingBasedLMRBootstrapper >> loadBootstrapModule [
	| spec classes moduleSpec bootstrapper |
	spec := PowertalkRingModule lmrBootstrapperSpec.
	classes := spec allClasses.
	classes := classes
		collect: [ :classSpec | self createNewClassFrom: classSpec ].
	moduleSpec := spec at: #BootstrapModule.
	bootstrapper := self createNewModule: moduleSpec with: classes.
	dest sendLocal: #loadRequiredModules to: bootstrapper.
	^bootstrapper
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> loadModule: symbol [
	| spec classes moduleSpec module |
	spec := self readModuleSpec: symbol.
	classes := spec allClasses.
	classes := classes
		collect: [ :classSpec | self createNewClassFrom: classSpec ].
	moduleSpec := spec at: symbol , #Module.
	moduleSpec ifNil: [moduleSpec := source specs at: #Module].
	module := self createNewModule: moduleSpec with: classes.
	dest sendLocal: #loadRequiredModules to: module.
	^ module
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

{ #category : #paths }
RingBasedLMRBootstrapper >> outputDirectory [
	^ self rootDirectory / 'build' 
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
RingBasedLMRBootstrapper >> readModuleSpec: aSymbol [
	| path |
	path := self findModulePath: aSymbol.
	^PowertalkRingModule readSpec: aSymbol at: path parent

	
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
RingBasedLMRBootstrapper >> result [
	^dest
]

{ #category : #paths }
RingBasedLMRBootstrapper >> rootDirectory [
	^ './specs/bee-dmr' asFileReference
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> source: aPowertalkRingImage [
	source := aPowertalkRingImage
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> transferLiteral: anObject [
	| transferred |
	anObject isInteger
		ifTrue: [ ^ dest newInteger: anObject ].
	anObject class == ByteArray
		ifTrue: [ ^ dest newByteArray: anObject ].
	anObject isSymbol
		ifTrue: [ ^ dest addSymbol: anObject ].
	anObject isString
		ifTrue: [ ^ dest newString: anObject ].
	anObject class == SCompiledBlock
		ifTrue: [ ^self createNewBlock: anObject ].
	anObject class == Array ifTrue: [ 
		transferred := anObject collect: [ :o | self transferLiteral: o ].
		^dest newArray: transferred ].
	anObject isCharacter
		ifTrue: [ ^ dest newCharacter: anObject ].
	self ASSERT: false
]
