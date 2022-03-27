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
		'stack'
	],
	#category : #'Powerlang-Core-Execution-LMR'
}

{ #category : #'instance creation' }
RingBasedLMRBootstrapper class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

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
		initializeSymbolTable.
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
	| mapped |
	ringObj isPointers
		ifFalse: [ ^ self ].
	ringObj slots
		withIndexDo: [ :slot :index | 
			mapped := mapping at: slot ifAbsentPut: [ self newMapping: slot ].
			lmrObj basicAt: index put: mapped ]
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
	source classes values with: source metaclasses values do: [ :class :metaclass |
			mclass := mapping at: class.
			mmetaclass := mapping at: metaclass.
			self
				initializeBehavior: mclass spec: metaclass spec;
				initializeBehavior: mmetaclass spec: metaspec]
.	behaviors do: [:behavior | self				initializeBehavior: behavior spec: behaviorspec ]
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
		hash: aRingObject hash
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> image: aPowertalkRingImage [
	| index |
	source := aPowertalkRingImage.
	index := (source => #Class) allInstVarNames
		indexOf: 'instanceBehavior'.
	dest classInstanceBehaviorIndex: index.
	index := (source => #Class) allInstVarNames indexOf: 'name'.
	dest classNameIndex: index.
	index := (source => #Behavior) allInstVarNames indexOf: 'methods'.
	dest behaviorMethodDictionaryIndex: index.
	index := (source => #Behavior) allInstVarNames indexOf: 'next'.
	dest behaviorNextIndex: index.
	index := (source => #Behavior) allInstVarNames indexOf: 'class'.
	dest behaviorClassIndex: index.
	index := (source => #CompiledMethod) allInstVarNames indexOf: 'flags'.
	dest methodFlagsIndex: index
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> initialize [
	dest := PowertalkLMR new.
	mapping := IdentityDictionary new.
	behaviors := IdentityDictionary new.
	stack := OrderedCollection new
]

{ #category : #building }
RingBasedLMRBootstrapper >> initializeBehavior: anLMRHeapObject spec: anRGBehavior [
	| behavior |
	behavior := behaviors at: anRGBehavior.
	anLMRHeapObject behavior: behavior
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> initializeSymbolTable [
	| symbol table mapped |
	symbol := source classNamed: #Symbol.
	table := symbol classVariables at: #SymbolTable.
	mapped := mapping at: table.
	dest symbolTable: mapped
]

{ #category : #initialization }
RingBasedLMRBootstrapper >> instantiateMetaobjects [
	| ibehavior mclass mbehavior |
	source classes , source metaclasses
		do: [ :class | 
			ibehavior := class instanceBehavior.
			mclass := self newMapping: class.
			mbehavior := self newBehaviorMapping: ibehavior.
			behaviors at: class instanceSpec put: mbehavior.
			mapping
				at: class put: mclass;
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

{ #category : #initialization }
RingBasedLMRBootstrapper >> undermethods [
	^ (self => #ProtoObject) methods
		select: [ :m | m category = 'header access' ]
]
