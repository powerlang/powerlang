"
I allow sending messages to objects of the `VirtualSmalltalkImage`.
The messages are interpreted and evaluated with the objects living in
that virtual image, and our semantics tries to mimic as much as possible
the one of the final system.
"
Class {
	#name : #PowertalkRingRuntime,
	#superclass : #PowertalkRuntime,
	#instVars : [
		'image',
		'sexpressionsCache',
		'overrides'
	],
	#category : #'Powerlang-Core-Execution-Ring'
}

{ #category : #'instance creation' }
PowertalkRingRuntime class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #services }
PowertalkRingRuntime >> argumentCountOf: anObjectMap [
	^ anObjectMap argumentCount
]

{ #category : #services }
PowertalkRingRuntime >> behaviorOf: anObjectMap [
	^ anObjectMap spec
]

{ #category : #accessing }
PowertalkRingRuntime >> compile: anRGMethod [
	| class |
	class := image speciesFor: anRGMethod parent.
	^ SCompiler new
		forClass: class;
		compile: anRGMethod sourceCode
]

{ #category : #accessing }
PowertalkRingRuntime >> doLookup: aSymbol startingAt: aBehavior [
	| behavior m c smethod |
	self ASSERT: aSymbol !== #error:.
	behavior := aBehavior.
	[ m := self methodFor: aSymbol in: behavior.
	m
		ifNotNil: [ smethod := self compile: m.
			^ self transferMethodLiterals: smethod ].
	behavior := behavior superclass.
	behavior notNil ] whileTrue.
	^ aBehavior isMeta
		ifTrue: [ c := aBehavior environment at: #Class.
			self doLookup: aSymbol startingAt: c ]
]

{ #category : #services }
PowertalkRingRuntime >> homeFrameOf: aClosureMap [
	^ aClosureMap slotAt: 2
]

{ #category : #services }
PowertalkRingRuntime >> homeFrameOf: aClosureMap put: anObject [
	^ aClosureMap slotAt: 2 put: anObject
]

{ #category : #accessing }
PowertalkRingRuntime >> image [
	^image
]

{ #category : #accessing }
PowertalkRingRuntime >> image: aPowertalkImage [
	image := aPowertalkImage.
	nilObj := image nil.
	trueObj := image true.
	falseObj := image false.
	self
		initializeEmulationOverrides;
		initializeInterpreter
]

{ #category : #accessing }
PowertalkRingRuntime >> initialize [
	super initialize.
	overrides := Dictionary new.
]

{ #category : #initialization }
PowertalkRingRuntime >> initializeEmulationOverrides [
	self
		override: #Species -> #basicNew with: 'New';
		override: #Species -> #basicNew: with: 'NewSized';
		override: #Species -> #new with: 'New';
		override: #Species -> #new: with: 'NewSized';
		override: #Species -> #primitiveNewBytes: with: 'NewBytes';
		override: #'Float class' -> #new with: 'FloatNew';
		override: #'PoolDictionary class' -> #new with: 'DictionaryNew';
		override: #'Namespace class' -> #new with: 'DictionaryNew';
		override: #ProtoObject -> #_size with: 'UnderSize';
		override: #ProtoObject -> #behavior with: 'Behavior';
		override: #ProtoObject -> #class with: 'Class';
		override: #ProtoObject -> #== with: 'Equal';
		override: #ProtoObject -> #primitiveSize with: 'Size';
		override: #ProtoObject -> #primitiveAt: with: 'At';
		override: #ProtoObject -> #primitiveAt:put: with: 'AtPut';
		override: #ProtoObject -> #basicHash with: 'Hash';
		override: #SmallInteger -> #+ with: 'SMIPlus';
		override: #SmallInteger -> #- with: 'SMIMinus';
		override: #SmallInteger -> #* with: 'SMITimes';
		override: #SmallInteger -> #// with: 'SMIIntDiv';
		override: #SmallInteger -> #\\ with: 'SMIIntQuot';
		override: #SmallInteger -> #bitAnd: with: 'SMIBitAnd';
		override: #SmallInteger -> #bitXor: with: 'SMIBitXor';
		override: #SmallInteger -> #bitShift: with: 'SMIBitShift';
		override: #SmallInteger -> #highBit with: 'SMIHighBit';
		override: #SmallInteger -> #> with: 'SMIGreaterThan';
		override: #SmallInteger -> #>= with: 'SMIGreaterEqualThan';
		override: #SmallInteger -> #= with: 'SMIEqual';
		override: #SmallInteger -> #sizeInBytes with: 'SMISize';
		override: #Closure -> #value with: 'ClosureValue';
		override: #Closure -> #evaluateAtomically with: 'ClosureValue';
		override: #Closure -> #value: with: 'ClosureValueWithArgs';
		override: #Closure -> #value:value: with: 'ClosureValueWithArgs';
		override: #Closure -> #value:value:value:
			with: 'ClosureValueWithArgs';
		override: #Closure -> #evaluateWith: with: 'ClosureValueWithArgs';
		override: #Closure -> #evaluateWith:with:
			with: 'ClosureValueWithArgs';
		override: #Closure -> #argumentCount with: 'ClosureArgumentCount';
		override: #String -> #replaceFrom:to:with:startingAt:
			with: 'StringReplaceFromToWithStartingAt';
		override: #'HashTable class' -> #primeFor: with: 'PrimeFor'
]

{ #category : #services }
PowertalkRingRuntime >> isClosure: anObjectMap [
	^anObjectMap class = ClosureMap
]

{ #category : #accessing }
PowertalkRingRuntime >> literalFor: anObject [
	^ image transferLiteral: anObject
]

{ #category : #accessing }
PowertalkRingRuntime >> loadAssociationValue: association [
	^association value
]

{ #category : #services }
PowertalkRingRuntime >> localSymbolFrom: anObjectMap [
	^ anObjectMap symbol
]

{ #category : #accessing }
PowertalkRingRuntime >> lookupAssociationFor: aSymbol in: dictionary [
^dictionary
				associationAt: aSymbol
				ifPresent: [ :assoc | assoc]
]

{ #category : #services }
PowertalkRingRuntime >> methodEnvironmentSize: anSCompiledMethod [
	^anSCompiledMethod environmentCount
]

{ #category : #accessing }
PowertalkRingRuntime >> methodFor: aSymbol in: anRGBehavior [
	overrides at: anRGBehavior->aSymbol ifPresent: [:m | ^m].
	^anRGBehavior methodNamed: aSymbol
]

{ #category : #accessing }
PowertalkRingRuntime >> moduleNamespace: anObjectMap [ 
	^ anObjectMap namespace
]

{ #category : #accessing }
PowertalkRingRuntime >> newBootstrapDictionaryOf: aSpeciesMap [
	^ image newBootstrapDictionaryOf: aSpeciesMap spec instanceSide
]

{ #category : #accessing }
PowertalkRingRuntime >> newBytesOf:  aSpeciesMap sized: size [
	^ image newOf: aSpeciesMap spec instanceSide sized: size
]

{ #category : #accessing }
PowertalkRingRuntime >> newClosure: anInteger [
	^ image newClosure: anInteger
]

{ #category : #accessing }
PowertalkRingRuntime >> newEnvironmentSized: anInteger [
	^ image newArraySized: anInteger
]

{ #category : #accessing }
PowertalkRingRuntime >> newInteger: anInteger [
	^image newInteger: anInteger
]

{ #category : #accessing }
PowertalkRingRuntime >> newOf: aSpeciesMap sized: size [
	^ image newOf: aSpeciesMap spec instanceSide sized: size
]

{ #category : #accessing }
PowertalkRingRuntime >> newSlotsOf: aSpeciesMap [
	^image newSlotsOf: aSpeciesMap spec instanceSide sized: 0
]

{ #category : #accessing }
PowertalkRingRuntime >> override: assoc with: primitive [
	| species selector method override count source |
	species := image specs at: assoc key.
	selector := assoc value.
	source := String
		streamContents: [ :s | 
			selector numArgs = 0
				ifTrue: [ s nextPutAll: selector ]
				ifFalse: [ count := 1.
					selector keywords
						do: [ :keyword | 
							s
								nextPutAll: keyword;
								nextPutAll: ' arg';
								nextPutAll: count asString;
								space . 					count := count + 1 ].
].
			s nextPutAll: '<primitive: ' , primitive , '>' ].
	method := species methodNamed: selector.
	override := method copy sourceCode: source.
	overrides at: species -> selector put: override
]

{ #category : #accessing }
PowertalkRingRuntime >> removeBootstrapDictionaryOverrides [
self
		removeOverride: #'PoolDictionary class' -> #new;
		removeOverride: #'Namespace class' -> #new

]

{ #category : #accessing }
PowertalkRingRuntime >> removeOverride: assoc [
	| species selector |
	species := image specs at: assoc key.
	selector := assoc value.
	
	overrides removeKey: species -> selector.
	methodCache removeKey: selector -> species ifAbsent: nil

]

{ #category : #accessing }
PowertalkRingRuntime >> sexpressionsOf: anSCompiledMethod [
	^ anSCompiledMethod prepareForExecution; optimizedCode
]

{ #category : #accessing }
PowertalkRingRuntime >> speciesClassVariables: aSpeciesMap [
	^ aSpeciesMap classVariables
]

{ #category : #accessing }
PowertalkRingRuntime >> speciesFor: anObjectMap [
	^ image speciesFor: anObjectMap spec
]

{ #category : #accessing }
PowertalkRingRuntime >> speciesModule: aSpeciesMap [
	^ aSpeciesMap module
]

{ #category : #accessing }
PowertalkRingRuntime >> staticBindingForIvar: aSymbol in: receiver [
	^receiver allSlotNames indexOf: aSymbol.
]

{ #category : #accessing }
PowertalkRingRuntime >> storeAssociation: association value: anObject [
	association value: anObject
]

{ #category : #accessing }
PowertalkRingRuntime >> superBehaviorOf: aSpeciesMap [
	^ aSpeciesMap superclass instanceSpec
]

{ #category : #services }
PowertalkRingRuntime >> symbolFrom: anObjectMap [
	^ anObjectMap symbol
]

{ #category : #services }
PowertalkRingRuntime >> symbolFromLocal: aSymbol [
	^ image newSymbol: aSymbol
]

{ #category : #accessing }
PowertalkRingRuntime >> transferLiteral: anObject [
	^image transferLiteral: anObject
]

{ #category : #accessing }
PowertalkRingRuntime >> transferMethodLiterals: method [
	| class |
	method withIndexDo: [:literal :i | 
		class := literal class.
		((class inheritsFrom: ObjectMap)
			or: [ class = SCompiledBlock ])
			ifFalse: [ method at: i put: (image transferLiteralDeep: literal) ] ].
	^ method
]
