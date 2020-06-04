Class {
	#name : #MirrorTest,
	#superclass : #TestCase,
	#instVars : [
		'runtime',
		'builder',
		'writer'
	],
	#category : #'Powerlang-TestsFailing-Metaphysics'
}

{ #category : #tests }
MirrorTest >> maneuvererForObjects [
	| mirror |
	mirror := runtime globalNamed: 'Object'.
	^ mirror handle maneuverer
]

{ #category : #tests }
MirrorTest >> mirageForObject [
	| mirror |
	mirror := runtime globalNamed: 'Object'.
	^mirror handle mirage
]

{ #category : #tests }
MirrorTest >> mirrorForObject [
	| address |
	address := runtime globalNamed: 'Object'.
	^address asClassMirror
]

{ #category : #tests }
MirrorTest >> setUp [
	super setUp.
	builder := SmalltalkBootstrapper fromSpec build.
	writer := builder writer write.
	runtime := Runtime
		forSimulating: SmalltalkBootstrapper spec
		memory: writer image
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
	self assert: class size equals: definition allInstVarNames size
]
