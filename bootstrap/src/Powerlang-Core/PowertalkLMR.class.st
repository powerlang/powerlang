Class {
	#name : #PowertalkLMR,
	#superclass : #PowertalkRuntime,
	#instVars : [
		'kernel',
		'wordSize',
		'smallInteger',
		'classInstanceBehaviorIndex',
		'behaviorNextIndex',
		'behaviorMethodDictionaryIndex',
		'behaviorClassIndex',
		'classNameIndex',
		'methodFlagsIndex',
		'symbolTable'
	],
	#pools : [
		'SCompiledMethodFlags'
	],
	#category : #'Powerlang-Core-Execution-LMR'
}

{ #category : #initialization }
PowertalkLMR >> behaviorClass: anLMRObject [
	^ anLMRObject slotAt: behaviorClassIndex
]

{ #category : #initialization }
PowertalkLMR >> behaviorClassIndex: anInteger [
	behaviorClassIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> behaviorMethodDictionary: anLMRObject [
	^ anLMRObject slotAt: behaviorMethodDictionaryIndex
]

{ #category : #initialization }
PowertalkLMR >> behaviorMethodDictionaryIndex: anInteger [
	behaviorMethodDictionaryIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> behaviorNext: anLMRObject [
	^ anLMRObject slotAt: behaviorNextIndex
]

{ #category : #initialization }
PowertalkLMR >> behaviorNextIndex: anInteger [
	behaviorNextIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> behaviorOf: anLMRObject [
	^ anLMRObject behavior
]

{ #category : #initialization }
PowertalkLMR >> classInstanceBehavior: anLMRObject [
	^anLMRObject slotAt: classInstanceBehaviorIndex
]

{ #category : #initialization }
PowertalkLMR >> classInstanceBehaviorIndex: anInteger [
	classInstanceBehaviorIndex := anInteger 
]

{ #category : #initialization }
PowertalkLMR >> className: anLMRObject [
	^ anLMRObject slotAt: classNameIndex
]

{ #category : #initialization }
PowertalkLMR >> classNameIndex: anInteger [
	classNameIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> doLookup: aSymbol startingAt: aBehavior [
	| behavior m |
	behavior := aBehavior.
	[ m := self methodFor: aSymbol in: behavior.
	m ifNotNil: [ m ].
	behavior := self behaviorNext: behavior.
	behavior != nilObj ] whileTrue.
	^ nil
]

{ #category : #initialization }
PowertalkLMR >> methodEnvironmentSize: anLMRObject [
	| flags |
	flags := anLMRObject slotAt: methodFlagsIndex.
	^ flags value bitsAt: EnvCount
]

{ #category : #initialization }
PowertalkLMR >> methodFlagsIndex: anInteger [
	methodFlagsIndex := anInteger
]

{ #category : #initialization }
PowertalkLMR >> methodFor: aSymbol in: behavior [
	| md |
	md := self behaviorMethodDictionary: behavior.
	2 to: md size by: 2 do: [:index | (md slotAt: index) == aSymbol ifTrue: [^md slotAt: index + 1]].
	^ nil
]

{ #category : #validating }
PowertalkLMR >> nativizeForLMR [
	| script |
	script := 'nativizeForLMR
	lmr := Kernel loadModule: ''Nativization/LMR''. 
	lmr nativizeLoadedModules'.
	self
		compile: script in: #UndefinedObject;
		sendLocal: #nativizeForLMR to: nilObj
]

{ #category : #initialization }
PowertalkLMR >> nil: n true: t false: f [
	nilObj := n.
	trueObj := t.
	falseObj := f
]

{ #category : #initialization }
PowertalkLMR >> print: anLMRObject on: aStream [
	| class classname |
	class := self behaviorClass: anLMRObject behavior.
	classname := self className: class.
	aStream
		nextPut: $<;
		nextPutAll: classname asLocalString withArticle;
		nextPut: $>
]

{ #category : #validating }
PowertalkLMR >> readKernel [
	| script |
	script := 'readKernel
	| reader |
	reader := Kernel loadModule: ''ImageSegment/Reader''. 
	segment := reader read: ''build/Kernel.ims''.
	^segment'.
	self
		compile: script in: #UndefinedObject;
		sendLocal: #readKernel to: nilObj
]

{ #category : #initialization }
PowertalkLMR >> smallInteger: anLMRObject [
	smallInteger := anLMRObject
]

{ #category : #initialization }
PowertalkLMR >> superBehavior [
	
	^ self classInstanceBehavior: frames last classBinding superclass
]

{ #category : #initialization }
PowertalkLMR >> symbolFromLocal: aString [
	| size table symbol |
	size := aString size + 1.
	table := symbolTable slotAt: 2.
	2 to: table size by: 2 do: [ :index | 
		symbol := table slotAt: index.
		(symbol size = size and: [ symbol asLocalString = aString ])
			ifTrue: [ ^ symbol ] ].
	self error: 'symbol not found'
]

{ #category : #initialization }
PowertalkLMR >> symbolTable: anLMRObject [
	symbolTable:= anLMRObject
]

{ #category : #validating }
PowertalkLMR >> writeKernelAt: anInteger [
	| script |
	script := 'writeKernel
	| writer |
	writer := Kernel loadModule: ''ImageSegment/Writer''. 
	writer write: Kernel at: ' , anInteger asString
		, ' to: ''build/Kernel.ims'''.
	self
		compile: script in: #UndefinedObject;
		sendLocal: #writeKernel to: nilObj
]
