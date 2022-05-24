"
I'm in charge of creating and managing the objects of an image. I'm created from a spec,
and I know how to bootstrap and connect an initial graph of objects and classes.

I do not add the spec methods to classes, as it requires some emulation done by
the `VirtualRuntime`. That step is left to the `VirtualImage`
that also creates the Kernel module.
"
Class {
	#name : #PowertalkRingImage,
	#superclass : #Object,
	#instVars : [
		'nilObj',
		'falseObj',
		'trueObj',
		'kernel',
		'wordSize',
		'minSMI',
		'maxSMI',
		'classes',
		'metaclasses',
		'runtime',
		'symbols',
		'bootstrapDicts',
		'identityMap',
		'specs',
		'closureSpec',
		'arraySpec',
		'smiSpec',
		'symbolSpec',
		'vmPrimitivesSpec'
	],
	#classInstVars : [
		'KernelSpec',
		'VMPrimitivesSpec',
		'LMRBootstrapperSpec'
	],
	#category : #'Powerlang-Core-Execution-Ring'
}

{ #category : #accessing }
PowertalkRingImage class >> LMRBootstrapperSpec [
	^ LMRBootstrapperSpec
		ifNil: [ LMRBootstrapperSpec := self readSpec: #Bootstrapper at: 'LMR' ]
]

{ #category : #accessing }
PowertalkRingImage class >> fromSpec [
	^ self new specs: self kernelSpec; vmPrimitivesSpec: self vmPrimitivesSpec
]

{ #category : #accessing }
PowertalkRingImage class >> kernelSpec [
	^ KernelSpec ifNil: [ KernelSpec := self readSpec: #Kernel at: '.' ]
]

{ #category : #'instance creation' }
PowertalkRingImage class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #accessing }
PowertalkRingImage class >> readSpec: specName at: path [
	| root current repo spec |
	root := (Smalltalk getPackageDirectoryForPackage: self package)
		/ '..' / '..'.
	current := (root / 'specs' / 'current') contents asString trim.
	repo := TonelRepository new
		directory: root / 'specs' / current / path .
	spec := repo asRingEnvironmentWith: {specName}.
	^ spec clean
]

{ #category : #accessing }
PowertalkRingImage class >> resetSpecs [
	KernelSpec := nil.
	VMPrimitivesSpec := nil
]

{ #category : #accessing }
PowertalkRingImage class >> vmPrimitivesSpec [
	^ VMPrimitivesSpec
		ifNil: [ VMPrimitivesSpec := self readSpec: #VM at: 'Kernel' ]
]

{ #category : #initialization }
PowertalkRingImage >> => aSymbol [
	^ specs at: aSymbol
]

{ #category : #services }
PowertalkRingImage >> basicNewBytes: classname contents: aByteObject [
	^ self basicNewBytesOf: self => classname contents: aByteObject
]

{ #category : #services }
PowertalkRingImage >> basicNewBytesOf: anRGBehavior  contents: aByteObject [
	^ ByteObjectMap new: anRGBehavior valued: aByteObject
]

{ #category : #accessing }
PowertalkRingImage >> basicNewSlots: classname [
	^ self basicNewSlots: classname sized: 0
]

{ #category : #accessing }
PowertalkRingImage >> basicNewSlots: classname in: spec [
	^ self basicNewSlots: classname in: spec sized: 0
]

{ #category : #accessing }
PowertalkRingImage >> basicNewSlots: classname in: spec sized: size [
	| species |
	species := spec at: classname.
	^self basicNewSlotsOf: species sized: size
]

{ #category : #accessing }
PowertalkRingImage >> basicNewSlots: classname sized: size [
	^ self basicNewSlots: classname in: specs sized: size
]

{ #category : #accessing }
PowertalkRingImage >> basicNewSlotsOf: anRGBehavior sized: size [
	^ SlotObjectMap new: anRGBehavior size: size withAll: nilObj
]

{ #category : #'own services' }
PowertalkRingImage >> bootstrap [
	runtime
		sendLocal: #bootstrap to: kernel;
		removeBootstrapDictionaryOverrides
]

{ #category : #'own services' }
PowertalkRingImage >> bootstrapDictionaries [
	^bootstrapDicts
]

{ #category : #'own services' }
PowertalkRingImage >> buildSpecies: spec [
	| sspec sclass sbehavior metasuper  |
	sspec := spec superclass.
	sspec
		ifNil: [ sclass := nilObj.
			sbehavior := nilObj.
			metasuper := classes at: self => #Class ]
		ifNotNil: [ sclass := classes at: sspec.
			sbehavior := sclass instanceBehavior.
			metasuper := metaclasses at: sspec metaclass ].
	self
		initializeClass: spec superclass: sclass superbehavior: sbehavior;
		initializeMetaclass: spec metaclass superclass: metasuper
]

{ #category : #'own services' }
PowertalkRingImage >> builder [
	^	RingBasedLMRBootstrapper new image: self.
]

{ #category : #accessing }
PowertalkRingImage >> classFor: anRGBehavior [
	^classes at: anRGBehavior
]

{ #category : #building }
PowertalkRingImage >> classNamed: aString [
	^self classFor: self => aString
]

{ #category : #accessing }
PowertalkRingImage >> classes [
	^ classes
]

{ #category : #accessing }
PowertalkRingImage >> createBootstrapCVars: spec [
	| names cvars array |
	names := spec classVariables.
	names isEmpty
		ifTrue: [ ^ nilObj ].
	cvars := self newBootstrapDictionaryOf: self => #Dictionary.
	names do: [ :rgVar | cvars at: rgVar name put: nilObj ].
	array := self newArraySized: 1.
	array at: 1 put: cvars.
	^ array
]

{ #category : #accessing }
PowertalkRingImage >> createBootstrapNamespace [
	| namespace |
	namespace := self newBootstrapDictionaryOf: self => #Namespace.
	kernel namespace: namespace.
	namespace
		at: #WordSize put: wordSize;
		at: #LastHash put: 1.
	classes do: [ :c | namespace at: c name asSymbol put: c ]
]

{ #category : #'own services' }
PowertalkRingImage >> createFinalNamespace [
	| namespace bootstrapped final |
	namespace := self classNamed: #Namespace.
	bootstrapped := kernel namespace.
	final := runtime sendLocal: #new to: namespace.
	bootstrapped
		associationsDo: [ :assoc | runtime sendLocal: #add: to: final with: assoc ].
	classes
		do: [ :class | 
			runtime
				sendLocal: #at:put:
				to: final
				with:
					{class name.
					class} ]
]

{ #category : #initialization }
PowertalkRingImage >> createMethodDictionary: species sized: anInteger [
	| behavior md size dictionary |
	behavior := species instanceBehavior.
	md := self classNamed: #MethodDictionary.
	size := self newInteger: anInteger.
	dictionary := runtime sendLocal: #new: to: md with: {size}.
	behavior methods: dictionary.
	^ dictionary
]

{ #category : #accessing }
PowertalkRingImage >> createSpecies: definition [
	| class meta ibehavior cbehavior |
	class := ClassMap new: definition metaclass size: 0 withAll: nilObj.
	class instanceSpec: definition.
	meta := MetaclassMap
		new: (self => #Metaclass) metaclass
		size: 0
		withAll: nilObj.
	meta instanceSpec: definition metaclass.
	ibehavior := self basicNewSlots: #Behavior.
	cbehavior := self basicNewSlots: #Behavior.
	ibehavior class: class.
	cbehavior class: meta.
	meta
		class: class;
		instanceBehavior: cbehavior.
	class instanceBehavior: ibehavior.
	classes at: definition put: class.
	metaclasses at: definition metaclass put: meta
]

{ #category : #accessing }
PowertalkRingImage >> false [
	^ falseObj
]

{ #category : #initialization }
PowertalkRingImage >> fillClasses [
	| class meta |
	specs allClasses	do: [ :def | 
			self log: 'filling ' , def name , '...'.
			class := self classFor: def.
			meta := self metaclassFor: def metaclass.
			self
				fillSpecies: meta with: def metaclass;
				fillSpecies: class with: def ]
]

{ #category : #initialization }
PowertalkRingImage >> fillSpecies: species with: classDefinition [
	| dictionary smethod transferred |
	dictionary := self
		createMethodDictionary: species
		sized: classDefinition methods size.
	classDefinition methods
		do: [ :methodDefinition | 
			smethod := runtime compile: methodDefinition.
			transferred := self transferMethod: smethod in: species.
			runtime
				sendLocal: #basicAt:put:
				to: dictionary
				with:
					{transferred selector.
					transferred} ]
]

{ #category : #initialization }
PowertalkRingImage >> fillSymbols [
	| table namespace cvars |
	namespace := (self classNamed: #Symbol) classVariables.
	cvars := namespace at: 1.
	table := cvars at: 'SymbolTable'.
	symbols
		do: [ :sym | runtime sendLocal: #add: to: table with: {sym} ]
]

{ #category : #initialization }
PowertalkRingImage >> formatOfClass: definition [
	| variable pointers |
	variable := definition isVariable ifTrue: [ 16r2000 ] ifFalse: [ 0 ].
	pointers := definition isBytes ifTrue: [ 0 ] ifFalse: [16r4000 ].
	^variable | pointers | definition allInstVarNames size
]

{ #category : #building }
PowertalkRingImage >> generateLMR [
	^(RingBasedLMRBootstrapper new image: self) convert
]

{ #category : #building }
PowertalkRingImage >> genesis [
	"
	Create the world (should take less than 6 days). This is named 'genesis' to remind us those who had
	done this (and much more) before us. Namely SELF people. I (JV) would like to use this opportunity and point you to
	
	https://github.com/russellallen/self/blob/2bcf2c4cab23f52bf68ac4f617020e748699a548/vm/src/any/memory/universe.cpp#L79
	"

	nilObj := self basicNewSlots: #UndefinedObject.
	trueObj := self basicNewSlots: #True.
	falseObj := self basicNewSlots: #False.
	kernel := self basicNewSlots: #Kernel.
	specs allClasses do: [ :def | self createSpecies: def ].
	specs allClasses do: [ :def | self buildSpecies: def ].
	self createBootstrapNamespace.
	runtime := PowertalkRingRuntime new.
	runtime image: self
]

{ #category : #initialization }
PowertalkRingImage >> initialize [
	classes := OrderedDictionary new.
	metaclasses := OrderedDictionary new.
		identityMap := IdentityDictionary new.
	bootstrapDicts := OrderedCollection new.
	symbols := OrderedCollection new
]

{ #category : #initialization }
PowertalkRingImage >> initializeBehavior: anObjectMap [
	| class |
	class := classes at: anObjectMap spec.
	anObjectMap behavior: class instanceBehavior.

]

{ #category : #building }
PowertalkRingImage >> initializeClass: definition superclass: superclass superbehavior: superbehavior [
	| class name flag ivars cvars poolnames pools subclasses format |
	class := classes at: definition.
	class instanceBehavior next: superbehavior.
	subclasses := definition subclasses
		collect: [ :def | classes at: def ].
	subclasses := self newArray: subclasses.
	name := self newString: definition name.
	flag := self formatOfClass: definition.
	format := self newInteger: flag.
	ivars := self newStringArray: definition instVarNames.
	cvars := self createBootstrapCVars: definition.
	poolnames := definition sharedPools collect: #name.
	pools := self newStringArray: poolnames.
	class
		superclass: superclass;
		format: format;
		instanceVariables: ivars;
		classVariables: cvars;
		organization: nilObj;
		name: name;
		subclasses: subclasses;
		sharedPools: pools;
		module: kernel.
	definition metaclass allInstVarNames
		do: [ :ivar | class slotNamed: ivar put: nilObj ]
]

{ #category : #building }
PowertalkRingImage >> initializeMetaclass: definition superclass: superclass [
	| meta ivars flags format superbehavior |
	meta := metaclasses at: definition.
	superbehavior := superclass instanceBehavior.
	meta instanceBehavior next: superbehavior.
	ivars := self newStringArray: definition instVarNames.
	flags := self formatOfClass: definition. 
	format := self newInteger: flags.
	meta
		superclass: superclass;
		format: format;
		instanceVariables: ivars;
		organization: nilObj
]

{ #category : #building }
PowertalkRingImage >> kernel [
	^kernel
]

{ #category : #initialization }
PowertalkRingImage >> log: aString [
	Transcript
		show: aString;
		cr
]

{ #category : #accessing }
PowertalkRingImage >> metaclassFor: anRGBehavior [
	^ metaclasses at: anRGBehavior
]

{ #category : #initialization }
PowertalkRingImage >> metaclasses [
	^metaclasses
]

{ #category : #initialization }
PowertalkRingImage >> newArray: anArray [
	| array |
	array := self newArraySized: anArray size.
	anArray withIndexDo: [ :obj :i | array at: i put: obj ].
	^ array
]

{ #category : #initialization }
PowertalkRingImage >> newArraySized: anInteger [
^self basicNewSlotsOf: arraySpec sized: anInteger.

]

{ #category : #initialization }
PowertalkRingImage >> newAssociation: anAssociation [
	| assoc key value |
	assoc := self newSlots: 'Association'.
	key := self transferLiteralDeep: anAssociation key.
	value := self transferLiteralDeep: anAssociation value.
	^ assoc
		key: key;
		value: value; yourself
]

{ #category : #accessing }
PowertalkRingImage >> newBootstrapDictionaryOf: anRGBehavior [
	"
	Allocate a bootstrap dictionary object. Its contents is managed by the
	mother image, but in the baby smalltalk can do	at: and at:put:, via primitives.
	It is used to replace PoolDictionaries and Namespaces until the baby has been
	initialized and is ready to become a fully working image. At that point, the
	BootstrapDictionaries are converted to the corresponding types and discarded.
	"

	| result |
	result := BootstrapDictionaryMap new
		initializeAs: self => #BootstrapDictionary.
	bootstrapDicts add: result.
	^ result
		realSpec: anRGBehavior;
		image: self
]

{ #category : #accessing }
PowertalkRingImage >> newBytes: classname contents: aByteObject [
	^self basicNewBytes: classname contents: aByteObject
]

{ #category : #initialization }
PowertalkRingImage >> newBytesFrom: aByteObject [
	^self newBytes: aByteObject class name contents: aByteObject
]

{ #category : #accessing }
PowertalkRingImage >> newBytesOf: anRGBehavior contents: aByteObject [
^ self basicNewBytesOf: anRGBehavior contents: aByteObject

]

{ #category : #initialization }
PowertalkRingImage >> newBytesOf: anRGBehavior sized: anInteger [
	| contents |
	contents := ByteArray new: anInteger.
	^ self newBytesOf: anRGBehavior contents: contents
]

{ #category : #accessing }
PowertalkRingImage >> newClosure: anInteger [
	^ ClosureMap new: closureSpec size: anInteger withAll: nilObj
]

{ #category : #accessing }
PowertalkRingImage >> newFloatFrom: aFloat [
	^ self newBytes: 'Float' contents: aFloat pointerDouble
]

{ #category : #initialization }
PowertalkRingImage >> newInteger: anInteger [
	anInteger > maxSMI
		ifTrue: [ ^ self newLargePositiveInteger: anInteger ].
	anInteger < minSMI
		ifTrue: [ ^ self newLargeNegativeInteger: anInteger ].
	^ SmallintObjectMap new: smiSpec valued: anInteger
]

{ #category : #initialization }
PowertalkRingImage >> newLargeNegativeInteger: anInteger [
	| size bytes byte |
	size := (anInteger bytesCount alignedTo: 2) max: wordSize.
	bytes := ByteArray new: size withAll: 16rFF.
	1 to: anInteger bytesCount do: [ :i | 
		byte := anInteger byteAt: i.
		byte > 0
			ifTrue: [ byte := 256 - byte ].
		bytes at: i put: byte ].
	^ self newBytes: #LargeNegativeInteger contents: bytes
]

{ #category : #initialization }
PowertalkRingImage >> newLargePositiveInteger: anInteger [
	| size bytes |
	size := (anInteger bytesCount alignedTo: 2) max: wordSize.
	bytes := anInteger asByteArrayOfSize: size.
	^ self newBytes: #LargePositiveInteger contents: bytes reversed
]

{ #category : #accessing }
PowertalkRingImage >> newOf: anRGBehavior sized: anInteger [
	^ anRGBehavior isBytes
		ifTrue: [ self newBytesOf: anRGBehavior sized: anInteger ]
		ifFalse: [ self newSlotsOf: anRGBehavior sized: anInteger ]
]

{ #category : #initialization }
PowertalkRingImage >> newSlots: classname [
	^self newSlots: classname sized: 0
]

{ #category : #accessing }
PowertalkRingImage >> newSlots: classname sized: size [
	"
	Allocate an object of pointer type (as SlotObjectMap).
	It is niled-out, and 	`size` is the size of indexed part (i.e.,
	shall not include named slots)
	"
^ self basicNewSlots: classname sized: size.

]

{ #category : #accessing }
PowertalkRingImage >> newSlotsOf: anRGBehavior sized: size [
	"
	Allocate an object of pointer type (as SlotObjectMap).
	It is niled-out, and 	`size` is the size of indexed part (i.e.,
	shall not include named slots)
	"

^ self basicNewSlotsOf: anRGBehavior sized: size

]

{ #category : #initialization }
PowertalkRingImage >> newString: aString [
	| bytes |
	bytes := aString copyWith: Character null.
	^self newBytes: 'String' contents: bytes
]

{ #category : #initialization }
PowertalkRingImage >> newStringArray: strings [
	| array bytes |
	array := self newSlots: 'Array' sized: strings size.
	strings
		withIndexDo: [ :s :i |
			bytes := self newString: s.
			array at: i put: bytes ].
	^ array
]

{ #category : #accessing }
PowertalkRingImage >> newSymbol: aSymbol [
	| new |
	identityMap at: aSymbol ifPresent: [ :s | ^ s ].
	new := SymbolMap new: symbolSpec symbol: aSymbol.
	symbols add: new.
	^ identityMap at: aSymbol put: new
]

{ #category : #accessing }
PowertalkRingImage >> nil [
	^ nilObj
]

{ #category : #accessing }
PowertalkRingImage >> runtime [
	^ runtime
]

{ #category : #accessing }
PowertalkRingImage >> speciesFor: anRGBehavior [
	^ anRGBehavior isMeta ifTrue: [metaclasses at: anRGBehavior] ifFalse: [ classes at: anRGBehavior ]
]

{ #category : #accessing }
PowertalkRingImage >> specs [
	^specs
]

{ #category : #accessing }
PowertalkRingImage >> specs: anRGEnvironment [
	specs := anRGEnvironment.
	closureSpec := self => #Closure.
	arraySpec := self => #Array.
	smiSpec := self => #SmallInteger.
	symbolSpec := self =>#Symbol
]

{ #category : #accessing }
PowertalkRingImage >> transferBlock: anSCompiledBlock [
	| transferred method format |
	identityMap at: anSCompiledBlock
		ifPresent: [ :b | ^ b ].
	transferred := self newSlots: #CompiledBlock.
	identityMap at: anSCompiledBlock put: transferred.
	method := identityMap at: anSCompiledBlock method.
	format := self newInteger: anSCompiledBlock format.
	transferred
		method: method;
		format: format;
		optimizedCode: nilObj.
	^ transferred
]

{ #category : #accessing }
PowertalkRingImage >> transferLiteral: anObject [
	| class transferred slot |
	class := anObject class.
	(class inheritsFrom: ObjectMap)
		ifTrue: [ ^ anObject ].
	(class inheritsFrom: Integer)
		ifTrue: [ ^ self newInteger: anObject ].
	(class inheritsFrom: Symbol)
		ifTrue: [ ^ self newSymbol: anObject ].
	(class inheritsFrom: String)
		ifTrue: [ ^ self newString: anObject ].
	class = ByteArray
		ifTrue: [ ^ self newBytesFrom: anObject ].
	transferred := self newSlots: anObject class name sized: anObject size.
	anObject
		withIndexDo: [ :elem :i | 
			slot := self transferLiteralDeep: elem.
			transferred at: i put: slot ].
	^ transferred
]

{ #category : #accessing }
PowertalkRingImage >> transferLiteralDeep: anObject [
	| class transferred slot size ivar |
	class := anObject class.
	anObject isInteger
		ifTrue: [ ^ self newInteger: anObject ].
	anObject == nil
		ifTrue: [ ^ nilObj ].
	anObject == false
		ifTrue: [ ^ falseObj ].
	anObject == true
		ifTrue: [ ^ trueObj ].
	identityMap at: anObject ifPresent: [ :existing | ^ existing ].
	(class == Symbol or:[class inheritsFrom: Symbol])
		ifTrue: [ ^ self newSymbol: anObject ].
	(anObject isString)
		ifTrue: [ ^ self newString: anObject ].
	class = ByteArray
		ifTrue: [ ^ self newBytesFrom: anObject ].
	(class == Float or:[class inheritsFrom: Float])
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
PowertalkRingImage >> transferMethod: anSCompiledMethod in: species [
	| size classname transferred astcodes selector format literal tliteral |
	(identityMap includesKey: anSCompiledMethod)
		ifTrue: [ self ASSERT: false ].
	size := anSCompiledMethod size.
	classname := anSCompiledMethod isCallback
		ifTrue: [ 'CallbackMethod' ]
		ifFalse: [ 'CompiledMethod' ].
	transferred := self newSlots: classname sized: size.
	identityMap at: anSCompiledMethod put: transferred.
	astcodes := self transferLiteralDeep: anSCompiledMethod astcodes.
	selector := self newSymbol: anSCompiledMethod selector.
	format := self newInteger: anSCompiledMethod format.
	transferred
		astcodes: astcodes;
		class: species;
		selector: selector;
		format: format;
		source: nilObj.
	1 to: size do: [ :i | 
		literal := anSCompiledMethod at: i.
		tliteral := self transferLiteralDeep: literal.
		transferred at: i put: tliteral ].
	^ transferred
]

{ #category : #accessing }
PowertalkRingImage >> true [
	^ trueObj
]

{ #category : #accessing }
PowertalkRingImage >> vmPrimitivesSpec [
	^vmPrimitivesSpec
]

{ #category : #accessing }
PowertalkRingImage >> vmPrimitivesSpec: anRGEnvironment [
	vmPrimitivesSpec := anRGEnvironment
]

{ #category : #accessing }
PowertalkRingImage >> wordSize [
	^ wordSize
]

{ #category : #accessing }
PowertalkRingImage >> wordSize: anInteger [
	wordSize := anInteger.
	maxSMI := (1 bitShift: wordSize * 8 - 2) - 1.
	minSMI := maxSMI negated - 1

]
