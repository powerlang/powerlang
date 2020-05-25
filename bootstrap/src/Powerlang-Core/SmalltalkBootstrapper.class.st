Class {
	#name : #SmalltalkBootstrapper,
	#superclass : #Object,
	#instVars : [
		'index',
		'classes',
		'objects',
		'symbols',
		'nilObj',
		'trueObj',
		'falseObj',
		'environment',
		'emulator',
		'globals',
		'hash'
	],
	#classVars : [
		'EmulationSpec',
		'Spec'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #accessing }
SmalltalkBootstrapper class >> emulationSpec [
	^EmulationSpec
]

{ #category : #accessing }
SmalltalkBootstrapper class >> fromSpec [
	^ self new spec: self spec; emulationSpec: self emulationSpec 
]

{ #category : #accessing }
SmalltalkBootstrapper class >> newEmulationSpec [
	| spec species basicNew new basicNewSized newSized proto equal table prime int plus minus times divdiv bitand less closure value size quot at obj behavior undersize whiletrue whilefalse evaluateWith evaluateWithWith valueWith valueWithWith valueWithWithWith atomic hash argCount bitxor bitshift newBytes string replace |
	spec := self newSpec.
	species := spec at: #Species.
	basicNew := species methodNamed: #basicNew.
	basicNew sourceCode: 'basicNew <primitive: New>'.
	new := species methodNamed: #new.
	new sourceCode: 'new <primitive: New>'.
	basicNewSized := species methodNamed: #basicNew:.
	basicNewSized sourceCode: 'basicNew: anInteger <primitive: NewSized>'.
	newSized := species methodNamed: #new:.
	newSized sourceCode: 'new: anInteger <primitive: NewSized>'.
	newBytes := species methodNamed: #primitiveNewBytes:.
	newBytes
		sourceCode: 'primitiveNewBytes: anInteger <primitive: NewBytes>'.
	proto := spec at: #ProtoObject.
	undersize := proto methodNamed: #_size.
	undersize sourceCode: '_size <primitive: UnderSize>'.
	behavior := proto methodNamed: #behavior.
	behavior sourceCode: 'behavior <primitive: Behavior>'.
	equal := proto methodNamed: #==.
	equal sourceCode: '== anObject <primitive: Equal>'.
	size := proto methodNamed: #primitiveSize.
	size sourceCode: 'primitiveSize <primitive: Size>'.
	at := proto methodNamed: #primitiveAt:.
	at sourceCode: 'primitiveAt: anInteger <primitive: At>'.
	hash := proto methodNamed: #basicHash.
	hash sourceCode: 'basicHash <primitive: Hash>'.
	obj := spec at: #Object.
	at := obj methodNamed: #primitiveAt:put:.
	at
		sourceCode: 'primitiveAt: anInteger put: anObject <primitive: AtPut>'.
	int := spec at: #SmallInteger.
	plus := int methodNamed: #+.
	plus sourceCode: '+ anObject <primitive: SMIPlus>'.
	minus := int methodNamed: #-.
	minus sourceCode: '- anObject <primitive: SMIMinus>'.
	times := int methodNamed: #*.
	times sourceCode: '* anObject <primitive: SMITimes>'.
	divdiv := int methodNamed: #//.
	divdiv sourceCode: '// anObject <primitive: SMIIntDiv>'.
	quot := int methodNamed: #\\.
	quot sourceCode: '\\ anObject <primitive: SMIIntQuot>'.
	bitand := int methodNamed: #bitAnd:.
	bitand sourceCode: 'bitAnd: aNumber <primitive: SMIBitAnd>'.
	bitxor := int methodNamed: #bitXor:.
	bitxor sourceCode: 'bitXor: aNumber <primitive: SMIBitXor>'.
	bitshift := int methodNamed: #bitShift:.
	bitshift sourceCode: 'bitShift: aNumber <primitive: SMIBitShift>'.
	less := int methodNamed: #>.
	less sourceCode: '> anObject <primitive: SMIGreaterThan>'.
	less := int methodNamed: #>=.
	less sourceCode: '>= anObject <primitive: SMIGreaterEqualThan>'.
	less := int methodNamed: #=.
	less sourceCode: '= anObject <primitive: SMIEqual>'.
	closure := spec at: #Closure.
	value := closure methodNamed: #value.
	value sourceCode: 'value <primitive: ClosureValue>'.
	atomic := closure methodNamed: #evaluateAtomically.
	atomic sourceCode: 'evaluateAtomically <primitive: ClosureValue>'.
	valueWith := closure methodNamed: #value:.
	valueWith sourceCode: 'value: a1 <primitive: ClosureValueWithArgs>'.
	valueWithWith := closure methodNamed: #value:value:.
	valueWithWith
		sourceCode: 'value: a1 value: 2 <primitive: ClosureValueWithArgs>'.
	valueWithWithWith := closure methodNamed: #value:value:value:.
	valueWithWithWith
		sourceCode: 'value: a1 value: a2 value: a3 <primitive: ClosureValueWithArgs>'.
	evaluateWith := closure methodNamed: #evaluateWith:.
	evaluateWith
		sourceCode: 'evaluateWith: arg <primitive: ClosureValueWithArgs>'.
	evaluateWithWith := closure methodNamed: #evaluateWith:with:.
	evaluateWithWith
		sourceCode: 'evaluateWith: a1 with: a2 <primitive: ClosureValueWithArgs>'.
	whiletrue := closure methodNamed: #whileTrue:.
	whiletrue
		sourceCode: 'whileTrue: aBlock <primitive: ClosureWhileTrue>'.
	whilefalse := closure methodNamed: #whileFalse:.
	whilefalse
		sourceCode: 'whileFalse: aBlock <primitive: ClosureWhileFalse>'.
	argCount := closure methodNamed: #argumentCount.
	argCount
		sourceCode: 'argumentCount <primitive: ClosureArgumentCount>'.
	string := spec at: #String.
	replace := string methodNamed: #replaceFrom:to:with:startingAt:.
	replace
		sourceCode:
			'replaceFrom: start to: end with: aCollection startingAt: position <primitive: StringReplaceFromToWithStartingAt>'.
	table := spec at: #HashTable.
	prime := table metaclass methodNamed: #primeFor:.
	prime sourceCode: 'primeFor: anInteger <primitive: PrimeFor>'.
	^ spec
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
	Spec
		ifNil: [ Spec := self newSpec.
			EmulationSpec := self newEmulationSpec].
	^ Spec
]

{ #category : #initialization }
SmalltalkBootstrapper >> => aSymbol [
	^environment at: aSymbol
]

{ #category : #initialization }
SmalltalkBootstrapper >> addObjectDeep: anObject [
	self ASSERT: (anObject isKindOf: ObjectMap).
	anObject isImmediate
		ifTrue: [ ^ self ].
	objects add: anObject.
	anObject
		slotsDo: [ :s | 
			(objects includes: s)
				ifFalse: [ self addObjectDeep: s ] ].
	^ anObject
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
	| spec instance |
	spec := environment at: classname.
	instance := SlotObjectMap new: spec size: size withAll: nilObj.
	^ objects add: instance
]

{ #category : #building }
SmalltalkBootstrapper >> build [
	self genesis
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
	^self objectNamed: name
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
SmalltalkBootstrapper >> compilerFor: anRGBehavior [
	| c |
	c := Compiler namespace: globals.
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
	self define: class as: name
]

{ #category : #initialization }
SmalltalkBootstrapper >> createClassAssociations: definition [
	| name class assoc emulated cvarEmu |
	name := definition name.
	class := classes at: definition.
	assoc := self newLiteralAssociation: name -> class.
	globals at: name put: assoc.
	definition classVariables
		do: [ :cvar | 
			assoc := self newLiteralAssociation: cvar name -> self nilObject.
			cvar association: assoc.
			emulated := emulator spec at: name.
			cvarEmu := emulated classVarNamed: cvar name.
			cvarEmu association: assoc ]
]

{ #category : #initialization }
SmalltalkBootstrapper >> createClassVars: definition [
	| class classvars |
	class := classes at: definition.
	classvars := self newClassVarDictionary: definition classVariables.
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
	"emulator bridge updateGlobals."
	all
		do: [ :def | 
			self
				initializeClass: def;
				initializeMetaclass: def;
				createClassAssociations: def ].
	self fixBehaviors; createGlobals.
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
	|  message receiver selector argument arguments |
	message := self new: #MessageSend.
	receiver := self newSmallInteger: 10.
	selector := self newSymbol: #gcd:.
	argument := self newSmallInteger: 15.
	arguments := self newArray: {argument}.
	message receiver: receiver; selector: selector; arguments: arguments.
	^message
]

{ #category : #initialization }
SmalltalkBootstrapper >> createMetaclass: spec [
	|  meta ibehavior class |
	meta := self basicNewSlots: #Metaclass.
	ibehavior := self basicNewSlots: #Behavior.
	ibehavior class: meta.
	class := classes at: spec.
	class behavior: ibehavior.
	meta instanceBehavior: ibehavior; class: class.

]

{ #category : #initialization }
SmalltalkBootstrapper >> createMethodDictionary: definition [
	| class behavior md size dictionary |
	class := classes at: definition.
	behavior := class instanceBehavior.
	md := self classNamed: #MethodDictionary.
	size := self newSmallInteger: definition methods size.
	dictionary := self emulateSend: md selector: #new: with: {size}.
	behavior methods: dictionary.
	^ self addObjectDeep: dictionary
]

{ #category : #initialization }
SmalltalkBootstrapper >> createMethodDictionary: species sized: anInteger [
	| behavior md size dictionary |
	behavior := species instanceBehavior.
	md := self classNamed: #MethodDictionary.
	size := self newSmallInteger: anInteger.
	dictionary := self emulateSend: md selector: #new: with: {size}.
	behavior methods: dictionary.
	^ self addObjectDeep: dictionary
]

{ #category : #initialization }
SmalltalkBootstrapper >> createModule [
	| module array |
	module := self new: #Module.
	array := self newArray: classes values.
	module classes: array; loadAction: self createLoadAction.
	^module
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
SmalltalkBootstrapper >> emulationSpec: anRGEnvironment [
	emulator spec: anRGEnvironment
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
			self log: 'filling ', def name, '...'.
			class := classes at: def.
			meta := class behavior slotNamed: #class.
			self
				initializeClassVariables: class with: def metaclass;
				fillSpecies: meta with: def metaclass;
				fillSpecies: class with: def ]
]

{ #category : #initialization }
SmalltalkBootstrapper >> fillSpecies: species with: definition [
	| dictionary compiler method transferred |
	dictionary := self
		createMethodDictionary: species
		sized: definition methods size.
	compiler := self compilerFor: definition.
	definition methods
		do: [ :m | 
			method := compiler compile: m sourceCode.
			transferred := self transferMethod: method in: species.
			self emulateSend: dictionary
				selector: #basicAt:put:
				with:
					{transferred selector.
					transferred}.
			 ]
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
		loadEmulator;
		createClasses;
		initializeSmalltalk;
		fillClasses;
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
	objects := OrderedCollection new.
	symbols := OrderedDictionary new.
	globals := BootstrapDictionary new.
	emulator := BootstrapEmulator new bootstrapper: self; classes: classes; globals: globals
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeBehavior: anObjectMap [
	| class |
	class := classes at: anObjectMap spec.
	anObjectMap behavior: class instanceBehavior.

]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeClass: definition [
	| class supername superclass name flag ivars pools subclasses format |
	class := classes at: definition.
	supername := definition superclass ifNotNil: [ :s | s name ].
	superclass := self classNamedOrNil: supername.
	subclasses := definition subclasses
		collect: [ :def | self classNamed: def name ].
	subclasses := self newArray: subclasses.
	name := self newString: definition name.
	flag := self formatOfClass: definition.
	format := self newSmallInteger: flag.
	ivars := self newStringArray: definition instVarNames.
	pools := self newStringArray: definition sharedPools.
	class
		superclass: superclass;
		format: format;
		instanceVariables: ivars;
		organization: nilObj;
		name: name;
		subclasses: subclasses;
		sharedPools: pools
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeClassVariables: class with: definition [
	| initializers |
	initializers := definition methods
		select: [ :m | m selector beginsWith: 'initialize' ].
	initializers
		do: [ :m | 
			self emulateSend: class selector: m selector ]
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeMetaclass: definition [
	| class meta supername superclass ivars supermeta flags format |
	class := classes at: definition.
	meta := class behavior slotNamed: #class.
	supername := definition superclass ifNotNil: [ :s | s name ].
	superclass := self classNamedOrNil: supername.
	supermeta := superclass == nilObj
		ifTrue: [ self classNamed: #ProtoObject ]
		ifFalse: [ superclass behavior slotNamed: #class].
	ivars := self newStringArray: definition metaclass instVarNames.
	flags := self formatOfClass: definition metaclass.
	format := self newSmallInteger: flags.
	meta
		superclass: supermeta;
		format: format;
		instanceVariables: ivars;
		organization: nilObj
]

{ #category : #initialization }
SmalltalkBootstrapper >> initializeSmalltalk [
	| class smalltalk |
	class := self classNamed: #SmalltalkSystem.
	smalltalk := self emulateSend: class selector: #new.
	globals
		do:
			[ :assoc | self emulateSend: smalltalk selector: #add: with: {assoc} ].
	self emulateSend: smalltalk selector: #bootstrapInitialize
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
SmalltalkBootstrapper >> lastHash [
	^hash value value

]

{ #category : #initialization }
SmalltalkBootstrapper >> lastHash: anInteger [
	^hash value value: anInteger

]

{ #category : #initialization }
SmalltalkBootstrapper >> loadEmulator [
	emulator nilObject: nilObj; falseObject: falseObj; trueObject: trueObj
]

{ #category : #initialization }
SmalltalkBootstrapper >> log: aString [
	Transcript
		show: aString;
		cr
]

{ #category : #'as yet unclassified' }
SmalltalkBootstrapper >> nameOf: anObject [
	^ index keyAtValue: anObject ifAbsent: nil
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
SmalltalkBootstrapper >> newClassVarDictionary: anArray [
	| dict |
	dict := self newDictionary.
	anArray
		do:
			[ :cvar | self emulateSend: dict selector: #add: with: {cvar association} ].
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

{ #category : #initialization }
SmalltalkBootstrapper >> newMethod: anAstcode selector: aSymbol in: species format: anInteger sized: size [
	| method astcodes selector format |
	method := self newSlots: 'CompiledMethod' sized: size.
	astcodes := self transferLiteralDeep: anAstcode.
	selector := self newSymbol: aSymbol.
	format := self newSmallInteger: anInteger.
	method
		nativeCode: self nilObject;
		astcodes: astcodes;
		class: species;
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
SmalltalkBootstrapper >> spec [
	^environment
]

{ #category : #initialization }
SmalltalkBootstrapper >> spec: anRGEnvironment [
	environment := anRGEnvironment
]

{ #category : #initialization }
SmalltalkBootstrapper >> specNamed: aSymbol [
	^environment at: aSymbol
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
SmalltalkBootstrapper >> transferBlock: anSCompiledBlock in: method [
	| transferred |
	transferred := self newSlots: #CompiledBlock.
	transferred
		method: method;
		format: anSCompiledBlock format.
		^transferred
]

{ #category : #initialization }
SmalltalkBootstrapper >> transferLiteralAt: anInteger in: method [
	| literal class transferred |
	literal := method at: anInteger.
	class := literal class.
	(class inheritsFrom: ObjectMap)
		ifTrue: [ ^ self ].
	transferred := class = SCompiledBlock
		ifTrue: [ self transferBlock: literal in: method ]
		ifFalse: [ self transferLiteralDeep: literal ].
	^ method at: anInteger put: transferred
]

{ #category : #initialization }
SmalltalkBootstrapper >> transferLiteralDeep: anObject [
	| class transferred slot size ivar |
	class := anObject class.
	class = SmallInteger
		ifTrue: [ ^ self newSmallInteger: anObject ].
	class = UndefinedObject
		ifTrue: [ ^ nilObj ].
	class = False
		ifTrue: [ ^ falseObj ].
	class = True
		ifTrue: [ ^ trueObj ].
	(class inheritsFrom: Symbol)
		ifTrue: [ ^ self newSymbol: anObject ].
	(class inheritsFrom: String)
		ifTrue: [ ^ self newString: anObject ].
	class = ByteArray
		ifTrue: [ ^ self newBytesFrom: anObject ].
	(class inheritsFrom: ObjectMap)
		ifTrue: [ ^ anObject ].
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
	| transferred size |
	size := anSCompiledMethod size.
	transferred := self
		newMethod: anSCompiledMethod astcodes
		selector: anSCompiledMethod selector
		in: species
		format: anSCompiledMethod format
		sized: size.
	1 to: size do: [ :i | self transferLiteralAt: i in: transferred ].
	^ transferred
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

{ #category : #validating }
SmalltalkBootstrapper >> validate [
	objects do:[:obj | obj validate]
]

{ #category : #validating }
SmalltalkBootstrapper >> writer [
	^ImageSegmentWriter new objects: objects; module: self createModule
]
