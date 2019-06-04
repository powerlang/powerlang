Class {
	#name : #Runtime,
	#superclass : #Object,
	#instVars : [
		'lookup',
		'storage',
		'objectFormat',
		'bridge',
		'sources',
		'shapeMap'
	],
	#category : #'Powerlang-PST-Metaphysics'
}

{ #category : #private }
Runtime class >> forSimulatedPst: aByteArray [
	| adapter |
	adapter := ByteArrayAdapter on: aByteArray.
	^ self new
		bridge: PstBridge new;
		objectFormat: (DmrObjectFormat on: adapter);
		storage: adapter
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

{ #category : #storage }
Runtime >> bytesOf: oid [
	| size |
	size := objectFormat sizeOf: oid.
	^ self bytesOf: oid count: size
]

{ #category : #storage }
Runtime >> bytesOf: oid count: size [
	^ storage bytesAt: oid sized: size
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
Runtime >> integerOf: oid [
	^objectFormat integerOf: oid
]

{ #category : #initialization }
Runtime >> loadShapesFrom: aProjectSpec [
	aProjectSpec classes do: [ :class | shapeMap load: class ]
]

{ #category : #'meta accessing' }
Runtime >> lookup: aSymbol on: aSubject [
	^lookup lookup: aSymbol on: aSubject
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
	^objectFormat := anObjectFormat
]

{ #category : #storage }
Runtime >> slotOf: object at: index [
	^storage slotOf: object at: index
]

{ #category : #storage }
Runtime >> slotOf: object at: index put: value [
	^ storage slotOf: object at: index put: value
]

{ #category : #accessing }
Runtime >> storage: anObject [
	storage := anObject
]

{ #category : #storage }
Runtime >> stringOf: oid [
	| size |
	size := objectFormat sizeOf: oid.
	^storage stringAt: oid sized: size
]

{ #category : #shapes }
Runtime >> structureOf: type [
	^shapeMap at: type
]

{ #category : #initialization }
Runtime >> useMirrorLookup [
	lookup := MirrorLookup new
]
