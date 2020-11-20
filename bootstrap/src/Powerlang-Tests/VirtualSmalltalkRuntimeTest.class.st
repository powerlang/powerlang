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
VirtualSmalltalkRuntimeTest >> assertNoLeftoverFrames [
	self assert: runtime frames isEmpty
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
	self assert: result equals: self ==> 2; assertNoLeftoverFrames
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
			self assert: result equals: image nil ].
		
	self assertNoLeftoverFrames
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test131sendIfFalseToTrue [
	| result |
	self
		compile: 'foo ^true ifFalse: [#failed]'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: image nil ].
	self assertNoLeftoverFrames
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test132sendIfTrueToTrue [
	| result |
	self
		compile: 'foo ^true ifTrue: [5]'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: self ==> 5 ].
	self assertNoLeftoverFrames
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test140sendWhileTrue [
	| result |
	self
		compile: 'foo
			 | a |
			a := true.
			[a] whileTrue: [a := false].
			^a'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: image false ].
	self assertNoLeftoverFrames
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test141sendToDo [
	| result |
	self
		compile:
			'foo
			 | a |
			a := 0.
			3 to: 4 do: [:i | a := a + i].
			^a'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: self ==> 7 ].
	self assertNoLeftoverFrames
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test150compute20dividedBy5 [
	| result |
	result := runtime send: #/ to: self ==> 20 with: {(self ==> 5)}.
	self assert: result equals: self ==> 4;
	assertNoLeftoverFrames
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test160evaluateClosure [
	| result |
	self
		compile: 'foo ^[5] value'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: self ==> 5 ].
	self assertNoLeftoverFrames
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test160evaluateClosureFrames [
	| result |
	self
		compile: 'foo [5] value'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: image true ].
	self assertNoLeftoverFrames
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test161evaluateClosureWithArgs [
	| result |
	self
		compile: 'foo ^[:a :b | a + b] value: 3 value: 4'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: self ==> 7 ]
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test162evaluateClosureWithArgsAndTemps [
	| result |
	self
		compile: 'foo ^[:a :b | | t | t := a + b. t] value: 3 value: 4'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: self ==> 7 ]
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test163evaluateClosureWithArgsAndMethodTemps [
	| result |
	self
		compile: 'foo | t | ^[:a :b | t := a + b. t] value: 3 value: 4'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: self ==> 7 ]
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test164evaluateClosureWithArgsAndMultipleTemps [
	| result |
	self
		compile:
			'foo 
				| s |
				s := 3.
				^[:a | | t | 
					t := a.
					t := t + s.
					t] value: 4'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: self ==> 7 ]
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test165evaluateClosureNonLocalReturn [
	| result |
	self
		compile:
			'foo 
				| s |
				[s := 3. ^s] value.
				s := 4.
				^s'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: self ==> 3 ]
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test166evaluateNestedClosure [
	| result |
	self
		compile: 'foo ^[ [ 7 ] value ] value'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: self ==> 7 ]
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test167evaluateNestedClosureWithArgs [
	| result |
	self
		compile: 'foo ^[:a | [:b | a + b ] value: 4 ] value: 3'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: self ==> 7 ]
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test168evaluateNestedClosureWithTemps [
	| result |
	self
		compile:
			'foo 
			| a |
			a := 2.
			^[ | b |
				b := 3.
				[ | c |
				c := 4.
				a + b + c ] value] value'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: self ==> 9 ]
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test169evaluateInlinedClosureInClosureWithMethodTemps [
	| result |
	self
		compile:
			'foo 
			| a result |
			a := 3.
			[ true ifTrue: [ result := a + 4 ] ] value.
			^result'
		in: #ProtoObject
		during: [ result := runtime send: #foo to: image true.
			self assert: result equals: self ==> 7 ]
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test200createDictionary [
	| class d |
	class := image classNamed: #Dictionary.
	d := runtime send: #new to: class with: {}.
	self assert: d spec name equals: 'Dictionary'; assertNoLeftoverFrames
]

{ #category : #tests }
VirtualSmalltalkRuntimeTest >> test210addAssociationToDictionary [
	| class d assoc |
	class := image classNamed: #Dictionary.
	assoc := image newAssociation: #foo -> nil.
	d := runtime send: #new to: class with: {}.
	runtime send: #add: to: d with: {assoc}.
	self assert: d spec name equals: 'Dictionary';
		assertNoLeftoverFrames
]
