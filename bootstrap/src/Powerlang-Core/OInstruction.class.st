"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OInstruction,
	#superclass : #OValue,
	#instVars : [
		'prev',
		'next',
		'firstUse'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OInstruction class >> empty [
	| begin last |
	begin := OBeginInstruction new.
	last := OEndInstruction new.
	begin next: last.
	last prev: begin.
	^begin
]

{ #category : #unclassified }
OInstruction >> acceptVisitor: aVisitor [
	| following current |
	current := self.
	[
		following := current next.
		current isEnd]
		whileFalse: [
			current basicAcceptVisitor: aVisitor.
			current := current next ifNil: [following]]
]

{ #category : #unclassified }
OInstruction >> addLast: anInstruction [
	next addLast: anInstruction
]

{ #category : #unclassified }
OInstruction >> addNext: anInstruction [
	^self afterInsert: anInstruction
]

{ #category : #unclassified }
OInstruction >> addUse: new [
	firstUse ifNil: [firstUse := new] ifNotNil: [firstUse addUse: new]
]

{ #category : #unclassified }
OInstruction >> addUse: user at: name [
	| operand |
	operand := OOperand at: user named: name.
	self addUse: operand
]

{ #category : #unclassified }
OInstruction >> afterInsert: anInstruction [
	anInstruction next: next.
	anInstruction prev: self.
	next prev: anInstruction.
	next := anInstruction
]

{ #category : #unclassified }
OInstruction >> afterInsertAll: anInstruction [
	| last |
	last := anInstruction last.
	last next: next.
	anInstruction prev: self.
	next prev: last.
	next := anInstruction
]

{ #category : #unclassified }
OInstruction >> allUses [
	| result following |
	result := OrderedCollection new.
	following := firstUse.
	[following notNil] whileTrue: [
		result add: following.
		following := following nextUse].
	^result
]

{ #category : #unclassified }
OInstruction >> assureBoundBy: binder [
	
]

{ #category : #unclassified }
OInstruction >> atOperand: name [
	^self subclassResponsibility
]

{ #category : #unclassified }
OInstruction >> atOperand: operandName put: instruction [
	^self subclassResponsibility
]

{ #category : #unclassified }
OInstruction >> basicPrintString [
	^self primitivePrintString
]

{ #category : #unclassified }
OInstruction >> beforeInsert: anInstruction [
	anInstruction next: self.
	anInstruction prev: prev.
	prev next: anInstruction.
	prev := anInstruction
]

{ #category : #unclassified }
OInstruction >> beforeInsertAll: anInstruction [
	| last |
	last := anInstruction "last".
	last next: self.
	anInstruction prev: prev.
	prev next: anInstruction.
	prev := last.
	self shouldBeImplemented
]

{ #category : #unclassified }
OInstruction >> canHaveSideEffects [
	^true
]

{ #category : #unclassified }
OInstruction >> cutFollowing [
	| end |
	end := OEndInstruction new.
	end prev: self.
	next := end.
	^end
]

{ #category : #unclassified }
OInstruction >> cutPrevious [
	| begin |
	begin := OBeginInstruction new.
	begin next: self.
	prev := begin.
	^begin
]

{ #category : #unclassified }
OInstruction >> detect: aBlock [
	^self detect: aBlock ifNone: [self errorAbsentObject]
]

{ #category : #unclassified }
OInstruction >> detect: aBlock ifNone: absentBlock [
	(aBlock value: self)
		ifTrue: [^self]
		ifFalse: [^next detect: aBlock ifNone: absentBlock]
]

{ #category : #unclassified }
OInstruction >> dissolve [
	self untie; operandsDo: [:instruction | instruction removeUse: self]
]

{ #category : #unclassified }
OInstruction >> dissolveDeep [
	prev ifNil: [^self].
	self untie; operandsDo: [:instruction | instruction removeUse: self; dissolveIfUseless]
]

{ #category : #unclassified }
OInstruction >> dissolveIfUnused [
	self isUsed ifFalse: [self dissolveDeep]
]

{ #category : #unclassified }
OInstruction >> dissolveIfUseless [
	self isUseless ifTrue: [self dissolveDeep]
]

{ #category : #unclassified }
OInstruction >> dissolveReplacingWith: anInstruction [
	prev next: anInstruction.
	next prev: anInstruction.
	anInstruction prev: prev.
	anInstruction next: next.
	prev := next := nil.
	self operandsDo: [:instruction | 
		instruction removeUse: self; dissolveIfUseless].
	self replaceAllUsesWith: anInstruction
]

{ #category : #unclassified }
OInstruction >> dissolveReplacingWithAll: instructions [
	| last |
	last := instructions last.
	prev next: instructions.
	instructions prev: prev.
	last next: next.
	next prev: last.
	prev := next := nil.
	self operandsDo: [:instruction | instruction removeUse: self].
	self replaceAllUsesWith: last
]

{ #category : #unclassified }
OInstruction >> do: aBlock [
	| following |
	following := next.
	aBlock value: self.
	next ifNil: [following do: aBlock] ifNotNil: [next do: aBlock]
]

{ #category : #unclassified }
OInstruction >> firstNonPhi [
	| current |
	current := self.
	[current isPhi] whileTrue: [current := current next].
	^current
]

{ #category : #unclassified }
OInstruction >> firstUse [
	^firstUse
]

{ #category : #unclassified }
OInstruction >> hasNext [
	^true
]

{ #category : #unclassified }
OInstruction >> hasPrev [
	^true
]

{ #category : #unclassified }
OInstruction >> insertCopyBefore: anInstruction [
	| copy |
	copy := self newCopy.
	anInstruction beforeInsert: copy.
	^copy
]

{ #category : #unclassified }
OInstruction >> insertPushBefore: anInstruction [
	| push |
	push := OUnaryOperation receiver: self name: #push.
	self addUse: push at: #receiver.
	anInstruction beforeInsert: push.
	^push
]

{ #category : #unclassified }
OInstruction >> isBlockStart [
	^false
]

{ #category : #unclassified }
OInstruction >> isConditionalJump [
	^false
]

{ #category : #unclassified }
OInstruction >> isConstant [
	^false
]

{ #category : #unclassified }
OInstruction >> isDefineArgument [
	^false
]

{ #category : #unclassified }
OInstruction >> isDefinedAt: aBlock [
	aBlock instructionsDo: [:instruction | instruction == self ifTrue: [^true]].
	^false
]

{ #category : #unclassified }
OInstruction >> isEnd [
	^false
]

{ #category : #unclassified }
OInstruction >> isGenericMessage [
	^false
]

{ #category : #unclassified }
OInstruction >> isInstruction [
	^true
]

{ #category : #unclassified }
OInstruction >> isJump [
	^false
]

{ #category : #unclassified }
OInstruction >> isLoadImplicit [
	^false
]

{ #category : #unclassified }
OInstruction >> isMessageSend [
	^false
]

{ #category : #unclassified }
OInstruction >> isPhi [
	^false
]

{ #category : #testing }
OInstruction >> isPrimitiveOperation [
	^false
]

{ #category : #unclassified }
OInstruction >> isReturn [
	^false
]

{ #category : #unclassified }
OInstruction >> isStoreVariable [
	^false
]

{ #category : #unclassified }
OInstruction >> isUnaryOperation [
	^ false
]

{ #category : #unclassified }
OInstruction >> isUnconditionalJump [
	^self isJump andNot: [self isConditionalJump]
]

{ #category : #unclassified }
OInstruction >> isUsed [
	^firstUse notNil
]

{ #category : #unclassified }
OInstruction >> isUsedJustOnce [
	^firstUse notNil and: [firstUse nextUse isNil]
]

{ #category : #unclassified }
OInstruction >> isUsedOnlyBy: instruction [
	^self isUsedJustOnce and: [firstUse user == instruction]
]

{ #category : #unclassified }
OInstruction >> isUseless [
	^firstUse isNil andNot: [ self canHaveSideEffects ]
]

{ #category : #unclassified }
OInstruction >> last [
	^next last
]

{ #category : #unclassified }
OInstruction >> lastPhi [
	| current |
	current := self.
	[current next isPhi] whileTrue: [current := current next].
	^current
]

{ #category : #unclassified }
OInstruction >> lastValue [
	| last |
	last := self last.
	^last isJump ifTrue: [last prev] ifFalse: [last]
]

{ #category : #unclassified }
OInstruction >> livesAfter: anInstruction [
	anInstruction
		nextDetect: [:instruction | instruction usesResultOf: self]
		ifNone: [^false].
	^true
]

{ #category : #unclassified }
OInstruction >> livesAfter: anInstruction orOutOf: aBasicBlock [
	^(self livesAfter: anInstruction) or: [self livesOutOfBlock: aBasicBlock]
]

{ #category : #unclassified }
OInstruction >> livesOutOfBlock: aBasicBlock [
	aBasicBlock successorsPostOrder
		reverseDo: [:block | (block usesResultOf: self) ifTrue: [^true]].
	^false
]

{ #category : #unclassified }
OInstruction >> newCopy [
	| copy |
	copy := OUnaryOperation receiver: self name: #copy.
	self addUse: copy at: #receiver.
	^copy
]

{ #category : #unclassified }
OInstruction >> next [
	^next
]

{ #category : #unclassified }
OInstruction >> next: anInstruction [
	self DENY: (self isJump and: [anInstruction isEnd not]).
	next := anInstruction
]

{ #category : #unclassified }
OInstruction >> nextDetect: aBlock ifNone: absentBlock [
	^next detect: aBlock ifNone: absentBlock
]

{ #category : #unclassified }
OInstruction >> operands [
	| result |
	result := OrderedCollection new.
	self operandsDo: [:o | result add: o].
	^result select: #isInstruction
]

{ #category : #unclassified }
OInstruction >> operandsDo: aBlock [
	self subclassResponsibility
]

{ #category : #unclassified }
OInstruction >> prev [
	^prev
]

{ #category : #unclassified }
OInstruction >> prev: anInstruction [
	prev := anInstruction
]

{ #category : #unclassified }
OInstruction >> primitivePrintString [
	^self class name
]

{ #category : #unclassified }
OInstruction >> printBackwardOn: aStream [
	aStream size > 1000 ifTrue: [
		aStream nextPutAll: '...'.
		^self].
	prev printBackwardOn: aStream.
	aStream nextPutAll: self basicPrintString; cr
]

{ #category : #unclassified }
OInstruction >> printForwardOn: aStream [
	aStream size > 100000 ifTrue: [
		aStream nextPutAll: '...'.
		^self].
	aStream nextPutAll: self basicPrintString; cr.
	next printForwardOn: aStream
]

{ #category : #unclassified }
OInstruction >> printForwardOn: aStream using: names [
	aStream size > 100000 ifTrue: [
		aStream nextPutAll: '...'.
		^self].
	aStream
		nextPutAll: (names at: self) , ' := ' , (self printStringUsing: names);
		cr.
	next printForwardOn: aStream using: names
]

{ #category : #unclassified }
OInstruction >> printOn: aStream [
	"
	prev printBackwardOn: aStream.
	aStrem nextPutAll: '-> '
	"
	aStream
		nextPutAll: self basicPrintString
	"	next printForwardOn: aStream cr"
]

{ #category : #unclassified }
OInstruction >> realReverseDo: aBlock [
	| following |
	following := prev.
	aBlock value: self.
	prev
		ifNil: [following realReverseDo: aBlock]
		ifNotNil: [prev realReverseDo: aBlock]
]

{ #category : #unclassified }
OInstruction >> removeUse: instruction [
	firstUse instruction == instruction
		ifTrue: [firstUse := firstUse nextUse]
		ifFalse: [firstUse removeUse: instruction].

]

{ #category : #unclassified }
OInstruction >> removeUse: instruction at: name [
	(firstUse instruction == instruction and: [firstUse name = name])
		ifTrue: [firstUse := firstUse nextUse]
		ifFalse: [firstUse removeUse: instruction at: name]
]

{ #category : #unclassified }
OInstruction >> replaceAllUsesWith: anInstruction [
	self == anInstruction ifTrue: [^self].
	firstUse ifNil: [^self].
	anInstruction addUse: firstUse.
	firstUse replaceAllUsesWith: anInstruction.
	firstUse := nil
]

{ #category : #unclassified }
OInstruction >> replaceOperand: name with: instruction [
	| previous |
	previous := self atOperand: name.
	previous removeUse: self.
	self atOperand: name put: instruction.
	instruction addUse: self at: name
]

{ #category : #unclassified }
OInstruction >> replaceUsesOf: value with: instruction [
	self operandsDo: [:operand | 
		operand = value ifTrue: [
			operand
				usesDo: [:use | use user = self
					ifTrue: [use disolveReplacingWith: instruction]]]]
]

{ #category : #unclassified }
OInstruction >> replaceWithCopyOf: value [
	| instruction |
	instruction := ((value isUsedOnlyBy: self) andNot: [value isPhi])
		ifTrue: [value untie]
		ifFalse: [value newCopy].
	self dissolveReplacingWith: instruction.
	^instruction
]

{ #category : #unclassified }
OInstruction >> reverseDo: aBlock [
	| following |
	following := prev.
	aBlock value: self.
	prev
		ifNil: [following reverseDo: aBlock]
		ifNotNil: [prev reverseDo: aBlock]
]

{ #category : #unclassified }
OInstruction >> targets [
	^OrderedCollection new
]

{ #category : #unclassified }
OInstruction >> untie [
	prev next: next.
	next prev: prev.
	prev := next := nil
]

{ #category : #unclassified }
OInstruction >> updateUser: instruction named: oldName with: newName [
	self usesDo: [:use | 
		(use instruction == instruction and: [use name == oldName])
			ifTrue: [use name: newName]]
]

{ #category : #unclassified }
OInstruction >> useDistanceTo: value [
	| count |
	count := 0.
	self do: [:instruction | 
		(instruction usesResultOf: value) ifTrue: [^count].
		count := count + 1].
	^Number infinity
]

{ #category : #unclassified }
OInstruction >> usesDo: aBlock [
	firstUse ifNotNil: [firstUse usesDo: aBlock]
]
