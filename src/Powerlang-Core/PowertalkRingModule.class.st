"
I'm in charge of creating and managing the objects of an image. I'm created from a spec,
and I know how to bootstrap and connect an initial graph of objects and classes.

I do not add the spec methods to classes, as it requires some emulation done by
the `VirtualRuntime`. That step is left to the `VirtualImage`
that also creates the Kernel module.
"
Class {
	#name : #PowertalkRingModule,
	#superclass : #Object,
	#instVars : [
		'nilObj',
		'falseObj',
		'trueObj',
		'classes',
		'metaclasses',
		'runtime',
		'symbols',
		'identityMap',
		'specs',
		'vmPrimitivesSpec',
		'module',
		'kernel'
	],
	#classVars : [
		'KernelSpec',
		'LMRBootstrapperSpec',
		'VMPrimitivesSpec'
	],
	#category : #'Powerlang-Core-Execution-Ring'
}

{ #category : #accessing }
PowertalkRingModule class >> fromSpec [
	^ self new specs: self kernelSpec; vmPrimitivesSpec: self vmPrimitivesSpec
]

{ #category : #accessing }
PowertalkRingModule class >> kernelSpec [
	^ KernelSpec ifNil: [ KernelSpec := self readSpec: #Kernel at: '.' ]
]

{ #category : #accessing }
PowertalkRingModule class >> lmrBootstrapper [
	^ self new
		specs: self lmrBootstrapperSpec
]

{ #category : #accessing }
PowertalkRingModule class >> lmrBootstrapperSpec [
	^ LMRBootstrapperSpec
		ifNil: [ LMRBootstrapperSpec := self readSpec: #Bootstrapper at: 'Core' ]
]

{ #category : #'instance creation' }
PowertalkRingModule class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #accessing }
PowertalkRingModule class >> readSpec: specName at: path [
	| root current repo spec subdir |
	root := '.' asFileReference.
	current := (root / 'specs' / 'current') contents asString trim.
	subdir := path isString ifTrue: [ path ] ifFalse: [ path asPath pathString ].
	repo := TonelRepository new
		directory: root / 'specs' / current / subdir.
		
	spec := repo asRingEnvironmentWith: {('.' split: specName) last}.
	^ spec clean
]

{ #category : #accessing }
PowertalkRingModule class >> resetSpecs [
	KernelSpec := nil.
	VMPrimitivesSpec := nil.
	LMRBootstrapperSpec := nil
]

{ #category : #accessing }
PowertalkRingModule class >> vmPrimitivesSpec [
	^ VMPrimitivesSpec
		ifNil: [ VMPrimitivesSpec := self readSpec: #VM at: 'Kernel' ]
]

{ #category : #initialization }
PowertalkRingModule >> => aSymbol [
	^ specs at: aSymbol
]

{ #category : #services }
PowertalkRingModule >> basicNewBytes: classname contents: aByteObject [
	^ self basicNewBytesOf: self => classname contents: aByteObject
]

{ #category : #services }
PowertalkRingModule >> basicNewBytesOf: anRGBehavior  contents: aByteObject [
	^ ByteObjectMap new: anRGBehavior valued: aByteObject
]

{ #category : #accessing }
PowertalkRingModule >> basicNewSlots: classname [
	^ self basicNewSlots: classname sized: 0
]

{ #category : #accessing }
PowertalkRingModule >> basicNewSlots: classname in: spec [
	^ self basicNewSlots: classname in: spec sized: 0
]

{ #category : #accessing }
PowertalkRingModule >> basicNewSlots: classname in: spec sized: size [
	| species |
	species := spec at: classname.
	^self basicNewSlotsOf: species sized: size
]

{ #category : #accessing }
PowertalkRingModule >> basicNewSlots: classname sized: size [
	^ self basicNewSlots: classname in: specs sized: size
]

{ #category : #accessing }
PowertalkRingModule >> basicNewSlotsOf: anRGBehavior sized: size [
	^ SlotObjectMap new: anRGBehavior size: size withAll: nilObj
]

{ #category : #'own services' }
PowertalkRingModule >> buildSpecies: spec [
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

{ #category : #accessing }
PowertalkRingModule >> classFor: anRGBehavior [
	^classes at: anRGBehavior
]

{ #category : #building }
PowertalkRingModule >> classNamed: aString [
	^self classFor: self => aString
]

{ #category : #accessing }
PowertalkRingModule >> classes [
	^ classes
]

{ #category : #initialization }
PowertalkRingModule >> createMethodDictionary: species sized: anInteger [
	| behavior md size dictionary |
	behavior := species instanceBehavior.
	md := self classNamed: #MethodDictionary.
	size := kernel newInteger: anInteger.
	dictionary := runtime sendLocal: #new: to: md with: {size}.
	behavior methods: dictionary.
	^ dictionary
]

{ #category : #accessing }
PowertalkRingModule >> createSpecies: definition [
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
PowertalkRingModule >> false [
	^ falseObj
]

{ #category : #initialization }
PowertalkRingModule >> fillClasses [
	| class meta |
	specs allClasses
		do: [ :def | 
			class := self classFor: def.
			meta := self metaclassFor: def metaclass.
			self
				fillSpecies: meta with: def metaclass;
				fillSpecies: class with: def ]
]

{ #category : #initialization }
PowertalkRingModule >> fillSpecies: species with: classDefinition [
	| dictionary smethod transferred |
	dictionary := self
		createMethodDictionary: species
		sized: classDefinition methods size.
	classDefinition methods
		do: [ :methodDefinition | 
			smethod := runtime compile: methodDefinition.
			transferred := kernel transferMethod: smethod in: species.
			runtime
				sendLocal: #basicAt:put:
				to: dictionary
				with:
					{transferred selector.
					transferred} ]
]

{ #category : #initialization }
PowertalkRingModule >> fillSymbols [
	| table namespaces cvars |
	namespaces := (self classNamed: #Symbol) namespaces.
	cvars := namespaces at: 1.
	table := cvars at: 'SymbolTable'.
	symbols
		do: [ :sym | kernel runtime sendLocal: #add: to: table with: {sym} ]
]

{ #category : #initialization }
PowertalkRingModule >> formatOfClass: definition [
	| variable pointers  |
	variable := definition isVariable
		ifTrue: [ 16r2000 ]
		ifFalse: [ 0 ].
	pointers := definition isBytes
		ifTrue: [ 0 ]
		ifFalse: [ 16r4000 ].
	^ variable | pointers | definition allInstVarNames size
]

{ #category : #initialization }
PowertalkRingModule >> formatOfMetaclass: definition [
	| variable pointers size |
	variable := definition isVariable
		ifTrue: [ 16r2000 ]
		ifFalse: [ 0 ].
	pointers := definition isBytes
		ifTrue: [ 0 ]
		ifFalse: [ 16r4000 ].
	size := (self => #Class) allInstVarNames size
		+ definition allInstVarNames size.
	^ variable | pointers | size
]

{ #category : #building }
PowertalkRingModule >> generateLMR [
	^(RingBasedLMRBootstrapper new image: self) convert
]

{ #category : #accessing }
PowertalkRingModule >> genesis [
	specs allClasses do: [ :def | self createSpecies: def ].
	specs allClasses do: [ :def | self buildSpecies: def ].

]

{ #category : #initialization }
PowertalkRingModule >> initialize [
	classes := OrderedDictionary new.
	metaclasses := OrderedDictionary new.
	identityMap := IdentityDictionary new.
	symbols := OrderedCollection new
]

{ #category : #initialization }
PowertalkRingModule >> initializeBehavior: anObjectMap [
	| class |
	class := classes at: anObjectMap spec.
	anObjectMap behavior: class instanceBehavior.

]

{ #category : #building }
PowertalkRingModule >> initializeClass: definition superclass: superclass superbehavior: superbehavior [
	| class name flag ivars namespaces subclasses format |
	class := classes at: definition.
	class instanceBehavior next: superbehavior.
	subclasses := definition subclasses
		collect: [ :def | classes at: def ].
	subclasses := kernel newArray: subclasses.
	name := kernel newString: definition name.
	flag := self formatOfClass: definition.
	format := kernel newInteger: flag.
	ivars := kernel newStringArray: definition instVarNames.
	namespaces := kernel createClassNamespaces: definition.
	class
		superclass: superclass;
		format: format;
		instanceVariables: ivars;
		namespaces: namespaces;
		organization: nilObj;
		name: name;
		subclasses: subclasses;
		module: module.
	definition metaclass allInstVarNames
		do: [ :ivar | class slotNamed: ivar put: nilObj ]
]

{ #category : #building }
PowertalkRingModule >> initializeMetaclass: definition superclass: superclass [
	| meta ivars flags format superbehavior |
	meta := metaclasses at: definition.
	superbehavior := superclass instanceBehavior.
	meta instanceBehavior next: superbehavior.
	ivars := kernel newStringArray: definition instVarNames.
	flags := kernel formatOfMetaclass: definition.
	format := kernel newInteger: flags.
	meta
		superclass: superclass;
		format: format;
		instanceVariables: ivars;
		organization: nilObj
]

{ #category : #initialization }
PowertalkRingModule >> kernel: aPowertalkRingKernelModule [
	kernel := aPowertalkRingKernelModule.
	nilObj := kernel nil.
	trueObj := kernel true.
	falseObj := kernel false.
	
]

{ #category : #initialization }
PowertalkRingModule >> log: aString [
	Transcript
		show: aString;
		cr
]

{ #category : #accessing }
PowertalkRingModule >> metaclassFor: anRGBehavior [
	^ metaclasses at: anRGBehavior
]

{ #category : #initialization }
PowertalkRingModule >> metaclasses [
	^metaclasses
]

{ #category : #initialization }
PowertalkRingModule >> newArray: anArray [
	| array |
	array := self newArraySized: anArray size.
	anArray withIndexDo: [ :obj :i | array at: i put: obj ].
	^ array
]

{ #category : #accessing }
PowertalkRingModule >> newBytes: classname contents: aByteObject [
	^self basicNewBytes: classname contents: aByteObject
]

{ #category : #initialization }
PowertalkRingModule >> newBytesFrom: aByteObject [
	^self newBytes: aByteObject class name contents: aByteObject
]

{ #category : #accessing }
PowertalkRingModule >> newBytesOf: anRGBehavior contents: aByteObject [
^ self basicNewBytesOf: anRGBehavior contents: aByteObject

]

{ #category : #initialization }
PowertalkRingModule >> newBytesOf: anRGBehavior sized: anInteger [
	| contents |
	contents := ByteArray new: anInteger.
	^ self newBytesOf: anRGBehavior contents: contents
]

{ #category : #accessing }
PowertalkRingModule >> newOf: anRGBehavior sized: anInteger [
	^ anRGBehavior isBytes
		ifTrue: [ self newBytesOf: anRGBehavior sized: anInteger ]
		ifFalse: [ self newSlotsOf: anRGBehavior sized: anInteger ]
]

{ #category : #initialization }
PowertalkRingModule >> newSlots: classname [
	^self newSlots: classname sized: 0
]

{ #category : #accessing }
PowertalkRingModule >> newSlots: classname sized: size [
	"
	Allocate an object of pointer type (as SlotObjectMap).
	It is niled-out, and 	`size` is the size of indexed part (i.e.,
	shall not include named slots)
	"
^ self basicNewSlots: classname sized: size.

]

{ #category : #accessing }
PowertalkRingModule >> newSlotsOf: anRGBehavior sized: size [
	"
	Allocate an object of pointer type (as SlotObjectMap).
	It is niled-out, and 	`size` is the size of indexed part (i.e.,
	shall not include named slots)
	"

^ self basicNewSlotsOf: anRGBehavior sized: size

]

{ #category : #accessing }
PowertalkRingModule >> nil [
	^ nilObj
]

{ #category : #accessing }
PowertalkRingModule >> runtime [
	^ runtime
]

{ #category : #accessing }
PowertalkRingModule >> speciesFor: anRGBehavior [
	^ anRGBehavior isMeta ifTrue: [metaclasses at: anRGBehavior] ifFalse: [ classes at: anRGBehavior ]
]

{ #category : #accessing }
PowertalkRingModule >> specs [
	^specs
]

{ #category : #accessing }
PowertalkRingModule >> specs: anRGEnvironment [
	specs := anRGEnvironment.

]

{ #category : #accessing }
PowertalkRingModule >> transferLiteral: anObject [
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
PowertalkRingModule >> transferLiteralDeep: anObject [
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
	(class == Symbol or: [ class inheritsFrom: Symbol ])
		ifTrue: [ ^ self newSymbol: anObject ].
	anObject isString
		ifTrue: [ ^ self newString: anObject ].
	class = ByteArray
		ifTrue: [ ^ self newBytesFrom: anObject ].
	(class == Float or: [ class inheritsFrom: Float ])
		ifTrue: [ ^ self newFloatFrom: anObject ].
	(class inheritsFrom: ObjectMap)
		ifTrue: [ ^ anObject ].
	class == SCompiledBlock
		ifTrue: [ ^ self transferBlock: anObject ].
	class == Character ifTrue: [ ^self transferCharacter: anObject ].
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

{ #category : #accessing }
PowertalkRingModule >> true [
	^ trueObj
]

{ #category : #accessing }
PowertalkRingModule >> vmPrimitivesSpec [
	^vmPrimitivesSpec
]

{ #category : #accessing }
PowertalkRingModule >> vmPrimitivesSpec: anRGEnvironment [
	vmPrimitivesSpec := anRGEnvironment
]
