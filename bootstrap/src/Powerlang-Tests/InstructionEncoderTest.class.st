"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #InstructionEncoderTest,
	#superclass : #TestCase,
	#pools : [
		'Registers'
	],
	#category : #'Powerlang-Tests-Assembler-Intel'
}

{ #category : #private }
InstructionEncoderTest >> encodingOf: instructionOrString equals: aByteArray [
	| encoded result actual instruction |
	instruction := instructionOrString isString
		ifTrue: [AssemblerParser new parseInstruction: instructionOrString]
		ifFalse: [instructionOrString].
	encoded := instruction encoding64.
	result := ISAInstructionReader new from: encoded readStream; asString.
	actual := ISAInstructionReader new from: aByteArray readStream; asString.
	self
		assert: result = actual;
		assert: aByteArray = encoded
]

{ #category : #other }
InstructionEncoderTest >> testCMPXCHG [
	self encodingOf: 'cmpxchg rbx, rcx' equals: #[16r48 16r0f 16rb1 16rcb]
]

{ #category : #other }
InstructionEncoderTest >> testINT3 [
	self encodingOf: 'int 3' equals: #[16rCC]
]

{ #category : #other }
InstructionEncoderTest >> testINT4 [
	self encodingOf: 'int 4' equals: #[16rCD 16r04]
]

{ #category : #other }
InstructionEncoderTest >> testMOVABS [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'mov';
		operands: r11 , 16r972d70.
	instruction operands last length: 64.
	self
		encodingOf: instruction
		equals: #[16r49 16rBB 16r70 16r2D 16r97 16r00 16r00 16r00 16r00 16r00]
]

{ #category : #other }
InstructionEncoderTest >> testMOVR11Imm [
	| imm instruction |
	imm := ISAImmediate new value: 16r5FF740; length: 64.
	instruction := ISAInstruction new
		mnemonic: 'mov';
		operands: (Array with: r11 with: imm).
	self
		encodingOf: instruction
		equals: #[16r49 16rBB 16r40 16rF7 16r5F 16r00 16r00 16r00 16r00 16r00]
]

{ #category : #specs }
InstructionEncoderTest >> testSpec_ADC_rax_imm32 [
	| instruction spec |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 256).
	spec := instruction spec.
	self
		assert: spec asString = 'adc rax, imm32';
		deny: spec isPreferred
]

{ #category : #specs }
InstructionEncoderTest >> testSpec_ADC_rax_imm8 [
	| instruction spec |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 1).
	spec := instruction spec.
	self
		assert: spec asString = 'adc r/m64, imm8';
		assert: spec isPreferred
]

{ #category : #specs }
InstructionEncoderTest >> testSpec_ADC_rax_mB [
	| instruction spec |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: (MemoryOperand new base: rbx; length: 64)).
	spec := instruction spec.
	self
		assert: spec asString = 'adc r64, r/m64';
		deny: spec isPreferred
]

{ #category : #specs }
InstructionEncoderTest >> testSpec_ADC_rax_rbx [
	| instruction spec |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: rbx).
	spec := instruction spec.
	self
		assert: spec asString = 'adc r/m64, r64';
		assert: spec isPreferred
]

{ #category : #specs }
InstructionEncoderTest >> testSpec_ADC_rbx_imm32 [
	| instruction spec |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rbx with: 256).
	spec := instruction spec.
	self
		assert: spec asString = 'adc r/m64, imm32';
		deny: spec isPreferred
]

{ #category : #'adc - imm' }
InstructionEncoderTest >> test_ADC_al_imm8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: al with: 1).
	self encodingOf: instruction equals: #[16r14 16r01]
]

{ #category : #'adc - mem' }
InstructionEncoderTest >> test_ADC_al_mB [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: al with: 'bword ptr [rbx]').
	self encodingOf: instruction equals: #[16r12 16r03]
]

{ #category : #'adc - mem' }
InstructionEncoderTest >> test_ADC_al_mBD [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: al with: 'bword ptr [rbx + 1]').
	self encodingOf: instruction equals: #[16r12 16r43 16r01]
]

{ #category : #'adc - mem' }
InstructionEncoderTest >> test_ADC_al_mBI [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: al with: 'bword ptr [rbx + rbp]').
	self encodingOf: instruction equals: #[16r12 16r04 16r2b]
]

{ #category : #'adc - mem' }
InstructionEncoderTest >> test_ADC_al_mBIS [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: al with: 'bword ptr [rbx + rbp * 8]').
	self encodingOf: instruction equals: #[16r12 16r04 16reb]
]

{ #category : #'adc - mem' }
InstructionEncoderTest >> test_ADC_al_mBISD [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: al with: 'byte ptr [rbx + rsi * 2 + 0x100]').
	self
		encodingOf: instruction
		equals: #[16r12 16r84 16r73 16r00 16r01 16r00 16r00]
]

{ #category : #'adc - imm' }
InstructionEncoderTest >> test_ADC_ax_imm16 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: ax with: 256).
	self encodingOf: instruction equals: #[16r66 16r15 16r00 16r01]
]

{ #category : #'adc - imm' }
InstructionEncoderTest >> test_ADC_ax_imm8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: ax with: 1).
	self encodingOf: instruction equals: #[16r66 16r83 16rd0 16r01]
]

{ #category : #'adc - imm' }
InstructionEncoderTest >> test_ADC_eax_imm32 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: eax with: 256).
	self encodingOf: instruction equals: #[16r15 16r00 16r01 16r00 16r00]
]

{ #category : #'adc - mem' }
InstructionEncoderTest >> test_ADC_r8_mBISD [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: r8 with: 'qword ptr [rbx + rcx * 8 - 1]').
	self encodingOf: instruction equals: #[16r4C 16r13 16r44 16rcb 16rff]
]

{ #category : #'adc - rr' }
InstructionEncoderTest >> test_ADC_r8_r9 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: r8 with: r9).
	self encodingOf: instruction equals: #[16r4D 16r11 16rC8]
]

{ #category : #'adc - rr' }
InstructionEncoderTest >> test_ADC_r8_rax [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: r8 with: rax).
	self encodingOf: instruction equals: #[16r49 16r11 16rC0]
]

{ #category : #'adc - imm' }
InstructionEncoderTest >> test_ADC_rax_imm32 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 256).
	self encodingOf: instruction equals: #[16r48 16r15 16r00 16r01 16r00 16r00]
]

