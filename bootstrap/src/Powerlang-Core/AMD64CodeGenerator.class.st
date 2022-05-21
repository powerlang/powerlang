"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #AMD64CodeGenerator,
	#superclass : #CodeGenerator,
	#instVars : [
		'instruction',
		'operands1',
		'operands2',
		'operands3',
		'pointer',
		'immediate',
		'encoder'
	],
	#pools : [
		'Registers'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #'instance creation' }
AMD64CodeGenerator class >> new [
	^ self basicNew initialize.

]

{ #category : #'operations - arithmetic' }
AMD64CodeGenerator >> add: src2 to: src1AndDst [
	self assemble: 'add' with: src1AndDst with: src2

]

{ #category : #'operations - arithmetic' }
AMD64CodeGenerator >> addDouble: source1 to: source2andDest [
	self 
		assemble: 'addsd'
		with: source2andDest
		with: source1

]

{ #category : #'operations - arithmetic' }
AMD64CodeGenerator >> addImm: imm to: src2AndDst [
	self assemble: 'add' with: src2AndDst withImm: imm
]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> and: src1AndDst with: source2 [
	self assemble: 'and' with: src1AndDst with: source2

]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> and: src1AndDst withImm: imm [

	(imm between: -128 and: -1) ifTrue: [ 
		"When `imm` is a small negative, we can safely
		 and bits only in lower part of the 64 bit register
		 since higher bits of immediate are all ones anyway.
		 This helps to generate shorter code on x86."
		self assemble: 'and' with: src1AndDst byte withImm: imm
	] ifFalse: [
		self assemble: 'and' with: src1AndDst withImm: imm
	].

]

{ #category : #basic }
AMD64CodeGenerator >> assemble [
	encoder reset; writeEncodingOn: memory
]

{ #category : #basic }
AMD64CodeGenerator >> assemble: mnemonic [
	instruction mnemonic: mnemonic; operands: #().
	self assemble
]

{ #category : #basic }
AMD64CodeGenerator >> assemble: mnemonic with: op [
	| op1 |
	op1 := op isInteger ifTrue: [immediate value: op] ifFalse: [op].
	operands1 at: 1 put: op1.
	instruction mnemonic: mnemonic; operands: operands1.
	self assemble
]

{ #category : #basic }
AMD64CodeGenerator >> assemble: mnemonic with: op1 with: op2 [
	| op |
	op := op2 isInteger ifTrue: [immediate value: op2] ifFalse: [op2].
	operands2
		at: 1 put: op1;
		at: 2 put: op.
	instruction mnemonic: mnemonic; operands: operands2.
	self assemble
]

{ #category : #basic }
AMD64CodeGenerator >> assemble: mnemonic
with: op1
with: op2
with: op3 [
	| op |
	op := op3 isInteger ifTrue: [immediate value: op3] ifFalse: [op3].
	operands3
		at: 1 put: op1;
		at: 2 put: op2;
		at: 3 put: op.
	instruction mnemonic: mnemonic; operands: operands3.
	self assemble
]

{ #category : #basic }
AMD64CodeGenerator >> assemble: mnemonic with: op1 withImm64: op2 [
	| v |
	v := self regV.
	self
		assemble: 'mov' with: v with: op2;
		assemble: mnemonic with: op1 with: v
]

{ #category : #basic }
AMD64CodeGenerator >> assemble: mnemonic with: op1 withImm: imm [
	immediate value: imm.
	(immediate length <= 32 or: [mnemonic = 'mov' and: [op1 class == Register]])
		ifTrue: [self assemble: mnemonic with: op1 with: immediate]
		ifFalse: [self assemble: mnemonic with: op1 withImm64: immediate]
]

{ #category : #basic }
AMD64CodeGenerator >> assemble: mnemonic withImm64: op1 [
	| v |
	v := self regV.
	self
		assemble: 'mov' with: v with: op1;
		assemble: mnemonic with: v
]

{ #category : #basic }
AMD64CodeGenerator >> assemble: mnemonic withImm: imm [
	immediate value: imm.
	immediate length <= 32
		ifTrue: [self assemble: mnemonic with: immediate]
		ifFalse: [self assemble: mnemonic withImm64: immediate]
]

{ #category : #basic }
AMD64CodeGenerator >> assemble: mnemonic withReg: reg index: index [
	pointer
		reset;
		length: self addressLength;
		base: reg;
		displacement: index - 1 * wordSize.
	self assemble: mnemonic with: pointer
]

{ #category : #basic }
AMD64CodeGenerator >> assemble: mnemonic
withReg: dst
withReg: src
index: index [
	pointer
		reset;
		length: self addressLength;
		base: src;
		displacement: index - 1 * wordSize.
	self assemble: mnemonic with: dst with: pointer
]

{ #category : #basic }
AMD64CodeGenerator >> assembleByte: byte [
	memory nextBytePut: byte
]

{ #category : #basic }
AMD64CodeGenerator >> assembleBytes: aByteArray [
	memory nextBytesPut: aByteArray
]

{ #category : #basic }
AMD64CodeGenerator >> assembleBytes: value count: count [
	self ASSERT: value isInteger.
	self ASSERT:(count == 4 or:[ count == 8 ]).

	count == 4 ifTrue: [
		memory nextLongPut: value
	] ifFalse: [ 
		memory nextLargePut: value
	].

]

{ #category : #debugging }
AMD64CodeGenerator >> breakpoint [
	self assemble: 'int' with: 3
]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> call: srcReg [ 
	self assemble: 'call' with: srcReg
]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> callIndirect: aMemRef [
	self assemble: 'call' with: aMemRef 
]

{ #category : #accessing }
AMD64CodeGenerator >> clearFPUFlags [
	self assemble: 'fnclex'
]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> clearHigh32: srcAndDstReg [
	self assemble: 'mov' with: srcAndDstReg e with: srcAndDstReg e
]

{ #category : #services }
AMD64CodeGenerator >> compare: reg1 with: reg2 [
	self assemble: 'cmp' with: reg1 with: reg2
]

{ #category : #services }
AMD64CodeGenerator >> compare: reg1 withImm: imm [
	#imm8.
	#imm32.
	self assemble: 'cmp' with: reg1 withImm: imm
]

{ #category : #services }
AMD64CodeGenerator >> compare: reg1 withMem: aMemRef [
	self assemble: 'cmp' with: reg1 with: aMemRef
]

{ #category : #accessing }
AMD64CodeGenerator >> compareEqualDoubleX0withAindirect [
	pointer
		reset;
		length: 64;
		base: self regA.
	self 
		assemble: 'cmpsd'
		with: self regX0
		with: pointer
		with: 0
]

{ #category : #accessing }
AMD64CodeGenerator >> compareLessThanDoubleX0withAindirect [
	pointer
		reset;
		length: 64;
		base: self regA.
	self
		assemble: 'cmpsd'
		with: self regX0
		with: pointer
		with: 1
]

{ #category : #basic }
AMD64CodeGenerator >> convert: src toDouble: dst [
	self assemble: 'cvtsi2sd' with: dst with: src
]

{ #category : #basic }
AMD64CodeGenerator >> dec: srcAndDstReg [
	self assemble: 'dec' with: srcAndDstReg
]

{ #category : #basic }
AMD64CodeGenerator >> decMem: aMemRef [
	self assemble: 'dec' with: aMemRef

]

{ #category : #services }
AMD64CodeGenerator >> disassembledText32 [
	^self nativeCode disassembledText32
]

{ #category : #services }
AMD64CodeGenerator >> disassembledText64 [
	^self nativeCode disassembledText64
]

{ #category : #basic }
AMD64CodeGenerator >> divDouble: src1andDstReg by: src2reg [ 
	self 
		assemble: 'divsd'
		with: src1andDstReg
		with: src2reg
]

{ #category : #basic }
AMD64CodeGenerator >> divide: srcAndDstReg extendingTo: extReg by: divisorReg [
	| conversion |
	self
		ASSERT: srcAndDstReg r == rax;
		ASSERT: extReg r == rdx.
	conversion := wordSize = 8
		ifTrue: [ 'cqo' ]
		ifFalse: [ 'cdq' ].
	self
		assemble: conversion;
		assemble: 'idiv' with: divisorReg
]

{ #category : #basic }
AMD64CodeGenerator >> dropTopOfFPU [
	"
	fstp st(0)
	"
	self assembleBytes: #[16rDD 16rD8]
]

{ #category : #services }
AMD64CodeGenerator >> exchange: op1 with: op2 [
	self assemble: 'xchg' with: op1 with: op2
]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> exchange: srcAndDstReg withMem: aMemRef [
	self assemble: 'xchg' with: aMemRef with: srcAndDstReg
]

{ #category : #basic }
AMD64CodeGenerator >> inc: srcAndDstReg [
	self assemble: 'inc' with: srcAndDstReg
]

{ #category : #initialization }
AMD64CodeGenerator >> initialize [
	super initialize.
	instruction := ISAInstruction new.
	operands1 := Array new: 1.
	operands2 := Array new: 2.
	operands3 := Array new: 3.
	immediate := ISAImmediate new.
	pointer := MemoryOperand new.
	encoder := instruction encoder.

]

{ #category : #'private - jumps' }
AMD64CodeGenerator >> jump: mnemonic to: label size: n [
	| placeholder end |
	placeholder := 1 bitShift: n - 1 * 8.
	self assemble: mnemonic with: placeholder.
	end := memory position.
	memory
		skip: -1;
		nextPut: 0;
		skip: n negated;
		addRelativeFixup: label size: n;
		position: end
]

{ #category : #jumps }
AMD64CodeGenerator >> jumpIfEqualTo: label [
	self nearJump: 'jz' to: label
]

{ #category : #jumps }
AMD64CodeGenerator >> jumpIfGreaterOrEqualSignedTo: label [
	self nearJump: 'jge' to: label
]

{ #category : #jumps }
AMD64CodeGenerator >> jumpIfGreaterSignedTo: label [
	self nearJump: 'jg' to: label
]

{ #category : #jumps }
AMD64CodeGenerator >> jumpIfLessOrEqualSignedTo: label [
	self nearJump: 'jle' to: label
]

{ #category : #jumps }
AMD64CodeGenerator >> jumpIfLessSignedTo: label [
	self nearJump: 'jl' to: label
]

{ #category : #jumps }
AMD64CodeGenerator >> jumpIfNotEqualTo: label [
	self nearJump: 'jnz' to: label
]

{ #category : #jumps }
AMD64CodeGenerator >> jumpIfNotZeroTo: label [
	self jumpIfNotEqualTo: label
]

{ #category : #jumps }
AMD64CodeGenerator >> jumpIfOverflowTo: label [
	self nearJump: 'jo' to: label
]

{ #category : #jumps }
AMD64CodeGenerator >> jumpIfSignTo: label [
	self nearJump: 'js' to: label
]

{ #category : #jumps }
AMD64CodeGenerator >> jumpIfZeroTo: label [
	self jumpIfEqualTo: label
]

{ #category : #jumps }
AMD64CodeGenerator >> jumpTo: label [
	self nearJump: 'jmp' to: label
]

{ #category : #loading }
AMD64CodeGenerator >> jumpToMem: aMemRef [ 
	self assemble: 'jmp' with: aMemRef
]

{ #category : #basic }
AMD64CodeGenerator >> lea: dstReg withMem: srcMemRef [
	self assemble: 'lea' with: dstReg with: srcMemRef
]

{ #category : #integers }
AMD64CodeGenerator >> leadingRzeroCount [
	"
	lzcnt is a special x64 extension: it puts the REX
	prefix after the first opcode byte. Our x64 
	encoder doesn't support that, so we fix the
	bytes by hand
	"
	| pos |
	pos := self currentAddress.
	self assemble: 'lzcnt' with: self regR with: self regR.
	memory
		writeByte: 16rF3 at: pos;
		writeByte: 16r48 at: pos + 1
]

{ #category : #basic }
AMD64CodeGenerator >> load: dstReg convertingDoubleToIntegerFromMem: srcMemRef [
	self assemble: 'cvttsd2si' with: dstReg with: srcMemRef
]

{ #category : #'memory - load / store' }
AMD64CodeGenerator >> load: dstReg fromMem: srcMemRef [
	| adjusted |
	adjusted := dstReg forLength: srcMemRef length.
	self
		assemble: 'mov'
		with: adjusted
		with: srcMemRef
]

{ #category : #'operations - arithmetic' }
AMD64CodeGenerator >> load: dstReg withTIBat: indexReg [
	| seg |
	seg := wordSize = 8
		ifTrue: [ gs ]
		ifFalse: [ fs ].
	pointer
		reset;
		length: self addressLength;
		index: indexReg; 
		scale: wordSize;
		segment: seg.
	self assemble: 'mov' with: dstReg with: pointer
]

{ #category : #'operations - arithmetic' }
AMD64CodeGenerator >> load: dstReg withThreadVariableAt: indexReg [
	pointer
		reset;
		length: self addressLength;
		index: indexReg;
		scale: wordSize.
	wordSize = 8
		ifTrue: [ pointer
				segment: gs;
				displacement: 16r1480 ]
		ifFalse: [ pointer
				segment: fs;
				displacement: 16rE10 ].
	self assemble: 'mov' with: dstReg with: pointer
]

{ #category : #'memory - load / store' }
AMD64CodeGenerator >> loadDouble: dstReg fromMem: srcMemRef [
	self ASSERT: srcMemRef sizeInBits == 64.
	self 
		assemble: 'movq'
		with: dstReg
		with: srcMemRef

]

{ #category : #accessing }
AMD64CodeGenerator >> loadLongMwithIPoffset: anInteger [
	| instsize |
	#dontOptimize.
	instsize := 6.
	pointer
		reset;
		length: 32;
		base: self regIP;
		displacement: anInteger - instsize.
	self assemble: 'mov' with: self regM e with: pointer
]

{ #category : #accessing }
AMD64CodeGenerator >> loadMXCSRfromA [
	pointer
		reset;
		length: 32;
		base: self regA.
	self assemble: 'ldmxcsr' with: pointer
]

{ #category : #storing }
AMD64CodeGenerator >> loadZeroExtendByte: reg1 from: reg2 atIndexAt: reg3 [
	pointer
		reset;
		length: 8;
		base: reg2;
		index: reg3;
		displacement: -1.
	self assemble: 'movzx' with: reg1 with: pointer
]

{ #category : #storing }
AMD64CodeGenerator >> loadZeroExtendByte: reg1 from: reg2 atIndexImm: index [
	self loadZeroExtendByte: reg1 from: reg2 atOffset: index - 1
]

{ #category : #storing }
AMD64CodeGenerator >> loadZeroExtendByte: reg1 from: reg2 atOffset: offset [
	pointer
		reset;
		length: 8;
		base: reg2;
		displacement: offset.
	self assemble: 'movzx' with: reg1 with: pointer
]

{ #category : #basic }
AMD64CodeGenerator >> loadZeroExtendShortRwithRoffset: offset [
	pointer
		reset;
		length: 16;
		base: self regR;
		displacement: offset.
	self assemble: 'movzx' with: self regR with: pointer
]

{ #category : #basic }
AMD64CodeGenerator >> lock [
	self assembleByte: 16rF0
]

{ #category : #memory }
AMD64CodeGenerator >> memRef [
	^ MemoryOperand new
		length: self addressBitSize
]

{ #category : #basic }
AMD64CodeGenerator >> move: srcReg to: dstReg [
	self ASSERT: (srcReg class = Register and: [dstReg class = Register]).
	self assemble: 'mov' with: dstReg with: srcReg

]

{ #category : #basic }
AMD64CodeGenerator >> moveDouble: srcReg into: dstReg [ 
	| mov |

	mov := wordSize = 8 ifTrue: [
			'movq'
		] ifFalse: [ 'movd' ].
	self 
		assemble: mov
		with: dstReg
		with: srcReg
]

{ #category : #basic }
AMD64CodeGenerator >> moveImm: imm to: dstReg [
	self ASSERT: (imm isInteger and: [dstReg class = Register]).
	self assemble: 'mov' with: dstReg with: imm

]

{ #category : #accessing }
AMD64CodeGenerator >> moveTslots [
	| rep mnemonic |
	rep := 16rF3.
	mnemonic := wordSize = 8
		ifTrue: [ 'movsq' ]
		ifFalse: [ 'movsd' ].
	self
		assembleByte: rep;
		assemble: mnemonic
]

{ #category : #basic }
AMD64CodeGenerator >> mulDouble: src1andDstReg by: src2reg [ 
	self 
		assemble: 'mulsd'
		with: src1andDstReg
		with: src2reg
]

{ #category : #basic }
AMD64CodeGenerator >> multiply: src1AndDstLoReg by: src2reg wideningTo: dstHiReg [
	self
		ASSERT: src1AndDstLoReg r == rax;
		ASSERT: dstHiReg r == rdx.
	self assemble: 'imul' with: src2reg
]

{ #category : #'private - jumps' }
AMD64CodeGenerator >> nearJump: mnemonic to: label [
	self jump: mnemonic to: label size: 4
]

{ #category : #alignment }
AMD64CodeGenerator >> nop [
	self assemble: 'nop'
]

{ #category : #alignment }
AMD64CodeGenerator >> nop2 [
	memory nextPutAll: #[16r66 16r90]
]

{ #category : #alignment }
AMD64CodeGenerator >> nop3 [
	memory nextPutAll: #[16r0F 16r1F 16r00]
]

{ #category : #alignment }
AMD64CodeGenerator >> nop4 [
	memory nextPutAll: #[16r0F 16r1F 16r40 16r00]
]

{ #category : #alignment }
AMD64CodeGenerator >> nop5 [
	memory nextPutAll: #[16r0F 16r1F 16r44 16r00 16r00]
]

{ #category : #alignment }
AMD64CodeGenerator >> nop6 [
	memory nextPutAll: #[16r66 16r0F 16r1F 16r44 16r00 16r00]
]

{ #category : #alignment }
AMD64CodeGenerator >> nop7 [
	memory nextPutAll: #[16r0F 16r1F 16r80 16r00 16r00 16r00 16r00]
]

{ #category : #alignment }
AMD64CodeGenerator >> nop8 [
	memory nextPutAll: #[16r0F 16r1F 16r84 16r00 16r00 16r00 16r00 16r00]
]

{ #category : #alignment }
AMD64CodeGenerator >> nop9 [
	memory nextPutAll: #[16r66 16r0F 16r1F 16r84 16r00 16r00 16r00 16r00 16r00]
]

{ #category : #alignment }
AMD64CodeGenerator >> nop: count [
	"
	ShellDLL current openWebPage: 'http://www.felixcloutier.com/x86/NOP.html'
	"
	| r |
	r := count.
	r >= 9 ifTrue: [
		r // 9 timesRepeat: [self nop9].
		r := r \\ 9].
	r = 8 ifTrue: [^self nop8].
	r = 7 ifTrue: [^self nop7].
	r = 6 ifTrue: [^self nop6].
	r = 5 ifTrue: [^self nop5].
	r = 4 ifTrue: [^self nop4].
	r = 3 ifTrue: [^self nop3].
	r = 2 ifTrue: [^self nop2].
	r = 1 ifTrue: [^self nop].

]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> or: src1AndDst with: src2 [
	self assemble: 'or' with: src1AndDst with: src2

]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> or: src1AndDst withImm: imm [

	(imm between: 0 and: 127) ifTrue: [ 
		"When `imm` is a small POSITIVE, we can safely
		 or bits only in lower part of the 64 bit register
		 since higher bits of immediate are all zeros anyway.
		 This helps to generate shorter code on x86."
		self assemble: 'or' with: src1AndDst byte withImm: imm
	] ifFalse: [
		self assemble: 'or' with: src1AndDst withImm: imm
	].

]

{ #category : #'push/pop' }
AMD64CodeGenerator >> pop: dstReg [
	self assemble: 'pop' with: dstReg

]

{ #category : #'push/pop' }
AMD64CodeGenerator >> popIntoMem: dstMemRef [
	self assemble: 'pop' with: dstMemRef
]

{ #category : #'printing & storing' }
AMD64CodeGenerator >> printOn: aStream [
	aStream print: self class; cr; cr;
		nextPutAll: memory bytes disassembledAmd64
]

{ #category : #'push/pop' }
AMD64CodeGenerator >> push: srcReg [
	self assemble: 'push' with: srcReg

]

{ #category : #'push/pop' }
AMD64CodeGenerator >> pushAOnFPUStack [
	pointer reset; length: 64; base: self regA.
	self assemble: 'fld' with: pointer
]

{ #category : #'push/pop' }
AMD64CodeGenerator >> pushImm: imm [
	#imm8.
	#imm32.
	self assemble: 'push' withImm: imm
]

{ #category : #'push/pop' }
AMD64CodeGenerator >> pushMem: aMemRef [
	self push: aMemRef
]

{ #category : #'push/pop' }
AMD64CodeGenerator >> pushROnFPUStack [
	pointer reset; length: 64; base: self regR.
	self assemble: 'fld' with: pointer
]

{ #category : #accessing }
AMD64CodeGenerator >> readFPUStatusOnA [
	pointer
		reset;
		length: 16;
		base: self regA.
	self assemble: 'fstsw' with: pointer
]

{ #category : #accessing }
AMD64CodeGenerator >> renameByteRegisterIfNeeded: register preserving: preserved during: aBlock [
	self
		renameByteRegisterIfNeeded: register
		preserving: preserved
		preserving: nil
		during: aBlock
]

{ #category : #accessing }
AMD64CodeGenerator >> renameByteRegisterIfNeeded: register
preserving: preserved1
preserving: preserved2
during: aBlock [
	| final |
	(self addressSize != 4 or: [register byte isLongModeOld8BitRegister not])
		ifTrue: [aBlock value: register]
		ifFalse: [
			final := self renameRegisterPreserving: preserved1 preserving: preserved2.
			self exchange: register e with: final.
			aBlock value: final.
			self exchange: final with: register e]
]

{ #category : #accessing }
AMD64CodeGenerator >> renameRegisterPreserving: preserved1 preserving: preserved2 [
	preserved1 == self regR
		ifTrue: [preserved2 == self regA
			ifTrue: [^self regT]
			ifFalse: [^self regA]].
	preserved2 == self regR
		ifTrue: [preserved1 == self regA
			ifTrue: [^self regT]
			ifFalse: [^self regA]].
	^self regR
]

{ #category : #calls }
AMD64CodeGenerator >> return [
	self assemble: 'ret'
]

{ #category : #calls }
AMD64CodeGenerator >> return: anInteger [
	anInteger = 0
		ifTrue: [self assemble: 'ret']
		ifFalse: [self assemble: 'ret' with: anInteger * self addressSize]
]

{ #category : #basic }
AMD64CodeGenerator >> roundDouble: srcReg into: dstReg [ 
	self 
		assemble: 'roundsd'
		with: dstReg
		with: srcReg
		with: 3
]

{ #category : #accessing }
AMD64CodeGenerator >> scaleFloatOnRWithA [
	self
		pushAOnFPUStack;
		pushROnFPUStack;
		assemble: 'fscale'.
	pointer
		reset;
		length: 64;
		base: self regR.
	self
		assemble: 'fstp' with: pointer;
		dropTopOfFPU
]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> shiftLeft: srcAndDst by: countReg [
	self ASSERT: countReg r = rcx.
	self assemble: 'sal' with: srcAndDst with: countReg b
]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> shiftLeft: srcAndDst byImm: count [
	self ASSERT: (count between: 0 and: srcAndDst length - 1).
	self assemble: 'sal' with: srcAndDst withImm: count
]

{ #category : #accessing }
AMD64CodeGenerator >> shiftRight: srcAndDst by: countReg [
	self ASSERT: countReg r = rcx.
	self assemble: 'sar' with: srcAndDst with: countReg b
]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> shiftRight: srcAndDst byImm: count [
	self ASSERT: (count between: 0 and: srcAndDst length - 1).
	self assemble: 'shr' with: srcAndDst withImm: count
]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> shiftRightArithmetic: srcAndDst by: countReg [
	self ASSERT: countReg r = rcx.
	self assemble: 'sar' with: srcAndDst with: countReg b
]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> shiftRightArithmetic: srcAndDst byImm: count [
	self ASSERT: (count between: 0 and: srcAndDst length - 1).
	self assemble: 'sar' with: srcAndDst withImm: count
]

{ #category : #'private - jumps' }
AMD64CodeGenerator >> shortJump: mnemonic to: label [
	self jump: mnemonic to: label size: 1
]

{ #category : #jumps }
AMD64CodeGenerator >> shortJumpIfCarryTo: label [
	self shortJump: 'jc' to: label
]

{ #category : #jumps }
AMD64CodeGenerator >> shortJumpIfEqualTo: label [
	self shortJump: 'jz' to: label
]

{ #category : #jumps }
AMD64CodeGenerator >> shortJumpIfNotCarryTo: label [
	self shortJump: 'jnc' to: label
]

{ #category : #jumps }
AMD64CodeGenerator >> shortJumpIfNotEqualTo: label [
	self shortJump: 'jnz' to: label
]

{ #category : #jumps }
AMD64CodeGenerator >> shortJumpIfSignTo: label [
	self shortJump: 'js' to: label
]

{ #category : #jumps }
AMD64CodeGenerator >> shortJumpTo: label [
	self shortJump: 'jmp' to: label
]

{ #category : #'operations - arithmetic' }
AMD64CodeGenerator >> sqrtDouble: srcReg into: dstReg [
	self 
		assemble: 'sqrtsd'
		with: srcReg
		with: dstReg
]

{ #category : #'memory - load / store' }
AMD64CodeGenerator >> store: srcReg intoMem: dstMemRef [
	| adjusted |
	adjusted := srcReg forLength: dstMemRef length.
	self
		assemble: 'mov'
		with: dstMemRef
		with: adjusted
]

{ #category : #'operations - arithmetic' }
AMD64CodeGenerator >> store: srcReg intoTIBat: indexReg [
	| seg |
	seg := wordSize = 8
		ifTrue: [ gs ]
		ifFalse: [ fs ].
	pointer
		reset;
		length: self addressLength;
		index: indexReg;
		scale: wordSize;
		segment: seg.
	self assemble: 'mov' with: pointer with: srcReg
]

{ #category : #basic }
AMD64CodeGenerator >> store: srcReg intoThreadVariableAt: indexReg [
	pointer
		reset;
		length: self addressLength;
		index: indexReg;
		scale: wordSize.
	wordSize = 8
		ifTrue: [ pointer
				segment: gs;
				displacement: 16r1480 ]
		ifFalse: [ pointer
				segment: fs;
				displacement: 16rE10 ].
	self assemble: 'mov' with: pointer with: srcReg
]

{ #category : #storing }
AMD64CodeGenerator >> storeByte: byte in: reg2 offset: offset [
	pointer
		reset;
		length: 8;
		base: reg2;
		displacement: offset.
	self assemble: 'mov' with: pointer with: byte
]

{ #category : #'memory - load / store' }
AMD64CodeGenerator >> storeDouble: srcReg intoMem: dstMemRef [
	self ASSERT: dstMemRef sizeInBits == 64.
	self 
		assemble: 'movq'
		with: dstMemRef
		with: srcReg

]

{ #category : #'memory - load / store' }
AMD64CodeGenerator >> storeDoubleResultIntoMem: dstMemRef [
	wordSize = 8
		ifTrue:
			[ self assemble: 'movq' with: dstMemRef  with: self regX0 ]
		ifFalse: [ self assemble: 'fstp' with: dstMemRef ]
]

{ #category : #'memory - load / store' }
AMD64CodeGenerator >> storeImm: imm intoMem: dstMemRef [
	self
		assemble: 'mov'
		with: dstMemRef
		withImm: imm

]

{ #category : #accessing }
AMD64CodeGenerator >> storeMXCSRintoA [
	pointer
		reset;
		length: 32;
		base: self regA.
	self assemble: 'stmxcsr' with: pointer
]

{ #category : #'operations - arithmetic' }
AMD64CodeGenerator >> sub: src1 from: src2AndDst [
	self assemble: 'sub' with: src2AndDst with:  src1

]

{ #category : #'operations - arithmetic' }
AMD64CodeGenerator >> subDouble: src1 from: src2AndDst [ 
	self 
		assemble: 'subsd'
		with: src2AndDst
		with: src1
]

{ #category : #'operations - arithmetic' }
AMD64CodeGenerator >> subImm: imm from: srcAndDst [
	self assemble: 'sub' with: srcAndDst withImm: imm

]

{ #category : #'to-cleanup' }
AMD64CodeGenerator >> subTslotsToSP [
	self assemble: 'neg' with: self regT.
	pointer
		reset;
		length: self addressLength;
		base: self regSP;
		index: self regT;
		scale: self regSP sizeInBytes.
	self
		assemble: 'lea' with: self regSP with: pointer;
		assemble: 'neg' with: self regT
]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> test: src1Reg with: src2Reg [
	self assemble: 'test' with: src1Reg with: src2Reg
]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> test: srcReg withImm: imm [
	self assemble: 'test' with: srcReg with: imm
]

{ #category : #services }
AMD64CodeGenerator >> testIntegerBit: op1 [
	| op |
	op := op1 byte.
	(self addressSize = 4 and: [op isLongModeOld8BitRegister])
		ifTrue: [op := op1].
	self assemble: 'test' with: op with: 1
]

{ #category : #accessing }
AMD64CodeGenerator >> wordSize: anInteger [
	super wordSize: anInteger.
	encoder wordSize: anInteger
]

{ #category : #'to-cleanup' }
AMD64CodeGenerator >> writeTslots [
	| rep mnemonic |
	rep := 16rF3.
	mnemonic := wordSize = 8
		ifTrue: [ 'stosq' ]
		ifFalse: [ 'stosd' ].
	self
		assembleByte: rep;
		assemble: mnemonic
]

{ #category : #'operations - logical' }
AMD64CodeGenerator >> xor: src1AndDst with: src2 [
	self assemble: 'xor' with: src1AndDst with: src2

]
