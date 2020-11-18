Class {
	#name : #VirtualSmalltalkRuntimeTest,
	#superclass : #TestCase,
	#instVars : [
		'image',
		'runtime'
	],
	#category : #'Powerlang-Tests-Building'
}

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> ==> anObject [
	^image transferLiteralDeep: anObject
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> compile: aString in: classname during: aBlock [
	| class selector method |
	class := image => classname.
	selector := class compile: aString notifying: nil.
	method := class methodNamed: selector.
	self assert: method notNil.
	aBlock 		ensure: [ class removeLocalMethod: method ]
]

{ #category : #running }
VirtualSmalltalkRuntimeTest >> setUp [
	image := VirtualSmalltalkImage fromSpec
		wordSize: 8;
		genesis.
	runtime := VirtualSmalltalkRuntime new image: image.
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test100yourself [
	| result |
	result := runtime send: #yourself to: image nil.
	self assert: result equals: image nil
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test110compute1plus1 [
	| one result |
	one := self ==> 1.
	result := runtime send: #+ to: one with: {one}.
	self assert: result equals: self ==> 2
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test111compute1minus1 [
	| one result |
	one := self ==> 1.
	result := runtime send: #- to: one with: {one}.
	self assert: result equals: self ==> 0
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test112compute3times4 [
	| result |
	result := runtime send: #* to: self ==> 3 with: {self ==> 4}.
	self assert: result equals: self ==> 12
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test113compute20quotient5 [
	|  result |

	result := runtime send: #// to: self ==>20 with: {self ==>5}.
	self assert: result equals: self ==>4
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test130sendIfTrueToFalse [
	| result |
	self
		compile: 'foo ^false ifTrue: [#failed]'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: image nil ]
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test131sendIfFalseToTrue [
	| result |
	self
		compile: 'foo ^true ifFalse: [#failed]'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: image nil ]
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test132sendIfTrueToTrue [
	| result |
	self
		compile: 'foo ^true ifTrue: [5]'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: self ==> 5 ]
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test150compute20dividedBy5 [
	| result |
	result := runtime send: #/ to: self ==> 20 with: {(self ==> 5)}.
	self assert: result equals: self ==> 4
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test200createDictionary [
	| class d |
	class := image classNamed: #Dictionary.
	d := runtime send: #new to: class with: {}.
	self assert: d spec name equals: 'Dictionary'
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test210addAssociationToDictionary [
	| class d assoc |
	class := image classNamed: #Dictionary.
	assoc := image newAssociation: #foo -> nil.
	d := runtime send: #new to: class with: {}.
	runtime send: #add: to: d with: {assoc}.
	self assert: d spec name equals: 'Dictionary'
]
