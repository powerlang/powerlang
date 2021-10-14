Class {
	#name : #RV64GRemoteShellResource,
	#superclass : #RV64GShellResource,
	#classVars : [
		'Host'
	],
	#category : #'Powerlang-RISCV-Tests'
}

{ #category : #accessing }
RV64GRemoteShellResource class >> host [
	^ Host isNil ifTrue: [ 'unleashed' ] ifFalse: [ Host ]
]

{ #category : #accessing }
RV64GRemoteShellResource class >> host: aString [
	Host := aString
]

{ #category : #running }
RV64GRemoteShellResource >> setUp [
	super setUp.

	self assert: (OperatingSystem executeCommand: 'scp ' , shell pathName , ' ' , self class host , ':/tmp')
		 description: 'Cannot upload shell'.

	target := GDBDebugger new.
	target executable: shell.
	target send: 'target extended-remote | ssh -C ', self class host , ' /opt/gdb/bin/gdbserver - /tmp/' , shell baseName.
]
