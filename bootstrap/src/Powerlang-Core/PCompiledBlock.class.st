Class {
	#name : #PCompiledBlock,
	#superclass : #Object,
	#type : #variable,
	#instVars : [
		'method',
		'nativeCode',
		'format'
	],
	#pools : [
		'PCompiledBlockFlags'
	],
	#category : #'Powerlang-Core-PST'
}

{ #category : #constants }
PCompiledBlock >> argumentCount [
	^format bitsAt: ArgCount
]

{ #category : #constants }
PCompiledBlock >> argumentCount: anInteger [
	format := format bitsAt: ArgCount put: anInteger
]

{ #category : #constants }
PCompiledBlock >> capturesSelf: aBoolean [
	format := aBoolean
		ifTrue: [ format bitOr: CapturesSelf ]
		ifFalse: [ format bitClear: CapturesSelf ]
]

{ #category : #accessing }
PCompiledBlock >> format [
	^ format
]

{ #category : #constants }
PCompiledBlock >> id [
	^format bitsAt: Id
]

{ #category : #constants }
PCompiledBlock >> id: anInteger [
	format := format bitsAt: Id put: anInteger
]

{ #category : #constants }
PCompiledBlock >> initialize [
	super initialize.
	format := 0
]

{ #category : #constants }
PCompiledBlock >> isBlock [
	^true
]

{ #category : #constants }
PCompiledBlock >> method [
	^method
]

{ #category : #accessing }
PCompiledBlock >> method: aCompiledMethod [
	method := aCompiledMethod
]

{ #category : #constants }
PCompiledBlock >> nativeCode [
	^nativeCode
]

{ #category : #constants }
PCompiledBlock >> nativeCode: code [
	nativeCode := code
]

{ #category : #constants }
PCompiledBlock >> tempCount [
	^format bitsAt: TempCount
]

{ #category : #constants }
PCompiledBlock >> tempCount: anInteger [
	format := format bitsAt: TempCount put: anInteger
]

{ #category : #constants }
PCompiledBlock >> value [
	<primitive: BlockValue>
	^self primitiveFailed
]
