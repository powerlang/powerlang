Class {
	#name : #MirrorTest,
	#superclass : #TestCase,
	#instVars : [
		'runtime',
		'builder'
	],
	#category : #'Powerlang-Tests-Metaphysics'
}

{ #category : #tests }
MirrorTest >> maneuvererForObjects [
	| mirror |
	mirror := runtime objectNamed: 'Object'.
	^ mirror handle maneuverer
]

{ #category : #tests }
MirrorTest >> mirageForObject [
	| mirror |
	mirror := runtime objectNamed: 'Object'.
	^ mirror handle mirage
]

{ #category : #tests }
MirrorTest >> mirrorForObject [
	| address |
	address := runtime objectNamed: 'Object'.
	^ address asClassMirror
]

{ #category : #running }
MirrorTest >> setUp [
	| vimage image |
	super setUp.
	vimage := PowertalkRingImage fromSpec
		wordSize: 8;
		genesis;
		bootstrap.
	builder := vimage builder.
	builder addGenesisObjects.
	image := builder writer write image.
	runtime := Runtime
		forSimulating: PowertalkRingImage kernelSpec
		memory: image
]

{ #category : #tests }
MirrorTest >> test010nilHandle [
	| handle |
	handle := runtime nil.
	self
		assert: handle isSmall;
		deny: handle isBytes;
		deny: handle isArrayed;
		assert: handle basicSize equals: 0
]

{ #category : #tests }
MirrorTest >> test020nilBehaviorHandle [
	| handle |
	handle := runtime nil getBehavior.
	self
		assert: handle isSmall;
		deny: handle isBytes;
		deny: handle isArrayed;
		assert: handle size equals: 3
]

{ #category : #tests }
MirrorTest >> test030nilClassHandle [
	| behavior class name |
	behavior := runtime nil getBehavior.
	class := behavior slotAt: 1.
	self
		assert: class isSmall;
		deny: class isBytes;
		deny: class isArrayed;
		assert: class size equals: 9.
	name := class slotAt: 6.
	self assert: name asLocalString equals: 'UndefinedObject'
]

{ #category : #tests }
MirrorTest >> test040nilClassMirror [
	| class hierarchy |
	class := runtime nil mirror reflectedClass.
	hierarchy := class allSuperclasses collect: #localName.
	self assert: class localName equals: 'UndefinedObject';
		assert: hierarchy asArray equals: #('Object' 'ProtoObject')
]

{ #category : #tests }
MirrorTest >> testObjectMirrorBasics [
	| class definition |
	class := self mirrorForObject.
	self
		deny: class reflectsInteger;
		deny: class reflectsBytesObject;
		deny: class reflectsLargeObject;
		deny: class reflectsNil.
	definition := builder => 'Class'.
	self assert: class slotSize equals: definition allInstVarNames size
]
