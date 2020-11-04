Class {
	#name : #SCompiledMethod,
	#superclass : #Array,
	#type : #variable,
	#instVars : [
		'format',
		'nativeCode',
		'astcodes',
		'class',
		'selector',
		'source'
	],
	#pools : [
		'SCompiledMethodFlags'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'instance creation' }
SCompiledMethod class >> new: anInteger [
	^ (self basicNew: anInteger) initialize
]

{ #category : #constants }
SCompiledMethod >> argumentCount [
	^format bitsAt: ArgCount
]

{ #category : #constants }
SCompiledMethod >> argumentCount: anInteger [
	format := format bitsAt: ArgCount put: anInteger
]

{ #category : #constants }
SCompiledMethod >> astcodes [
	^astcodes
]

{ #category : #constants }
SCompiledMethod >> astcodes: aCollection [
	astcodes := aCollection
]

{ #category : #constants }
SCompiledMethod >> beDebugabble [
	format := format bitOr: Debuggable
]

{ #category : #constants }
SCompiledMethod >> blockCount [
	^format bitsAt: BlockCount
]

{ #category : #constants }
SCompiledMethod >> blockCount: anInteger [
	format := format bitsAt: BlockCount put: anInteger
]

{ #category : #constants }
SCompiledMethod >> blocks [
	self hasBlocks ifFalse: [^#()].
	^self select: [:literal | literal isBlock]
]

{ #category : #constants }
SCompiledMethod >> capturesSelf [ 
	^ format anyMask: CapturesSelf
]

{ #category : #constants }
SCompiledMethod >> capturesSelf: aBoolean [
	format := aBoolean
		          ifTrue: [ format bitOr: CapturesSelf ]
		          ifFalse: [ format bitClear: CapturesSelf ]
]

{ #category : #constants }
SCompiledMethod >> classBinding [
	^class
]

{ #category : #constants }
SCompiledMethod >> classBinding: aClass [
	class := aClass
]

{ #category : #constants }
SCompiledMethod >> copyWithLiterals: aCollection [
	| result |
	result := self species withAll: aCollection.
	^ result
		astcodes: astcodes;
		classBinding: class;
		format: format;
		nativeCode: nativeCode;
		selector: selector;
		source: source;
		yourself
]

{ #category : #constants }
SCompiledMethod >> environmentCount [
	^format bitsAt: EnvCount
]

{ #category : #constants }
SCompiledMethod >> environmentCount: anInteger [
	format := format bitsAt: EnvCount put: anInteger
]

{ #category : #accessing }
SCompiledMethod >> format [
	^format
]

{ #category : #accessing }
SCompiledMethod >> format: anInteger [
	format := anInteger
]

{ #category : #printing }
SCompiledMethod >> gtDisplayOn: stream [
stream
		nextPutAll: self classBinding name;
		nextPutAll: '>>';
		print: selector
]

{ #category : #constants }
SCompiledMethod >> hasBlocks [
	^self blockCount > 0
]

{ #category : #constants }
SCompiledMethod >> hasEnvironment [
	^ format anyMask: HasEnvironment
]

{ #category : #constants }
SCompiledMethod >> hasEnvironment: aBoolean [
	format := aBoolean
		          ifTrue: [ format bitOr: HasEnvironment ]
		          ifFalse: [ format bitClear: HasEnvironment ]
]

{ #category : #constants }
SCompiledMethod >> hasFrame [
	^ format anyMask: HasFrame
]

{ #category : #constants }
SCompiledMethod >> hasFrame: aBoolean [
	format := aBoolean
		          ifTrue: [ format bitOr: HasFrame ]
		          ifFalse: [ format bitClear: HasFrame ]
]

{ #category : #constants }
SCompiledMethod >> initialize [
	super initialize.
	format := 0
]

{ #category : #constants }
SCompiledMethod >> isCallback [
	^false
]

{ #category : #constants }
SCompiledMethod >> isCalloutMethod [
	^ false
]

{ #category : #constants }
SCompiledMethod >> isDebuggable [
	^ format anyMask: Debuggable
]

{ #category : #constants }
SCompiledMethod >> isFrameless [
	^ self hasFrame not
]

{ #category : #constants }
SCompiledMethod >> literals [
	^Array withAll: self
]

{ #category : #accessing }
SCompiledMethod >> nativeCode [
	^nativeCode
]

{ #category : #accessing }
SCompiledMethod >> nativeCode: aNativeCode [ 
	nativeCode := aNativeCode 
]

{ #category : #constants }
SCompiledMethod >> pragma: aPragmaNode [

]

{ #category : #printing }
SCompiledMethod >> printOn: aStream [
	aStream nextPutAll: self classBinding name; nextPutAll: '>>'; print: selector; cr.
	source
		ifNotNil: [ aStream
				cr;
				nextPutAll: source ]
]

{ #category : #constants }
SCompiledMethod >> selector [
	^selector
]

{ #category : #constants }
SCompiledMethod >> selector: aSymbol [
	selector := aSymbol
]

{ #category : #constants }
SCompiledMethod >> sexpressions [
	| decoder |
	decoder := AstcodeDecoder new
		stream: astcodes readStream;
		method: self.
	^decoder decodeMethod
]

{ #category : #constants }
SCompiledMethod >> signature [
	^class-> selector
]

{ #category : #constants }
SCompiledMethod >> source [
	^source
]

{ #category : #constants }
SCompiledMethod >> source: aString [
	source := aString
]

{ #category : #constants }
SCompiledMethod >> tempCount [
	^format bitsAt: TempCount
]

{ #category : #constants }
SCompiledMethod >> tempCount: anInteger [
	format := format bitsAt: TempCount put: anInteger
]
