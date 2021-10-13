Class {
	#name : #RV64GABI,
	#superclass : #ABI,
	#classVars : [
		'RegA',
		'RegE',
		'RegFP',
		'RegFalse',
		'RegFlags',
		'RegG',
		'RegLink',
		'RegM',
		'RegNil',
		'RegR',
		'RegS',
		'RegSP',
		'RegT',
		'RegTmp1',
		'RegTrue',
		'RegV',
		'RegX0',
		'RegX1',
		'RegZero'
	],
	#category : #'Powerlang-RISCV-Code Generator'
}

{ #category : #initialization }
RV64GABI class >> initialize [
	"Invoked at system start or when the class is dynamically loaded."

	| gprs fprs |

	gprs := AcProcessorDescriptions riscv64 maps at: 'gpr'.
	fprs := AcProcessorDescriptions riscv64 maps at: 'fpr'.

	"RegIP does not exists in RISC-V"
	RegSP   := AcDSLRegister value: (gprs lookup: 'sp').
	RegFP   := AcDSLRegister value: (gprs lookup: 's0')."The presence of a frame pointer is optional. If a frame pointer exists it must reside in x8 (s0), the register remains callee-saved."

	RegR    := AcDSLRegister value: (gprs lookup: 't0').
	RegM    := AcDSLRegister value: (gprs lookup: 's1').
	RegS    := AcDSLRegister value: (gprs lookup: 's2').
	RegE    := AcDSLRegister value: (gprs lookup: 's3').
	RegA    := AcDSLRegister value: (gprs lookup: 't1').
	RegT    := AcDSLRegister value: (gprs lookup: 't2'). 
	RegV    := AcDSLRegister value: (gprs lookup: 't3').

	RegNil  := AcDSLRegister value: (gprs lookup: 's4').
	RegTrue := AcDSLRegister value: (gprs lookup: 's5').
	RegFalse:= AcDSLRegister value: (gprs lookup: 's6').
	RegG    := AcDSLRegister value: (gprs lookup: 's7').

	RegX0   := AcDSLRegister value: (fprs lookup: 'ft0').
	RegX1   := AcDSLRegister value: (fprs lookup: 'ft1').

	RegZero := AcDSLRegister value: (gprs lookup: 'zero').
	RegFlags:= AcDSLRegister value: (gprs lookup: 't5').
	RegTmp1 := AcDSLRegister value: (gprs lookup: 't6').
	RegLink := AcDSLRegister value: (gprs lookup: 'ra').
]

{ #category : #'registers - IR' }
RV64GABI >> regA [
	^ RegA
]

{ #category : #'registers - IR' }
RV64GABI >> regE [
	^ RegE
]

{ #category : #'registers - IR' }
RV64GABI >> regFP [
	^ RegFP
]

{ #category : #'registers - IR' }
RV64GABI >> regFalse [
	^ RegFalse
]

{ #category : #'registers - internal use only' }
RV64GABI >> regFlags [
	^ RegFlags
]

{ #category : #'registers - IR' }
RV64GABI >> regG [
	^ RegG
]

{ #category : #'registers - IR' }
RV64GABI >> regIP [
	^ self error: 'Oops, on RISC-V PC is not a visible register. Use auipc instruction!'.
]

{ #category : #'registers - internal use only' }
RV64GABI >> regLink [
	^ RegLink
]

{ #category : #'registers - IR' }
RV64GABI >> regM [
	^ RegM
]

{ #category : #'registers - IR' }
RV64GABI >> regNil [
	^ RegNil
]

{ #category : #'registers - IR' }
RV64GABI >> regR [
	^ RegR
]

{ #category : #'registers - IR' }
RV64GABI >> regS [
	^ RegS
]

{ #category : #'registers - IR' }
RV64GABI >> regSP [
	^ RegSP
]

{ #category : #'registers - IR' }
RV64GABI >> regT [
	^ RegT
]

{ #category : #'registers - internal use only' }
RV64GABI >> regTmp1 [
	^ RegTmp1
]

{ #category : #'registers - IR' }
RV64GABI >> regTrue [
	^ RegTrue
]

{ #category : #'registers - IR' }
RV64GABI >> regV [
	^ RegV
]

{ #category : #'registers - IR' }
RV64GABI >> regX0 [
	^ RegX0
]

{ #category : #'registers - IR' }
RV64GABI >> regX1 [
	^ RegX1
]

{ #category : #'registers - internal use only' }
RV64GABI >> regZero [
	^ RegZero
]
