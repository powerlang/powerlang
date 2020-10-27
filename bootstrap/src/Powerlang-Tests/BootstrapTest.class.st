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

{ #category : #accessing }
BootstrapTest class >> defaultTimeLimit [
	^ 60 seconds
]

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
		assert: class name bytes asString allButLast equals: 'UndefinedObject'
]

{ #category : #tests }
BootstrapTest >> test100writeSegment [
	| nilObj trueObj falseObj offset |
	nilObj := builder objects first.
	trueObj := builder objects second.
	falseObj := builder objects third.
	writer := builder writer.
	writer	write.
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
	writer := builder writer
		base: b;
		write.
	offset := writer objectsOffset.
	self
		assert: (writer offsetOf: nilObj) equals: offset + 16r08;
		assert: (writer offsetOf: trueObj) equals: offset + 16r10;
		assert: (writer offsetOf: falseObj) equals: offset + 16r18;
		assert: (writer encodedReferenceTo: nilObj)
			equals: b + offset + 16r08;
		assert: (writer encodedReferenceTo: trueObj)
			equals: b + offset + 16r10;
		assert: (writer encodedReferenceTo: falseObj)
			equals: b + offset + 16r18.
			
	FileLocator temp asFileReference / 'kernel.ims'
		binaryWriteStreamDo: [ :s | s nextPutAll: writer image ]
]

{ #category : #tests }
BootstrapTest >> test200writeTestMethod [
	| method offset |
	method := builder buildTestMethod.
	writer := builder writer write.
	offset := writer offsetOf: method
]
