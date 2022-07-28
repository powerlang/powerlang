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
		'sexpressionsCache'
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
self halt.
	^ anObjectMap argumentCount
]

{ #category : #accessing }
PowertalkRingRuntime >> arrayedSizeOf: anObjectMap [
	^anObjectMap arrayedSize
]

{ #category : #services }
PowertalkRingRuntime >> behaviorOf: anObjectMap [
	^ anObjectMap spec
]

{ #category : #services }
PowertalkRingRuntime >> blockArgumentCount: block [
	^ block argumentCount
]

{ #category : #'own services' }
PowertalkRingRuntime >> blockCapturesSelf: block [
	^ block capturesSelf 
]

{ #category : #services }
PowertalkRingRuntime >> blockExecutionTree: block [
	^ block executionTree
]

{ #category : #services }
PowertalkRingRuntime >> blockMethod: anObjectMap [
	^ anObjectMap method
]

{ #category : #services }
PowertalkRingRuntime >> blockOptimizedCode: block [
	^block optimizedCode
]

{ #category : #services }
PowertalkRingRuntime >> blockOptimizedCode: block put: anObject [
	block optimizedCode: anObject
]

{ #category : #services }
PowertalkRingRuntime >> blockTempCount: block [
	^ block tempCount
]

{ #category : #services }
PowertalkRingRuntime >> closureBlock: aClosureMap [
	^aClosureMap block
]

{ #category : #services }
PowertalkRingRuntime >> closureHome: aClosureMap [
	^ aClosureMap home
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
PowertalkRingRuntime >> homeEnvironmentOf: aClosureMap [
	^ aClosureMap slotAt: 2
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

{ #category : #initialization }
PowertalkRingRuntime >> initializeEmulationOverrides [
	| classes |
	classes := image vmPrimitivesSpec allExtensionClasses.
	classes
		do: [ :class | 
			class methods do: [ :m | self override: class name with: m ].
			class metaclass methods
				do: [ :m | self override: class metaclass name with: m ] ]
]

{ #category : #accessing }
PowertalkRingRuntime >> isBlock: anSCompiledMethod [
	^anSCompiledMethod isBlock
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

{ #category : #accessing }
PowertalkRingRuntime >> method: anSCompiledMethod literalAt: index [
	^anSCompiledMethod at: index
]

{ #category : #services }
PowertalkRingRuntime >> methodArgumentCount: method [
	^ method argumentCount
]

{ #category : #services }
PowertalkRingRuntime >> methodClassBinding: method [
	^ method classBinding
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

{ #category : #services }
PowertalkRingRuntime >> methodOptimizedCode: anSCompiledMethod [
	^ anSCompiledMethod optimizedCode
]

{ #category : #services }
PowertalkRingRuntime >> methodOptimizedCode: method put: anObject [
	method optimizedCode: anObject
]

{ #category : #services }
PowertalkRingRuntime >> methodTempCount: method [
	^ method tempCount
]

{ #category : #accessing }
PowertalkRingRuntime >> moduleNamespace: anObjectMap [ 
	^ anObjectMap namespace
]

{ #category : #accessing }
PowertalkRingRuntime >> newArraySized: anInteger [
	^ image newArraySized: anInteger
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
PowertalkRingRuntime >> newClosureFor: compiledBlock [
	| closure |
	closure :=  image newClosure: compiledBlock environmentCount.
	^closure
		block: compiledBlock

]

{ #category : #accessing }
PowertalkRingRuntime >> newCompiledMethod [
	^ SCompiledMethod new
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

{ #category : #services }
PowertalkRingRuntime >> newSymbol: aSymbol [
	^ image newSymbol: aSymbol
]

{ #category : #services }
PowertalkRingRuntime >> override: classname with: rgMethod [
	| species selector method override |
	species := image specs at: classname.
	selector := rgMethod selector.
	method := species methodNamed: selector.
	override := method copy sourceCode: rgMethod sourceCode.
	overrides at: species -> selector put: override
]

{ #category : #accessing }
PowertalkRingRuntime >> override: assoc withPrimitive: primitive [
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
								space.
							count := count + 1 ] ].
			s nextPutAll: '<primitive: ' , primitive , '>' ].
	method := species methodNamed: selector.
	override := method copy sourceCode: source.
	overrides at: species -> selector put: override
]

{ #category : #accessing }
PowertalkRingRuntime >> removeBootstrapDictionaryOverrides [
self
		removeOverride: #'Namespace class' -> #new

]

{ #category : #accessing }
PowertalkRingRuntime >> removeOverride: assoc [
	| species selector symbol |
	species := image specs at: assoc key.
	selector := assoc value.
	overrides removeKey: species -> selector.
	methodCache removeKey: selector -> species ifAbsent: nil.
	symbol := self symbolFromLocal: selector.
	symbolCache
		at: symbol
		ifPresent: [ :messages | messages do: #flushCache ]
]

{ #category : #accessing }
PowertalkRingRuntime >> sexpressionsOf: anSCompiledMethod [
	^ anSCompiledMethod prepareForExecution; optimizedCode
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
PowertalkRingRuntime >> speciesNamespaces: aSpeciesMap [
	^ aSpeciesMap namespaces
]

{ #category : #accessing }
PowertalkRingRuntime >> speciesSuperclass: aSpeciesMap [
	^ aSpeciesMap superclass
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
