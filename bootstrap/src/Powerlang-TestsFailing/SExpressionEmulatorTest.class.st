Class {
	#name : #SExpressionEmulatorTest,
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
	#category : #'Powerlang-TestsFailing-Metaphysics'
}

{ #category : #tests }
SExpressionEmulatorTest >> handleFor: anObjectMap [
	| oid |
	oid := writer offsetOf: anObjectMap.
	^runtime handleOn: oid

]

{ #category : #tests }
SExpressionEmulatorTest >> injectMethod: anAstcode selector: selector for: classname [
	^ builder
		newMethod: anAstcode
		selector: selector
		in: classname
		format: 0
		literals: #()
]

{ #category : #tests }
SExpressionEmulatorTest >> injectObject [
	^ builder newSlots: 'Object'
]

{ #category : #tests }
SExpressionEmulatorTest >> invoke: method with: object [
	| m receiver |
	m := self handleFor: method.
	receiver := self handleFor: object.
	^receiver mirror invoke: m mirror asMethodMirror with: #()
]

{ #category : #running }
SExpressionEmulatorTest >> setUp [
	super setUp.
	builder := SmalltalkBootstrapper fromSpec build
]

{ #category : #tests }
SExpressionEmulatorTest >> test100yourself [
	| object handle result |
	object := self injectObject.
	handle := builder emulator handleOn: object.
	result := handle maneuverer yourself.
	self
		assert: object == result
]

{ #category : #running }
SExpressionEmulatorTest >> write [
	writer := builder writer write.
	runtime := Runtime
		forSimulating: SmalltalkBootstrapper spec
		memory: writer image
]