{ #category : #'adc - imm' }
InstructionEncoderTest >> test_ADC_rax_imm8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 1).
	self encodingOf: instruction equals: #[16r48 16r83 16rD0 16r01]
]

{ #category : #'adc - mem' }
InstructionEncoderTest >> test_ADC_rax_mB [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 'qword ptr [rbx]').
	self encodingOf: instruction equals: #[16r48 16r13 16r03]
]

{ #category : #'adc - mem' }
InstructionEncoderTest >> test_ADC_rax_mBD [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 'qword ptr [rbx + 1]').
	self encodingOf: instruction equals: #[16r48 16r13 16r43 16r01]
]

{ #category : #'adc - mem' }
InstructionEncoderTest >> test_ADC_rax_mBI [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 'qword ptr [rbx + rbp]').
	self encodingOf: instruction equals: #[16r48 16r13 16r04 16r2b]
]

{ #category : #'adc - mem' }
InstructionEncoderTest >> test_ADC_rax_mBIS [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 'qword ptr [rbx + rbp * 8]').
	self encodingOf: instruction equals: #[16r48 16r13 16r04 16reb]
]

{ #category : #'adc - mem' }
InstructionEncoderTest >> test_ADC_rax_mBISD [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: 'qword ptr [rbx + rcx * 8 - 1]').
	self encodingOf: instruction equals: #[16r48 16r13 16r44 16rcb 16rff]
]

{ #category : #'adc - mem' }
InstructionEncoderTest >> test_ADC_rax_mD [
	| mem instruction |
	mem := MemoryOperand new length: 64; displacement: 16r7FFFFFFF.
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: mem).
	self
		encodingOf: instruction
		equals: #[16r48 16r13 16r04 16r25 16rFF 16rFF 16rFF 16r7F]
]

