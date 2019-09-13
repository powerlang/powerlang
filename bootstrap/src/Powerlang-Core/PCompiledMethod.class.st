Class {
	#name : #PCompiledMethod,
	#superclass : #Object,
	#instVars : [
		'nativeCode',
		'literals',
		'astcodes',
		'class',
		'selector',
		'format',
		'source'
	],
	#pools : [
		'PCompiledMethodFlags'
	],
	#category : #'Powerlang-Core-PST'
}

{ #category : #'instance creation' }
PCompiledMethod class >> new: anInteger [
	^(super new: anInteger) initialize
]

{ #category : #constants }
PCompiledMethod >> argumentCount [
	^format bitsAt: ArgCount
]

{ #category : #constants }
PCompiledMethod >> argumentCount: anInteger [
	format := format bitsAt: ArgCount put: anInteger
]

{ #category : #constants }
PCompiledMethod >> astcodes [
	^astcodes
]

{ #category : #constants }
PCompiledMethod >> astcodes: aCollection [
	astcodes := aCollection
]

{ #category : #constants }
PCompiledMethod >> blockCount [
	^format bitsAt: BlockCount
]

{ #category : #constants }
PCompiledMethod >> blockCount: anInteger [
	format := format bitsAt: BlockCount put: anInteger
]

{ #category : #constants }
PCompiledMethod >> blocks [
	self hasBlocks ifFalse: [^#()].
	^self literals select: [:literal | literal isBlock]
]

{ #category : #constants }
PCompiledMethod >> classBinding [
	^class
]

{ #category : #constants }
PCompiledMethod >> classBinding: aClass [
	class := aClass
]

{ #category : #constants }
PCompiledMethod >> hasBlocks [
	^self blockCount > 0
]

{ #category : #constants }
PCompiledMethod >> initialize [
	super initialize.
	format := 0
]

{ #category : #accessing }
PCompiledMethod >> literals [
	^ literals
]

{ #category : #accessing }
PCompiledMethod >> literals: anObject [
	literals := anObject
]

{ #category : #constants }
PCompiledMethod >> selector [
	^selector
]

{ #category : #constants }
PCompiledMethod >> selector: aSymbol [
	selector := aSymbol
]

{ #category : #constants }
PCompiledMethod >> sexpressions [
	| decoder |
	decoder := AstcodeDecoder new
		stream: astcodes readStream;
		method: self.
	^decoder decodeMethod
]

{ #category : #constants }
PCompiledMethod >> source [
	^source
]

{ #category : #constants }
PCompiledMethod >> source: aString [
	source := aString
]

{ #category : #constants }
PCompiledMethod >> tempCount [
	^format bitsAt: TempCount
]

{ #category : #constants }
PCompiledMethod >> tempCount: anInteger [
	format := format bitsAt: TempCount put: anInteger
]
