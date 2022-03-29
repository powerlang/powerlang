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
		'namespace',
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

{ #category : #accessing }
PowertalkRingRuntime >> evaluateClosure: closure withArgs: arguments [
		| frame sblock evaluator result |
	frame := closure builder.
	sblock := closure astcodes.
	evaluator := frame copy beBlock.
	self pushFrame: evaluator.
	result := sblock isInlined
		ifTrue: [ evaluator evaluateBlock: sblock args: arguments ]
		ifFalse: [ evaluator evaluateBlock: sblock args: arguments closure: closure ].
	self popFrame
	.^ result
]

{ #category : #accessing }
PowertalkRingRuntime >> evaluatePrimitivePrimeFor: anInteger [
	| result |

	result := #(2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103 107 109 113 127 131 137 139 149 151 157 163 167 173 179 181 191 193 197 199 211 223 227 229 233 239 241 251 269 359 479 641 857 1151 1549 2069 2237 2423 2617 2797 2999 3167 3359 3539 3727 3911 4441 4787 5119 5471 5801 6143 6521 6827 7177 7517 7853 8783 9601 10243 10867 11549 12239 12919 13679 14293 15013 15731 17569 19051 20443 21767 23159 24611 25847 27397 28571 30047 31397 35771 38201 40841 43973 46633 48989 51631 54371 57349 60139 62969)
		detect: [ :i | i >= anInteger ].
	^ self newInteger: result
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
	self initializeEmulationOverrides; initializePrimitives; initializeUndermessages
]

{ #category : #services }
PowertalkRingRuntime >> isClosure: anObjectMap [
	^anObjectMap class = ClosureMap
]

{ #category : #accessing }
PowertalkRingRuntime >> loadAssociationValue: association [
	^association value
]

{ #category : #accessing }
PowertalkRingRuntime >> loadNamed: aSymbol in: receiver [
	| species |
	(receiver loadIvar: aSymbol) ifNotNil: [ :value | ^ value ].
	species := image speciesFor: receiver spec.
	^species loadNamed: aSymbol
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
PowertalkRingRuntime >> namespace [
	^ namespace
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
PowertalkRingRuntime >> speciesFor: anObjectMap [
	^ image speciesFor: anObjectMap spec
]

{ #category : #accessing }
PowertalkRingRuntime >> storeAssociation: association value: anObject [
	association value: anObject
]

{ #category : #accessing }
PowertalkRingRuntime >> storeNamed: aSymbol in: receiver with: anObject [
	| species |
	(receiver storeIvar: aSymbol with: anObject)
		ifNotNil: [ :value | ^ value ].
	species := image speciesFor: receiver spec.
	^species storeNamed: aSymbol with: anObject

]

{ #category : #services }
PowertalkRingRuntime >> superBehavior [
	^frames last classBinding superclass instanceSpec
]

{ #category : #services }
PowertalkRingRuntime >> symbolFrom: anObjectMap [
	^ anObjectMap symbol
]

{ #category : #services }
PowertalkRingRuntime >> symbolFromLocal: aSymbol [
	^aSymbol
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
