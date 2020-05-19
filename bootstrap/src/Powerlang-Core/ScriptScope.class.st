Class {
	#name : #ScriptScope,
	#superclass : #Object,
	#instVars : [
		'script',
		'arguments',
		'temporaries',
		'stackSize',
		'envSize',
		'captureSelf'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'instance creation' }
ScriptScope class >> new [
	^super new initialize
]

{ #category : #'instance creation' }
ScriptScope class >> on: aScriptNode [
	^self new script: aScriptNode
]

{ #category : #services }
ScriptScope >> capturesSelf [
	^ captureSelf
]

{ #category : #binding }
ScriptScope >> defineArgument: identifier [
	| binding |
	(self resolves: identifier) ifTrue: [self redefinitionError: identifier].
	binding := ArgumentBinding new name: identifier.
	arguments define: identifier as: binding.
	^binding
]

{ #category : #binding }
ScriptScope >> defineTemporary: identifier [
	| binding |
	(temporaries defines: identifier)
		ifTrue: [self redefinitionError: identifier].
	binding := TemporaryBinding new name: identifier.
	temporaries define: identifier as: binding.
	^binding
]

{ #category : #binding }
ScriptScope >> defines: aString [
	^(temporaries defines: aString) or: [arguments defines: aString]
]

{ #category : #services }
ScriptScope >> describe: identifier [
	| binding type |
	binding := self resolve: identifier.
	type := self class name asLowercase allButLast: 'scope' size.
	^binding description , ' of ' , type
]

{ #category : #services }
ScriptScope >> environmentSize [
	^envSize
]

{ #category : #private }
ScriptScope >> growEnvironment [
	^envSize := envSize + 1
]

{ #category : #private }
ScriptScope >> growStack [
	^stackSize := stackSize + 1
]

{ #category : #initialization }
ScriptScope >> initialize [
	super initialize.
	arguments := StaticBinder new.
	temporaries := StaticBinder new.
	stackSize := envSize := 0.
		captureSelf := false.
]

{ #category : #binding }
ScriptScope >> localBindings [
	^arguments values , temporaries values
]

{ #category : #private }
ScriptScope >> positionDefinedArguments [
	arguments withIndexDo: [:binding :index | binding index: index]
]

{ #category : #private }
ScriptScope >> positionDefinedLocals [
	self positionDefinedTemporariesIn: self; positionDefinedArguments
]

{ #category : #private }
ScriptScope >> positionDefinedTemporariesIn: aScriptScope [
	temporaries do: [:binding | | position |
		position := binding isInStack
			ifTrue: [aScriptScope growStack]
			ifFalse: [aScriptScope growEnvironment].
		binding index: position]
]

{ #category : #private }
ScriptScope >> positionLocals [
	self positionDefinedLocals
]

{ #category : #private }
ScriptScope >> realScope [
	^script realScript scope
]

{ #category : #private }
ScriptScope >> redefinitionError: name [
	| scope description |
	scope := self scopeOf: name.
	description := scope describe: name.
	script compiler
		warning: name , ' already declared as ' , description
		at: script stretch
]

{ #category : #binding }
ScriptScope >> resolveLocal: aString [
	(temporaries at: aString) ifNotNil: [:binding | ^binding].
	^arguments at: aString
]

{ #category : #binding }
ScriptScope >> resolves: aString [
	^(self resolve: aString) isUnresolved not
]

{ #category : #services }
ScriptScope >> scopeOf: aString [
	| s |
	s := self scriptDefining: aString.
	^s notNil ifTrue: [s scope]
]

{ #category : #accessing }
ScriptScope >> script: aScriptNode [
	script := aScriptNode
]

{ #category : #services }
ScriptScope >> stackSize [
	^stackSize
]
