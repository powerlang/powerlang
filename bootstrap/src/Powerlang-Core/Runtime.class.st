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
Runtime class >> forBootstrappingPst: aSmalltalkBootstrapper spec: anRGEnvironment [
	^ self new
		bridge: (BootstrappedPstBridge new bootstrapper: aSmalltalkBootstrapper);
		objectFormat: (BootstrapObjectFormat on: aSmalltalkBootstrapper);
		storage: (BootstrapStorage on: aSmalltalkBootstrapper);
		useEmulationLookup: anRGEnvironment
]

{ #category : #private }
Runtime class >> forEmulatingPst: aSmalltalkBootstrapper [
	^ self new
		bridge: (BootstrappedPstBridge new bootstrapper: aSmalltalkBootstrapper);
		objectFormat: (BootstrapObjectFormat on: aSmalltalkBootstrapper);
		storage: (BootstrapStorage on: aSmalltalkBootstrapper);
		loadBridge
]

{ #category : #private }
Runtime class >> forLocalPharo [
	^ self new
		bridge: PharoBridge new;
		objectFormat: PharoObjectFormat new;
		usePharoLookup;
		loadBridge;
		loadShapesFromImage
]

{ #category : #private }
Runtime class >> forSimulating: aModuleSpec memory: aByteArray [
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

{ #category : #storage }
Runtime >> arrayedSlotOf: object at: index [
	^ objectFormat arrayedSlotOf: object at: index
]

{ #category : #storage }
Runtime >> arrayedSlotOf: object at: index put: value [
	^ storage arrayedSlotOf: object at: index put: value
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

{ #category : #storage }
Runtime >> bytesOf: oid [
	^objectFormat bytesOf: oid
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
	^ ObjectHandle on: oid within: self
]

{ #category : #'meta accessing' }
Runtime >> handleOnGlobal: aString [
	| oid |
	oid := self globalNamed: aString.
	^self handleOn: oid
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
Runtime >> loadShapesFrom: anRGEnvironment [
	objectModel := anRGEnvironment.
	anRGEnvironment allClasses do: [ :class | shapeMap load: class ]
]

{ #category : #initialization }
Runtime >> loadShapesFromImage [
	| classes |
	objectModel := Smalltalk.
	classes := #(ClassDescription Class Metaclass) collect: [ :name | Smalltalk at: name ].
	classes do: [ :class | shapeMap load: class ]
]

{ #category : #'meta accessing' }
Runtime >> lookup [
	^ lookup
]

{ #category : #'meta accessing' }
Runtime >> lookup: aSymbol on: aSubject [
	^lookup lookup: aSymbol on: aSubject
]

{ #category : #'meta accessing' }
Runtime >> lookupSuper: aSymbol on: aSubject from: classname [
	^ lookup lookupSuper: aSymbol on: aSubject from: classname
]

{ #category : #'object format' }
Runtime >> new: oid [
	| instance |
	instance := storage new: oid.
	^ self handleOn: instance
]

{ #category : #'object format' }
Runtime >> new: oid sized: anInteger [
	| instance |
	instance := storage new: oid sized: anInteger.
	^ self handleOn: instance
]

{ #category : #'object format' }
Runtime >> newClosure: anObjectHandle [
	| oid |
	oid := storage newClosure: anObjectHandle.
	"should put a thing that lives in remote runtime, not a PCompiledBlock"
	oid block: anObjectHandle.
	^ self handleOn: oid
]

{ #category : #'object format' }
Runtime >> newClosureHandle: aPCompiledBlock [
	| oid |
	oid := storage newClosure: aPCompiledBlock.
	"should put a thing that lives in remote runtime, not a PCompiledBlock"
	oid block: aPCompiledBlock.
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
	objectFormat := anObjectFormat.
	anObjectFormat runtime: self
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

{ #category : #storage }
Runtime >> symbolOf: oid [
	^objectFormat symbolOf: oid
]

{ #category : #accessing }
Runtime >> true [
	^ bridge true
]

{ #category : #initialization }
Runtime >> useEmulationLookup: anRGEnvironment [ 
	lookup := EmulationLookup new spec: anRGEnvironment
]

{ #category : #initialization }
Runtime >> useMirrorLookup [
	lookup := MirrorLookup new
]

{ #category : #initialization }
Runtime >> usePharoLookup [
	lookup := PharoLookup new
]
