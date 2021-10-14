Class {
	#name : #RV64GCodeGeneratorTests,
	#superclass : #TestCase,
	#instVars : [
		'cg',
		'target',
		'nzoneAddress'
	],
	#classVars : [
		'TargetResource'
	],
	#category : #'Powerlang-RISCV-Tests'
}

{ #category : #accessing }
RV64GCodeGeneratorTests class >> resources [
	^ Array with: self target
]

{ #category : #accessing }
RV64GCodeGeneratorTests class >> target [
	^ TargetResource isNil ifTrue:[ #RV64GQEMUShellResource asClass ] ifFalse: [ TargetResource ]

	"
	RV64GCodeGeneratorTests target: RV64GQEMUShellResource.
	RV64GCodeGeneratorTests target: RV64GRemoteShellResource.
	"
]

{ #category : #accessing }
RV64GCodeGeneratorTests class >> target: target [
	TargetResource := target.
]

{ #category : #running }
RV64GCodeGeneratorTests >> setUp [
	super setUp.

	target := self class target current target.
	nzoneAddress := self class target current nzoneAddress.
	cg := RV64GCodeGenerator new target: NativizationTarget riscv64_linux_gnu.
]

{ #category : #tests }
RV64GCodeGeneratorTests >> test_add_to_01 [

	cg add: cg regA to: cg regR.
	cg breakpoint.
	cg memory relocateTo: nzoneAddress with: nil.

	target memoryAt: nzoneAddress put: cg memory bytes. 
	target setRegister: cg regA to: 10.
	target setRegister: cg regR to: 32. 

	target c.
	self assert: (target getRegister: cg regR) = 42.
	self assert: (target getRegister: cg regFlags) = 0.
	"
	VDBDebuggerApplication openFor: target
	"
]

{ #category : #tests }
RV64GCodeGeneratorTests >> test_add_to_02 [

	cg add: cg regA to: cg regR.
	cg breakpoint.
	cg memory relocateTo: nzoneAddress with: nil.

	target memoryAt: nzoneAddress put: cg memory bytes. 
	target setRegister: cg regA to: 16r7FFFFFFFFFFFFFFF.
	target setRegister: cg regR to: 16r7FFFFFFFFFFFFFFF. 

	target c.
	self assert: (target getRegister: cg regFlags) ~~ 0.
	"
	VDBDebuggerApplication openFor: target
	"
]

{ #category : #tests }
RV64GCodeGeneratorTests >> test_add_to_03 [

	cg add: cg regA to: cg regR.
	cg breakpoint.
	cg memory relocateTo: nzoneAddress with: nil.

	target memoryAt: nzoneAddress put: cg memory bytes. 
	target getRegister: cg regA.
	target setRegister: cg regA to: -1.
	target setRegister: cg regR to: 16r8000000000000000. 

	target c.
	self assert: (target getRegister: cg regFlags) ~~ 0.
	"
	VDBDebuggerApplication openFor: target
	"
]
