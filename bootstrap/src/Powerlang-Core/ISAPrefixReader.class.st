"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #ISAPrefixReader,
	#superclass : #ISAInstructionPartReader,
	#instVars : [
		'legacy',
		'rex',
		'vex'
	],
	#category : #'Powerlang-Core-Assembler-Intel-Tools'
}

{ #category : #private }
ISAPrefixReader >> from: aStream [
	super from: aStream.
	self
		legacyFrom: aStream;
		rexFrom: aStream;
		vexFrom: aStream
]

{ #category : #private }
ISAPrefixReader >> legacyFrom: aStream [
	| prefix |
	legacy := #() writeStream.
	[
		prefix := LegacyPrefix withValue: aStream peek.
		prefix isNil]
		whileFalse: [
			legacy nextPut: prefix.
			contents nextPut: aStream next]
]

{ #category : #printing }
ISAPrefixReader >> printLegacyOn: aStream [
	legacy contents
		do: [:p | aStream nextPutAll: p asString]
		separatedBy: [aStream space]
]

{ #category : #printing }
ISAPrefixReader >> printOn: aStream [
	self printLegacyOn: aStream.
	legacy size > 0 ifTrue: [aStream space].
	rex notNil ifTrue: [
		self printRexOn: aStream.
		aStream space].
	vex notNil ifTrue: [self printVexOn: aStream]
]

{ #category : #printing }
ISAPrefixReader >> printRexOn: aStream [
	rex isNil ifTrue: [^self].
	aStream nextPutAll: REXPrefix rex asString.
	(rex isOnBit: REXPrefix w value) ifTrue: [aStream nextPutAll: '.W'].
	(rex isOnBit: REXPrefix r value) ifTrue: [aStream nextPutAll: '.R'].
	(rex isOnBit: 1) ifTrue: [aStream nextPutAll: '.B'].
	(rex isOnBit: 2) ifTrue: [aStream nextPutAll: '.X']
]

{ #category : #printing }
ISAPrefixReader >> printVex2On: aStream [
	self printVexVvvvLpp: vex second on: aStream
]

{ #category : #printing }
ISAPrefixReader >> printVex3On: aStream [
	| byte x b mmmmm w |
	byte := vex second.
	x := (byte bitAnd: 2r1000000) > 0 ifTrue: [$1] ifFalse: [$0].
	aStream nextPut: x; nextPut: $..
	b := (byte bitAnd: 2r100000) > 0 ifTrue: [$1] ifFalse: [$0].
	aStream nextPut: b; nextPut: $..
	mmmmm := byte bitAnd: 2r11111.
	aStream
		nextPutAll: (mmmmm bin: 5);
		nextPut: $|.
	byte := vex third.
	w := byte >= 16r80 ifTrue: [$1] ifFalse: [$0].
	aStream nextPut: w; nextPut: $..
	self printVexVvvvLpp: byte on: aStream
]

{ #category : #printing }
ISAPrefixReader >> printVexOn: aStream [
	| byte r |
	vex isNil ifTrue: [^self].
	aStream nextPutAll: vex first hex; nextPut: $|.
	byte := vex second.
	r := byte // 16r80 > 0 ifTrue: [$1] ifFalse: [$0].
	aStream nextPut: r; nextPut: $..
	vex size = 2
		ifTrue: [self printVex2On: aStream]
		ifFalse: [self printVex3On: aStream]
]

{ #category : #printing }
ISAPrefixReader >> printVexVvvvLpp: byte on: aStream [
	| vvvv l pp |
	vvvv := (byte bitShift: -3) bitAnd: 2r1111.
	aStream
		nextPutAll: (vvvv bin: 4);
		nextPut: $..
	l := (byte bitAnd: 2r100) > 0 ifTrue: [$1] ifFalse: [$0].
	aStream nextPut: l; nextPut: $..
	pp := byte bitAnd: 2r11.
	aStream nextPutAll: (pp bin: 2)
]

{ #category : #private }
ISAPrefixReader >> rexFrom: aStream [
	(aStream peek bitAnd: 16rF0) = REXPrefix rex value ifTrue: [
		rex := aStream next.
		contents nextPut: rex]
]

{ #category : #private }
ISAPrefixReader >> vexFrom: aStream [
	| byte |
	byte := aStream peek.
	vex := byte = 16rC4 ifTrue: [aStream next: 3] ifFalse: [
		byte = 16rC5 ifFalse: [^self].
		aStream next: 2].
	contents nextPutAll: vex
]