{ #category : #'adc - rr' }
InstructionEncoderTest >> test_ADC_rax_r8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: r8).
	self encodingOf: instruction equals: #[16r4C 16r11 16rC0]
]

{ #category : #'adc - rr' }
InstructionEncoderTest >> test_ADC_rax_rbx [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: rbx).
	self encodingOf: instruction equals: #[16r48 16r11 16rd8]
]

{ #category : #'adc - rr' }
InstructionEncoderTest >> test_ADC_rax_rsi [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rax with: rsi).
	self encodingOf: instruction equals: #[16r48 16r11 16rf0]
]

{ #category : #'adc - rr' }
InstructionEncoderTest >> test_ADC_rbx_rax [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rbx with: rax).
	self encodingOf: instruction equals: #[16r48 16r11 16rc3]
]

{ #category : #'adc - rr' }
InstructionEncoderTest >> test_ADC_rsi_rax [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ADC';
		operands: (Array with: rsi with: rax).
	self encodingOf: instruction equals: #[16r48 16r11 16rc6]
]

{ #category : #float }
InstructionEncoderTest >> test_ADDSS_xmm [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'addss';
		operands: (Array with: xmm1 with: 'dword ptr [rcx]').
	self encodingOf: instruction equals: #[16rf3 16r0f 16r58 16r09]
]

{ #category : #vex }
InstructionEncoderTest >> test_BEXTR_rsi_rcx_r8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'bextr';
		operands: (Array with: rsi with: rcx with: r8).
	self encodingOf: instruction equals: #[16rc4 16re2 16rb8 16rf7 16rf1]
]

{ #category : #vex }
InstructionEncoderTest >> test_BEXTR_rsi_rcx_rbx [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'bextr';
		operands: (Array with: rsi with: rcx with: rbx).
	self encodingOf: instruction equals: #[16rc4 16re2 16re0 16rf7 16rf1]
]

{ #category : #shifts }
InstructionEncoderTest >> test_BSWAP [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'BSWAP';
		operands: (Array with: rcx).
	self encodingOf: instruction equals: #[16r48 16r0f 16rc9]
]

{ #category : #calls }
InstructionEncoderTest >> test_CALL_016 [
	self encodingOf: 'call qword [r8]' equals: #[16r41 16rFF 16r10]
]

{ #category : #calls }
InstructionEncoderTest >> test_CALL_017 [
	self encodingOf: 'call qword [rax]' equals: #[16rFF 16r10]
]

{ #category : #calls }
InstructionEncoderTest >> test_CALL_r64 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'CALL';
		operands: (Array with: rbx).
	self encodingOf: instruction equals: #[16rFF 16rD3]
]

{ #category : #calls }
InstructionEncoderTest >> test_CALL_rel32 [
	| instruction |
	instruction := ISAInstruction new mnemonic: 'CALL'; operands: #(-9).
	self encodingOf: instruction equals: #[16re8 16rf7 16rff 16rff 16rff]
]

{ #category : #arithmetic }
InstructionEncoderTest >> test_CMP_m32_imm [
	| instruction parser |
	parser := AssemblerParser new.
	instruction := parser parseInstruction: 'cmp dword ptr[rax-4], 0x12345678'.
	self
		encodingOf: instruction
		equals: #[16r81 16r78 16rfc 16r78 16r56 16r34 16r12]
]

{ #category : #arithmetic }
InstructionEncoderTest >> test_CMP_m32_imm8 [
	| instruction parser |
	parser := AssemblerParser new.
	instruction := parser parseInstruction: 'cmp dword ptr[rax-4], 0x12'.
	self encodingOf: instruction equals: #[16r83 16r78 16rfc 16r12]
]

{ #category : #float }
InstructionEncoderTest >> test_CVTSS2SI [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'cvtss2si';
		operands: (Array with: eax with: xmm1).
	self encodingOf: instruction equals: #[16rf3 16r0f 16r2d 16rc1]
]

{ #category : #SSE2 }
InstructionEncoderTest >> test_CVTTSD2SI_145 [
	self
		encodingOf: 'cvttsd2si rax, [eax]'
		equals: #[16r67 16rF2 16r48 16rF 16r2C 16r0]
]

{ #category : #dec }
InstructionEncoderTest >> test_DEC_038 [
	self encodingOf: 'dec r11w' equals: #[16r66 16r41 16rFF 16rCB]
]

{ #category : #stack }
InstructionEncoderTest >> test_ENTER_imm16_0 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ENTER';
		operands: (Array with: 8 with: 0).
	self encodingOf: instruction equals: #[16rC8 16r08 16r00 16r00]
]

{ #category : #stack }
InstructionEncoderTest >> test_ENTER_imm16_1 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ENTER';
		operands: (Array with: 8 with: 1).
	self encodingOf: instruction equals: #[16rC8 16r08 16r00 16r01]
]

{ #category : #stack }
InstructionEncoderTest >> test_ENTER_imm16_imm8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ENTER';
		operands: (Array with: 8 with: 32).
	self encodingOf: instruction equals: #[16rC8 16r08 16r00 16r20]
]

{ #category : #float }
InstructionEncoderTest >> test_FSCALE [
	| instruction |
	instruction := ISAInstruction new mnemonic: 'fscale'.
	self encodingOf: instruction equals: #[16rD9 16rFD]
]

{ #category : #float }
InstructionEncoderTest >> test_FSTSW [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'fstsw';
		operands: (Array with: 'word ptr [rdx]').
	self encodingOf: instruction equals: #[16r9b 16rdd 16r3a]
]

{ #category : #generated }
InstructionEncoderTest >> test_IMUL_000F7C0F5C [
	self
		encodingOf: 'imul rax, rdx, 0x7543'
		equals: #[16r48 16r69 16rC2 16r43 16r75 16r0 16r0]
]

{ #category : #arithmetic }
InstructionEncoderTest >> test_IMUL_r64_r64_imm8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'IMUL';
		operands: (Array with: r9 with: r10 with: -1).
	self encodingOf: instruction equals: #[16r4D 16r6B 16rCA 16rFF]
]

{ #category : #jumps }
InstructionEncoderTest >> test_JA_rel32 [
	| instruction |
	instruction := ISAInstruction new mnemonic: 'JA'; operands: #(16r100).
	self encodingOf: instruction equals: #[16r0F 16r87 16r00 16r01 16r00 16r00].
	instruction := ISAInstruction new mnemonic: 'JA'; operands: #(-16r100).
	self encodingOf: instruction equals: #[16r0F 16r87 16r00 16rFF 16rFF 16rFF]
]

{ #category : #jumps }
InstructionEncoderTest >> test_JA_rel8 [
	| instruction |
	instruction := ISAInstruction new mnemonic: 'JA'; operands: #(3).
	self encodingOf: instruction equals: #[16r77 16r03].
	instruction := ISAInstruction new mnemonic: 'JA'; operands: #(-3).
	self encodingOf: instruction equals: #[16r77 16rFD]
]

{ #category : #jumps }
InstructionEncoderTest >> test_JBE_rel8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'JBE';
		operands: (Array with: 16rD).
	self encodingOf: instruction equals: #[16r76 16r0D]
]

{ #category : #float }
InstructionEncoderTest >> test_LDMXCSR [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'ldmxcsr';
		operands: (Array with: 'dword ptr [rdx]').
	self encodingOf: instruction equals: #[16r0f 16rae 16r12]
]

{ #category : #generated }
InstructionEncoderTest >> test_LEA_000A56EEEC [
	self
		encodingOf: 'lea rax, qword [rax + rdx * 4]'
		equals: #[16r48 16r8D 16r4 16r90]
]

{ #category : #generated }
InstructionEncoderTest >> test_LEA_000ABC86B8 [
	self
		encodingOf: 'lea rax, qword [rax + rdx * 8]'
		equals: #[16r48 16r8D 16r4 16rD0]
]

{ #category : #generated }
InstructionEncoderTest >> test_LEA_000B62FF0C [
	self
		encodingOf: 'lea rsp, qword [rsp + rdx * 4]'
		equals: #[16r48 16r8D 16r24 16r94]
]

{ #category : #generated }
InstructionEncoderTest >> test_LEA_000BC897D8 [
	self
		encodingOf: 'lea rsp, qword [rsp + rdx * 8]'
		equals: #[16r48 16r8D 16r24 16rD4]
]

{ #category : #generated }
InstructionEncoderTest >> test_LEA_000D6FDCF7 [
	self
		encodingOf: 'lea rsp, qword [rsp + rcx * 8]'
		equals: #[16r48 16r8D 16r24 16rCC]
]

{ #category : #generated }
InstructionEncoderTest >> test_LEA_000EA0A51B [
	self
		encodingOf: 'lea rsp, qword [rsp + rcx * 4]'
		equals: #[16r48 16r8D 16r24 16r8C]
]

{ #category : #generated }
InstructionEncoderTest >> test_LOCK_DEC_0000758F4B [
	self encodingOf: 'lock dec qword [rax]' equals: #[16rF0 16r48 16rFF 16r8]
]

{ #category : #generated }
InstructionEncoderTest >> test_LOCK_INC_00042D40A1 [
	self encodingOf: 'lock inc qword [rax]' equals: #[16rF0 16r48 16rFF 16r0]
]

{ #category : #float }
InstructionEncoderTest >> test_MOVAPD_xmm [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'movapd';
		operands: (Array with: xmm1 with: 'xmmword ptr [rbx]').
	self encodingOf: instruction equals: #[16r66 16r0f 16r28 16r0b]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOVSS_090 [
	self
		encodingOf: 'movss dword ptr [eax], xmm0'
		equals: #[16r67 16rF3 16rF 16r11 16r0]
]

{ #category : #float }
InstructionEncoderTest >> test_MOVSS_rip [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'movss';
		operands: (Array with: xmm1 with: 'dword ptr [rip + 0x4]').
	self
		encodingOf: instruction
		equals: #[16rf3 16r0f 16r10 16r0d 16r04 16r00 16r00 16r00]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_001 [
	self
		encodingOf: 'mov rax, 0x102030405060708'
		equals: #[16r48 16rB8 16r8 16r7 16r6 16r5 16r4 16r3 16r2 16r1]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_002 [
	self
		encodingOf: 'mov [eax+0x10], ax'
		equals: #[16r67 16r66 16r89 16r40 16r10]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_003 [
	self
		encodingOf: 'mov [eax+0x1000], ebx'
		equals: #[16r67 16r89 16r98 16r0 16r10 16r0 16r0]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_004 [
	self
		encodingOf: 'mov [ebp+eax+0x40], esi'
		equals: #[16r67 16r89 16r74 16r5 16r40]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_005 [
	self
		encodingOf: 'mov qword [ebp+edi+0x1000], 0x10'
		equals: #[16r67 16r48 16rC7 16r84 16r3D 16r0 16r10 16r0 16r0 16r10 16r0 16r0 16r0]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_006 [
	self
		encodingOf: 'mov byte [esp], 0x10'
		equals: #[16r67 16rC6 16r4 16r24 16r10]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_007 [
	self encodingOf: 'mov [eax], rax' equals: #[16r67 16r48 16r89 16r0]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_008 [
	self encodingOf: 'mov [r12], eax' equals: #[16r41 16r89 16r4 16r24]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_009 [
	self
		encodingOf: 'mov [r13+r12+0x200], eax'
		equals: #[16r43 16r89 16r84 16r25 16r0 16r2 16r0 16r0]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_010 [
	self
		encodingOf: 'mov [r8*4+0x670], sil'
		equals: #[16r42 16r88 16r34 16r85 16r70 16r6 16r0 16r0]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_013 [
	self
		encodingOf: 'mov rax, 0x10000'
		equals: #[16r48 16rC7 16rC0 16r0 16r0 16r1 16r0]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_065 [
	self encodingOf: 'mov al, r11b' equals: #[16r44 16r88 16rD8]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_066 [
	self encodingOf: 'mov sil, al' equals: #[16r40 16r88 16rC6]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_067 [
	self encodingOf: 'mov r11b, dil' equals: #[16r41 16r88 16rFB]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_124 [
	self encodingOf: 'mov [rax-0x1], eax' equals: #[16r89 16r40 16rFF]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_128 [
	self
		encodingOf: 'mov [0x10], rax'
		equals: #[16r48 16r89 16r4 16r25 16r10 16r0 16r0 16r0]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_129 [
	self
		encodingOf: 'mov rax, [0x10]'
		equals: #[16r48 16r8B 16r4 16r25 16r10 16r0 16r0 16r0]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_130 [
	self
		encodingOf: 'mov rax, 0x102030405060708'
		equals: #[16r48 16rB8 16r8 16r7 16r6 16r5 16r4 16r3 16r2 16r1]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_135 [
	self
		encodingOf: 'mov rax, [0x100]'
		equals: #[16r48 16r8B 16r4 16r25 16r0 16r1 16r0 16r0]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_eax_ax_mBD [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'word [ eax+0x10 ]' with: ax).
	self encodingOf: instruction equals: #[16r67 16r66 16r89 16r40 16r10]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_fs [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'qword ptr [fs:0x18]' with: r9).
	self
		encodingOf: instruction
		equals: #[16r64 16r4c 16r89 16r0c 16r25 16r18 16r00 16r00 16r00]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_fs_r9 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: fs with: r9).
	self encodingOf: instruction equals: #[16r49 16r8e 16re1]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_mRD_reg [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'qword ptr[rax+0x10]' with: rdx).
	self encodingOf: instruction equals: #[16r48 16r89 16r50 16r10]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_m_r9 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'qword ptr [0x8]' with: r9).
	self
		encodingOf: instruction
		equals: #[16r4c 16r89 16r0c 16r25 16r08 16r00 16r00 16r00]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_na_r9_mD_0 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'qword ptr [0x0]' with: r9).
	self
		encodingOf: instruction
		equals: #[16r4C 16r89 16r0C 16r25 16r00 16r00 16r00 16r00]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_r13 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'byte ptr [r13]' with: 17).
	self encodingOf: instruction equals: #[16r41 16rc6 16r45 16r00 16r11]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_r13_rax_mB [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'qword ptr [r13]' with: rax).
	self encodingOf: instruction equals: #[16r49 16r89 16r45 16r00]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_r13_rax_mBIS [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'qword ptr [r13 + rbx * 2]' with: rax).
	self encodingOf: instruction equals: #[16r49 16r89 16r44 16r5D 16r00]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_r8_imm8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: cl with: -1).
	self encodingOf: instruction equals: #[16rB1 16rFF]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_rax_eax_mBD [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'dword [ rax+0x10 ]' with: eax).
	self encodingOf: instruction equals: #[16r89 16r40 16r10]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_rax_moffset [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: rax with: 16r1122334455667788).
	self
		encodingOf: instruction
		equals: #[16r48 16rb8 16r88 16r77 16r66 16r55 16r44 16r33 16r22 16r11]
]

{ #category : #mov }
InstructionEncoderTest >> test_MOV_rip_rax_mBD [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'MOV';
		operands: (Array with: 'qword ptr [rip + 0x200]' with: rax).
	self
		encodingOf: instruction
		equals: #[16r48 16r89 16r05 16r00 16r02 16r00 16r00]
]

{ #category : #SSE2 }
InstructionEncoderTest >> test_PMOVMKSB_136 [
	self
		encodingOf: 'pmovmskb r12d, xmm14'
		equals: #[16r66 16r45 16rF 16rD7 16rE6]
]

{ #category : #SSE2 }
InstructionEncoderTest >> test_PSLLW_139 [
	self
		encodingOf: 'psllw xmm12, 0x23'
		equals: #[16r66 16r41 16rF 16r71 16rF4 16r23]
]

{ #category : #SSE2 }
InstructionEncoderTest >> test_PSRLW_137 [
	self
		encodingOf: 'psrlw xmm10, 0x10'
		equals: #[16r66 16r41 16rF 16r71 16rD2 16r10]
]

{ #category : #stack }
InstructionEncoderTest >> test_PUSH_r64 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'PUSH';
		operands: (Array with: r8).
	self encodingOf: instruction equals: #[16r41 16r50]
]

{ #category : #calls }
InstructionEncoderTest >> test_RET [
	| instruction |
	instruction := ISAInstruction new mnemonic: 'RET'.
	self encodingOf: instruction equals: #[16rC3]
]

{ #category : #calls }
InstructionEncoderTest >> test_RET_068 [
	self encodingOf: 'ret 0x10' equals: #[16rC2 16r10 16r0]
]

{ #category : #calls }
InstructionEncoderTest >> test_RET_imm [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'RET';
		operands: (Array with: 256).
	self encodingOf: instruction equals: #[16rC2 16r00 16r01]
]

{ #category : #float }
InstructionEncoderTest >> test_ROUNDPD_xmm [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'roundpd';
		operands: (Array with: xmm1 with: xmm2 with: 3).
	self encodingOf: instruction equals: #[16r66 16r0f 16r3a 16r09 16rca 16r03]
]

{ #category : #shifts }
InstructionEncoderTest >> test_SAL_m64_1 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'SAL';
		operands: (Array with: 'qword ptr [rbx]' with: 1).
	self encodingOf: instruction equals: #[16r48 16rd1 16r23]
]

{ #category : #shifts }
InstructionEncoderTest >> test_SAL_r64_1 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'SAL';
		operands: (Array with: rbx with: 1).
	self encodingOf: instruction equals: #[16r48 16rd1 16re3]
]

{ #category : #shifts }
InstructionEncoderTest >> test_SAL_r64_cl [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'SAL';
		operands: (Array with: rbx with: cl).
	self encodingOf: instruction equals: #[16r48 16rd3 16re3]
]

{ #category : #shifts }
InstructionEncoderTest >> test_SHRD_r64_r64_cl [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'SHRD';
		operands: (Array with: rbx with: rsi with: cl).
	self encodingOf: instruction equals: #[16r48 16r0f 16rad 16rf3]
]

{ #category : #shifts }
InstructionEncoderTest >> test_SHRD_r64_r64_imm8 [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'SHRD';
		operands: (Array with: rbx with: rsi with: -1).
	self encodingOf: instruction equals: #[16r48 16r0f 16rac 16rf3 16rff]
]

{ #category : #float }
InstructionEncoderTest >> test_STMXCSR [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'stmxcsr';
		operands: (Array with: 'dword ptr [rdx]').
	self encodingOf: instruction equals: #[16r0f 16rae 16r1a]
]

{ #category : #vex }
InstructionEncoderTest >> test_VBLENDPD_xmm [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'vblendpd';
		operands: (Array with: xmm1 with: xmm2 with: xmm3 with: -1).
	self encodingOf: instruction equals: #[16rc4 16re3 16r69 16r0d 16rcb 16rff]
]

{ #category : #vex }
InstructionEncoderTest >> test_VBLENDVPD_xmm [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'vblendvpd';
		operands: (Array with: xmm1 with: xmm2 with: xmm3 with: xmm4).
	self encodingOf: instruction equals: #[16rc4 16re3 16r69 16r4b 16rcb 16r40]
]

{ #category : #vex }
InstructionEncoderTest >> test_VPSLLD_xmm [
	| instruction |
	instruction := ISAInstruction new
		mnemonic: 'vpslld';
		operands: (Array with: xmm1 with: xmm2 with: -1).
	self encodingOf: instruction equals: #[16rc5 16rf1 16r72 16rf2 16rff]
]

{ #category : #smoke }
InstructionEncoderTest >> test_XCHG_057 [
	self encodingOf: 'xchg [eax], sil' equals: #[16r67 16r40 16r86 16r30]
]
