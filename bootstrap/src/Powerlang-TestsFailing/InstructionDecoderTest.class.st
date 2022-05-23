"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #InstructionDecoderTest,
	#superclass : #TestCase,
	#pools : [
		'AnObsoleteRegisters'
	],
	#category : #'Powerlang-TestsFailing-Assembler-Intel'
}

{ #category : #other }
InstructionDecoderTest >> decoding32Of: aByteArray equals: anISAInstruction [
	| decoder instruction |
	decoder := #InstructionDecoder on: aByteArray readStream.
	decoder wordSize: 4.
	instruction := decoder next.
	self assert: (instruction isLike: anISAInstruction)
]

{ #category : #other }
InstructionDecoderTest >> decodingOf: aByteArray equals: anISAInstruction [
	| decoder instruction |
	decoder := #InstructionDecoder on: aByteArray readStream.
	instruction := decoder next.
	self assert: (instruction isLike: anISAInstruction)

]

{ #category : #'16 bits' }
InstructionDecoderTest >> testAddSP4 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'add';
		operands: (Array with: sp with: 4).
	self decodingOf: #[16r66 16r83 16rC4 16r04] equals: instruction
]

{ #category : #other }
InstructionDecoderTest >> testCMPS [
	| instruction op1 op2 |
	op1 := MemoryOperand new
		segment: ds;
		base: esi;
		length: 32.
	op2 := MemoryOperand new
		segment: es;
		base: edi;
		length: 32.
	instruction := ISAInstruction new
		mnemonic: 'cmps';
		operands: op1 , op2.
	self decoding32Of: #[16ra7] equals: instruction
]

{ #category : #other }
InstructionDecoderTest >> testMOVABS [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'mov';
		operands: r11 , 16r972d70.
	instruction operands second length: 64.
	self
		decodingOf: #[16r49 16rBB 16r70 16r2D 16r97 16r00 16r00 16r00 16r00 16r00]
		equals: instruction
]

{ #category : #other }
InstructionDecoderTest >> testMOVR11Imm [
	| imm instruction |
	imm := ISAImmediate new value: 16r5FF740; length: 64.
	instruction := ISAInstruction new
		mnemonic: 'mov';
		operands: (Array with: r11 with: imm).
	self
		decodingOf: #[16r49 16rBB 16r40 16rF7 16r5F 16r00 16r00 16r00 16r00 16r00]
		equals: instruction
]

{ #category : #other }
InstructionDecoderTest >> testMovALMem32 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'mov';
		operands: (Array with: al with: 'byte ptr[-0x4FEFFE9F]').
	self decoding32Of: #[16ra0 16r61 16r01 16r10 16rb0] equals: instruction
]

{ #category : #other }
InstructionDecoderTest >> testMovECXMem32 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'mov';
		operands: (Array with: ecx with: 'dword ptr[0x55870c]').
	self
		decoding32Of: #[16r8b 16r0c 16r25 16r0c 16r87 16r55 16r00]
		equals: instruction
]

{ #category : #other }
InstructionDecoderTest >> testOrBH01 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'or';
		operands: (Array with: bh with: 1).
	self decoding32Of: #[16r80 16rcf 16r01] equals: instruction
]

{ #category : #other }
InstructionDecoderTest >> testPush40 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'pushq';
		operands: (Array with: 16r40).
	self decoding32Of: #[16r6A 16r40] equals: instruction
]

{ #category : #vex }
InstructionDecoderTest >> testVPSLLD [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'vpslld';
		operands: (Array with: xmm1 with: xmm2 with: -1).
	self decodingOf: #[16rc5 16rf1 16r72 16rf2 16rff] equals: instruction
]

{ #category : #'adc - imm' }
InstructionDecoderTest >> test_ADC_al_imm8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: al with: 1).
	self decodingOf: #[16r14 16r01] equals: instruction
]

{ #category : #'adc - mem' }
InstructionDecoderTest >> test_ADC_al_mB [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: al with: 'bword ptr [rbx]').
	self decodingOf: #[16r12 16r03] equals: instruction
]

{ #category : #'adc - mem' }
InstructionDecoderTest >> test_ADC_al_mBD [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: al with: 'bword ptr [rbx + 1]').
	self decodingOf: #[16r12 16r43 16r01] equals: instruction
]

{ #category : #'adc - mem' }
InstructionDecoderTest >> test_ADC_al_mBI [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: al with: 'bword ptr [rbx + rbp]').
	self decodingOf: #[16r12 16r04 16r2b] equals: instruction
]

{ #category : #'adc - mem' }
InstructionDecoderTest >> test_ADC_al_mBIS [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: al with: 'bword ptr [rbx + rbp * 8]').
	self decodingOf: #[16r12 16r04 16reb] equals: instruction
]

{ #category : #'adc - mem' }
InstructionDecoderTest >> test_ADC_al_mBISD [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: al with: 'byte ptr [rbx + rsi * 2 + 0x100]').
	self
		decodingOf: #[16r12 16r84 16r73 16r00 16r01 16r00 16r00]
		equals: instruction
]

{ #category : #'adc - imm' }
InstructionDecoderTest >> test_ADC_ax_imm16 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: ax with: 256).
	self decodingOf: #[16r66 16r15 16r00 16r01] equals: instruction
]

{ #category : #'adc - imm' }
InstructionDecoderTest >> test_ADC_ax_imm8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: ax with: 1).
	self decodingOf: #[16r66 16r83 16rd0 16r01] equals: instruction
]

{ #category : #'adc - imm' }
InstructionDecoderTest >> test_ADC_eax_imm32 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: eax with: 256).
	instruction operands second length: 32.
	self decodingOf: #[16r15 16r00 16r01 16r00 16r00] equals: instruction
]

{ #category : #'adc - mem' }
InstructionDecoderTest >> test_ADC_r8_mBISD [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: r8 with: 'qword ptr [rbx + rcx * 8 - 1]').
	self decodingOf: #[16r4C 16r13 16r44 16rcb 16rff] equals: instruction
]

{ #category : #'adc - rr' }
InstructionDecoderTest >> test_ADC_r8_r9 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: r8 with: r9).
	self decodingOf: #[16r4D 16r11 16rC8] equals: instruction
]

{ #category : #'adc - rr' }
InstructionDecoderTest >> test_ADC_r8_rax [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: r8 with: rax).
	self decodingOf: #[16r49 16r11 16rC0] equals: instruction
]

{ #category : #'adc - imm' }
InstructionDecoderTest >> test_ADC_rax_imm32 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 256).
	instruction operands second length: 32.
	self decodingOf: #[16r48 16r15 16r00 16r01 16r00 16r00] equals: instruction
]

