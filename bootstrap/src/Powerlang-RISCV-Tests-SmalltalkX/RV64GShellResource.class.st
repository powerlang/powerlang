Class {
	#name : #RV64GShellResource,
	#superclass : #TestResource,
	#instVars : [
		'target',
		'nzone',
		'shell'
	],
	#category : #'Powerlang-RISCV-Tests'
}

{ #category : #accessing }
RV64GShellResource >> nzoneAddress [
	nzone isNil ifTrue: [ 
		nzone := ((target evaluate: '(void*)&nzone') valueFormatted: GDBOutputFormat signedDecimal) asInteger.
	].
	^ nzone
]

{ #category : #running }
RV64GShellResource >> setUp [
	super setUp.

	shell := (Smalltalk getPackageDirectoryForPackage:'jv:libgdbs/tests') / 'c' / 'riscv64-unknown-linux-gnu' / 'fatshell'.
	" shell := '/home/jv/Projects/Phoenix/thinshell/modtalk/riscv64/modtalk.elf' asFilename."

	self assert: shell exists  description: 'fatshell for RISC-V does not exists'.
]

{ #category : #accessing }
RV64GShellResource >> target [
	target setRegister: 'pc' to: self nzoneAddress.
	^ target
]

{ #category : #running }
RV64GShellResource >> tearDown [
	(target notNil and: [ target isConnected ]) ifTrue: [ 
		target send: 'kill' andWait: false.
		target send: 'quit' andWait: false.
	].
	target := nil.
]
