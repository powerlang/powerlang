Class {
	#name : #RV64GCodeGenerator,
	#superclass : #BaseCodeGenerator,
	#instVars : [
		'cpu'
	],
	#pools : [
		'RVRegisters'
	],
	#category : #'Powerlang-RISCV-Code Generator'
}

{ #category : #'instance creation' }
RV64GCodeGenerator class >> new [
	"return an initialized instance"

	^ self basicNew initialize.
]

{ #category : #initialization }
RV64GCodeGenerator >> initialize [
	super initialize.
	cpu := AcProcessorDescriptions riscv.
]
