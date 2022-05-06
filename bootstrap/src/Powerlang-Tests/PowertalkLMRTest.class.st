Class {
	#name : #PowertalkLMRTest,
	#superclass : #TestCase,
	#instVars : [
		'runtime'
	],
	#category : #'Powerlang-Tests-Bootstrap'
}

{ #category : #accessing }
PowertalkLMRTest class >> resources [
	^ Array with: PowertalkLMRTestResource
]

{ #category : #tests }
PowertalkLMRTest >> ==> anObject [
	| class |
	class := anObject class.
	anObject isInteger
		ifTrue: [ ^ runtime newInteger: anObject ].
	anObject == nil
		ifTrue: [ ^ runtime nil ].
	anObject == false
		ifTrue: [ ^ runtime false ].
	anObject == true
		ifTrue: [ ^ runtime true ].
	(class == Symbol or: [ class inheritsFrom: Symbol ])
		ifTrue: [ ^ runtime symbolFromLocal: anObject ].
	anObject isString
		ifTrue: [ ^ runtime newString: anObject ].
	class = ByteArray
		ifTrue: [ ^ runtime newBytesFrom: anObject ].
	self ASSERT: false
]

{ #category : #tests }
PowertalkLMRTest >> assertNoLeftoverFrames [
	self assert: runtime interpreter hasFinished
]

{ #category : #tests }
PowertalkLMRTest >> compile: aString in: classname during: aBlock [
	| class selector method |
	class := self globalNamed: classname.
	method := SCompiler new compile: aString.
	self assert: method notNil.
	method := self convertMethod: method.
	selector := method slotAt: 5.
	runtime
		sendLocal: #at:put:
		to: class
		with:
			{selector.
			method}
]

{ #category : #tests }
PowertalkLMRTest >> convert: anObject with: map [
	map at: anObject ifPresent: [:mapped | ^mapped ].
	anObject ifNil: [ ^runtime nil ].
	anObject isInteger
		ifTrue: [ ^ runtime newInteger: anObject ].
	anObject isSymbol
		ifTrue: [ ^ runtime addSymbol: anObject ].
	anObject isString
		ifTrue: [ ^ runtime newString: anObject ].
	anObject class = ByteArray
		ifTrue: [ ^ runtime newByteArray: anObject ].
	self ASSERT: false
]

{ #category : #tests }
PowertalkLMRTest >> convertMethod: anSCompiledMethod [
	| class result map instsize slot |
	class := self globalNamed: #CompiledMethod.
	result := runtime newSlots: class size: anSCompiledMethod size.
	map := IdentityDictionary new.
	map at: anSCompiledMethod put: result.
	instsize := anSCompiledMethod class instSize.
	1 to: instsize do: [ :i | 
		slot := anSCompiledMethod instVarAt: i.
		result slotAt: i put: (self convert: slot with: map) ].
	1 to: anSCompiledMethod size
		do: [ :i | 
			slot := anSCompiledMethod at: i.
			result slotAt: i + instsize put: (self convert: slot with: map) ].
	^ result
]

{ #category : #tests }
PowertalkLMRTest >> globalNamed: aSymbol [
	| symbol namespace assoc |
	symbol := runtime symbolFromLocal: aSymbol.
	namespace := runtime moduleNamespace: runtime kernel.
	assoc := runtime lookupAssociationFor: symbol in: namespace.
	^runtime loadAssociationValue: assoc
]

{ #category : #running }
PowertalkLMRTest >> setUp [
	runtime := PowertalkLMRTestResource current runtime
]

{ #category : #tests }
PowertalkLMRTest >> test100yourself [
	| result |
	result := runtime sendLocal: #yourself to: runtime nil.
	self assert: result equals: runtime nil
]

{ #category : #tests }
PowertalkLMRTest >> test110compute1plus1 [
	| one result |
	one := self ==> 1.
	result := runtime sendLocal: #+ to: one with: {one}.
	self assert: result equals: self ==> 2; assertNoLeftoverFrames
]

{ #category : #tests }
PowertalkLMRTest >> test111compute1minus1 [
	| one result |
	one := self ==> 1.
	result := runtime sendLocal: #- to: one with: {one}.
	self assert: result equals: self ==> 0
]

{ #category : #tests }
PowertalkLMRTest >> test112compute3times4 [
	| result |
	result := runtime sendLocal: #* to: self ==> 3 with: {self ==> 4}.
	self assert: result equals: self ==> 12
]

{ #category : #tests }
PowertalkLMRTest >> test113compute20quotient5 [
	|  result |

	result := runtime sendLocal: #// to: self ==>20 with: {self ==>5}.
	self assert: result equals: self ==>4
]

{ #category : #tests }
PowertalkLMRTest >> test130sendIfTrueToFalse [
	| result |
	self
		compile: 'foo ^false ifTrue: [#failed]'
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: runtime nil ].
	self assertNoLeftoverFrames
]

{ #category : #tests }
PowertalkLMRTest >> test131sendIfFalseToTrue [
	| result |
	self
		compile: 'foo ^true ifFalse: [#failed]'
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: runtime nil ].
	self assertNoLeftoverFrames
]

{ #category : #tests }
PowertalkLMRTest >> test132sendIfTrueToTrue [
	| result |
	self
		compile: 'foo ^true ifTrue: [5]'
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: self ==> 5 ].
	self assertNoLeftoverFrames
]

{ #category : #tests }
PowertalkLMRTest >> test140evaluateClosure [
	| result |
	self
		compile: 'foo ^[5] value'
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: self ==> 5 ].
	self assertNoLeftoverFrames
]

{ #category : #tests }
PowertalkLMRTest >> test141evaluateClosureFrames [
	| result |
	self
		compile: 'foo [5] value'
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: runtime true ].
	self assertNoLeftoverFrames
]

{ #category : #tests }
PowertalkLMRTest >> test150sendWhileTrue [
	| result |
	self
		compile:
			'foo
			 | a |
			a := true.
			[a] whileTrue: [a := false].
			^a'
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: runtime false ].
	self assertNoLeftoverFrames
]

{ #category : #tests }
PowertalkLMRTest >> test151sendToDo [
	| result |
	self
		compile:
			'foo
			 | a |
			a := 0.
			3 to: 4 do: [:i | a := a + i].
			^a'
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: self ==> 7 ].
	self assertNoLeftoverFrames
]

{ #category : #tests }
PowertalkLMRTest >> test152compute20dividedBy5 [
	| result |
	result := runtime sendLocal: #/ to: self ==> 20 with: {(self ==> 5)}.
	self 
		assert: result equals: self ==> 4;
		assertNoLeftoverFrames
]

{ #category : #tests }
PowertalkLMRTest >> test161evaluateClosureWithArgs [
	| result |
	self
		compile: 'foo ^[:a :b | a + b] value: 3 value: 4'
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: self ==> 7 ]
]

{ #category : #tests }
PowertalkLMRTest >> test162evaluateClosureWithArgsAndTemps [
	| result |
	self
		compile: 'foo ^[:a :b | | t | t := a + b. t] value: 3 value: 4'
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: self ==> 7 ]
]

{ #category : #tests }
PowertalkLMRTest >> test163evaluateClosureWithArgsAndMethodTemps [
	| result |
	self
		compile: 'foo | t | ^[:a :b | t := a + b. t] value: 3 value: 4'
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: self ==> 7 ]
]

{ #category : #tests }
PowertalkLMRTest >> test164evaluateClosureWithArgsAndMultipleTemps [
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
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: self ==> 7 ]
]

{ #category : #tests }
PowertalkLMRTest >> test165evaluateClosureNonLocalReturn [
	| result |
	self
		compile:
			'foo 
				| s |
				[s := 3. ^s] value.
				s := 4.
				^s'
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: self ==> 3 ]
]

{ #category : #tests }
PowertalkLMRTest >> test166evaluateNestedClosure [
	| result |
	self
		compile: 'foo ^[ [ 7 ] value ] value'
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: self ==> 7 ]
]

{ #category : #tests }
PowertalkLMRTest >> test167evaluateNestedClosureWithArgs [
	| result |
	self
		compile: 'foo ^[:a | [:b | a + b ] value: 4 ] value: 3'
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: self ==> 7 ]
]

{ #category : #tests }
PowertalkLMRTest >> test168evaluateNestedClosureWithTemps [
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
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: self ==> 9 ]
]

{ #category : #tests }
PowertalkLMRTest >> test169evaluateInlinedClosureInClosureWithMethodTemps [
	| result |
	self
		compile:
			'foo 
			| a result |
			a := 3.
			[ true ifTrue: [ result := a + 4 ] ] value.
			^result'
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result equals: self ==> 7 ]
]

{ #category : #tests }
PowertalkLMRTest >> test180evaluateToDo [
	| result |
	self
		compile:
			'foo | result | result := 0. 1 to: 5 do: [:i | result := result + i]. ^result'
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self
				assert: result isImmediate;
				assert: result value equals: 1 + 2 + 3 + 4 + 5 ].
	self assertNoLeftoverFrames
]

{ #category : #tests }
PowertalkLMRTest >> test190evaluateStringConcatenation [
	| result |
	self
		compile: 'foo ^''ABC'', ''DE'''
		in: #ProtoObject
		during: [ result := runtime sendLocal: #foo to: runtime true.
			self assert: result asLocalString equals: 'ABCDE' ].
	self assertNoLeftoverFrames
]

{ #category : #tests }
PowertalkLMRTest >> test200createDictionary [
	| class d |
	class := runtime classNamed: #Dictionary.
	d := runtime sendLocal: #new to: class with: {}.
	self
		assert: d spec name equals: 'Dictionary';
		assertNoLeftoverFrames
]

{ #category : #tests }
PowertalkLMRTest >> test210addAssociationToDictionary [
	| class d assoc |
	class := runtime classNamed: #Dictionary.
	assoc := runtime newAssociation: #foo -> nil.
	d := runtime sendLocal: #new to: class with: {}.
	runtime sendLocal: #add: to: d with: {assoc}.
	self
		assert: d spec name equals: 'Dictionary';
		assertNoLeftoverFrames
]
