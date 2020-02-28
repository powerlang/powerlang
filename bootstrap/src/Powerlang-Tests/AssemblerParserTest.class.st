"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #AssemblerParserTest,
	#superclass : #PPAbstractParserTest,
	#pools : [
		'Registers'
	],
	#category : #'Powerlang-Tests-Assembler-Intel'
}

{ #category : #tests }
AssemblerParserTest >> test_TP49427 [
	| parser instruction |
	parser := AssemblerParser new instruction.
	instruction := parser parse: 'mov bword ptr [r8*4+0x670], sil'.
	self assert: instruction operands first length = 8
]

{ #category : #tests }
AssemblerParserTest >> test_constant [
	| parser |
	parser := AssemblerParser new constant.
	self
		assert: parser parse: '12' to: 12;
		assert: parser parse: '0xFEED' to: 16rFEED
]

{ #category : #tests }
AssemblerParserTest >> test_displacement [
	| parser |
	parser := AssemblerParser new displacement.
	self
		assert: parser parse: ' + 12' to: 12;
		assert: parser parse: ' - 12' to: -12;
		assert: parser parse: ' + 0xFEED' to: 16rFEED;
		assert: parser parse: ' - 0xCAFE' to: -16rCAFE;
		assert: parser parse: '+0xfeed' to: 16rFEED
]

{ #category : #tests }
AssemblerParserTest >> test_imm_decimal [
	| parser |
	parser := AssemblerParser new imm.
	self
		"--8bit--"
		assert: parser parse: '10' to: (ISAImmediate new value: 10; length: 8);
		assert: parser parse: '-10' to: (ISAImmediate new value: -10; length: 8);
		assert: parser parse: '-128' to: (ISAImmediate new value: -128; length: 8);
		assert: parser parse: '127' to: (ISAImmediate new value: 127; length: 8);
		"--16bit--"
		assert: parser parse: '128' to: (ISAImmediate new value: 128; length: 16);
		assert: parser parse: '-129' to: (ISAImmediate new
			value: -129;
			length: 16);
		assert: parser
		parse: '-32768'
		to: (ISAImmediate new value: -32768; length: 16);
		assert: parser
		parse: '32767'
		to: (ISAImmediate new value: 32767; length: 16);
		"--32bit--"
		assert: parser
		parse: '-32769'
		to: (ISAImmediate new value: -32769; length: 32);
		assert: parser
		parse: '32768'
		to: (ISAImmediate new value: 32768; length: 32);
		assert: parser
		parse: '-2147483648'
		to: (ISAImmediate new value: -2147483648; length: 32);
		assert: parser
		parse: '2147483647'
		to: (ISAImmediate new value: 2147483647; length: 32);
		"--64bit--"
		assert: parser
		parse: '-2147483649'
		to: (ISAImmediate new value: -2147483649; length: 64);
		assert: parser
		parse: '2147483648'
		to: (ISAImmediate new value: 2147483648; length: 64)
]

{ #category : #tests }
AssemblerParserTest >> test_imm_hex [
	| parser |
	parser := AssemblerParser new imm.
	self
		"--8bit--"
		assert: parser parse: '0x10' to: (ISAImmediate new
			value: 16r10;
			length: 8);
		assert: parser parse: '0xFF' to: (ISAImmediate new value: -1; length: 8);
		"--16bit--"
		assert: parser
		parse: '0x100'
		to: (ISAImmediate new value: 16r100; length: 16);
		assert: parser parse: '0xFFFF' to: (ISAImmediate new
			value: -1;
			length: 16);
		"--32bit--"
		assert: parser
		parse: '0x10000'
		to: (ISAImmediate new value: 16r10000; length: 32);
		assert: parser
		parse: '0xFFFFFFFF'
		to: (ISAImmediate new value: -1; length: 32);
		"--64bit--"
		assert: parser
		parse: '0x100000000'
		to: (ISAImmediate new value: 16r100000000; length: 64);
		assert: parser
		parse: '0xFFFFFFFFFFFFFFFF'
		to: (ISAImmediate new value: -1; length: 64)
]

{ #category : #tests }
AssemblerParserTest >> test_instruction [
	| parser |
	parser := AssemblerParser new instruction.
	self
		assert: parser parse: 'nop';
		assert: parser parse: 'inc al';
		assert: parser parse: 'mov rax, 0x10';
		assert: parser parse: 'imul rax, [eax+ebx*8+0x100000], 0x10';
		assert: parser parse: 'mov al, r11d'
]

{ #category : #tests }
AssemblerParserTest >> test_memory [
	| parser |
	parser := AssemblerParser new memory.
	self
		assert: parser parse: '[ eax ]' to: (MemoryOperand new base: eax);
		assert: parser
		parse: '[ 0x10 ]'
		to: (MemoryOperand new displacement: 16r10);
		assert: parser
		parse: 'qword [ eax ]'
		to: (MemoryOperand new base: eax; length: 64);
		assert: parser
		parse: 'byte ptr [ eax ]'
		to: (MemoryOperand new base: eax; length: 8);
		assert: parser parse: 'bword ptr [r8*4+0x670]' to: (MemoryOperand new
			index: r8;
			scale: 4;
			displacement: 1648;
			length: 8)
]

{ #category : #tests }
AssemblerParserTest >> test_memory_2 [
	| parser |
	parser := AssemblerParser new memory.
	self
		assert: parser
		parse: '[ fs:0x18 ]'
		to: (MemoryOperand new displacement: 16r18; segment: fs)
]

{ #category : #tests }
AssemblerParserTest >> test_operand [
	| parser |
	parser := AssemblerParser new operand.
	self
		assert: parser parse: '[ eax ]' to: (MemoryOperand new base: eax);
		assert: parser parse: '[0x10]' to: (MemoryOperand new displacement: 16r10);
		assert: parser parse: 'eax' to: eax;
		assert: parser parse: 'r11d' to: r11d;
		assert: parser
		parse: 'byte ptr [ eax ]'
		to: (MemoryOperand new base: eax; length: 8);
		assert: parser parse: 'bword ptr [r8*4+0x670]' to: (MemoryOperand new
			index: r8;
			scale: 4;
			displacement: 1648;
			length: 8)
]

{ #category : #tests }
AssemblerParserTest >> test_operands [
	| parser |
	parser := AssemblerParser new operands.
	self
		assert: parser
		parse: '[ eax ], edx'
		to: (Array with: (MemoryOperand new base: eax; length: 32) with: edx);
		assert: parser
		parse: '[ eax ], dx'
		to: (Array with: (MemoryOperand new base: eax; length: 16) with: dx);
		assert: parser
		parse: 'qword [ eax ], dx'
		to: (Array with: (MemoryOperand new base: eax; length: 64) with: dx);
		assert: parser
		parse: '[ eax ], 0x1'
		to: (Array
			with: (MemoryOperand new base: eax)
			with: (ISAImmediate new value: 1))
]

{ #category : #tests }
AssemblerParserTest >> test_prefix_LOCK [
	| parser |
	parser := AssemblerParser new instruction.
	self assert: parser parse: 'lock inc rax' to: (ISAInstruction new
		prefix: (LegacyPrefix prefixes at: 'LOCK');
		mnemonic: 'inc';
		operands: (Array with: rax))
]

{ #category : #tests }
AssemblerParserTest >> test_reg [
	| parser |
	parser := AssemblerParser new reg.
	self
		assert: parser parse: 'eax' to: eax;
		assert: parser parse: 'r11' to: r11;
		assert: parser parse: 'sil' to: sil;
		assert: parser parse: 'r11b' to: r11b.
	Registers asArray do: [:reg | self assert: parser parse: reg name to: reg]
]

{ #category : #tests }
AssemblerParserTest >> test_scale [
	| parser |
	parser := AssemblerParser new scale.
	self
		assert: parser parse: '*1' to: 1;
		assert: parser parse: '* 2' to: 2;
		assert: parser parse: ' *4' to: 4;
		assert: parser parse: '*8' to: 8;
		assert: parser fail: '*5'
]

{ #category : #tests }
AssemblerParserTest >> test_sib [
	| parser |
	parser := AssemblerParser new sib.
	self
		assert: parser parse: 'eax' to: (MemoryOperand new base: eax);
		assert: parser parse: '+ 10' to: (MemoryOperand new displacement: 10);
		assert: parser parse: '0x10' to: (MemoryOperand new displacement: 16r10).
	self
		assert: parser
		parse: 'eax + r9'
		to: (MemoryOperand new base: eax; index: r9).
	self assert: parser parse: 'eax + r9*8' to: (MemoryOperand new
		base: eax;
		index: r9;
		scale: 8).
	self assert: parser parse: 'eax + r9 - 0x12' to: (MemoryOperand new
		base: eax;
		index: r9;
		displacement: -16r12).
	self
		assert: parser
		parse: 'eax - 0x12'
		to: (MemoryOperand new base: eax; displacement: -16r12)
]

{ #category : #tests }
AssemblerParserTest >> test_smoke_01 [
	| parser |
	parser := AssemblerParser new instruction.
	#(
    'mov rax, 0x102030405060708'
    'mov [eax+0x10], ax'
    'mov [eax+0x1000], ebx'
    'mov [ebp+eax+0x40], esi'
    'mov qword [ebp+edi+0x1000], 0x10'
    'mov byte [esp], 0x10'
    'mov [eax], rax'
    'mov [r12], eax'
    'mov [r13+r12+0x200], eax'
    'mov [r8*4+0x670], sil'
    'inc rax'
    'dec rax'
    "'mov [rip+0x200], rax'"
    'mov rax, 0x10000'
    'push rax'
    'push r12'
    'call qword [r8]'
    'call qword [rax]'
    'cbw '
    'cwde '
    'cdqe '
    'cwd '
    'cdq '
    'cqo '
    'cmovl rax, [rax]'
    'cmovge eax, [rax]'
    'clflush [r14]'
    'cmp [rax], rax'
    'cmp rbx, r12'
    'cmp r12d, r8d'
    'cmpsb '
    'cmpsw '
    'cmpsd '
    'cmpsq '
    'cmpxchg [eax], r14'
    'cmpxchg8b [ebx]'
    'inc r12d'
    'inc dword [rax]'
    'dec r11w'
    'hlt '
    'imul rax, [eax+ebx*8+0x100000], 0x10'
    'idiv dword [r12]'
    'enter 0x100, 0x0'
    'enter 0x100, 0x1'
    'enter 0x100, 0x10'
    'in al, 0x10'
    'in ax, 0x10'
    'in eax, 0x10'
    'lfs eax, [eax]'
    'lgs eax, [ebx]'
    'lea eax, [rbx]'
    'lea r11, [eax]'
    'lodsb '
    'lodsq '
    'lodsd '
    'push rax'
    'push r11'
    'xchg [eax], sil'
    'xchg [eax], ebx'
    'xchg [eax], bx'
    'xchg r8, rax'
    'xchg r9, rax'
    'xchg cx, ax'
    'movsd '
    'movsq '
    'mov al, r11b'
    'mov sil, al'
    'mov r11b, dil'
    'ret 0x10'
    'pop rax'
    'pop r11'
    'pop qword [eax]'
    'insd '
    'outsd '
    "'mov [r14d], cs'"
    "'mov cs, [ebx+ecx]'"
    'pushfq '
    'scasq '
    'lsl ax, [rbx]'
    'movups xmm0, [r12d]'
    'movupd xmm0, [r12d]'
    'movsldup xmm0, [r12d]'
    'movups xmm0, xmm1'
    'movups xmm10, xmm12'
    'movups xmm0, xmm12'
    'movlps xmm0, [rax]'
    'movlps [rax], xmm0'
    'unpcklps xmm4, xmm5'
    'unpckhps xmm4, xmm5'
    'movhps xmm3, [eax]'
    'movhps [rax], xmm3'
    'movss xmm0, [eax]'
    'movss [eax], xmm0'
    'movlpd [eax], xmm0'
    'movlpd xmm0, [eax]'
    'unpcklpd xmm2, xmm4'
    'unpckhpd xmm3, [eax+ebx*8-0x1243]'
    'movhpd xmm3, [rax]'
    'movhpd [rax], xmm2'
    'movsd xmm3, xmm4'
    'movddup xmm3, [rax]'
    "'mov dr0, rax'"
    "'mov rax, dr1'"
    'movnti [eax], eax'
    'movnti [rax], rax'
    'movd [eax], xmm0'
    'movd [eax], xmm0'
    'movd xmm11, qword [eax]'
    'vmmcall '
    'vmrun '
    'clgi '
    'stgi '
    'mfence '
    'lfence '
    'sfence '
    'clflush [rax]'
    "'mov cr8, rax'"
    'push qword [eax]'
    'push word [eax]'
    'add bh, bh'
    'add dil, dil'
    'add sil, bpl'
    'add al, sil'
    'add rax, r12'
    'add eax, r12d'
    'prefetcht0 [eax]'
    'prefetchnta [eax]'
    'prefetch [eax]'
    'add [r8], r9b'
    'mov [rax-0x1], eax'
    'inc rax'
    'jmp qword [eax]'
    'jmp rax'
    'mov [0x10], rax'
    'mov rax, [0x10]'
    'mov rax, 0x102030405060708'
    'xchg r8, rax'
    'push ax'
    'push rax'
    'push r11'
    'mov rax, [0x100]'
    'pmovmskb r12d, xmm14'
    "'movdq2q mm0, xmm13'"
    'psrlw xmm10, 0x10'
    'psraw xmm7, 0x1'
    'psllw xmm12, 0x23'
    'swapgs '
    'fadd dword [rax+rbx]'
    'shl rsi, 1'
    'cvtsi2ss xmm1, qword [eax]'
    'cvtss2si rax, [eax]'
    'cvttsd2si rax, [eax]'
    'call 0x64'
    'mpsadbw xmm7, xmm6, 0x7'
    'popfq'
) do: [:e | self assert: parser parse: e]
]
