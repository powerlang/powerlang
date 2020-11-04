Class {
	#name : #SCompiledBlock,
	#superclass : #Object,
	#type : #variable,
	#instVars : [
		'format',
		'nativeCode',
		'method'
	],
	#pools : [
		'SCompiledBlockFlags'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #constants }
SCompiledBlock >> argumentCount [
	^format bitsAt: ArgCount
]

{ #category : #constants }
SCompiledBlock >> argumentCount: anInteger [
	format := format bitsAt: ArgCount put: anInteger
]

{ #category : #constants }
SCompiledBlock >> capturesHome [
	^ format anyMask: CapturesHome
]

{ #category : #constants }
SCompiledBlock >> capturesHome: aBoolean [
	format := aBoolean
		          ifTrue: [ format bitOr: CapturesHome ]
		          ifFalse: [ format bitClear: CapturesHome ]
]

{ #category : #constants }
SCompiledBlock >> capturesSelf [
	^format anyMask: CapturesSelf
]

{ #category : #constants }
SCompiledBlock >> capturesSelf: aBoolean [
	format := aBoolean
		ifTrue: [ format bitOr: CapturesSelf ]
		ifFalse: [ format bitClear: CapturesSelf ]
]

{ #category : #constants }
SCompiledBlock >> environmentCount [
	^ format bitsAt: EnvCount
]

{ #category : #constants }
SCompiledBlock >> environmentCount: anInteger [
	format := format bitsAt: EnvCount put: anInteger
]

{ #category : #constants }
SCompiledBlock >> format [
	^ format
]

{ #category : #constants }
SCompiledBlock >> id [
	^format bitsAt: Id
]

{ #category : #constants }
SCompiledBlock >> id: anInteger [
	format := format bitsAt: Id put: anInteger
]

{ #category : #constants }
SCompiledBlock >> initialize [
	super initialize.
	format := 0
]

{ #category : #constants }
SCompiledBlock >> isBlock [
	^true
]

{ #category : #constants }
SCompiledBlock >> method [
	^method
]

{ #category : #accessing }
SCompiledBlock >> method: aCompiledMethod [
	method := aCompiledMethod
]

{ #category : #constants }
SCompiledBlock >> nativeCode [
	^nativeCode
]

{ #category : #constants }
SCompiledBlock >> nativeCode: code [
	nativeCode := code
]

{ #category : #constants }
SCompiledBlock >> newClosure [
	| closure |
	closure := SClosure new: self environmentCount.
	^ closure block: self
]

{ #category : #constants }
SCompiledBlock >> tempCount [
	^format bitsAt: TempCount
]

{ #category : #constants }
SCompiledBlock >> tempCount: anInteger [
	format := format bitsAt: TempCount put: anInteger
]

{ #category : #constants }
SCompiledBlock >> value [
self halt
"	<primitive: BlockValue>
	^ self primitiveFailed" 
]
