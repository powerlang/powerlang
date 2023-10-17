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
PowertalkModuleTest >> test010LoadClassAndMethod [
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
		sendLocal: #load:
		to: runtime kernel
		with: {(runtime addSymbol: #A)}.
	classes := runtime sendLocal: #classes to: module.
	class := runtime sendLocal: #first to: classes.
	a := runtime sendLocal: #new to: class.
	str := runtime sendLocal: #a to: a.
	self assert: str asLocalString equals: 'a'
]

{ #category : #running }
PowertalkModuleTest >> test020LoadClassMethodAndRequire [
	| st p module classes class b str |
	(bootstrapper rootDirectory / 'B') ensureCreateDirectory.
	st := bootstrapper rootDirectory / 'B/B.st'.
	st
		createFile;
		writeStreamDo: [ :s | 
			s truncate;
				nextPutAll:
					'Class {
	#name : #B,
	#superclass : #A,
	#instVars : [],
	#category : #''B''
}
{ #category : #accessing }
B >> a [
	^super a, ''b''
] ' ].
	st := bootstrapper rootDirectory / 'B/ModuleB.st'.
	st
		createFile;
		writeStreamDo: [ :s | 
			s truncate;
				nextPutAll:
					'Class {
	#name : #ModuleB,
	#superclass : #Module,
	#instVars : [],
	#category : #''B''
}
{ #category : #initializing }
ModuleB >> initialize [
	super initialize.
	requires := #(''A'')
]
{ #category : #spec }
ModuleB >> imports [
	^{#A -> #A}
] ' ].
	p := bootstrapper rootDirectory / 'B/package.st'.
	p
		createFile;
		writeStreamDo: [ :s | 
			s truncate;
				nextPutAll:
					'Package {
	#name : #B,
	#classes : [
		''B''
	]
}' ].
	module := runtime
		sendLocal: #load:
		to: runtime kernel
		with: {(runtime addSymbol: #B)}.
	classes := runtime sendLocal: #classes to: module.
	class := runtime sendLocal: #first to: classes.
	b := runtime sendLocal: #new to: class.
	str := runtime sendLocal: #a to: b.
	self assert: str asLocalString equals: 'ab'
]

{ #category : #running }
PowertalkModuleTest >> test100LoadCompiler [
	
	| symbol module namespace name compiler object code method foo |
	symbol := (runtime addSymbol: #Compiler).
	module := runtime
		sendLocal: #load:
		to: runtime kernel
		with: {symbol}.
	namespace := runtime sendLocal: #namespace to: module.
	name := runtime addSymbol: #SCompiler. 
	compiler := runtime sendLocal: #at: to: namespace with: { name }.
	object := bootstrapper => #Object.
	code := runtime newString: 'foo ^''foo'''.
	method := runtime sendLocal: #compile:in: to: compiler with: {code. object}.
	runtime sendLocal: #install to: method.
	foo := runtime sendLocal: #foo to: object.
	self assert: foo asLocalString equals: 'foo'
]
