Class {
	#name : #SExpressionInterpreterTest,
	#superclass : #TestCase,
	#instVars : [
		'builder',
		'writer',
		'runtime',
		'kernel'
	],
	#pools : [
		'AstBindingTypes',
		'SExpressionTypes'
	],
	#category : #'Powerlang-PST-Metaphysics-Tests'
}

{ #category : #tests }
SExpressionInterpreterTest >> handleFor: anObjectMap [
	| oid |
	oid := writer offsetOf: anObjectMap.
	^runtime handleOn: oid

]

{ #category : #tests }
SExpressionInterpreterTest >> injectMethod: anAstcode selector: selector for: classname [
	^ builder
		newMethod: anAstcode
		selector: selector
		in: classname
		format: 0
		literals: #()
]

{ #category : #tests }
SExpressionInterpreterTest >> injectObject [
	^ builder newTyped: 'Object'
]

{ #category : #tests }
SExpressionInterpreterTest >> invoke: method with: object [
	| m receiver |
	m := self handleFor: method.
	receiver := self handleFor: object.
	^receiver mirror invoke: m mirror asMethodMirror with: #()
]

{ #category : #running }
SExpressionInterpreterTest >> setUp [
	super setUp.
	kernel := ProjectSpec new
		name: 'kernel';
		path: '../src/kernel' asFileReference;
		load.
	builder := SmalltalkKernel new
		project: kernel;
		build
]

{ #category : #tests }
SExpressionInterpreterTest >> test100empty [
	| object astcodes method result original |
	object := self injectObject.
	astcodes := {MethodId. {IdentifierId. SelfId}}.	"foo self"
	method := self injectMethod: astcodes selector: #foo for: 'Object'.
	self write.
	result := self invoke: method with: object.
	original := self handleFor: object.
	self
		assert: result localClassname equals: 'Object';
		assert: (result equals: original mirror)
]

{ #category : #running }
SExpressionInterpreterTest >> write [
	| stream |
	stream := #[] writeStream.
	writer := ImageSegmentWriter new
		stream: stream;
		objects: builder objects;
		write.

	runtime := Runtime forSimulatedPst: writer image.
	runtime bridge findNilObject.
	runtime loadShapesFrom: kernel
]
