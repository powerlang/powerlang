Class {
	#name : #InvokeLinker,
	#superclass : #MessageLinker,
	#instVars : [
		'invoker',
		'sends'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #nativizing }
InvokeLinker >> addMethod: aCompiledMethod [
	self addMethod: aCompiledMethod for: aCompiledMethod selector
]

{ #category : #nativizing }
InvokeLinker >> addMethod: aCompiledMethod for: aSymbol [
	| instructions send |
	filter add: aSymbol.
	instructions := invoker ifNil: [ aCompiledMethod nativeCode code ].
	send := SendSite new invoke: aCompiledMethod using: instructions.
	sends at: aSymbol put: send
]

{ #category : #nativizing }
InvokeLinker >> addMethods: aCollection [
	aCollection do: [:m | self addMethod: m]
]

{ #category : #nativizing }
InvokeLinker >> emitSend: aSymbol using: anAssembler [
	| send |
	send := sends at: aSymbol.
	anAssembler
		loadAwithLiteral: send;
		callIndirectA;
		discardArguments: aSymbol arity
]

{ #category : #nativizing }
InvokeLinker >> initialize [
	super initialize.
	sends := Dictionary new.
	self filter: #()
]

{ #category : #nativizing }
InvokeLinker >> invoker: aNativeCode [
	invoker := aNativeCode
]
