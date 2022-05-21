"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #AssemblerParser,
	#superclass : #AssemblerGrammar,
	#category : #'Powerlang-Core-Assembly-Intel-Parser'
}

{ #category : #accessing }
AssemblerParser >> bitLengthOf: anInteger [
	(anInteger between: -16r80 and: 16r7F) ifTrue: [^8].
	(anInteger between: -16r8000 and: 16r7FFF) ifTrue: [^16].
	(anInteger between: -16r80000000 and: 16r7FFFFFFF) ifTrue: [^32].
	(anInteger between: -16r8000000000000000 and: 16r7FFFFFFFFFFFFFFF)
		ifTrue: [^64].
	(anInteger
		between: -16r80000000000000000000000000000000
		and: 16r7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
		ifTrue: [^128].
	^nil
]

{ #category : #private }
AssemblerParser >> comma [
	^super comma ==> [:nodes | ]
]

{ #category : #accessing }
AssemblerParser >> decimal [
	^super decimal ==> [:node | node asInteger]
]

{ #category : #accessing }
AssemblerParser >> displacement [
	^super displacement
		==> [:nodes | nodes first = $-
			ifTrue: [nodes second negated]
			ifFalse: [nodes second]]
]

{ #category : #accessing }
AssemblerParser >> hex [
	^super hex
		==> [:nodes | Integer readFrom: nodes second readStream radix: 16]
]

{ #category : #accessing }
AssemblerParser >> immD [
	^super immD ==> [:nodes | | sign value |
		sign := nodes first = $- ifTrue: [-1] ifFalse: [1].
		value := nodes second * sign.
		ISAImmediate new value: value]
]

{ #category : #accessing }
AssemblerParser >> immH [
	^super immH ==> [:value | | s len |
		len := self bitLengthOf: value.
		s := self signInteger: value.
		s < 0 ifTrue: [len := len // 2].
		ISAImmediate new value: s; length: len]
]

{ #category : #accessing }
AssemblerParser >> index [
	^super index ==> [:nodes | nodes second]
]

{ #category : #accessing }
AssemblerParser >> instruction [
	^super instruction ==> [:nodes | 
		ISAInstruction new
			prefix: nodes first;
			mnemonic: nodes second;
			operands: (nodes third ifNil: #())]
]

{ #category : #accessing }
AssemblerParser >> memory [
	^super memory ==> [:nodes | | memory |
		memory := nodes fourth.
		nodes third ifNotNil: [:seg | memory segment: seg first].
		nodes first ifNotNil: [:len | memory length: len].
		memory]
]

{ #category : #accessing }
AssemblerParser >> memorySize [
	^super memorySize ==> [:nodes | | c index |
		index := 'bwdqxyz' indexOf: nodes first first.
		#(8 16 32 64 128 256 512) at: index]
]

{ #category : #accessing }
AssemblerParser >> operands [
	^super operands ==> [:nodes | | reg |
		nodes notNil ifTrue: [
			reg := nodes
				detect: [:op | op isInteger not
					and: [op isString not]
					and: [op isRegister]]
				ifNone: nil.
			reg notNil ifTrue: [
				nodes
					select: [:op | op isInteger not
						and: [op isMemory]
						and: [op length isNil]]
					thenDo: [:op | op length: reg length]]].
		nodes]
]

{ #category : #accessing }
AssemblerParser >> operands1 [
	^super operands1 ==> [:node | {node}]
]

{ #category : #accessing }
AssemblerParser >> operands2 [
	^super operands2 ==> [:nodes | {nodes first. nodes third}]
]

{ #category : #accessing }
AssemblerParser >> operands3 [
	^super operands3 ==> [:nodes | {nodes first. nodes third. nodes fifth}]
]

{ #category : #accessing }
AssemblerParser >> parseInstruction: aString [
	| array |
	array := self parse: aString.
	^array anyOne

]

{ #category : #accessing }
AssemblerParser >> prefix [
	^super prefix ==> [:name | InstructionPrefix prefixes at: name asUppercase]
]

{ #category : #accessing }
AssemblerParser >> reg [
	^super reg ==> [:nodes | Register named: nodes]
]

{ #category : #accessing }
AssemblerParser >> scale [
	^super scale ==> [:nodes | nodes second digitValue]
]

{ #category : #accessing }
AssemblerParser >> segment [
	^super segment ==> [:nodes | Register named: nodes]
]

{ #category : #accessing }
AssemblerParser >> sib1 [
	^super sib1 ==> [:node | MemoryOperand new displacement: node]
]

{ #category : #accessing }
AssemblerParser >> sib2 [
	| scale displacement |
	^ super sib2
		==> [ :nodes |  scale := nodes third ifNil: [ 1 ].
			displacement := nodes fourth ifNil: [ 0 ].
			MemoryOperand new
				base: nodes first;
				index: nodes second;
				scale: scale;
				displacement: displacement ]
]

{ #category : #accessing }
AssemblerParser >> sib3 [
	^super sib3 ==> [:nodes | 
		MemoryOperand new
			index: nodes first;
			scale: nodes second;
			displacement: nodes third]
]

{ #category : #accessing }
AssemblerParser >> signInteger: anInteger [
	anInteger < 0 ifTrue: [^anInteger].
	anInteger < 16r80 ifTrue: [^anInteger].
	anInteger < 16r100 ifTrue: [^anInteger - 16r100].
	anInteger < 16r8000 ifTrue: [^anInteger].
	anInteger < 16r10000 ifTrue: [^anInteger - 16r10000].
	anInteger < 16r80000000 ifTrue: [^anInteger].
	anInteger < 16r100000000 ifTrue: [^anInteger - 16r100000000].
	anInteger < 16r8000000000000000 ifTrue: [^anInteger].
	anInteger < 16r10000000000000000
		ifTrue: [^anInteger - 16r10000000000000000].
	^anInteger
]

{ #category : #accessing }
AssemblerParser >> start [
	^super start ==> [:nodes | | tail |
		tail := nodes second collect: [:a | a second].
		Array with: nodes first withAll: tail]
]
