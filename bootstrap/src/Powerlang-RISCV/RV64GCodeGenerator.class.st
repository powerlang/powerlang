Class {
	#name : #RV64GCodeGenerator,
	#superclass : #BaseCodeGenerator,
	#instVars : [
		'generate',
		'zeroReg',
		'flagsReg',
		'tmp1Reg',
		'linkReg'
	],
	#category : #'Powerlang-RISCV-Code Generator'
}

{ #category : #'instance creation' }
RV64GCodeGenerator class >> new [
	"return an initialized instance"

	^ self basicNew initialize.
]

{ #category : #basic }
RV64GCodeGenerator >> add: src1Reg to: src2andDstReg [
	"Here we have to emulate X86 behavior and in addition to addition
	 we have to set artificial flags register to indicate overflow
	"

	generate
		slti: tmp1Reg,       src2andDstReg, 0;             "set tmp1Reg to 1 if src2andDstReg (operand 2) is negative"
		add:  src2andDstReg, src1Reg,       src2andDstReg; "perform the addition that may overflow"
		slt:  flagsReg,      src2andDstReg, src1Reg;       "set flagsReg to 1 if result is smaller than src1Ref (operand 1)"
		sub:  flagsReg,      tmp1Reg,       flagsReg.      "set flagsReg to 0 if both operand 2 is negative and result is
															smaller than operand 2."
]

{ #category : #'operations - arithmetic' }
RV64GCodeGenerator >> addDouble: source1 to: source2andDest [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> addImm: imm to: dest [
	generate
		addi: dest, dest, imm
]

{ #category : #basic }
RV64GCodeGenerator >> and: source1andDest with: source2 [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> and: source1andDest withImm: imm [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> breakpoint [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ generate ebreak
]

{ #category : #basic }
RV64GCodeGenerator >> call: srcReg [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #accessing }
RV64GCodeGenerator >> callIndirect: memRef [
	self load: tmp1Reg fromMem: memRef.

	generate
		jalr: linkReg, tmp1Reg, 0
]

{ #category : #basic }
RV64GCodeGenerator >> compare: reg1 with: reg2 [
	generate
		sub: flagsReg, reg1, reg2
]

{ #category : #basic }
RV64GCodeGenerator >> compare: reg1 withImm: imm [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> compare: reg1 withMem: aMemRef [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> convert: src toDouble: dst [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> divDouble: src1andDstReg by: src2reg [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> divide: srcAndDstReg extendingTo: extReg by: divisorReg [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> exchange: srcAndDstReg withMem: aMemRef [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #initialization }
RV64GCodeGenerator >> initialize [
	super initialize.
	generate := AcDSLRV64GAssembler new.
	memory := generate memory
]

{ #category : #private }
RV64GCodeGenerator >> isValidITypeImm: anInteger [
	"Return true, if given integer value fits into I-type instruction immediate"

	^ (-2048 <= anInteger  "((2 raisedTo:12) // 2) * -1")
		& (anInteger <= 2047"((2 raisedTo:12) // 2) - 1")
]

{ #category : #jumps }
RV64GCodeGenerator >> jumpIfEqualTo: label [
	generate
		beq: flagsReg, zeroReg, label
]

{ #category : #jumps }
RV64GCodeGenerator >> jumpIfNotEqualTo: label [
	generate
		bne: flagsReg, zeroReg, label
]

{ #category : #jumps }
RV64GCodeGenerator >> jumpIfOverflowTo: label [
	generate
		bne: flagsReg, zeroReg, label
]

{ #category : #basic }
RV64GCodeGenerator >> jumpTo: label [
	generate
		jal: zeroReg, label.
]

{ #category : #basic }
RV64GCodeGenerator >> jumpToMem: aMemRef [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #memory }
RV64GCodeGenerator >> lea: dstReg withMem: srcMemRef [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> load: dstReg convertingDoubleToIntegerFromMem: srcMemRef [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #memory }
RV64GCodeGenerator >> load: dstReg fromMem: srcMemRef [
	"Load `dstReg` from memory location `srcMemRef`.
	 The size of data loaded is specified in `srcMemRef`.
	 
	 When loading 32bits into 64bit register, high 32bits must be
	 cleared (in other words, 32bit value is *zero* extended to
	 64bits and stored in `dstReg`.
	 
	 However, when loading 16bits or 8bits, high 48 or 56 bits
	 are *left intact*.
	 
	 This somewhat weird behavior is heritage of x86."

	srcMemRef length == 64 ifTrue: [ 
		generate 
			ld: dstReg, srcMemRef base, srcMemRef displacement.
		^ self.
	].

	self error: 'Not yet implemented'  

]

{ #category : #basic }
RV64GCodeGenerator >> load: dstReg withTIBat: indexReg [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> load: dstReg withThreadVariableAt: indexReg [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #memory }
RV64GCodeGenerator >> loadDouble: dstReg fromMem: srcMemRef [
	"Load 64-bit floating point `dstReg` from memory location `srcMemRef`"

	^ self shouldImplement
]

{ #category : #memory }
RV64GCodeGenerator >> memRef [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ RVMemoryReference new
		length: self wordSize * 8
]

{ #category : #services }
RV64GCodeGenerator >> move: srcReg to: dstReg [

	generate
		addi: dstReg , srcReg, 0
]

{ #category : #basic }
RV64GCodeGenerator >> moveDouble: srcReg into: dstReg [
	"move from X-type register srcReg into general purpose dstReg"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> moveImm: imm to: dstReg [
	"Load constant to register `dstImm`"

	(self isValidITypeImm: imm) ifTrue: [
		generate
			addi: dstReg, zeroReg, imm
	] ifFalse: [ 
		self shouldImplement
	].
]

{ #category : #basic }
RV64GCodeGenerator >> or: src1andDest withImm: imm [
	(self isValidITypeImm: imm) ifTrue: [ 
		generate
			ori: src1andDest, src1andDest, imm
	] ifFalse: [ 
		self moveImm: imm to: tmp1Reg.
		generate
			or: src1andDest, src1andDest, tmp1Reg.
	].
]

{ #category : #'push/pop' }
RV64GCodeGenerator >> popIntoMem: dstMemRef [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #'push/pop' }
RV64GCodeGenerator >> pushMem: aMemRef [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #'push/pop' }
RV64GCodeGenerator >> pushROnFPUStack [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #'registers - internal use only' }
RV64GCodeGenerator >> regFlags [
	^ flagsReg
]

{ #category : #basic }
RV64GCodeGenerator >> return [
	"Return from subroutine"

	generate
		jalr: zeroReg, linkReg, 0
]

{ #category : #memory }
RV64GCodeGenerator >> roundDouble: srcReg into: dstReg [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> shiftLeft: srcAndDst byImm: count [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> shiftRight: srcAndDst byImm: count [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> shiftRightArithmetic: srcAndDst by: countReg [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> shiftRightArithmetic: srcAndDst byImm: count [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #memory }
RV64GCodeGenerator >> store: srcReg intoMem: dstMemRef [
	dstMemRef length == 64 ifTrue: [ 
		generate 
			sd: dstMemRef base, srcReg, dstMemRef displacement.
		^ self.
	].

	self error: 'Not yet implemented'

]

{ #category : #memory }
RV64GCodeGenerator >> storeDouble: srcReg intoMem: dstMemRef [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> sub: src1 from: src2AndDst [
   generate
		sub: src2AndDst, src1, src2AndDst
]

{ #category : #basic }
RV64GCodeGenerator >> subDouble: src1 from: src2AndDst [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #initialization }
RV64GCodeGenerator >> target: aNativizationTarget [
	super target: aNativizationTarget.
	zeroReg := abi regZero.
	flagsReg := abi regFlags.
	tmp1Reg := abi regTmp1.
	linkReg := abi regLink.
]

{ #category : #basic }
RV64GCodeGenerator >> test: src1Reg with: src2Reg [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> test: srcReg withImm: imm [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]
