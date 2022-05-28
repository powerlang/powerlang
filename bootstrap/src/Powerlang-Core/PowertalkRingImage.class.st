Class {
	#name : #PowertalkRingImage,
	#superclass : #PowertalkRingModule,
	#instVars : [
		'bootstrapDicts',
		'arraySpec',
		'closureSpec',
		'smiSpec',
		'symbolSpec',
		'wordSize',
		'minSMI',
		'maxSMI'
	],
	#category : #'Powerlang-Core-Execution-Ring'
}

{ #category : #'own services' }
PowertalkRingImage >> bootstrap [
	runtime
		sendLocal: #bootstrap to: module;
		removeBootstrapDictionaryOverrides
]

{ #category : #'own services' }
PowertalkRingImage >> bootstrapDictionaries [
	^bootstrapDicts
]

{ #category : #'own services' }
PowertalkRingImage >> builder [
	^	RingBasedLMRBootstrapper new image: self.
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
	module namespace: namespace.
	namespace
		at: #WordSize put: wordSize;
		at: #LastHash put: 1.
	classes do: [ :c | namespace at: c name asSymbol put: c ]
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
	module := self basicNewSlots: #KernelModule.
	super genesis.
	self createBootstrapNamespace.
	runtime := PowertalkRingRuntime new.
	runtime image: self
]

{ #category : #accessing }
PowertalkRingImage >> initialize [
	super initialize.
	bootstrapDicts := OrderedCollection new.
	kernel := self
]

{ #category : #building }
PowertalkRingImage >> kernel [
	^module
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
PowertalkRingImage >> specs: anRGEnvironment [
	super specs: anRGEnvironment.
	closureSpec := self => #Closure.
	arraySpec := self => #Array.
	smiSpec := self => #SmallInteger.
	symbolSpec := self => #Symbol
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
PowertalkRingImage >> wordSize [
	^ wordSize
]

{ #category : #accessing }
PowertalkRingImage >> wordSize: anInteger [
	wordSize := anInteger.
	maxSMI := (1 bitShift: wordSize * 8 - 2) - 1.
	minSMI := maxSMI negated - 1

]
