Class {
	#name : #BootstrapTest,
	#superclass : #TestCase,
	#instVars : [
		'builder',
		'writer',
		'runtime',
		'kernel'
	],
	#category : #'Powerlang-TestsFailing-Building'
}

{ #category : #running }
BootstrapTest >> setUp [
	kernel := SmalltalkBootstrapper spec.
	builder := SmalltalkBootstrapper fromSpec	build.
	runtime := Runtime forEmulatingPst: builder.
	runtime loadShapesFrom: kernel
]

{ #category : #tests }
BootstrapTest >> test010nil [
	| nilObj class behavior |
	nilObj := builder objects first.
	class := builder classNamed: 'UndefinedObject'.
	behavior := class instanceBehavior.
	self
		assert: nilObj equals: builder nilObject;
		assert: nilObj size equals: 0;
		assert: nilObj behavior equals: behavior;
		assert: (behavior slotNamed: 'class') equals: class;
		assert: nilObj classname equals: 'UndefinedObject';
		assert: behavior classname equals: 'Behavior';
		assert: class name bytes asString allButLast = 'UndefinedObject'
]

{ #category : #tests }
BootstrapTest >> test100writeSegment [
	| nilObj trueObj falseObj offset |
	nilObj := builder objects first.
	trueObj := builder objects second.
	falseObj := builder objects third.
	writer := builder writer write.
	offset := writer objectsOffset.
	self
		assert: (writer offsetOf: nilObj) equals: offset + 16r08;
		assert: (writer offsetOf: trueObj) equals: offset + 16r10;
		assert: (writer offsetOf: falseObj) equals: offset + 16r18.

]

{ #category : #tests }
BootstrapTest >> test120writeSegmentWithBase [
	| nilObj trueObj falseObj b offset |
	nilObj := builder objects first.
	trueObj := builder objects second.
	falseObj := builder objects third.
	b := 16r1ff10000.
	writer := builder writer base: b; write.
	offset := writer objectsOffset.
	self
		assert: (writer offsetOf: nilObj) equals: offset + 16r08;
		assert: (writer offsetOf: trueObj) equals: offset + 16r10;
		assert: (writer offsetOf: falseObj) equals: offset + 16r18;
		assert: (writer encodedReferenceTo: nilObj) equals: b + offset + 16r08;
		assert: (writer encodedReferenceTo: trueObj) equals: b + offset + 16r10;
		assert: (writer encodedReferenceTo: falseObj) equals: b + offset + 16r18
]

{ #category : #tests }
BootstrapTest >> test200writeTestMethod [
	| method offset |
	method := builder buildTestMethod.
	writer := builder writer write.
	offset := writer offsetOf: method.
	offset halt
]

{ #category : #tests }
BootstrapTest >> test500interpretMethodDictionaryCreation [
	| md object class binding dict | 
	md := builder classNamed: #MethodDictionary.
	object := builder classNamed: #Object.
	class := runtime handleOn: md.
	binding := runtime handleOn: object.
	dict := class mirage new classBinding: binding mirage.
	self
		assert: dict isMethodDictionary;
		assert: dict size = 0
]
