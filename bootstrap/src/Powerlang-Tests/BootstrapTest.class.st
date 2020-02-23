Class {
	#name : #BootstrapTest,
	#superclass : #TestCase,
	#instVars : [
		'builder',
		'writer',
		'runtime',
		'kernel'
	],
	#category : #'Powerlang-Tests-Building'
}

{ #category : #running }
BootstrapTest >> setUp [
	kernel := SmalltalkKernel spec.
	builder := SmalltalkKernel new spec: kernel; build.
	runtime := Runtime forBootstrappingPst: builder.
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
		assert: behavior classname equals: 'Behavior'
]

{ #category : #tests }
BootstrapTest >> test100writeSegment [
	| nilObj trueObj falseObj stream writer |
	nilObj := builder objects first.
	trueObj := builder objects second.
	falseObj := builder objects third.
	stream := #[] writeStream.
	writer := ImageSegmentWriter new
		stream: stream;
		objects: builder objects.
	writer write.
	self
		assert: (writer offsetOf: nilObj) equals: 16r10;
		assert: (writer offsetOf: trueObj) equals: 16r18;
		assert: (writer offsetOf: falseObj) equals: 16r20.

]

{ #category : #tests }
BootstrapTest >> test200writeTestMethod [
	| method stream writer offset |
	method := builder buildTestMethod.
	stream := #[] writeStream.
	writer := ImageSegmentWriter new
		stream: stream;
		objects: builder objects.
	writer write.
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
