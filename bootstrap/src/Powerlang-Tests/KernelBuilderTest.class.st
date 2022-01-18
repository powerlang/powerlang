Class {
	#name : #KernelBuilderTest,
	#superclass : #TestCase,
	#instVars : [
		'builder'
	],
	#category : #'Powerlang-Tests-Building'
}

{ #category : #running }
KernelBuilderTest class >> defaultTimeLimit [
	^ 60 seconds
]

{ #category : #running }
KernelBuilderTest >> setUp [
	builder := VirtualImage fromSpec
		wordSize: 8;
		genesis;
		bootstrap;
		builder
]

{ #category : #tests }
KernelBuilderTest >> test010nil [
	| nilObj behavior |
	nilObj := builder addGenesisObjects objects first.
	behavior := nilObj behavior.
	self
		assert: nilObj equals: builder runtime nil;
		assert: nilObj size equals: 0;
		assert: nilObj classname equals: 'UndefinedObject';
		assert: behavior classname equals: 'Behavior'
]

{ #category : #tests }
KernelBuilderTest >> test020false [
	| f behavior |
	f := builder addGenesisObjects objects second.
	behavior := f behavior.
	self
		assert: f equals: builder runtime false;
		assert: f size equals: 0;
		assert: f classname equals: 'False';
		assert: behavior classname equals: 'Behavior'
]

{ #category : #tests }
KernelBuilderTest >> test030true [
	| t behavior |
	t := builder addGenesisObjects objects third.
	behavior := t behavior.
	self
		assert: t equals: builder runtime true;
		assert: t size equals: 0;
		assert: t classname equals: 'True';
		assert: behavior classname equals: 'Behavior'
]

{ #category : #tests }
KernelBuilderTest >> test100addMethods [
	builder fillClasses addGenesisObjects
]

{ #category : #tests }
KernelBuilderTest >> test200writeSegment [
	| nilObj trueObj falseObj offset writer |
	builder addGenesisObjects.
	nilObj := builder objects first.
	trueObj := builder objects second.
	falseObj := builder objects third.
	writer := builder writer.
	writer write.
	offset := writer objectsOffset.
	self
		assert: (writer offsetOf: nilObj) equals: offset + 16r08;
		assert: (writer offsetOf: trueObj) equals: offset + 16r10;
		assert: (writer offsetOf: falseObj) equals: offset + 16r18
]

{ #category : #tests }
KernelBuilderTest >> test220writeSegmentWithBase [
	| nilObj trueObj falseObj b offset writer |
	builder addGenesisObjects.
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
	ByteArray streamContents: [ :s | s nextPutAll: writer image ]
]

{ #category : #tests }
KernelBuilderTest >> test300completeSegmentWithBase [
	| nilObj trueObj falseObj b offset writer |
	builder fillClasses addGenesisObjects.
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
	ByteArray streamContents: [ :s | s nextPutAll: writer image ]
]

{ #category : #tests }
KernelBuilderTest >> test400completeNativizedSegmentWithBase [
	| nilObj trueObj falseObj b offset writer |
	builder
		fillClasses;
		nativizeForDMR;
		addGenesisObjects.
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
	ByteArray streamContents: [ :s | s nextPutAll: writer image ]
]
