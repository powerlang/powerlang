Class {
	#name : #VirtualSmalltalkImageTest,
	#superclass : #TestCase,
	#instVars : [
		'image'
	],
	#category : #'Powerlang-Tests-Building'
}

{ #category : #tests }
VirtualSmalltalkImageTest >> setUp [
	image := VirtualSmalltalkImage fromSpec wordSize: 8; genesis
]

{ #category : #tests }
VirtualSmalltalkImageTest >> test010nil [
	| nilObj class behavior |
	nilObj := image nil.
	class := image classNamed: #UndefinedObject.
	behavior := class instanceBehavior.
	self
		assert: nilObj size equals: 0;
		assert: nilObj behavior equals: behavior;
		assert: (behavior slotNamed: 'class') equals: class;
		assert: nilObj classname equals: 'UndefinedObject';
		assert: behavior classname equals: 'Behavior';
		assert: class name bytes asString allButLast
			equals: 'UndefinedObject'
]

{ #category : #tests }
VirtualSmalltalkImageTest >> test020true [
	| trueObj  class behavior |
	trueObj := image true.
	class := image classNamed: #True.
	behavior := class instanceBehavior.
	self
		assert: trueObj size equals: 0;
		assert: trueObj behavior equals: behavior;
		assert: (behavior slotNamed: 'class') equals: class;
		assert: trueObj classname equals: 'True';
		assert: behavior classname equals: 'Behavior';
		assert: class name bytes asString allButLast equals: 'True'
]

{ #category : #tests }
VirtualSmalltalkImageTest >> test030false [
	| falseObj class behavior |
	falseObj := image false.
	class := image classNamed: #False.
	behavior := class instanceBehavior.
	self
		assert: falseObj size equals: 0;
		assert: falseObj behavior equals: behavior;
		assert: (behavior slotNamed: 'class') equals: class;
		assert: falseObj classname equals: 'False';
		assert: behavior classname equals: 'Behavior';
		assert: class name bytes asString allButLast equals: 'False'
]

{ #category : #tests }
VirtualSmalltalkImageTest >> test040superclasses [
	|  proto object collection class metaproto |
	proto := image classNamed: #ProtoObject.
	object := image classNamed: #Object.
	collection := image classNamed: #Collection.
	class := image classNamed: #Class.
	metaproto := image metaclassFor: (image => #ProtoObject) metaclass.
	self
		assert: proto superclass equals: image nil;
		assert: object superclass equals: proto;
		assert: collection superclass equals: object;
		assert: metaproto superclass equals: class
]

{ #category : #tests }
VirtualSmalltalkImageTest >> test100behaviors [
	| proto object coll class mproto mobject |
	proto := image classNamed: #ProtoObject.
	object := image classNamed: #Object.
	coll := image classNamed: #Collection.
	class := image classNamed: #Class.
	mproto := image metaclassFor: (image => #ProtoObject) metaclass.
	mobject := image metaclassFor: (image => #Object) metaclass.
	self
		assert: proto instanceBehavior next equals: image nil;
		assert: object instanceBehavior next equals: proto instanceBehavior;
		assert: coll instanceBehavior next equals: object instanceBehavior;
		assert: mproto instanceBehavior next equals: class instanceBehavior;
		assert: mobject instanceBehavior next
			equals: mproto instanceBehavior
]
