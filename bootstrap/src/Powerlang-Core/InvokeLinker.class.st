Class {
	#name : #InvokeLinker,
	#superclass : #MessageLinker,
	#instVars : [
		'methods',
		'invoker'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #nativizing }
InvokeLinker >> emitSend: aSymbol using: anAssembler [
	| method send |
	method := self methodFor: aSymbol.
	send := SendSite new invoke: method using: invoker.
	anAssembler
		loadAwithLiteral: send;
		callIndirectA;
		discardArguments: aSymbol arity
]

{ #category : #nativizing }
InvokeLinker >> invoker: aNativeCode [
	invoker := aNativeCode
]

{ #category : #nativizing }
InvokeLinker >> methodFor: aSymbol [
			^methods detect: [:method | method selector = aSymbol]
]

{ #category : #nativizing }
InvokeLinker >> methods: aCollection [
	methods := aCollection.
	filter := methods asIdentitySet collect: [ :m | m selector ]
]