{ #category : #'adc - imm' }
InstructionDecoderTest >> test_ADC_rax_imm8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 1).
	self decodingOf: #[16r48 16r83 16rD0 16r01] equals: instruction
]

{ #category : #'adc - mem' }
InstructionDecoderTest >> test_ADC_rax_mB [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 'qword ptr [rbx]').
	self decodingOf: #[16r48 16r13 16r03] equals: instruction
]

{ #category : #'adc - mem' }
InstructionDecoderTest >> test_ADC_rax_mBD [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 'qword ptr [rbx + 1]').
	self decodingOf: #[16r48 16r13 16r43 16r01] equals: instruction
]

{ #category : #'adc - mem' }
InstructionDecoderTest >> test_ADC_rax_mBI [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 'qword ptr [rbx + rbp]').
	self decodingOf: #[16r48 16r13 16r04 16r2b] equals: instruction
]

{ #category : #'adc - mem' }
InstructionDecoderTest >> test_ADC_rax_mBIS [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 'qword ptr [rbx + rbp * 8]').
	self decodingOf: #[16r48 16r13 16r04 16reb] equals: instruction
]

{ #category : #'adc - mem' }
InstructionDecoderTest >> test_ADC_rax_mBISD [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 'qword ptr [rbx + rcx * 8 - 1]').
	self decodingOf: #[16r48 16r13 16r44 16rcb 16rff] equals: instruction
]

{ #category : #'adc - mem' }
InstructionDecoderTest >> test_ADC_rax_mD [
	| mem instruction |
	mem := MemoryOperand new length: 64; displacement: 16r7FFFFFFF.
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: mem).
	self
		decodingOf: #[16r48 16r13 16r04 16r25 16rFF 16rFF 16rFF 16r7F]
		equals: instruction
]

{ #category : #'adc - rr' }
InstructionDecoderTest >> test_ADC_rax_r8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: r8).
	self decodingOf: #[16r4C 16r11 16rC0] equals: instruction
]

