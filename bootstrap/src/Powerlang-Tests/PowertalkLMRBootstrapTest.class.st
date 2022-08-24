Class {
	#name : #PowertalkLMRBootstrapTest,
	#superclass : #TestCase,
	#instVars : [
		'runtime',
		'bootstrapper'
	],
	#category : #'Powerlang-Tests-Bootstrap'
}

{ #category : #accessing }
PowertalkLMRBootstrapTest class >> defaultTimeLimit [
	^ 1000 seconds
]

{ #category : #tests }
PowertalkLMRBootstrapTest >> setUp [
	bootstrapper := PowertalkLMRTestResource new
		setUp;
		bootstrapper.
	runtime := bootstrapper result.
]

{ #category : #tests }
PowertalkLMRBootstrapTest >> test010GenenerateKernelSegment [
	| output module |
	output := bootstrapper outputDirectory / 'bootstrap' / 'Kernel.is'.
	output exists
		ifTrue: [ output deleteFile ].
	module := bootstrapper loadBootstrapModule.
	"runtime sendLocal: #writeModules to: module.
	self assert: output exists"
]
