"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OperandEncoding,
	#superclass : #Object,
	#instVars : [
		'name',
		'selectors',
		'descriptions',
		'immediate',
		'modrm'
	],
	#classVars : [
		'Encodings'
	],
	#pools : [
		'Registers'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #initialization }
OperandEncoding class >> commentEncodingMethods [
	"
	StChangesetBrowser new
		label: 'OperandEncoding comments';
		setModel: (ChangesetBrowserModel on: OperandEncoding commentEncodingMethods);
		openInWindow
	"
	| changes |
	changes := OrderedCollection new.
	Encodings collect: [:oe | | comment |
		comment := String streamContents: [:strm | 
			strm crtab; nextPut: $"; crtab.
			oe descriptions do: [:d | strm nextPutAll: d; crtab].
			strm nextPut: $"; cr].
		oe selectors do: [:s | | cm reader source change |
			cm := self >> s.
			reader := cm sourceCode readStream.
			source := String streamContents: [:strm | 
				strm
					nextPutAll: reader nextLine;
					nextPutAll: comment;
					nextPutAll: reader upToEnd].
			change := self project changes
				methodDefinitionClass: self
				sourceCode: source.
			changes add: change]].
	^changes
]

{ #category : #initialization }
OperandEncoding class >> defs [
	^#(
		#('A' 'imm8')
		#('D' 'offset')
		#('FD' 'AL/AX/EAX/RAX' 'Moffs')
		#('FV' 'ModRM:reg (w)' 'EVEX.vvvv' 'ModRM:r/m (r)')
		#('FV-RVM' 'ModRM:reg (w)' 'EVEX.vvvv' 'ModRM:r/m (r)')
		#('I' 'AL/AX/EAX/RAX' 'imm8')
		#('II' 'iw' 'imm8')
		#('M' 'ModRM:r/m (r)')
		#('M1' 'ModRM:r/m (w)' '1')
		#('MC' 'ModRM:r/m (w)' 'CL')
		#('MI' 'ModRM:r/m (r, w)' 'imm8')
		#('MR' 'ModRM:r/m (r, w)' 'ModRM:reg (r)')
		#('MRC' 'ModRM:r/m (w)' 'ModRM:reg (r)' 'CL')
		#('MRI' 'ModRM:r/m (w)' 'ModRM:reg (r)' 'imm8')
		#('MVR' 'ModRM:r/m (w)' 'VEX.vvvv (r)' 'ModRM:reg (r)')
		#('NP' 'ModRM:r/m (w)' 'ModRM:reg (r)')
		#('O' 'opcode + rd (r, w)')
		#('OI' 'opcode + rd (w)' 'imm8/16/32/64')
		#('RM' 'ModRM:reg (r, w)' 'ModRM:r/m (r)')
		#('RM0' 'ModRM:reg (r, w)' 'ModRM:r/m (r)')
		#('RMI' 'ModRM:reg (w)' 'ModRM:r/m (r)' 'imm8')
		#('RMV' 'ModRM:reg (w)' 'ModRM:r/m (r)' 'VEX.vvvv (r)')
		#('RVM' 'ModRM:reg (w)' 'VEX.vvvv' 'ModRM:r/m (r)')
		#('RVMI' 'ModRM:reg (w)' 'VEX.vvvv (r)' 'ModRM:r/m (r)' 'imm8[3:0]')
		#('RVMR' 'ModRM:reg (w)' 'VEX.vvvv (r)' 'ModRM:r/m (r)' 'imm8[7:4]')
		#('T1S' 'ModRM:reg (w)' 'EVEX.vvvv' 'ModRM:r/m (r)')
		#('T1S-RVM' 'ModRM:reg (w)' 'EVEX.vvvv' 'ModRM:r/m (r)')
		#('TD' 'Moffs (w)' 'AL/AX/EAX/RAX')
		#('VM' 'VEX.vvvv (w)' 'ModRM:r/m (r)')
		#('VMI' 'VEX.vvvv (w)' 'ModRM:r/m (r)' 'imm8')
		#('XM' 'ModRM:reg (w)' 'ModRM:r/m (r)'))
]

{ #category : #initialization }
OperandEncoding class >> initialize [
	self initializeEncodings
]

{ #category : #initialization }
OperandEncoding class >> initializeEncodings [
	Encodings := OrderedCollection new.
	self defs do: [:def | | oe n selectors |
		n := def first replaceAll: '-' with: ''.
		oe := OperandEncoding new.
		selectors := (2 to: def size)
			collect: [:i | ('encode' , n , 'Operand' , (i - 1) asString , ':') asSymbol].
		oe
			name: n;
			selectors: selectors;
			descriptions: def allButFirst.
		selectors reject: [:s | self includesSelector: s] thenDo: [:s | | change |
			change := self project changes
				methodDefinitionClass: self
				sourceCode: s , ' instruction'.
			change perform].
		Encodings add: oe].
	Encodings := Encodings asArray
]

{ #category : #'instance creation' }
OperandEncoding class >> named: aString [
	^Encodings
		detect: [:e | e name = aString]
		ifNone: [(aString includes: $-) ifTrue: [self halt]]
]

{ #category : #services }
OperandEncoding >> bytesFor: integer length: n [
	| bytes v |
	bytes := ByteArray new: n.
	v := integer.
	v < 0 ifTrue: [v := v + (1 bitShift: n * 8)].
	1 to: n do: [:i | | b |
		b := v bitAnd: 16rFF.
		bytes at: i put: b.
		v := v bitShift: -8].
	^bytes
]

{ #category : #accessing }
OperandEncoding >> descriptions [
	^descriptions
]

{ #category : #accessing }
OperandEncoding >> descriptions: aCollection [
	descriptions := aCollection.
	modrm := immediate := false.
	(selectors conform: [:s | s beginsWith: 'encodeNP']) ifTrue: [^self].
	descriptions do: [:d | 
		(d includesString: 'ModRM') ifTrue: [modrm := true].
		(d includesString: 'offs') ifTrue: [immediate := true].
		(d includesString: 'imm') ifTrue: [immediate := true]]
]

{ #category : #private }
OperandEncoding >> encodeAOperand1: operand [
	"
	imm8
	"
	
]

{ #category : #private }
OperandEncoding >> encodeDOperand1: instruction [
	"
	offset
	"
	| op bytes |
	op := instruction spec operands at: 1.
	bytes := self bytesFor: instruction operand1 value length: op length // 8.
	instruction immediate: bytes
]

{ #category : #private }
OperandEncoding >> encodeFDOperand1: instruction [
	"
	AL/AX/EAX/RAX
	Moffs
	"
	
]

{ #category : #private }
OperandEncoding >> encodeFDOperand2: operand [
	"
	AL/AX/EAX/RAX
	Moffs
	"
	
]

{ #category : #private }
OperandEncoding >> encodeFVOperand1: instruction [
	"
	ModRM:reg (w)
	EVEX.vvvv
	ModRM:r/m (r)
	"
]

{ #category : #private }
OperandEncoding >> encodeFVOperand2: instruction [
	"
	ModRM:reg (w)
	EVEX.vvvv
	ModRM:r/m (r)
	"
]

{ #category : #private }
OperandEncoding >> encodeFVOperand3: instruction [
	"
	ModRM:reg (w)
	EVEX.vvvv
	ModRM:r/m (r)
	"
]

{ #category : #private }
OperandEncoding >> encodeFVRVMOperand1: instruction [
	"
	ModRM:reg (w)
	EVEX.vvvv
	ModRM:r/m (r)
	"
]

{ #category : #private }
OperandEncoding >> encodeFVRVMOperand2: instruction [
	"
	ModRM:reg (w)
	EVEX.vvvv
	ModRM:r/m (r)
	"
]

{ #category : #private }
OperandEncoding >> encodeFVRVMOperand3: instruction [
	"
	ModRM:reg (w)
	EVEX.vvvv
	ModRM:r/m (r)
	"
]

{ #category : #private }
OperandEncoding >> encodeIIOperand1: instruction [
	"
	iw
	imm8
	"
	| op bytes |
	op := instruction spec operands at: 1.
	bytes := self bytesFor: instruction operand1 value length: op length // 8.
	instruction immediate: bytes
]

{ #category : #private }
OperandEncoding >> encodeIIOperand2: instruction [
	"
	iw
	imm8
	"
	| op bytes |
	op := instruction spec operands at: 2.
	bytes := self bytesFor: instruction operand2 value length: op length // 8.
	instruction immediate2: bytes
]

{ #category : #private }
OperandEncoding >> encodeIOperand1: instruction [
	"
	AL/AX/EAX/RAX
	imm8
	"
	"
	do nothing
	"
	instruction arity = 1 ifTrue: [| op bytes |
		op := instruction spec operands at: 1.
		bytes := self bytesFor: instruction operand1 value length: op length // 8.
		instruction immediate: bytes]
]

{ #category : #private }
OperandEncoding >> encodeIOperand2: instruction [
	"
	AL/AX/EAX/RAX
	imm8
	"
	| op bytes |
	op := instruction spec operands at: 2.
	bytes := self bytesFor: instruction operand2 value length: op length // 8.
	instruction immediate: bytes
]

{ #category : #private }
OperandEncoding >> encodeM1Operand1: instruction [
	"
	ModRM:r/m (w)
	1
	"
	instruction rm: instruction operand1 rm
]

{ #category : #private }
OperandEncoding >> encodeM1Operand2: instruction [
	"
	ModRM:r/m (w)
	1
	"
	"
	do nothing
	"
	
]

{ #category : #private }
OperandEncoding >> encodeMCOperand1: instruction [
	"
	ModRM:r/m (w)
	CL
	"
	instruction rm: instruction operand1 rm
]

{ #category : #private }
OperandEncoding >> encodeMCOperand2: operand [
	"
	ModRM:r/m (w)
	CL
	"
	"
	do nothing
	"
	
]

{ #category : #private }
OperandEncoding >> encodeMIOperand1: instruction [
	"
	ModRM:r/m (r, w)
	imm8
	"
	instruction rm: instruction operand1 rm
]

{ #category : #private }
OperandEncoding >> encodeMIOperand2: instruction [
	"
	ModRM:r/m (r, w)
	imm8
	"
	| op bytes |
	op := instruction spec operands at: 2.
	bytes := self bytesFor: instruction operand2 value length: op length // 8.
	instruction immediate: bytes
]

{ #category : #private }
OperandEncoding >> encodeMOperand1: instruction [
	"
	ModRM:r/m (r)
	"
	instruction rm: instruction operand1 rm
]

{ #category : #private }
OperandEncoding >> encodeMRCOperand1: instruction [
	"
	ModRM:r/m (w)
	ModRM:reg (r)
	CL
	"
	instruction rm: instruction operand1 rm
]

{ #category : #private }
OperandEncoding >> encodeMRCOperand2: instruction [
	"
	ModRM:r/m (w)
	ModRM:reg (r)
	CL
	"
	instruction reg: instruction operand2
]

{ #category : #private }
OperandEncoding >> encodeMRCOperand3: instruction [
	"
	ModRM:r/m (w)
	ModRM:reg (r)
	CL
	"
	"
	do nothing
	"
	
]

{ #category : #private }
OperandEncoding >> encodeMRIOperand1: instruction [
	"
	ModRM:r/m (w)
	ModRM:reg (r)
	imm8
	"
	instruction rm: instruction operand1 rm
]

{ #category : #private }
OperandEncoding >> encodeMRIOperand2: instruction [
	"
	ModRM:r/m (w)
	ModRM:reg (r)
	imm8
	"
	instruction reg: instruction operand2
]

{ #category : #private }
OperandEncoding >> encodeMRIOperand3: instruction [
	"
	ModRM:r/m (w)
	ModRM:reg (r)
	imm8
	"
	| op bytes |
	op := instruction spec operands at: 3.
	bytes := self bytesFor: instruction operand3 value length: op length // 8.
	instruction immediate: bytes
]

{ #category : #private }
OperandEncoding >> encodeMROperand1: instruction [
	"
	ModRM:r/m (r, w)
	ModRM:reg (r)
	"
	instruction rm: instruction operand1 rm
]

{ #category : #private }
OperandEncoding >> encodeMROperand2: instruction [
	"
	ModRM:r/m (r, w)
	ModRM:reg (r)
	"
	instruction reg: instruction operand2
]

{ #category : #private }
OperandEncoding >> encodeMVROperand1: instruction [
	"
	ModRM:r/m (w)
	VEX.vvvv (r)
	ModRM:reg (r)
	"
	instruction vrm: instruction operand1 rm
]

{ #category : #private }
OperandEncoding >> encodeMVROperand2: instruction [
	"
	ModRM:r/m (w)
	VEX.vvvv (r)
	ModRM:reg (r)
	"
	instruction vvvv: instruction operand2 index
]

{ #category : #private }
OperandEncoding >> encodeMVROperand3: instruction [
	"
	ModRM:r/m (w)
	VEX.vvvv (r)
	ModRM:reg (r)
	"
	instruction vreg: instruction operand3
]

{ #category : #private }
OperandEncoding >> encodeNPOperand1: instruction [
	"
	ModRM:r/m (w)
	ModRM:reg (r)
	"
	self ASSERT: instruction operand1 isImmediate
]

{ #category : #private }
OperandEncoding >> encodeNPOperand2: operand [
	"
	ModRM:r/m (w)
	ModRM:reg (r)
	"
	self ASSERT: false
]

{ #category : #private }
OperandEncoding >> encodeOIOperand1: instruction [
	"
	opcode + rd (w)
	imm8/16/32/64
	"
	self encodeOOperand1: instruction
]

{ #category : #private }
OperandEncoding >> encodeOIOperand2: instruction [
	"
	opcode + rd (w)
	imm8/16/32/64
	"
	instruction operand2 length: instruction operand1 length.
	instruction immediate: instruction operand2 bytes
]

{ #category : #private }
OperandEncoding >> encodeOOperand1: instruction [
	"
	opcode + rd (r, w)
	"
	| index i opcode |
	index := instruction operand1 index.
	i := index bitAnd: 2r111.
	opcode := instruction spec primaryOpcode copy.
	opcode at: opcode size put: opcode last + i.
	index > 7
		ifTrue: [instruction rexB: true opcode: opcode]
		ifFalse: [instruction opcode: opcode]
]

{ #category : #services }
OperandEncoding >> encodeOperand: i of: instruction [
	| selector |
	selector := selectors at: i.
	self perform: selector with: instruction
]

{ #category : #services }
OperandEncoding >> encodeOperands: instruction [
	1 to: instruction arity do: [:i | self encodeOperand: i of: instruction]
]

{ #category : #private }
OperandEncoding >> encodeRM0Operand1: instruction [
	"
	ModRM:reg (r, w)
	ModRM:r/m (r)
	"
	instruction vreg: instruction operand1
]

{ #category : #private }
OperandEncoding >> encodeRM0Operand2: instruction [
	"
	ModRM:reg (r, w)
	ModRM:r/m (r)
	"
	instruction vrm: instruction operand2 rm
]

{ #category : #private }
OperandEncoding >> encodeRMIOperand1: instruction [
	"
	ModRM:reg (w)
	ModRM:r/m (r)
	imm8
	"
	instruction reg: instruction operand1
]

{ #category : #private }
OperandEncoding >> encodeRMIOperand2: instruction [
	"
	ModRM:reg (w)
	ModRM:r/m (r)
	imm8
	"
	instruction rm: instruction operand2 rm
]

{ #category : #private }
OperandEncoding >> encodeRMIOperand3: instruction [
	"
	ModRM:reg (w)
	ModRM:r/m (r)
	imm8
	"
	| op bytes |
	op := instruction spec operands at: 3.
	bytes := self bytesFor: instruction operand3 value length: op length // 8.
	instruction immediate: bytes
]

{ #category : #private }
OperandEncoding >> encodeRMOperand1: instruction [
	"
	ModRM:reg (r, w)
	ModRM:r/m (r)
	"
	instruction reg: instruction operand1
]

{ #category : #private }
OperandEncoding >> encodeRMOperand2: instruction [
	"
	ModRM:reg (r, w)
	ModRM:r/m (r)
	"
	instruction rm: instruction operand2 rm
]

{ #category : #private }
OperandEncoding >> encodeRMVOperand1: instruction [
	"
	ModRM:reg (w)
	ModRM:r/m (r)
	VEX.vvvv (r)
	"
	instruction vreg: instruction operand1
]

{ #category : #private }
OperandEncoding >> encodeRMVOperand2: instruction [
	"
	ModRM:reg (w)
	ModRM:r/m (r)
	VEX.vvvv (r)
	"
	instruction vrm: instruction operand2 rm
]

{ #category : #private }
OperandEncoding >> encodeRMVOperand3: instruction [
	"
	ModRM:reg (w)
	ModRM:r/m (r)
	VEX.vvvv (r)
	"
	instruction vvvv: instruction operand3 index
]

{ #category : #private }
OperandEncoding >> encodeRVMIOperand1: instruction [
	"
	ModRM:reg (w)
	VEX.vvvv (r)
	ModRM:r/m (r)
	imm8[3:0]
	"
	instruction vreg: instruction operand1
]

{ #category : #private }
OperandEncoding >> encodeRVMIOperand2: instruction [
	"
	ModRM:reg (w)
	VEX.vvvv (r)
	ModRM:r/m (r)
	imm8[3:0]
	"
	instruction vvvv: instruction operand2 index
]

{ #category : #private }
OperandEncoding >> encodeRVMIOperand3: instruction [
	"
	ModRM:reg (w)
	VEX.vvvv (r)
	ModRM:r/m (r)
	imm8[3:0]
	"
	instruction vrm: instruction operand3 rm
]

{ #category : #private }
OperandEncoding >> encodeRVMIOperand4: instruction [
	"
	ModRM:reg (w)
	VEX.vvvv (r)
	ModRM:r/m (r)
	imm8[3:0]
	"
	| op bytes |
	op := instruction spec operands at: 4.
	bytes := self bytesFor: instruction operand4 value length: op length // 8.
	instruction immediate: bytes
]

{ #category : #private }
OperandEncoding >> encodeRVMOperand1: instruction [
	"
	ModRM:reg (w)
	VEX.vvvv
	ModRM:r/m (r)
	"
	instruction vreg: instruction operand1
]

{ #category : #private }
OperandEncoding >> encodeRVMOperand2: instruction [
	"
	ModRM:reg (w)
	VEX.vvvv
	ModRM:r/m (r)
	"
	instruction vvvv: instruction operand2 index
]

{ #category : #private }
OperandEncoding >> encodeRVMOperand3: instruction [
	"
	ModRM:reg (w)
	VEX.vvvv
	ModRM:r/m (r)
	"
	instruction vrm: instruction operand3 rm
]

{ #category : #private }
OperandEncoding >> encodeRVMROperand1: instruction [
	"
	ModRM:reg (w)
	VEX.vvvv (r)
	ModRM:r/m (r)
	imm8[7:4]
	"
	instruction vreg: instruction operand1
]

{ #category : #private }
OperandEncoding >> encodeRVMROperand2: instruction [
	"
	ModRM:reg (w)
	VEX.vvvv (r)
	ModRM:r/m (r)
	imm8[7:4]
	"
	instruction vvvv: instruction operand2 index
]

{ #category : #private }
OperandEncoding >> encodeRVMROperand3: instruction [
	"
	ModRM:reg (w)
	VEX.vvvv (r)
	ModRM:r/m (r)
	imm8[7:4]
	"
	instruction vrm: instruction operand3 rm
]

{ #category : #private }
OperandEncoding >> encodeRVMROperand4: instruction [
	"
	ModRM:reg (w)
	VEX.vvvv (r)
	ModRM:r/m (r)
	imm8[7:4]
	"
	| imm |
	imm := instruction operand4 index bitShift: 4.
	instruction immediate: imm
]

{ #category : #private }
OperandEncoding >> encodeT1SOperand1: instruction [
	"
	ModRM:reg (w)
	EVEX.vvvv
	ModRM:r/m (r)
	"
]

{ #category : #private }
OperandEncoding >> encodeT1SOperand2: instruction [
	"
	ModRM:reg (w)
	EVEX.vvvv
	ModRM:r/m (r)
	"
]

{ #category : #private }
OperandEncoding >> encodeT1SOperand3: instruction [
	"
	ModRM:reg (w)
	EVEX.vvvv
	ModRM:r/m (r)
	"
]

{ #category : #private }
OperandEncoding >> encodeT1SRVMOperand1: instruction [
	"
	ModRM:reg (w)
	EVEX.vvvv
	ModRM:r/m (r)
	"
]

{ #category : #private }
OperandEncoding >> encodeT1SRVMOperand2: instruction [
	"
	ModRM:reg (w)
	EVEX.vvvv
	ModRM:r/m (r)
	"
]

{ #category : #private }
OperandEncoding >> encodeT1SRVMOperand3: instruction [
	"
	ModRM:reg (w)
	EVEX.vvvv
	ModRM:r/m (r)
	"
]

{ #category : #private }
OperandEncoding >> encodeTDOperand1: operand [
	"
	Moffs (w)
	AL/AX/EAX/RAX
	"
	
]

{ #category : #private }
OperandEncoding >> encodeTDOperand2: operand [
	"
	Moffs (w)
	AL/AX/EAX/RAX
	"
	
]

{ #category : #private }
OperandEncoding >> encodeTOOperand1: operand [
	
]

{ #category : #private }
OperandEncoding >> encodeTOOperand2: operand [
	
]

{ #category : #private }
OperandEncoding >> encodeVMIOperand1: instruction [
	"
	VEX.vvvv (w)
	ModRM:r/m (r)
	imm8
	"
	instruction vvvv: instruction operand1 index
]

{ #category : #private }
OperandEncoding >> encodeVMIOperand2: instruction [
	"
	VEX.vvvv (w)
	ModRM:r/m (r)
	imm8
	"
	instruction vrm: instruction operand2 rm
]

{ #category : #private }
OperandEncoding >> encodeVMIOperand3: instruction [
	"
	VEX.vvvv (w)
	ModRM:r/m (r)
	imm8
	"
	| op bytes |
	op := instruction spec operands at: 3.
	bytes := self bytesFor: instruction operand3 value length: op length // 8.
	instruction immediate: bytes
]

{ #category : #private }
OperandEncoding >> encodeVMOperand1: operand [
	"
	VEX.vvvv (w)
	ModRM:r/m (r)
	"
	
]

{ #category : #private }
OperandEncoding >> encodeVMOperand2: operand [
	"
	VEX.vvvv (w)
	ModRM:r/m (r)
	"
	
]

{ #category : #private }
OperandEncoding >> encodeXMOperand1: operand [
	"
	ModRM:reg (w)
	ModRM:r/m (r)
	"
	
]

{ #category : #private }
OperandEncoding >> encodeXMOperand2: operand [
	"
	ModRM:reg (w)
	ModRM:r/m (r)
	"
	
]

{ #category : #services }
OperandEncoding >> immediateOperand [
	^descriptions findFirst: [:d | d includesString: 'imm']
]

{ #category : #testing }
OperandEncoding >> isImmediate1Operand: index [
	^(self isImmediateOperand: index)
		and: [(1 to: index - 1) noneSatisfy: [:i | self isImmediateOperand: i]]
]

{ #category : #testing }
OperandEncoding >> isImmediate2Operand: index [
	^(self isImmediateOperand: index)
		and: [(1 to: index - 1) anySatisfy: [:i | self isImmediateOperand: i]]
]

{ #category : #testing }
OperandEncoding >> isImmediateOperand: index [
	| d |
	d := descriptions at: index.
	^(d includesString: 'imm') or: [d includesString: 'offs'] or: [d = 'iw']
]

{ #category : #testing }
OperandEncoding >> isVvvvOperand: index [
	^(descriptions at: index) includesString: 'vvvv'
]

{ #category : #accessing }
OperandEncoding >> name [
	^name
]

{ #category : #accessing }
OperandEncoding >> name: aString [
	name := aString
]

{ #category : #services }
OperandEncoding >> operand: index of: instruction [
	| d |
	d := descriptions at: index.
	(d includesString: 'reg') ifTrue: [^instruction regOperand: index].
	(d includesString: 'r/m') ifTrue: [^instruction rmOperand: index].
	(d includesString: 'vvvv') ifTrue: [^instruction vvvvOperand: index].
	(self isImmediate1Operand: index) ifTrue: [^instruction immediateOperand].
	(self isImmediate2Operand: index) ifTrue: [^instruction immediateOperand2].
	(instruction spec operands at: index) isImmediate
		ifTrue: [^instruction immediateOperand].
	((d beginsWith: 'opcode') and: [index = 1])
		ifTrue: [^instruction opcodeOperand].
	self ASSERT: false
]

{ #category : #printing }
OperandEncoding >> printOn: aStream [
	name isNil ifTrue: [^super printOn: aStream].
	aStream nextPutAll: name
]

{ #category : #accessing }
OperandEncoding >> selectors [
	^selectors
]

{ #category : #accessing }
OperandEncoding >> selectors: aCollection [
	selectors := aCollection
]

{ #category : #testing }
OperandEncoding >> usesImmediate [
	^immediate
]

{ #category : #testing }
OperandEncoding >> usesImmediate2 [
	^immediate and: [selectors anySatisfy: [:s | s includesString: 'II']]
]

{ #category : #testing }
OperandEncoding >> usesModRM [
	^modrm
]