{ #category : #'adc - rr' }
InstructionDecoderTest >> test_ADC_rax_rbx [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: rbx).
	self decodingOf: #[16r48 16r11 16rd8] equals: instruction
]

{ #category : #'adc - rr' }
InstructionDecoderTest >> test_ADC_rax_rsi [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: rsi).
	self decodingOf: #[16r48 16r11 16rf0] equals: instruction
]

{ #category : #'adc - rr' }
InstructionDecoderTest >> test_ADC_rbx_rax [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rbx with: rax).
	self decodingOf: #[16r48 16r11 16rc3] equals: instruction
]

{ #category : #'adc - rr' }
InstructionDecoderTest >> test_ADC_rsi_rax [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rsi with: rax).
	self decodingOf: #[16r48 16r11 16rc6] equals: instruction
]

{ #category : #float }
InstructionDecoderTest >> test_ADDSS_xmm [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'addss';
		operands: (Array with: xmm1 with: 'dword ptr [rcx]').
	self decodingOf: #[16rf3 16r0f 16r58 16r09] equals: instruction
]

{ #category : #vex }
InstructionDecoderTest >> test_BEXTR_rsi_rcx_r8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'bextr';
		operands: (Array with: rsi with: rcx with: r8).
	self decodingOf: #[16rc4 16re2 16rb8 16rf7 16rf1] equals: instruction
]

{ #category : #vex }
InstructionDecoderTest >> test_BEXTR_rsi_rcx_rbx [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'bextr';
		operands: (Array with: rsi with: rcx with: rbx).
	self decodingOf: #[16rc4 16re2 16re0 16rf7 16rf1] equals: instruction
]

{ #category : #shifts }
InstructionDecoderTest >> test_BSWAP [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'BSWAP';
		operands: (Array with: rcx).
	self decodingOf: #[16r48 16r0f 16rc9] equals: instruction
]

{ #category : #calls }
InstructionDecoderTest >> test_CALL_r64 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'CALL';
		operands: (Array with: rbx).
	self decodingOf: #[16rFF 16rD3] equals: instruction
]

{ #category : #jumps }
InstructionDecoderTest >> test_CALL_rel32 [
	| instruction |
	instruction := ISAInstruction new mnemonic: 'CALL'; operands: #(-9).
	instruction operands anyone length: 32.
	self decodingOf: #[16re8 16rf7 16rff 16rff 16rff] equals: instruction
]

{ #category : #arithmetic }
InstructionDecoderTest >> test_CMPXCHG_m64_rcx [
	| instruction parser |
	parser := AssemblerParser new.
	instruction := parser parse: 'cmpxchg qword ptr [rdx], rcx'.
	self decodingOf: #[16r48 16r0F 16rB1 16r0A] equals: instruction anyone
]

{ #category : #arithmetic }
InstructionDecoderTest >> test_CMP_m32_imm8 [
	| instruction parser |
	parser := AssemblerParser new.
	instruction := parser parse: 'cmp dword ptr[rax-4], 0x12'.
	self decodingOf: #[16r83 16r78 16rfc 16r12] equals: instruction anyone
]

{ #category : #float }
InstructionDecoderTest >> test_CVTSS2SI [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'cvtss2si';
		operands: (Array with: eax with: xmm1).
	self decodingOf: #[16rf3 16r0f 16r2d 16rc1] equals: instruction
]

{ #category : #stack }
InstructionDecoderTest >> test_ENTER_imm16_0 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ENTER';
		operands: (Array with: 8 with: 0).
	instruction operands first length: 16.
	instruction operands second length: 8.
	self decodingOf: #[16rC8 16r08 16r00 16r00] equals: instruction
]

{ #category : #stack }
InstructionDecoderTest >> test_ENTER_imm16_1 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ENTER';
		operands: (Array with: 8 with: 1).
	instruction operands first length: 16.
	instruction operands second length: 8.
	self decodingOf: #[16rC8 16r08 16r00 16r01] equals: instruction
]

{ #category : #stack }
InstructionDecoderTest >> test_ENTER_imm16_imm8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ENTER';
		operands: (Array with: 8 with: 32).
	instruction operands first length: 16.
	instruction operands second length: 8.
	self decodingOf: #[16rC8 16r08 16r00 16r20] equals: instruction
]

{ #category : #float }
InstructionDecoderTest >> test_FSCALE [
	| instruction |
	instruction := ISAInstruction new mnemonic: 'fscale'.
	self decodingOf: #[16rD9 16rFD] equals: instruction
]

{ #category : #float }
InstructionDecoderTest >> test_FSTSW [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'fstsw';
		operands: (Array with: 'word ptr [rdx]').
	self decodingOf: #[16r9b 16rdd 16r3a] equals: instruction
]

{ #category : #arithmetic }
InstructionDecoderTest >> test_IMUL_r64_r64_imm8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'IMUL';
		operands: (Array with: r9 with: r10 with: -1).
	self decodingOf: #[16r4D 16r6B 16rCA 16rFF] equals: instruction
]

{ #category : #jumps }
InstructionDecoderTest >> test_JA_rel32 [
	| instruction |
	instruction := ISAInstruction new mnemonic: 'JA'; operands: #(16r100).
	instruction operands anyone length: 32.
	self decodingOf: #[16r0F 16r87 16r00 16r01 16r00 16r00] equals: instruction.
	instruction := ISAInstruction new mnemonic: 'JA'; operands: #(-16r100).
	instruction operands anyone length: 32.
	self decodingOf: #[16r0F 16r87 16r00 16rFF 16rFF 16rFF] equals: instruction
]

{ #category : #float }
InstructionDecoderTest >> test_LDMXCSR [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ldmxcsr';
		operands: (Array with: 'dword ptr [rdx]').
	self decodingOf: #[16r0f 16rae 16r12] equals: instruction
]

{ #category : #float }
InstructionDecoderTest >> test_MOVAPD_xmm [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'movapd';
		operands: (Array with: xmm1 with: 'xmmword ptr [rbx]').
	self decodingOf: #[16r66 16r0f 16r28 16r0b] equals: instruction
]

{ #category : #float }
InstructionDecoderTest >> test_MOVSS_rip [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'movss';
		operands: (Array with: xmm1 with: 'dword ptr [rip + 0x4]').
	self
		decodingOf: #[16rf3 16r0f 16r10 16r0d 16r04 16r00 16r00 16r00]
		equals: instruction
]

{ #category : #stack }
InstructionDecoderTest >> test_MOV_32_in_64 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: ebp , esp.
	self decodingOf: #[16r89 16rE5] equals: instruction
]

{ #category : #mov }
InstructionDecoderTest >> test_MOV_esi_mem [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: esi , 'dword ptr [esp + 0xc]'.
	self decoding32Of: #[16r8b 16r74 16r24 16r0c] equals: instruction
]

{ #category : #mov }
InstructionDecoderTest >> test_MOV_fs [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'qword ptr [fs:0x18]' with: r9).
	self
		decodingOf: #[16r64 16r4c 16r89 16r0c 16r25 16r18 16r00 16r00 16r00]
		equals: instruction
]

{ #category : #mov }
InstructionDecoderTest >> test_MOV_fs_r9 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: fs with: r9).
	self decodingOf: #[16r49 16r8e 16re1] equals: instruction
]

{ #category : #mov }
InstructionDecoderTest >> test_MOV_m_r9 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'qword ptr [0x8]' with: r9).
	self
		decodingOf: #[16r4c 16r89 16r0c 16r25 16r08 16r00 16r00 16r00]
		equals: instruction
]

{ #category : #mov }
InstructionDecoderTest >> test_MOV_na_r9_mD_0 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'qword ptr [0x0]' with: r9).
	self
		decodingOf: #[16r4C 16r89 16r0C 16r25 16r00 16r00 16r00 16r00]
		equals: instruction
]

{ #category : #mov }
InstructionDecoderTest >> test_MOV_r13 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'byte ptr [r13]' with: 17).
	self decodingOf: #[16r41 16rc6 16r45 16r00 16r11] equals: instruction
]

{ #category : #mov }
InstructionDecoderTest >> test_MOV_r13_rax_mB [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'qword ptr [r13]' with: rax).
	self decodingOf: #[16r49 16r89 16r45 16r00] equals: instruction
]

{ #category : #mov }
InstructionDecoderTest >> test_MOV_r13_rax_mBIS [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'qword ptr [r13 + rbx * 2]' with: rax).
	self decodingOf: #[16r49 16r89 16r44 16r5D 16r00] equals: instruction
]

{ #category : #mov }
InstructionDecoderTest >> test_MOV_r8_imm8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: cl with: -1).
	self decodingOf: #[16rB1 16rFF] equals: instruction
]

{ #category : #mov }
InstructionDecoderTest >> test_MOV_rax_moffset [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: rax with: 16r1122334455667788).
	self
		decodingOf: #[16r48 16rb8 16r88 16r77 16r66 16r55 16r44 16r33 16r22 16r11]
		equals: instruction
]

{ #category : #mov }
InstructionDecoderTest >> test_MOV_rip_rax_mBD [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'qword ptr [rip + 0x200]' with: rax).
	self
		decodingOf: #[16r48 16r89 16r05 16r00 16r02 16r00 16r00]
		equals: instruction
]

{ #category : #stack }
InstructionDecoderTest >> test_PUSH_bp [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'PUSH';
		operands: (Array with: bp).
	self decodingOf: #[16r66 16r55] equals: instruction
]

{ #category : #stack }
InstructionDecoderTest >> test_PUSH_r64 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'PUSH';
		operands: (Array with: r8).
	self decodingOf: #[16r41 16r50] equals: instruction
]

{ #category : #stack }
InstructionDecoderTest >> test_PUSH_rbp [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'PUSH';
		operands: (Array with: rbp).
	self decodingOf: #[16r55] equals: instruction
]

{ #category : #mov }
InstructionDecoderTest >> test_REPNZ_SCAS [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'repne_scas';
		operands: (Array with: al).
	self decoding32Of: #[16rf2 16rae] equals: instruction
]

{ #category : #calls }
InstructionDecoderTest >> test_RET [
	| instruction |
	instruction := ISAInstruction new mnemonic: 'RET'.
	self decodingOf: #[16rC3] equals: instruction
]

{ #category : #calls }
InstructionDecoderTest >> test_RET_imm [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'RET';
		operands: (Array with: 256).
	self decodingOf: #[16rC2 16r00 16r01] equals: instruction
]

{ #category : #float }
InstructionDecoderTest >> test_ROUNDPD_xmm [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'roundpd';
		operands: (Array with: xmm1 with: xmm2 with: 3).
	self decodingOf: #[16r66 16r0f 16r3a 16r09 16rca 16r03] equals: instruction
]

{ #category : #shifts }
InstructionDecoderTest >> test_SAL_m64_1 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'SAL';
		operands: (Array with: 'qword ptr [rbx]' with: 1).
	self decodingOf: #[16r48 16rd1 16r23] equals: instruction
]

{ #category : #shifts }
InstructionDecoderTest >> test_SAL_r64_1 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'SAL';
		operands: (Array with: rbx with: 1).
	self decodingOf: #[16r48 16rd1 16re3] equals: instruction
]

{ #category : #shifts }
InstructionDecoderTest >> test_SHL_r32_1 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'SHL';
		operands: eax , 1.
	self decoding32Of: #[16rd1 16re0] equals: instruction
]

{ #category : #shifts }
InstructionDecoderTest >> test_SHL_r64_1 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'SHL';
		operands: rax , 1.
	self decodingOf: #[16r48 16rd1 16re0] equals: instruction
]

{ #category : #shifts }
InstructionDecoderTest >> test_SHRD_r64_r64_cl [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'SHRD';
		operands: (Array with: rbx with: rsi with: cl).
	self decodingOf: #[16r48 16r0f 16rad 16rf3] equals: instruction
]

{ #category : #shifts }
InstructionDecoderTest >> test_SHRD_r64_r64_imm8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'SHRD';
		operands: (Array with: rbx with: rsi with: -1).
	self decodingOf: #[16r48 16r0f 16rac 16rf3 16rff] equals: instruction
]

{ #category : #float }
InstructionDecoderTest >> test_STMXCSR [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'stmxcsr';
		operands: (Array with: 'dword ptr [rdx]').
	self decodingOf: #[16r0f 16rae 16r1a] equals: instruction
]

{ #category : #vex }
InstructionDecoderTest >> test_VBLENDPD_xmm [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'vblendpd';
		operands: (Array with: xmm1 with: xmm2 with: xmm3 with: -1).
	self decodingOf: #[16rc4 16re3 16r69 16r0d 16rcb 16rff] equals: instruction
]

{ #category : #vex }
InstructionDecoderTest >> test_VBLENDVPD_xmm [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'vblendvpd';
		operands: (Array with: xmm1 with: xmm2 with: xmm3 with: xmm4).
	self decodingOf: #[16rc4 16re3 16r69 16r4b 16rcb 16r40] equals: instruction
]
