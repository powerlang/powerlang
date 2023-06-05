Class {
	#name : #PowertalkModuleTest,
	#superclass : #TestCase,
	#instVars : [
		'runtime',
		'bootstrapper'
	],
	#category : #'Powerlang-Tests-Bootstrap'
}

{ #category : #accessing }
PowertalkModuleTest class >> defaultTimeLimit [
	^ 1000 seconds
]

{ #category : #running }
PowertalkModuleTest >> setUp [
	| image bootstrapModule |
	super setUp.
	image := PowertalkRingImage fromSpec
		wordSize: 8;
		genesis;
		bootstrap;
		fillClasses;
		fillSymbols.
	bootstrapper := image generateLMR.
	runtime := bootstrapper result.
	bootstrapModule := bootstrapper loadBootstrapModule.
	runtime sendLocal: #start to: bootstrapModule
]

{ #category : #running }
PowertalkModuleTest >> testLoadClassAndMethod [
	| st p module classes class a str |
	(bootstrapper rootDirectory / 'A') ensureCreateDirectory.
	st := bootstrapper rootDirectory / 'A/A.st'.
	st
		createFile;
		writeStreamDo: [ :s | 
			s
				nextPutAll:
					'Class {
	#name : #A,
	#superclass : #Object,
	#instVars : [],
	#category : #''A''
}
{ #category : #accessing }
A >> a [
	^''a''
] ' ].
	p := bootstrapper rootDirectory / 'A/package.st'.
	p
		createFile;
		writeStreamDo: [ :s | 
			s
				nextPutAll:
					'Package {
	#name : #A,
	#classes : [
		''A''
	]
}' ].
	module := runtime
		sendLocal: #loadModule:
		to: runtime kernel
		with: {(runtime addSymbol: #A)}.
	classes := runtime sendLocal: #classes to: module.
	class := runtime sendLocal: #first to: classes.
	a := runtime sendLocal: #new to: class.
	str := runtime sendLocal: #a to: a.
	self assert: str asLocalString equals: 'a'
]
