Class {
	#name : #RV64GQEMUShellResource,
	#superclass : #RV64GShellResource,
	#instVars : [
		'qemu'
	],
	#category : #'Powerlang-RISCV-Tests'
}

{ #category : #accessing }
RV64GQEMUShellResource >> target [
	self tearDown.

	self assert: (OperatingSystem pathOfCommand: 'qemu-riscv64-static') notNil
		 description: 'QEMU not found'.
	"First, start QEMU: "
	TerminalView 
		openWithAction: [:vt | vt startCommand:'qemu-riscv64-static -g 1234 ', shell pathName ]
		setupTerminalViewWith:[:vt | qemu := vt ]
		onExit:[:vt | vt topView close ]. 

	"...then create a new GDB and connect to QEMU: "
	target := GDBDebugger new.
	target executable: shell.
	target targetConnect: 'remote' parameters: #('localhost:1234').          

	target setRegister: 'pc' to: self nzoneAddress.
	^ target
]

{ #category : #running }
RV64GQEMUShellResource >> tearDown [
	super tearDown.
	qemu notNil ifTrue: [ 
		qemu closeDownShell
	].
]
