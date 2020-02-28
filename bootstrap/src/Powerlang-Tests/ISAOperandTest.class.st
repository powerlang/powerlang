"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #ISAOperandTest,
	#superclass : #TestCase,
	#pools : [
		'Registers'
	],
	#category : #'Powerlang-Tests-Assembler-Intel'
}

{ #category : #immediate }
ISAOperandTest >> testImm32 [
	| imm32 |
	imm32 := ISAImmediate new value: -16r80000000.
	self assert: imm32 length = 32.
	imm32 := ISAImmediate new value: -129.
	self assert: imm32 length = 16.
	imm32 := ISAImmediate new value: 128.
	self assert: imm32 length = 16.
	imm32 := ISAImmediate new value: 16r7FFFFFFF.
	self assert: imm32 length = 32
]

{ #category : #immediate }
ISAOperandTest >> testImm8 [
	| imm8 |
	imm8 := ISAImmediate new value: -128.
	self assert: imm8 length = 8.
	imm8 := ISAImmediate new value: 127.
	self assert: imm8 length = 8
]

{ #category : #registers }
ISAOperandTest >> testIndexes [
	| table |
	table := '0	al	ax	eax	rax
		1	cl	cx	ecx	rcx
		2	dl	dx	edx	rdx
		3	bl	bx	ebx	rbx
		4	ah	sp	esp	rsp
		5	ch,bpl	bp	ebp	rbp
		6	dh,sil	si	esi	rsi
		7	bh,dil	di	edi	rdi
		8	r8b	r8w	r8d	r8
		9	r9b	r9w	r9d	r9
		10	r10b	r10w	r10d	r10
		11	r11b	r11w	r11d	r11
		12	r12b	r12w	r12d	r12
		13	r13b	r13w	r13d	r13
		14	r14b	r14w	r14d	r14
		15	r15b	r15w	r15d	r15'.
	table lines collect: #substrings thenDo: [:array | 
		array allButFirst withIndexDo: [:r :i | 
			($, split: r) do: [:rg | | reg length |
				reg := Register named: rg.
				length := #(8 16 32 64) at: i.
				self
					assert: reg length = length;
					assert: reg name = rg;
					assert: reg index = array first asNumber]]]
]

{ #category : #registers }
ISAOperandTest >> testMMIndexes [
	(0 to: 7)
		collect: [:i | ('mmx* xmm* ymm*' replaceAllSubstrings: '*' with: i asString) substrings]
		thenDo: [:array | 
			array withIndexDo: [:r :i | | index reg length |
				index := r last digitValue.
				reg := Register named: r.
				length := #(64 128 256) at: i.
				self
					assert: reg length = length;
					assert: reg name = r;
					assert: reg index = index]].
	(8 to: 15)
		collect: [:i | ('xmm*	ymm*' replaceAllSubstrings: '*' with: i asString) substrings]
		thenDo: [:array | 
			array withIndexDo: [:r :i | | index reg length |
				index := (r select: #isDigit) asInteger.
				reg := Register named: r.
				length := #(128 256) at: i.
				self
					assert: reg length = length;
					assert: reg name = r;
					assert: reg index = index]]
]

{ #category : #vex }
ISAOperandTest >> test_VBLENDVPD_spec [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'vblendvpd';
		operands: (Array with: xmm1 with: xmm2 with: xmm3 with: xmm4).
	self assert: instruction spec primaryOpcode = #[16r4b]
]

{ #category : #vex }
ISAOperandTest >> test_VMOVSD_spec [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'vmovsd';
		operands: (Array with: xmm3 with: xmm2 with: xmm1).
	self assert: instruction spec primaryOpcode = #[16r11]
]
