Class {
	#name : #SmalltalkBootstrapper,
	#superclass : #Object,
	#instVars : [
		'index',
		'classes',
		'methods',
		'objects',
		'identityMap',
		'symbols',
		'nilObj',
		'trueObj',
		'falseObj',
		'environment',
		'emulator',
		'nativizer',
		'globals',
		'lookup',
		'lookupSuper',
		'invoke',
		'writeBarrier',
		'hash',
		'cvarMap',
		'wordSize',
		'maxSMI',
		'minSMI',
		'module',
		'smalltalk'
	],
	#classVars : [
		'Spec'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #accessing }
SmalltalkBootstrapper class >> fromSpec [
	^ self new
		spec: self spec
]

{ #category : #accessing }
SmalltalkBootstrapper class >> newSpec [
	| current repo spec |
	current := 'specs/current' asFileReference contents trim.
	repo := TonelRepository new
		directory: ('specs/', current) asFileReference.
	spec := repo asRingEnvironmentWith: #(Kernel).
	^ spec clean
]

{ #category : #accessing }
SmalltalkBootstrapper class >> spec [
	^Spec ifNil: [ Spec := self newSpec ].

]

{ #category : #initialization }
SmalltalkBootstrapper >> => aSymbol [
	^environment at: aSymbol
]

{ #category : #initialization }
SmalltalkBootstrapper >> abi [
	^nativizer abi
]

{ #category : #initialization }
SmalltalkBootstrapper >> addObjectDeep: anObject [
	self ASSERT: (anObject isKindOf: ObjectMap).
	anObject isImmediate
		ifTrue: [ ^ self ].
	(objects includes: anObject)  ifTrue: [ ^self ].
	objects add: anObject.
	anObject
		slotsDo: [ :s | 
			 self addObjectDeep: s ].
	^ anObject
]

{ #category : #initialization }
SmalltalkBootstrapper >> addRemainingObjects [
	| slot |
	globals valuesDo: [ :obj | self addObjectDeep: obj ].
	classes
		do: [ :c | 
			1 to: c instSize do: [ :i | 
				slot := c slotAt: i.
				self addObjectDeep: slot ] ].
	cvarMap
		valuesDo: [ :dict | dict valuesDo: [ :v | self addObjectDeep: v ] ]
]

{ #category : #initialization }
SmalltalkBootstrapper >> basicNewBytes: classname contents: aByteObject [
	| obj |
	obj := ByteObjectMap new: self => classname valued: aByteObject.
	^objects add: obj
]

{ #category : #initialization }
SmalltalkBootstrapper >> basicNewSlots: classname [
	^self basicNewSlots: classname sized: 0

]

{ #category : #initialization }
SmalltalkBootstrapper >> basicNewSlots: classname sized: size [
	| instance |
	instance := SlotObjectMap new: self => classname size: size withAll: nilObj.
	^ objects add: instance
]

{ #category : #building }
SmalltalkBootstrapper >> build [
	self build64
]

{ #category : #building }
SmalltalkBootstrapper >> build64 [
	self wordSize: 8; genesis
]

{ #category : #initialization }
SmalltalkBootstrapper >> buildTestMethod [
	| method astcodes |
	method := self newSlots: 'CompiledMethod'.
	astcodes := self transferArrayDeep: self testMethodAstcodes.
	method
		nativeCode: nilObj;
		astcodes: astcodes.
	^ method
]

{ #category : #initialization }
SmalltalkBootstrapper >> classNamed: name [
	| class |
	^ (name endsWith: ' class')
		ifTrue: [ class := self objectNamed: (name allButLast: 6).
			class behavior slotNamed: 'class' ]
		ifFalse: [ self objectNamed: name ]
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> classNamedOrNil: aSymbol [
	^ index at: aSymbol ifAbsent: nilObj
]

{ #category : #initialization }
SmalltalkBootstrapper >> classes [
	^classes
]

{ #category : #initialization }
SmalltalkBootstrapper >> compile: anRGMethod [
	^emulator compile: anRGMethod
]

{ #category : #initialization }
SmalltalkBootstrapper >> compilerFor: anRGBehavior [
	| c |
	c := SCompiler namespace: globals.
	^c forClass: anRGBehavior
]

{ #category : #initialization }
SmalltalkBootstrapper >> createClass: definition [
	| name class behavior |
	name := definition name.
	class := self basicNewSlots: #Class.
	class initializeAs: definition metaclass sized: 0.
	self define: class as: name.
	behavior := self basicNewSlots: #Behavior.
	behavior class: class.
	class instanceBehavior: behavior.
	classes at: definition put: class.
	self define: class as: name.

]

{ #category : #initialization }
SmalltalkBootstrapper >> createClassAssociations: definition [
	| name class assoc assocs cvars |
	name := definition name.
	class := classes at: definition.
	assoc := self newLiteralAssociation: name -> class.
	globals at: name put: assoc.
	definition
		sharedPoolsDo: [ :pool | 
			assoc := self newLiteralAssociation: pool name -> nilObj.
			globals at: pool name put: assoc ].
	assocs := definition classVariables
		collect: [ :cvar | self newLiteralAssociation: cvar name -> self nilObject ].
	cvars := BootstrapDictionary withAll: assocs.
	cvarMap at: definition put: cvars.
	^ cvars
]

{ #category : #initialization }
SmalltalkBootstrapper >> createClassVars: definition [
	| class classvars cvars |
	cvars := cvarMap at: definition.
	classvars := self newClassVarDictionary: cvars associations.
	class := classes at: definition.
	class classVariables: classvars
]

{ #category : #initialization }
SmalltalkBootstrapper >> createClasses [
	| all |
	all := environment allClasses.
	all
		do: [ :def | 
			self
				createClass: def;
				createMetaclass: def ].

	all
		do: [ :def | 
			self
				initializeClass: def;
				initializeMetaclass: def ].
	self loadEmulator;		fixBehaviors;
		createGlobals.
	all do: [ :def | self createClassVars: def ]
]

{ #category : #initialization }
SmalltalkBootstrapper >> createFalse [
	falseObj := self basicNewSlots: #False
]

{ #category : #initialization }
SmalltalkBootstrapper >> createGlobals [
	| names assoc |
	hash := self newLiteralAssociation: #LastHash -> 1.
	globals at: #LastHash put: hash.
	assoc := self newLiteralAssociation: #WordSize -> 8.
	globals at: #WordSize put: assoc.
	assoc := self newLiteralAssociation: #WordSizeShift -> 3.
	globals at: #WordSizeShift put: assoc.
	names := #(#ActiveProcess #ActiveLocale #ByteCharacters #CharacterConstants #FrameMarker #GC #KernelLibrary #NamedPrimitives #ProcessFrameOffsets #Processor #Reserved #Smalltalk #UnresolvedObjects #UserLibrary).
	names
		do: [ :g | 
			assoc := self newLiteralAssociation: g -> nilObj.
			globals at: g put: assoc ]
]

{ #category : #initialization }
SmalltalkBootstrapper >> createLoadAction [
	^nilObj
]

{ #category : #initialization }
SmalltalkBootstrapper >> createMetaclass: spec [
	| meta ibehavior class |
	meta := self basicNewSlots: #Metaclass.
	ibehavior := self basicNewSlots: #Behavior.
	ibehavior class: meta.
	class := classes at: spec.
	class behavior: ibehavior.
	meta
		instanceBehavior: ibehavior;
		class: class.

]

{ #category : #initialization }
SmalltalkBootstrapper >> createMethodDictionary: species sized: anInteger [
	| behavior md size dictionary |
	behavior := species instanceBehavior.
	md := self classNamed: #MethodDictionary.
	size := self newInteger: anInteger.
	dictionary := self emulateSend: md selector: #new: with: {size}.
	behavior methods: dictionary.
	^ self addObjectDeep: dictionary
]

{ #category : #initialization }
SmalltalkBootstrapper >> createModule [
	| runtime smethod transferred exports |
	module := self new: #Kernel.
	runtime := {(self => #Kernel >> #entry:argv:)}
		collect: [ :def | 
			smethod := methods at: def.
			transferred := identityMap at: smethod.
			transferred nativeCode machineCode ].
	exports := self newArray: classes values.
	module
		name: (self newString: 'Kernel');
		version: (self newString: '0.1.0');
		exports: exports;
		hash: nilObj;
		loadAction: self createLoadAction;
		runtime: (self newArray: runtime)
]

{ #category : #initialization }
SmalltalkBootstrapper >> createNil [
	nilObj := self basicNewSlots: #UndefinedObject.
]

{ #category : #initialization }
SmalltalkBootstrapper >> createTrue [
	trueObj := self basicNewSlots: #True
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> define: anObject as: aSymbol [
	^ index at: aSymbol put: anObject
]

{ #category : #initialization }
SmalltalkBootstrapper >> emulateSend: receiver selector: aSymbol [
^self emulateSend: receiver selector: aSymbol with: { }

]

{ #category : #initialization }
SmalltalkBootstrapper >> emulateSend: receiver selector: aSymbol with: anArray [
		| message |
	message := MessageSend
		receiver: receiver
		selector: aSymbol arguments: anArray.
	^emulator send: message
]

{ #category : #initialization }
SmalltalkBootstrapper >> emulator [
	^emulator
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> falseObject [
	^ falseObj
]

{ #category : #initialization }
SmalltalkBootstrapper >> fillClasses [
	| class meta |
	environment allClasses
		do: [ :def | 
			self log: 'filling ' , def name , '...'.
			class := classes at: def.
			meta := class behavior slotNamed: #class.
			self
				fillSpecies: meta with: def metaclass;
				fillSpecies: class with: def ]
]

{ #category : #initialization }
SmalltalkBootstrapper >> fillSpecies: species with: classDefinition [
	| dictionary smethod transferred |
	dictionary := self
		createMethodDictionary: species
		sized: classDefinition methods size.
	classDefinition methods
		do: [ :methodDefinition | 
			smethod := self compile: methodDefinition.	
			methods at: methodDefinition put: smethod.
			transferred := self transferMethod: smethod in: species.
			self
				emulateSend: dictionary
				selector: #basicAt:put:
				with:
					{transferred selector.
					transferred} ]
]

{ #category : #initialization }
SmalltalkBootstrapper >> fixBehaviors [
	objects do: [ :o | o behavior ifNil: [ self initializeBehavior: o ] ]
]

{ #category : #initialization }
SmalltalkBootstrapper >> formatOfClass: definition [
	| variable pointers |
	variable := definition isVariable ifTrue: [ 16r2000 ] ifFalse: [ 0 ].
	pointers := definition isBytes ifTrue: [ 0 ] ifFalse: [16r4000 ].
	^variable | pointers | definition allInstVarNames size
]

{ #category : #building }
SmalltalkBootstrapper >> genesis [
	"
	Create the world (should take less than 6 days). This is named 'genesis' to remind us those who had
	done this (and much more) before us. Namely SELF people. I (JV) would like to use this opportunity and point you to
	
	https://github.com/russellallen/self/blob/2bcf2c4cab23f52bf68ac4f617020e748699a548/vm/src/any/memory/universe.cpp#L79
	"

	self
		createNil;
		createTrue;
		createFalse;
		createClasses;
		initializeSmalltalk;
		fillClasses;
		nativize;
		addRemainingObjects;
		createModule;
		validate
]

{ #category : #initialization }
SmalltalkBootstrapper >> globals [
	^index

]

{ #category : #initialization }
SmalltalkBootstrapper >> initialize [
	index := OrderedDictionary new.
	classes := OrderedDictionary new.
	methods := OrderedDictionary new.
	objects := OrderedCollection new.
	symbols := OrderedDictionary new.
	cvarMap := OrderedDictionary new.
	globals := BootstrapDictionary new.
	identityMap := IdentityDictionary new.
	emulator := BootstrapEmulator new
		bootstrapper: self;
		classes: classes;
		globals: globals
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeBehavior: anObjectMap [
	| class |
	class := classes at: anObjectMap spec.
	anObjectMap behavior: class instanceBehavior.

]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeClass: definition [
	| class supername superclass name flag ivars poolnames pools subclasses format cvars superbehavior |
	class := classes at: definition.
	supername := definition superclass ifNotNil: [ :s | s name ].
	superclass := self classNamedOrNil: supername.
	superbehavior := superclass == nilObj
		ifTrue: [ nilObj ]
		ifFalse: [ superclass instanceBehavior ].
	class instanceBehavior next: superbehavior.
	subclasses := definition subclasses
		collect: [ :def | self classNamed: def name ].
	subclasses := self newArray: subclasses.
	name := self newString: definition name.
	flag := self formatOfClass: definition.
	format := self newSmallInteger: flag.
	ivars := self newStringArray: definition instVarNames.
	poolnames := definition sharedPools collect: #name.
	pools := self newStringArray: poolnames.
	class
		superclass: superclass;
		format: format;
		instanceVariables: ivars;
		organization: nilObj;
		name: name;
		subclasses: subclasses;
		sharedPools: pools.
	definition metaclass allInstVarNames
		do: [ :ivar | class slotNamed: ivar put: nilObj ].
	cvars := self createClassAssociations: definition.
	emulator wrap: class using: definition cvars: cvars
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeInlinedMethods [
	| compiled |
	compiled := self inlinedMethods
		collect: [ :method | methods at: method ].
	nativizer inlinedMethods: compiled
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeInvokedMethods [
	| compiled |
	compiled := self invokedMethods
		collect: [ :method | methods at: method ].
	nativizer invokedMethods: compiled
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeMetaclass: definition [
	| class meta metadef supername superclass ivars supermeta flags format cvars superbehavior |
	class := classes at: definition.
	meta := class behavior slotNamed: #class.
	metadef := definition metaclass.
	supername := definition superclass ifNotNil: [ :s | s name ].
	superclass := self classNamedOrNil: supername.
	supermeta := superclass == nilObj
		ifTrue: [ self classNamed: #Class ]
		ifFalse: [ superclass behavior slotNamed: #class ].
	superbehavior := supermeta == nilObj
		ifTrue: [ nilObj ]
		ifFalse: [ supermeta instanceBehavior ].
	meta instanceBehavior next: superbehavior.

	ivars := self newStringArray: metadef instVarNames.
	flags := self formatOfClass: metadef.
	format := self newSmallInteger: flags.
	meta
		superclass: supermeta;
		format: format;
		instanceVariables: ivars;
		organization: nilObj.
	cvars := cvarMap at: definition.
	emulator wrap: meta using: metadef cvars: cvars
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeNativizer [
	nativizer := NativizationEnvironment new.
	self
		initializeNativizerGlobals;
		initializeInlinedMethods;
		initializeInvokedMethods;
		initializeOptimizedMethods;
		nativizeInvoke;
		nativizeWriteBarrier;
		nativizeLookup;
		transferNativizerGlobals;
		setupMessageLinkers
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeNativizerGlobals [
	| smi items |
	smi := self classNamed: #SmallInteger.
	nativizer globalNamed: #SmallIntegerBehavior put: smi behavior.
	items := {(#Lookup -> (NativeCode new code: 'Lookup Placeholder')).
	(#LookupSuper -> (NativeCode new code: 'LookupSuper Placeholder')).
	(#DebuggableLookup
		-> (NativeCode new code: 'DebuggableLookup placeholder')).
	(#DebuggableLookupSuper
		-> (NativeCode new code: 'DebuggableLookupSuper placeholder')).
	(#Invoke -> (NativeCode new code: 'Invoke placeholder')).
	(#Safepoint -> (NativeCode new code: 'SafepointCheck placeholder')).
	(#WriteBarrier -> (NativeCode new code: 'Write Barrier placeholder'))} asDictionary.
	items
		keysAndValuesDo:
			[ :key :placeholder | nativizer globalNamed: key put: placeholder ]
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeOptimizedMethods [
	| compiled |
	compiled := self optimizedMethods
		collect: [ :method | methods at: method ].
	nativizer optimizedMethods: compiled
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeSendSite [
	| class lkup invk mic pic |
	class := self classNamed: #SendSite.
	lkup := globals at: #Lookup.
	invk := globals at: #Invoke.
	mic := self newBytesFrom: nativizer monomorphicCache.
	pic := self newBytesFrom: nativizer polymorphicCache.
	self
		emulateSend: class
			selector: #allocateInitialCachesUsing:
			with: {lkup};
		emulateSend: class selector: #initializeInvoke: with: {invk};
		emulateSend: class selector: #monomorphicCache: with: {mic};
		emulateSend: class selector: #polymorphicCache: with: {pic}
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeSmalltalk [
	| class |
	class := self classNamed: #SmalltalkSystem.
	smalltalk := self emulateSend: class selector: #new.
	globals
		do: [ :assoc | self emulateSend: smalltalk selector: #add: with: {assoc} ].
	self emulateSend: smalltalk selector: #bootstrapInitialize
]

{ #category : #initialization }
SmalltalkBootstrapper >> inlinedMethods [
	| map |
	map := {(#ProtoObject
		->
			#(#objectAtValid: #objectAtValid:put: #behavior #class #primitiveAt: #_cachedLookup: #_cachedLookup:in:)).
	(#Object
		-> #(#byteAtValid: #byteAtValid:put: #basicObjectIndexOf: #at:put:)).
	(#Species
		->
			#(#instSize #_instancesAreArrayed #_instancesHavePointers #memory #instanceBehavior #primitiveNew #primitiveNew:)).
	(#CompiledMethod
		->
			#(#prepareForExecution #isNativized #nativeCode #blockCount #literalIndexFrom:)).
	(#CompiledBlock -> #(#argumentCount #blockNumber #blockCode #method)).
	(#NativeCode -> #(#code)).
	(#GCSpace -> #(#commitedLimit #nextFree #nextFree:)).
	(#CharacterArray -> #(#characterAtValid:))}.
		^self undermethods , (self methodSubset: map)
]

{ #category : #initialization }
SmalltalkBootstrapper >> instanceBehaviorOf: classname [
	| class |
	class := self classNamed: classname.
	^class instanceBehavior

]

{ #category : #initialization }
SmalltalkBootstrapper >> instanceBehaviorOfSpec: spec [
	| class |
	class := classes at: spec.
	^class instanceBehavior
]

{ #category : #initialization }
SmalltalkBootstrapper >> invoke [
	^invoke
]

{ #category : #initialization }
SmalltalkBootstrapper >> invokedMethods [
	| map |
	map := {(#ProtoObject
		-> #(behavior class primitiveAt: #initializeExtended:contentSize:)).
	(#Object -> #(#_replaceFrom:to:with:)).
	(#Species
		->
			#(#allocate:size: instanceBehavior _instancesAreArrayed _instancesHavePointers #nil:slotsOf: memory primitiveNewBytes: primitiveNewPointers: #zero:bytesOf:))}.
	^ self undermethods , (self methodSubset: map)
]

{ #category : #initialization }
SmalltalkBootstrapper >> lastHash [
	^hash value value

]

{ #category : #initialization }
SmalltalkBootstrapper >> lastHash: anInteger [
	^hash value value: anInteger

]

{ #category : #initialization }
SmalltalkBootstrapper >> loadEmulator [
	| behavior |
	behavior := (self classNamed: #SmallInteger) instanceBehavior.
	emulator
		nilObject: nilObj;
		falseObject: falseObj;
		trueObject: trueObj;
		smallintBehavior: behavior
]

{ #category : #initialization }
SmalltalkBootstrapper >> log: aString [
	Transcript
		show: aString;
		cr
]

{ #category : #initialization }
SmalltalkBootstrapper >> mapNativizerGlobal: name to: transferred [
	| placeholder |
	placeholder := nativizer globalNamed: name.
	identityMap
		at: placeholder put: transferred;
		at: placeholder code put: transferred machineCode.
		
	globals at: name put: transferred.
]

{ #category : #initialization }
SmalltalkBootstrapper >> methodSubset: aDictionary [
	| all species m |
	all := aDictionary
		flatCollect: [ :assoc | 
			species := environment at: assoc key.
			assoc value
				collect: [ :sel | 
					m := species >> sel.
					self ASSERT: m notNil.
					m ] ].
	^ all asOrderedCollection
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> nameOf: anObject [
	^ index keyAtValue: anObject ifAbsent: nil
]

{ #category : #initialization }
SmalltalkBootstrapper >> nativize [
	self initializeNativizer;
		initializeSendSite;
		nativizeRemainingMethods
]

{ #category : #initialization }
SmalltalkBootstrapper >> nativizeInvoke [
	invoke := self compile: self => #SendSite >> #_invokeOn:.
	nativizer nativizeOptimizing: invoke.
	self transfer: invoke in: #ProtoObject asNativizerGlobal: #Invoke
]

{ #category : #initialization }
SmalltalkBootstrapper >> nativizeLookup [
	| n transferred species  |
	n := LookupNativizer new
		bootstrapper: self;
		nativizeMethods.
	lookup := n methodFor: #_dispatchOn:.
	lookupSuper := n methodFor: #_dispatchOn:startingAt:.
	n methods
		do: [ :m | 
			species := self classNamed: m classBinding name.
			transferred := self transferMethod: m in: species.
			identityMap at: m put: transferred ];
		do: [ :m | 
			transferred := identityMap at: m.
			self transferNativeCode: m nativeCode of: transferred ].
	transferred := (identityMap at: lookup) nativeCode.
	self mapNativizerGlobal: #Lookup to: transferred.
	transferred := (identityMap at: lookupSuper) nativeCode.
	self mapNativizerGlobal: #LookupSuper to: transferred
]

{ #category : #initialization }
SmalltalkBootstrapper >> nativizeRemainingMethods [
	environment allClasses
		do: [ :def | 
			self
				log: 'compiling ' , def name , '...';
				nativizeRemainingMethodsIn: def;
				nativizeRemainingMethodsIn: def metaclass ]
]

{ #category : #initialization }
SmalltalkBootstrapper >> nativizeRemainingMethodsIn: species [
	methods
		do: [ :smethod | 
			smethod nativeCode
				ifNil: [
					nativizer nativize: smethod.
					self transferNativeCodeOfMethod: smethod ] ]
]

{ #category : #initialization }
SmalltalkBootstrapper >> nativizeWriteBarrier [
	| map inlined dispatcher |
	map := {('Memory class' -> #(current)).
	(#Memory -> #(isYoung: isYoungSafe: remember:)).
	(#CriticalArray -> #(unsafeAdd: #unsafeAt:put:)).
	(#Magnitude -> #(#between:and:))}.
	inlined := self methodSubset: map.
	inlined addAll: self undermethods.
	inlined := inlined collect: [ :m | self compile: m ].
	writeBarrier := emulator
		compile: self => #ProtoObject >> #holdRefererIfNeeded:.
	dispatcher := LookupLinker new initializeFrom: nativizer.
	NativizationEnvironment new
		globals: nativizer globals;
		inlinedMethods: inlined;
		messageLinker: dispatcher;
		completeInitialization;
		nativizeOptimizing: writeBarrier.
	self
		transfer: writeBarrier
		in: #ProtoObject
		asNativizerGlobal: #WriteBarrier
]

{ #category : #initialization }
SmalltalkBootstrapper >> nativizer [
	^nativizer
]

{ #category : #initialization }
SmalltalkBootstrapper >> new: classname [
	"	Allocate an object of pointer type. It is niled-out "

	^self new: classname sized: 0
]

{ #category : #initialization }
SmalltalkBootstrapper >> new: classname sized: size [
	"
	Allocate an object of pointer type (as SlotObjectMap).
	It is niled-out, and 	`size` is the size of indexed part (i.e.,
	shall not include named slots)
	"

	| obj |
	obj := self newSlots: classname sized: size.
	1 to: obj basicSize do: [ :i | obj basicAt: i put: nilObj ].
	^ obj
]

{ #category : #initialization }
SmalltalkBootstrapper >> newArray: anArray [
	| assoc |
	assoc := self newSlots: 'Array' sized: anArray size.
	anArray withIndexDo: [ :obj :i | assoc at: i put: obj ].
	^ assoc
]

{ #category : #initialization }
SmalltalkBootstrapper >> newAssociationKey: key value: value [
	| assoc |
	assoc := self newSlots: #Association.
	assoc key: key; value: value .
	^ assoc
]

{ #category : #initialization }
SmalltalkBootstrapper >> newBehavior [
	^ self newSlots: 'Behavior'
]

{ #category : #initialization }
SmalltalkBootstrapper >> newBytes: classname contents: aByteObject [
	| obj |
	obj := self basicNewBytes: classname contents: aByteObject. 
	self initializeBehavior: obj.
	^obj
]

{ #category : #initialization }
SmalltalkBootstrapper >> newBytesFrom: aByteObject [
	^self newBytes: aByteObject class name contents: aByteObject
]

{ #category : #initialization }
SmalltalkBootstrapper >> newCallback: aNativeCode bytesFrom: aByteArray [
	| code original behavior class |
	code := self newBytesFrom: aByteArray.
	original := code behavior.
	behavior := self newSlots: 'CallbackBehavior'.
	class := original slotNamed: 'class'.
	behavior
		slotNamed: 'class' put: class;
		methods: original methods;
		next: nilObj;
		nativeCode: aNativeCode.
	code behavior: behavior.
	^ code
]

{ #category : #initialization }
SmalltalkBootstrapper >> newClassVarDictionary: anArray [
	| dict |
	dict := self newDictionary.
	anArray
		do:
			[ :assoc | self emulateSend: dict selector: #add: with: {assoc} ].
	^ self addObjectDeep: dict
]

{ #category : #initialization }
SmalltalkBootstrapper >> newClosure: aPCompiledBlock [
	^ self newSlots: 'Closure'
]

{ #category : #initialization }
SmalltalkBootstrapper >> newDictionary [
	| factory |
	factory := self classNamed: 'Dictionary'.
	^ self emulateSend: factory selector: #new
]

{ #category : #initialization }
SmalltalkBootstrapper >> newFloatFrom: aFloat [
	| bytes |
bytes := aFloat pointerDouble.
	^ self newBytes: 'Float' contents: bytes
]

{ #category : #initialization }
SmalltalkBootstrapper >> newInteger: anInteger [
	anInteger > maxSMI
		ifTrue: [ ^ self newLargePositiveInteger: anInteger ].
	anInteger < minSMI
		ifTrue: [ ^ self newLargeNegativeInteger: anInteger ].
	^self newSmallInteger: anInteger
]

{ #category : #initialization }
SmalltalkBootstrapper >> newLargeNegativeInteger: anInteger [
	| size bytes byte |
	size := (anInteger bytesCount alignedTo: 2) max: wordSize.
	bytes := ByteArray new: size withAll: 16rFF.
	1 to: anInteger bytesCount do: [ :i | 
		byte := anInteger byteAt: i.
		byte > 0 ifTrue: [ byte := 256 - byte].
		bytes at: i put: byte].
	^ ByteObjectMap new: self => #LargeNegativeInteger valued: bytes
]

{ #category : #initialization }
SmalltalkBootstrapper >> newLargePositiveInteger: anInteger [
	| size bytes |
	size := (anInteger bytesCount alignedTo: 2) max: wordSize.
	bytes := anInteger asByteArrayOfSize: size.
	^ByteObjectMap new: self => #LargePositiveInteger valued: bytes
]

{ #category : #initialization }
SmalltalkBootstrapper >> newLiteralAssociation: anAssociation [
	^self transferLiteralDeep: anAssociation
]

{ #category : #initialization }
SmalltalkBootstrapper >> newMethod: anAstcode selector: aSymbol in: classname format: anInteger literals: anArray [
	| method astcodes class selector format |
	method := self newSlots: 'CompiledMethod'.
	astcodes := self transferAstcodesFrom: anAstcode.
	class := self classNamed: classname.
	selector := self newSymbol: aSymbol.
	format := self newSmallInteger: anInteger.
	method
		nativeCode: self nilObject;
		astcodes: astcodes;
		class: class;
		selector: selector;
		format: format;
		source: self nilObject.
	^ method
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> newNamed: aSymbol [
	| obj |
	obj := self newSlots: aSymbol.
	^ index at: aSymbol put: obj
]

{ #category : #initialization }
SmalltalkBootstrapper >> newSlots: classname [
	^self newSlots: classname sized: 0
]

{ #category : #initialization }
SmalltalkBootstrapper >> newSlots: classname sized: size [
	| obj |
	obj := self basicNewSlots: classname sized: size.
	self initializeBehavior: obj.
	^obj
]

{ #category : #initialization }
SmalltalkBootstrapper >> newSmallInteger: anInteger [
	^SmallintObjectMap new: self => #SmallInteger valued: anInteger
]

{ #category : #initialization }
SmalltalkBootstrapper >> newString: aString [
	| bytes |
	bytes := aString copyWith: Character null.
	^self newBytes: 'String' contents: bytes
]

{ #category : #initialization }
SmalltalkBootstrapper >> newStringArray: strings [
	| array bytes |
	array := self newSlots: 'Array' sized: strings size.
	strings
		withIndexDo: [ :s :i |
			bytes := self newString: s.
			array at: i put: bytes ].
	^ array
]

{ #category : #initialization }
SmalltalkBootstrapper >> newSymbol: aSymbol [
	| new bytes |
	symbols at: aSymbol ifPresent: [:s | ^s ].
	bytes := aSymbol copyWith: Character null.
	new := self newBytes: 'Symbol' contents: bytes.
	^symbols at: aSymbol put: new
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> nilObject [
	^nilObj 
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> objectNamed: aSymbol [
	^ index at: aSymbol
]

{ #category : #accessing }
SmalltalkBootstrapper >> objects [
	^ objects
]

{ #category : #initialization }
SmalltalkBootstrapper >> optimizedMethods [
	| map |
	map :=  {(#ProtoObject
		->
	
					#(behavior class primitiveAt: #primitiveAt:put: #initializeExtended:contentSize:)).
	(#Object
		->
			#(at: #at:put: basicByteAt: #basicByteAt:put: byteAtValid: #byteAtValid:put: basicObjectAt: #basicObjectAt:put: #replaceBytesForwardFrom:to:with:startingAt:)).
	(#SendSite
		->
			#(_dispatchOn: #_dispatchOn:startingAt: _dispatchDebuggableOn: #_dispatchDebuggableOn:startingAt:)).
	(#Species
		->
			#(#allocate:size: primitiveNew primitiveNew: instSize primitiveNewBytes: primitiveNewPointers:)).
	(#'Float class' -> #(new)).
	(#CompiledBlock -> #(argumentCount arity blockCode method)).
	(#Closure -> #(value value: #value:value:)).
	(#CompiledMethod -> #(blockCount isNativized)).
	(#String -> #(at: #at:put: byteAt: #byteAt:put:)).
	(#GCSpace
		-> #(lockedAllocateIfPossible: lockedAllocateUnsafe: shallowCopy:)).
	(#Memory -> #(shallowCopy:))}.
	^self undermethods, (self methodSubset: map)
]

{ #category : #initialization }
SmalltalkBootstrapper >> setupMessageLinkers [
	| invoker dispatcher |
	invoker := InvokeLinker new
		invoker: nativizer invokeStub;
		addMethods: nativizer invokedMethods.
	dispatcher := LookupLinker new initializeFrom: nativizer.
	nativizer
		addLinker: invoker;
		addLinker: dispatcher;
		completeInitialization
]

{ #category : #initialization }
SmalltalkBootstrapper >> spec [
	^environment
]

{ #category : #initialization }
SmalltalkBootstrapper >> spec: anRGEnvironment [

	environment := anRGEnvironment.
	emulator spec: anRGEnvironment.

]

{ #category : #initialization }
SmalltalkBootstrapper >> speciesFrom: anRGBehavior [
	| class species |
	species := classes
		at: anRGBehavior
		ifAbsent: [ class := classes at: anRGBehavior instanceSide.
			^class behavior ].
	^ species instanceBehavior
]

{ #category : #initialization }
SmalltalkBootstrapper >> testMethodAstcodes [
	"m instVar1 := true
	#(MethodId #(AssignmentId #(IdentifierId InstVarId 1) #(IdentifierId TrueId)))"
	^#(1 #(8 #(3 8 1) #(3 2)))
]

{ #category : #initialization }
SmalltalkBootstrapper >> transfer: anSMethod in: classname asNativizerGlobal: name [
	| species transferred |
	species := self classNamed: classname.
	transferred := self transferMethod: anSMethod in: species.
	transferred := self
		transferNativeCode: anSMethod nativeCode
		of: transferred.
	self mapNativizerGlobal: name to: transferred
]

{ #category : #initialization }
SmalltalkBootstrapper >> transferArrayDeep: anArray [
	| copy transferred |
	copy := self newSlots: 'Array' sized: anArray size.
	anArray
		withIndexDo: [ :elem :i | 
			transferred := elem isSmallInteger
				ifTrue: [ self newSmallInteger: elem ]
				ifFalse: [ self transferArrayDeep: elem ].
			copy at: i put: transferred ].
	^ copy
]

{ #category : #initialization }
SmalltalkBootstrapper >> transferAstcodesFrom: anArray [
	| copy transferred |
	copy := self newSlots: 'Array' sized: anArray size.
	anArray withIndexDo: [ :elem :i | 
			transferred := elem isSmallInteger
				ifTrue: [ self newSmallInteger: elem ]
				ifFalse: [ self transferAstcodesFrom: elem ].
			copy at: i put: transferred ].
	^ copy
]

{ #category : #initialization }
SmalltalkBootstrapper >> transferBlock: anSCompiledBlock [
	| transferred method format |
	identityMap at: anSCompiledBlock ifPresent: [ :b | ^ b ].
	transferred := self newSlots: #CompiledBlock.
	identityMap at: anSCompiledBlock put: transferred.
	method := identityMap at: anSCompiledBlock method.
	format := self newInteger: anSCompiledBlock format.
	transferred
		method: method;
		format: format;
		nativeCode: nilObj.
	^ transferred
]

{ #category : #initialization }
SmalltalkBootstrapper >> transferLiteralAt: anInteger in: method [
	| literal class transferred |
	literal := method at: anInteger.
	class := literal class.
	(class inheritsFrom: ObjectMap)
		ifTrue: [ ^ self ].
	transferred := self transferLiteralDeep: literal.
	^ method at: anInteger put: transferred
]

{ #category : #initialization }
SmalltalkBootstrapper >> transferLiteralDeep: anObject [
	| class transferred slot size ivar |
	class := anObject class.
	class = SmallInteger
		ifTrue: [ ^ self newSmallInteger: anObject ].
	anObject == nil
		ifTrue: [ ^ nilObj ].
	anObject == false
		ifTrue: [ ^ falseObj ].
	anObject == true
		ifTrue: [ ^ trueObj ].
	identityMap at: anObject ifPresent: [ :existing | ^existing].
	(class inheritsFrom: Symbol)
		ifTrue: [ ^ self newSymbol: anObject ].
	(class inheritsFrom: String)
		ifTrue: [ ^ self newString: anObject ].
	class = ByteArray
		ifTrue: [ ^ self newBytesFrom: anObject ].
	(class inheritsFrom: Float)
		ifTrue: [ ^ self newFloatFrom: anObject ].
	(class inheritsFrom: ObjectMap)
		ifTrue: [ ^ anObject ].
	class == SCompiledBlock
		ifTrue: [ ^ self transferBlock: anObject ].
	size := class isVariable
		ifTrue: [ anObject size ]
		ifFalse: [ 0 ].
	transferred := self newSlots: class name sized: size.
	1 to: class instSize do: [ :i | 
		ivar := anObject instVarAt: i.
		slot := self transferLiteralDeep: ivar.
		transferred slotAt: i put: slot ].
	size > 0
		ifTrue: [ anObject
				withIndexDo: [ :elem :i | 
					slot := self transferLiteralDeep: elem.
					transferred at: i put: slot ] ].
	^ transferred
]

{ #category : #initialization }
SmalltalkBootstrapper >> transferMethod: anSCompiledMethod in: species [
	| size classname transferred astcodes selector format literal tliteral |
	identityMap
		at: anSCompiledMethod
		ifPresent: [ :m | self ASSERT: false ].
	size := anSCompiledMethod size.
	classname := anSCompiledMethod isCallback
		ifTrue: [ 'CallbackMethod' ]
		ifFalse: [ 'CompiledMethod' ].
	transferred := self newSlots: classname sized: size.
	identityMap at: anSCompiledMethod put: transferred.
	astcodes := self transferLiteralDeep: anSCompiledMethod astcodes.
	selector := self newSymbol: anSCompiledMethod selector.
	format := self newSmallInteger: anSCompiledMethod format.
	transferred
		astcodes: astcodes;
		class: species;
		selector: selector;
		format: format;
		source: self nilObject.
	1 to: size do: [ :i | 
		literal := anSCompiledMethod at: i.
		tliteral  := self transferLiteralDeep: literal.
		transferred at: i put: tliteral ].
	^ transferred
]

{ #category : #initialization }
SmalltalkBootstrapper >> transferNativeCode: aNativeCode of: compiledCode [
	| size transferred code slot callback |
	size := aNativeCode size.
	transferred := self newSlots: 'NativeCode' sized: size.
	callback := compiledCode classname = #CallbackMethod.
	code := callback
		ifTrue: [ self newCallback: transferred bytesFrom: aNativeCode code ]
		ifFalse: [ self newBytesFrom: aNativeCode code ].
	transferred
		machineCode: code;
		compiledCode: compiledCode.
	compiledCode nativeCode: transferred.
	aNativeCode
		withIndexDo: [ :elem :i | 
			slot := self transferLiteralDeep: elem.
			transferred at: i put: slot ].
	^ transferred
]

{ #category : #initialization }
SmalltalkBootstrapper >> transferNativeCodeOfMethod: anSCompiledMethod [
	| transferred remaining literal block position |
	transferred := identityMap at: anSCompiledMethod.
	self transferNativeCode: anSCompiledMethod nativeCode of: transferred.
	remaining := anSCompiledMethod blockCount.
	position := 1.
	[ remaining > 0 ]
		whileTrue: [ literal := anSCompiledMethod at: position.
			literal isBlock
				ifTrue: [ block := transferred at: position.
					self transferNativeCode: literal nativeCode of: block.
					remaining := remaining - 1 ].
			position := position + 1 ].
	^ transferred
]

{ #category : #initialization }
SmalltalkBootstrapper >> transferNativizerGlobals [
	self transferLiteralDeep: nativizer globals

]

{ #category : #initialization }
SmalltalkBootstrapper >> transferSimpleLiterals: method [
	"fixme: to be used by emulator only"

	| literal class |
	1 to: method size do: [ :i | 
		literal := method at: i.
		class := literal class.
		((class inheritsFrom: ObjectMap) or: [ class = SCompiledBlock ])
			ifFalse: [ method at: i put: (self transferLiteralDeep: literal) ] ].
	^method
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> trueObject [
	^ trueObj
]

{ #category : #initialization }
SmalltalkBootstrapper >> undermethods [
	^ (environment at: #ProtoObject) methods
		select: [ :m | m category = 'header access' ]
]

{ #category : #validating }
SmalltalkBootstrapper >> validate [
	objects do:[:obj | obj validate]
]

{ #category : #validating }
SmalltalkBootstrapper >> wordSize: anInteger [
	wordSize := anInteger.
	maxSMI := (1 bitShift: wordSize * 8 - 2) - 1.
	minSMI := maxSMI negated - 1
]

{ #category : #initialization }
SmalltalkBootstrapper >> writeBarrier [
	^writeBarrier
]

{ #category : #validating }
SmalltalkBootstrapper >> writer [
	^ ImageSegmentWriter new
		objects: objects;
		module: module;
		space: smalltalk memory edenSpace;
		yourself
]
