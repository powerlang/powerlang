Class {
	#name : #PowertalkLMR,
	#superclass : #PowertalkRuntime,
	#instVars : [
		'kernel',
		'wordSize',
		'bootstrapper',
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
		'metaclassInstanceClassIndex',
		'classModuleIndex',
		'moduleNamespaceIndex',
		'byteArrayClass',
		'stringClass',
		'closureBlockIndex',
		'closureClass',
		'lastHash',
		'blockMethodIndex',
		'behaviorClass',
		'classNamespacesIndex',
		'largePositiveIntegerClass',
		'largeNegativeIntegerClass',
		'methodSelectorIndex'
	],
	#pools : [
		'SCompiledBlockFlags',
		'SCompiledMethodFlags'
	],
	#category : #'Powerlang-Core-Execution-LMR'
}

{ #category : #initialization }
PowertalkLMR >> addSymbol: aSymbol [
	| string |
	string := self newString: aSymbol asString.
	^ self sendLocal: #asSymbol to: string
]

{ #category : #initialization }
PowertalkLMR >> arrayClass: anLMRObject [
	arrayClass := anLMRObject 
]

{ #category : #initialization }
PowertalkLMR >> arrayedSizeOf: anLMRObject [
	| species ivars |
	anLMRObject isImmediate ifTrue: [ ^0 ].
	species := self speciesFor: anLMRObject.
	ivars := self speciesInstanceSize: species.
	^anLMRObject size - ivars
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
PowertalkLMR >> behaviorClass_: anLMRObject [
	behaviorClass := anLMRObject
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
PowertalkLMR >> blockCapturesHome: block [
	| flags |
	flags := block slotAt: methodFlagsIndex.
	^ flags value anyMask: BlockCapturesHome
]

{ #category : #initialization }
PowertalkLMR >> blockCapturesSelf: block [
	| flags |
	flags := block slotAt: methodFlagsIndex.
	^ flags value anyMask: BlockCapturesSelf
]

{ #category : #initialization }
PowertalkLMR >> blockClass: anLMRObject [
	blockClass := anLMRObject
]

{ #category : #initialization }
PowertalkLMR >> blockEnvironmentCount: anLMRObject [
	| flags |
	flags := anLMRObject slotAt: methodFlagsIndex.
	^ flags value bitsAt: BlockEnvCount
]

{ #category : #initialization }
PowertalkLMR >> blockExecutionTree: anLMRObject [
	^ anLMRObject slotAt: methodOptimizedCodeIndex
]

{ #category : #initialization }
PowertalkLMR >> blockMethod: anLMRObject [
	^ anLMRObject slotAt: blockMethodIndex
]

{ #category : #initialization }
PowertalkLMR >> blockMethodIndex: anInteger [
	blockMethodIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> blockOptimizedCode: anLMRObject [

	^ self methodOptimizedCode: anLMRObject
]

{ #category : #initialization }
PowertalkLMR >> blockOptimizedCode: anLMRObject put: anObject [
	^ self methodOptimizedCode: anLMRObject put: anObject
]

{ #category : #initialization }
PowertalkLMR >> blockTempCount: anLMRObject [
	| flags |
	flags := anLMRObject slotAt: methodFlagsIndex.
	^ flags value bitsAt: BlockTempCount
]

{ #category : #initialization }
PowertalkLMR >> bootstrapper [
	^bootstrapper
]

{ #category : #initialization }
PowertalkLMR >> bootstrapper: aBootstrapper [
	bootstrapper := aBootstrapper
]

{ #category : #initialization }
PowertalkLMR >> byteArrayClass: anLMRObject [
	byteArrayClass := anLMRObject
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
PowertalkLMR >> classNamespacesIndex: anInteger [
	classNamespacesIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> closureBlock: closure [ 
	^closure slotAt: closureBlockIndex
]

{ #category : #initialization }
PowertalkLMR >> closureBlockIndex: anInteger [
	closureBlockIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> closureClass: anLMRObject [
	closureClass := anLMRObject
]

{ #category : #initialization }
PowertalkLMR >> closureHome: closure [
	| block |
	block := self closureBlock: closure.
	(self blockCapturesHome: block)
		ifFalse: [ self error: 'closure has no home' ].
	^ (self blockCapturesSelf: block)
		ifTrue: [ closure at: 2 ]
		ifFalse: [ closure at: 1 ]
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
PowertalkLMR >> fixOverrides [
	| selector md |
	overrides
		keysAndValuesDo: [ :assoc :method | 
			selector := assoc value.
			md := self behaviorMethodDictionary: assoc key.
			self
				sendLocal: #at:put:
				to: md
				with:
					{selector.
					method} ]
]

{ #category : #initialization }
PowertalkLMR >> hashFor: anLMRObject [
	| shifted hash current |
	anLMRObject isImmediate
		ifTrue: [ ^ anLMRObject value ].
	current := anLMRObject headerHash.
	current != 0
		ifTrue: [ ^ current ].
	shifted := lastHash bitShift: -1.
	hash := (lastHash bitAnd: 1) = 0
		ifTrue: [ shifted ]
		ifFalse: [ shifted bitXor: 16rB9C8 ].
	anLMRObject headerHash: hash.
	^ lastHash := hash
]

{ #category : #initialization }
PowertalkLMR >> initialize [
	lastHash := 1.
	super initialize
]

{ #category : #initialization }
PowertalkLMR >> integerFrom: anLMRObject [
	| behavior class |
	anLMRObject isImmediate
		ifTrue: [ ^ anLMRObject value ].
	behavior := self behaviorOf: anLMRObject.
	class := self behaviorClass: behavior.
	^ class == largePositiveIntegerClass
		ifTrue: [ anLMRObject bytes asLittleEndianPositiveInteger ]
		ifFalse: [ anLMRObject bytes asLittleEndianNegativeInteger ]
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
PowertalkLMR >> kernel [
	^kernel
]

{ #category : #initialization }
PowertalkLMR >> kernel: anLMRObject [ 
	kernel := anLMRObject
]

{ #category : #initialization }
PowertalkLMR >> knownSymbols: associations [
	knownSymbols := Dictionary withAll: associations
]

{ #category : #initialization }
PowertalkLMR >> largeNegativeIntegerClass: anLMRObject [
	largeNegativeIntegerClass := anLMRObject
]

{ #category : #initialization }
PowertalkLMR >> largePositiveIntegerClass: anLMRObject [
	largePositiveIntegerClass := anLMRObject
]

{ #category : #initialization }
PowertalkLMR >> loadAssociationValue: association [
	^ association slotAt: 2.

]

{ #category : #initialization }
PowertalkLMR >> loadModule: symbol [
	^ bootstrapper loadModule: symbol asLocalString
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
	| md table  |
	overrides at: behavior -> aSymbol ifPresent: [ :m | ^ m ].
	md := self behaviorMethodDictionary: behavior.
	table := self dictionaryTable: md.
	2 to: table size by: 2 do: [ :index | 
		(table slotAt: index) == aSymbol
			ifTrue: [ ^ table slotAt: index + 1 ] ].
	^ nil
]

{ #category : #initialization }
PowertalkLMR >> methodInstSize: anInteger [
	methodInstSize := anInteger
]

{ #category : #initialization }
PowertalkLMR >> methodOptimizedCode: anLMRObject [
	| slot |
	slot := anLMRObject slotAt: methodOptimizedCodeIndex.
	^ slot == nilObj ifTrue: [ slot ] ifFalse: [ slot code ]
]

{ #category : #initialization }
PowertalkLMR >> methodOptimizedCode: anLMRObject put: anObject [
	| behavior header code |
	behavior := self speciesInstanceBehavior: arrayClass.
	header := LMRObjectHeader new
		behavior: behavior;
		bytes: false arrayed: true named: false;
		size: 0;
		hash: 0.

	code := LMRExecutableCode new header: header; code: anObject.
	^ anLMRObject slotAt: methodOptimizedCodeIndex put: code
]

{ #category : #initialization }
PowertalkLMR >> methodOptimizedCodeIndex: anInteger [
	methodOptimizedCodeIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> methodSelector: anLMRObject [

	^ anLMRObject slotAt: methodSelectorIndex
]

{ #category : #initialization }
PowertalkLMR >> methodSelectorIndex: anInteger [

	methodSelectorIndex := anInteger
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
PowertalkLMR >> newArray: anArray [
| result |
result := 	self newArraySized: anArray size.
	anArray withIndexDo: [ :elem :i | result at: i put: elem ].
	^result
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
PowertalkLMR >> newByteArray: aByteArray [
	| behavior header |
	behavior := self speciesInstanceBehavior: byteArrayClass.
	header := LMRObjectHeader new
		behavior: behavior;
		bytes: false arrayed: true named: false;
		size: aByteArray size;
		hash: 0.
	^ LMRByteObject new header: header; bytes: aByteArray
]

{ #category : #initialization }
PowertalkLMR >> newBytes: species size: anInteger [
	| behavior header |
	behavior := self speciesInstanceBehavior: species.
	header := LMRObjectHeader new
		behavior: behavior;
		bytes: false arrayed: true named: false;
		size: anInteger;
		hash: 0.
	^ LMRByteObject new
		header: header;
		bytes: (ByteArray new: anInteger)
]

{ #category : #initialization }
PowertalkLMR >> newBytesOf: species sized: size [
	^ self newBytes: species size: size
]

{ #category : #initialization }
PowertalkLMR >> newCharacter: aCharacter [
	| value |
	value := self newInteger: aCharacter asInteger.
	^self sendLocal: #asCharacter to: value.

]

{ #category : #initialization }
PowertalkLMR >> newClosureFor: compiledBlock [
	| size closure |
	size := self blockEnvironmentCount: compiledBlock.
	closure := self newSlots: closureClass size:  size.
	closure slotAt: closureBlockIndex put: compiledBlock.
	^ closure
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
PowertalkLMR >> newLargeNegativeInteger: anInteger [
	| size bytes byte result complement |
	size := (anInteger bytesCount alignedTo: 2) max: wordSize.
	complement := anInteger negated - 1.
	bytes := ByteArray new: size withAll: 16rFF.
	1 to: anInteger bytesCount do: [ :i | 
		byte := 255 - (complement byteAt: i).
		bytes at: i put: byte ].
	(bytes at: size) < 128 ifTrue: [ bytes := bytes, #[16rFF 16rFF] ].
	result := self newBytes: largeNegativeIntegerClass size: bytes size.
	^result bytes: bytes

]

{ #category : #initialization }
PowertalkLMR >> newLargePositiveInteger: anInteger [
	| size bytes result |
	size := (anInteger bytesCount alignedTo: 2) max: wordSize.
	bytes := anInteger asByteArrayOfSize: size.
	result := self newBytes: largePositiveIntegerClass size: size.
	^ result bytes: bytes reversed
]

{ #category : #initialization }
PowertalkLMR >> newOf: aSpecies sized: anInteger [
	^(self speciesIsBytes: aSpecies)
		ifTrue: [ self newBytes: aSpecies size: anInteger ]
		ifFalse: [ self newSlots: aSpecies size: anInteger ]
]

{ #category : #initialization }
PowertalkLMR >> newSlots: class [
	^self newSlots: class size: 0
]

{ #category : #initialization }
PowertalkLMR >> newSlots: class size: anInteger [
	| ivars behavior header result |
	ivars := self speciesInstanceSize: class.
	behavior := self speciesInstanceBehavior: class.
	header := LMRObjectHeader new
		behavior: behavior;
		bytes: false arrayed: false named: true;
		size: ivars + anInteger;
		hash: 0.
	result := class == behaviorClass
		ifTrue: [ LMRBehaviorObject new runtime: self]
		ifFalse: [ LMRSlotObject new ].
	^ result
		header: header;
		nilSlots: nilObj
]

{ #category : #initialization }
PowertalkLMR >> newSlotsOf: class [
	^ self newSlots: class size: 0
]

{ #category : #initialization }
PowertalkLMR >> newSmallInteger: anInteger [
	^ LMRSmallInteger new value: anInteger
]

{ #category : #initialization }
PowertalkLMR >> newString: aString [
	| behavior header bytes |
	behavior := self speciesInstanceBehavior: stringClass.
	bytes := aString asByteArray copyWith: 0.
	header := LMRObjectHeader new
		behavior: behavior;
		bytes: false arrayed: true named: false;
		size: bytes size;
		hash: 0.
	^ LMRByteObject new
		header: header;
		bytes: bytes
]

{ #category : #initialization }
PowertalkLMR >> nil: n true: t false: f [
	nilObj := n.
	trueObj := t.
	falseObj := f
]

{ #category : #initialization }
PowertalkLMR >> override: assoc with: method [
	overrides at: assoc put: method
]

{ #category : #initialization }
PowertalkLMR >> print: anLMRObject on: aStream [
	| species name selector |
	species := self behaviorClass: anLMRObject behavior.
	name := self speciesLocalName: species.
	name = 'Symbol'
		ifTrue: [ ^ aStream nextPutAll: '<#' , anLMRObject asLocalString , '>' ].
	name = 'String'
		ifTrue: [ ^ aStream nextPutAll: '<''' , anLMRObject asLocalString , '''>' ].
	name = 'CompiledMethod'
		ifTrue: [
			selector := anLMRObject slotAt: methodSelectorIndex.
			selector := selector == nilObj ifTrue: ['<nil>'] ifFalse: [ selector asLocalString ].
			  ^ aStream
				nextPutAll: '<';
				print: (self methodClassBinding: anLMRObject);
				nextPutAll: '>>#';
				nextPutAll: selector;
				nextPutAll: '>' ].
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
PowertalkLMR >> removeOverride: assoc [
	| species selector |
	species := assoc key.
	selector := assoc value.
	overrides removeKey: species -> selector.
	methodCache removeKey: selector -> species ifAbsent: nil.
	symbolCache
		at: selector
		ifPresent: [ :messages | messages do: #flushCache ]
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
	^ (anLMRObject slotAt: speciesFormatIndex) value bitAnd: 16r7F.
]

{ #category : #initialization }
PowertalkLMR >> speciesIsBytes: anLMRObject [
	^ (anLMRObject slotAt: speciesFormatIndex) value noMask: 16r4000
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
PowertalkLMR >> speciesNamespaces: anLMRObject [
	| class |
	class := self speciesInstanceClass: anLMRObject.
	^class slotAt: classNamespacesIndex
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
PowertalkLMR >> stringClass: anLMRObject [
	stringClass := anLMRObject
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
