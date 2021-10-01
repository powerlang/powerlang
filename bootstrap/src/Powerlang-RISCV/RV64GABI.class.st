Class {
	#name : #RV64GABI,
	#superclass : #ABI,
	#classVars : [
		'RegA',
		'RegE',
		'RegFP',
		'RegFalse',
		'RegG',
		'RegM',
		'RegNil',
		'RegR',
		'RegS',
		'RegSP',
		'RegT',
		'RegTrue',
		'RegV',
		'RegX0',
		'RegX1'
	],
	#category : #'Powerlang-RISCV-Code Generator'
}

{ #category : #initialization }
RV64GABI class >> initialize [
	"Invoked at system start or when the class is dynamically loaded."

	| gprs fprs |

	gprs := AcProcessorDescriptions riscv maps at: 'gpr'.
	fprs := AcProcessorDescriptions riscv maps at: 'fpr'.

	"RegIP does not exists in RISC-V"
	RegSP   := gprs lookup: 'sp'.
	RegFP   := gprs lookup: 's0'."The presence of a frame pointer is optional. If a frame pointer exists it must reside in x8 (s0), the register remains callee-saved."

	RegR    := gprs lookup: 't0'.
	RegM    := gprs lookup: 's1'.
	RegS    := gprs lookup: 's2'.
	RegE    := gprs lookup: 's3'.
	RegA    := gprs lookup: 't1'.
	RegT    := gprs lookup: 't2'. 
	RegV    := gprs lookup: 't3'.

	RegNil  := gprs lookup: 's4'.
	RegTrue := gprs lookup: 's5'.
	RegFalse:= gprs lookup: 's6'.
	RegG    := gprs lookup: 's7'.

	RegX0   := fprs lookup: 'ft0'.
	RegX1   := fprs lookup: 'ft1'.
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

{ #category : #'registers - IR' }
RV64GABI >> regG [
	^ RegG
]

{ #category : #'registers - IR' }
RV64GABI >> regIP [
	^ self error: 'Oops, on RISC-V PC is not a visible register. Use auipc instruction!'.
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
