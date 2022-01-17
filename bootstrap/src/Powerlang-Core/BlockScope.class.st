Class {
	#name : #BlockScope,
	#superclass : #ScriptScope,
	#instVars : [
		'environments',
		'captured'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #binding }
BlockScope >> captureArgument: anArgumentBinding [
	| name |
	name := anArgumentBinding name.
	^captured at: name ifAbsentPut: [| transferred copy |
		transferred := self parent transferLocal: name.
		copy := self copyLocal: transferred.
		(anArgumentBinding isInlined and: [copy != anArgumentBinding])
			ifTrue: [anArgumentBinding beInArray].
		copy declaration: transferred declaration]
]

{ #category : #private }
BlockScope >> captureEnvironment: aScriptNode [
	script == aScriptNode ifTrue: [^self].
	(environments identityIncludes: aScriptNode) ifTrue: [^self].
	self realParent captureEnvironment: aScriptNode.
	aScriptNode isMethod
		ifTrue: [environments addFirst: aScriptNode]
		ifFalse: [environments addLast: aScriptNode]
]

{ #category : #services }
BlockScope >> captureLocal: aLocalBinding [
	(self defines: aLocalBinding name) ifTrue: [^aLocalBinding].
	^aLocalBinding isTemporary
		ifTrue: [self captureTemporary: aLocalBinding]
		ifFalse: [self captureArgument: aLocalBinding]
]

{ #category : #services }
BlockScope >> captureSelf [
	captureSelf ifTrue: [^self].
	captureSelf := true.
	self parent captureSelf
]

{ #category : #services }
BlockScope >> captureTemporary: aTemporaryBinding [
	| name |
	name := aTemporaryBinding name.
	(self defines: name) ifTrue: [^aTemporaryBinding].
	^captured at: name ifAbsentPut: [| parent declaration transferred copy |
		parent := self parent.
		declaration := parent scriptDefining: name.
		self realScope captureEnvironment: declaration realScript.
		transferred := parent transferLocal: name.
		copy := self copyLocal: transferred.
		copy isInArray ifTrue: [aTemporaryBinding beInArray].
		copy declaration: transferred declaration]
]

{ #category : #services }
BlockScope >> capturedArguments [
	^captured select: [:b | b isArgument]
]

{ #category : #private }
BlockScope >> capturedEnvironmentIndexOf: aScriptNode [
	| index |
	aScriptNode realScript == script realScript
		ifTrue: [ ^ nil ].
	index := environments indexOf: aScriptNode ifAbsent: nil.
	self ASSERT: index notNil.
	^self capturesSelf ifTrue: [ index + 1 ] ifFalse: [ index ]
]

{ #category : #services }
BlockScope >> capturedEnvironments [
	^environments
]

{ #category : #services }
BlockScope >> capturesHome [
	^self home notNil
]

{ #category : #services }
BlockScope >> capturesSelf [
	^captureSelf
]

{ #category : #private }
BlockScope >> copyLocal: binding [
	^script isInlined ifTrue: [binding] ifFalse: [binding copy beInArray]
]

{ #category : #private }
BlockScope >> environmentIndexOf: aScriptNode [
	"
	temporal compatibility
	"
	(aScriptNode isKindOf: SScriptNode)
		ifFalse: [ self ASSERT: false. ^nil ].
	^self capturedEnvironmentIndexOf: aScriptNode
]

{ #category : #private }
BlockScope >> environmentSizeUpToCapturedArguments [
	^self environmentSizeUpToEnvironments + self capturedArguments size
]

{ #category : #private }
BlockScope >> environmentSizeUpToEnvironments [
	| receiver |
	receiver := self capturesSelf ifTrue: [ 1 ] ifFalse: [ 0 ].
	^receiver + environments size
]

{ #category : #services }
BlockScope >> environments [
	"
	compatibility, removes the home environment
	"
	| first |
	environments isEmpty ifTrue: [^#()].
	first := environments first.
	^first isMethod ifTrue: [environments allButFirst] ifFalse: [environments]
]

{ #category : #services }
BlockScope >> home [
	| first |
	environments isEmpty ifTrue: [^nil].
	first := environments first.
	^first isMethod ifTrue: [first]
]

{ #category : #initialization }
BlockScope >> initialize [
	super initialize.
	captured := StaticBinder new.
	environments := OrderedCollection new
]

{ #category : #binding }
BlockScope >> localBindings [
	^super localBindings , captured values
]

{ #category : #private }
BlockScope >> parent [
	^script parent scope
]

{ #category : #private }
BlockScope >> positionCapturedArgument: anArgumentBinding [
	anArgumentBinding index: self growEnvironment
]

{ #category : #private }
BlockScope >> positionCapturedLocals [
	script isInlined ifTrue: [^self].
	envSize := self environmentSizeUpToEnvironments.
	captured do: [:binding | 
		binding isArgument
			ifTrue: [self positionCapturedArgument: binding]
			ifFalse: [self positionCapturedTemporary: binding]]
]

{ #category : #private }
BlockScope >> positionCapturedTemporary: aTemporaryBinding [
	| outest index declaration |
	outest := self scriptDefining: aTemporaryBinding name.
	index := self capturedEnvironmentIndexOf: outest realScript.
	aTemporaryBinding environmentIndex: index.
	declaration := outest scope resolve: aTemporaryBinding name.
	self ASSERT: declaration index isInteger.
	aTemporaryBinding index: declaration index
]

{ #category : #private }
BlockScope >> positionDefinedArgumentsIn: aScriptScope [
	arguments do: [:binding | | index |
		index := binding isInArray
			ifTrue: [aScriptScope growEnvironment]
			ifFalse: [aScriptScope growStack].
		binding index: index]
]

{ #category : #private }
BlockScope >> positionDefinedLocals [
	| real |
	script isInlined
		ifTrue: [
			real := self realScope.
			self
				positionDefinedTemporariesIn: real;
				positionDefinedArgumentsIn: real]
		ifFalse: [super positionDefinedLocals]
]

{ #category : #private }
BlockScope >> positionLocals [
	self positionCapturedLocals.
	super positionLocals
]

{ #category : #private }
BlockScope >> realParent [
	^script realParent scope
]

{ #category : #binding }
BlockScope >> resolve: aString [
	(self resolveLocal: aString) ifNotNil: [:binding | ^binding].
	^self parent resolve: aString
]

{ #category : #services }
BlockScope >> resolveLocal: aString [
	(super resolveLocal: aString) ifNotNil: [:binding | ^binding].
	^captured at: aString
]

{ #category : #services }
BlockScope >> scriptDefining: aString [
	(self defines: aString) ifTrue: [^script].
	^self parent scriptDefining: aString
]

{ #category : #private }
BlockScope >> transferLocal: name [
	| binding copy |
	(self resolveLocal: name) ifNotNil: [:b | ^b].
	binding := self parent transferLocal: name.
	copy := self copyLocal: binding.
	captured at: name put: copy.
	^copy
]
