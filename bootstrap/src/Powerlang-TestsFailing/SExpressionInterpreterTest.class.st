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
	#category : #'Powerlang-TestsFailing-Metaphysics'
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
	^ builder newSlots: 'Object'
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
	builder := VirtualSmalltalkImage kernelSpec build
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
	writer := builder writer write.
	runtime := Runtime
		forSimulating: VirtualSmalltalkImage kernelSpec
		memory: writer image
]
