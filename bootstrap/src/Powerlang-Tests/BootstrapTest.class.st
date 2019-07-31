Class {
	#name : #BootstrapTest,
	#superclass : #TestCase,
	#instVars : [
		'builder'
	],
	#category : #'Powerlang-Tests-Building'
}

{ #category : #running }
BootstrapTest >> setUp [
	| kernel |
	kernel := ProjectSpec new
		name: 'kernel';
		path: '../pst/kernel' asFileReference;
		load.
	builder := SmalltalkKernel new project: kernel; build
]

{ #category : #tests }
BootstrapTest >> test010nil [
	| nilObj behavior class |
	nilObj := builder objects first.
	behavior := builder instanceBehaviorOf: 'UndefinedObject'. 
	class := builder classNamed: 'UndefinedObject'.
	self
		assert: nilObj equals: builder nilObject;
		assert: nilObj slots isEmpty;
		assert: nilObj behavior equals: behavior;
		assert: (behavior at: 'class') equals: class;
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
