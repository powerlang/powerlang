Class {
	#name : #PowertalkJSTest,
	#superclass : #TestCase,
	#instVars : [
		'runtime',
		'bootstrapper'
	],
	#category : #'Powerlang-JS'
}

{ #category : #accessing }
PowertalkJSTest class >> defaultTimeLimit [
	^ 1000 seconds
]

{ #category : #tests }
PowertalkJSTest >> setUp [
	bootstrapper := PowertalkLMRTestResource new
		setUp;
		bootstrapper.
	runtime := bootstrapper result.
]

{ #category : #tests }
PowertalkJSTest >> test010WriteKernelAsJSON [
	| output module result |
	output := bootstrapper rootDirectory / 'LMRjs' / 'Kernel.json'.
	output exists
		ifTrue: [ output delete ].
	module := bootstrapper loadBootstrapModule.
	result := runtime sendLocal: #writeJSONKernel to: module.
	self assert: output exists
]
