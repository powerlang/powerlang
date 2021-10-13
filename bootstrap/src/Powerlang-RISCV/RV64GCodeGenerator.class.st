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
RV64GCodeGenerator >> add: source1 to: source2andDest [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #'operations - arithmetic' }
RV64GCodeGenerator >> addDouble: source1 to: source2andDest [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> addImm: imm to: dest [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
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

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> call: srcReg [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #accessing }
RV64GCodeGenerator >> callIndirect: aMemRef [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> compare: reg1 with: reg2 [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
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
	cpu := AcProcessorDescriptions riscv.
]

{ #category : #basic }
RV64GCodeGenerator >> jumpTo: label [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
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

	^ self shouldImplement
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
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> moveDouble: srcReg into: dstReg [
	"move from X-type register srcReg into general purpose dstReg"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> moveImm: imm to: dstReg [
	"Load constant to register `dstImm`"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> mulDouble: src1andDstReg by: src2reg [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> multiply: src1AndDstLoReg by: src2reg wideningTo: dstHiReg [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> or: src1andDest withImm: imm [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #'push/pop' }
RV64GCodeGenerator >> popIntoMem: dstMemRef [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #'push/pop' }
RV64GCodeGenerator >> pushAOnFPUStack [
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

{ #category : #basic }
RV64GCodeGenerator >> sqrtDouble: srcReg into: dstReg [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #memory }
RV64GCodeGenerator >> store: srcReg intoMem: dstMemRef [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #memory }
RV64GCodeGenerator >> storeDouble: srcReg intoMem: dstMemRef [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
]

{ #category : #basic }
RV64GCodeGenerator >> sub: src1 from: src2AndDst [
	"superclass CodeGenerator says that I am responsible to implement this method"

	^ self shouldImplement
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
