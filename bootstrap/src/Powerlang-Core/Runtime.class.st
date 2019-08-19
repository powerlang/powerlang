Class {
	#name : #Runtime,
	#superclass : #Object,
	#instVars : [
		'lookup',
		'storage',
		'objectFormat',
		'bridge',
		'sources',
		'shapeMap',
		'objectModel'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #private }
Runtime class >> forBootstrappingPst: aSmalltalkKernel [
	^ self new
		bridge: BootstrappedPstBridge new;
		objectFormat: (BootstrapObjectFormat on: aSmalltalkKernel);
		storage: aSmalltalkKernel;
		loadBridge
]

{ #category : #private }
Runtime class >> forLocalPharo [
	^ self new
		bridge: PharoBridge new;
		objectFormat: PharoObjectFormat new;
		loadBridge;
		loadShapesFromImage
]

{ #category : #private }
Runtime class >> forSimulatedPst: aByteArray with: aModuleSpec [
	| adapter |
	adapter := ByteArrayAdapter on: aByteArray.
	^ self new
		bridge: PstBridge new;
		objectFormat: (DmrObjectFormat on: adapter);
		storage: adapter;
		loadShapesFrom: aModuleSpec;
		loadBridge
]

{ #category : #private }
Runtime class >> new [
	^self basicNew initialize
]

{ #category : #accessing }
Runtime >> bridge [
	^bridge
]

{ #category : #accessing }
Runtime >> bridge: aBridge [
	bridge := aBridge.
	bridge runtime: self
]

{ #category : #accessing }
Runtime >> false [
	^ bridge false
]

{ #category : #accessing }
Runtime >> globalNamed: name [
	^bridge globalNamed: name
]

{ #category : #'meta accessing' }
Runtime >> handleOn: oid [
	^ObjectHandle on: oid within: self
]

{ #category : #shapes }
Runtime >> indexOf: varname inStructureOf: type [
	^shapeMap indexOf: varname at: type
]

{ #category : #initialization }
Runtime >> initialize [
	shapeMap := ShapeMap new.
	self useMirrorLookup
]

{ #category : #'object format' }
Runtime >> integerHandle: anInteger [
	| oid |
	oid := objectFormat newInteger: anInteger.
	^ self handleOn: oid
]

{ #category : #'object format' }
Runtime >> integerOf: oid [
	^objectFormat integerOf: oid
]

{ #category : #initialization }
Runtime >> isLocal [
	^objectModel == Smalltalk.

]

{ #category : #accessing }
Runtime >> loadBridge [
	bridge findRootObjects
]

{ #category : #initialization }
Runtime >> loadShapesFrom: aModuleSpec [
	objectModel := aModuleSpec.
	aModuleSpec classes do: [ :class | shapeMap load: class ]
]

{ #category : #initialization }
Runtime >> loadShapesFromImage [
	| classes |
	objectModel := Smalltalk.
	classes := #(ClassDescription Class Metaclass) collect: [ :name | Smalltalk at: name ].
	classes do: [ :class | shapeMap load: class ]
]

{ #category : #'meta accessing' }
Runtime >> lookup: aSymbol on: aSubject [
	^lookup lookup: aSymbol on: aSubject
]

{ #category : #'object format' }
Runtime >> newClosureHandle: aPCompiledBlock [
	| oid |
	oid := objectFormat newClosure: aPCompiledBlock.
	"should put a thing that lives in remote runtime, not a PCompiledBlock"
	oid at: 'block' put: aPCompiledBlock.
	^ self handleOn: oid
]

{ #category : #accessing }
Runtime >> nil [
	^bridge nil
]

{ #category : #accessing }
Runtime >> objectFormat [
	^objectFormat
]

{ #category : #accessing }
Runtime >> objectFormat: anObjectFormat [
	objectFormat := anObjectFormat
]

{ #category : #initialization }
Runtime >> objectModel [
	^objectModel
]

{ #category : #initialization }
Runtime >> objectModel: aModuleSpec [
	^objectModel := aModuleSpec
]

{ #category : #storage }
Runtime >> slotOf: object at: index [
	^objectFormat slotOf: object at: index
]

{ #category : #storage }
Runtime >> slotOf: object at: index put: value [
	^ storage slotOf: object at: index put: value
]

{ #category : #accessing }
Runtime >> storage [
	^storage
]

{ #category : #accessing }
Runtime >> storage: anObject [
	storage := anObject
]

{ #category : #storage }
Runtime >> stringOf: oid [
	^objectFormat stringOf: oid
]

{ #category : #shapes }
Runtime >> structureOf: type [
	^shapeMap at: type
]

{ #category : #accessing }
Runtime >> true [
	^ bridge true
]

{ #category : #initialization }
Runtime >> useMirrorLookup [
	lookup := MirrorLookup new
]
