Class {
	#name : #IdentifierNode,
	#superclass : #ParseNode,
	#instVars : [
		'name',
		'binding'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #visiting }
IdentifierNode >> acceptVisitor: visitor [
	^visitor visitIdentifier: self
]

{ #category : #binding }
IdentifierNode >> beAssigned [
	| immutable |
	binding canBeAssigned ifTrue: [^self].
	immutable := binding isClassBinding
		ifTrue: ['class']
		ifFalse: [compiler activeScope describe: binding name].
	self compileError: 'cannot assign to ' , immutable
]

{ #category : #accessing }
IdentifierNode >> binding [
	^binding
]

{ #category : #accessing }
IdentifierNode >> binding: aBinding [
	binding := aBinding
]

{ #category : #testing }
IdentifierNode >> checkLowercase [
	| char |
	char := name first.
	(char isLetter and: [char isUppercase]) ifFalse: [^self].
	self compileWarning: name storeString , ' should start with lowercase'
]

{ #category : #private }
IdentifierNode >> declaration [
	^binding declaration
]

{ #category : #private }
IdentifierNode >> defineArgumentIn: aScriptScope [
	binding := aScriptScope defineArgument: name.
	binding declaration: self
]

{ #category : #private }
IdentifierNode >> defineTemporaryIn: scope [
	binding := scope defineTemporary: name.
	binding declaration: self
]

{ #category : #private }
IdentifierNode >> emitLoadAusing: anAstcodeEncoder [
	binding emitLoadAusing: anAstcodeEncoder
]

{ #category : #accessing }
IdentifierNode >> initialize [
	super initialize.
	binding := UnresolvedBinding default
]

{ #category : #testing }
IdentifierNode >> isEvaluable [
	^self isIdentifierLiteral
]

{ #category : #testing }
IdentifierNode >> isIdentifier [
	^true
]

{ #category : #testing }
IdentifierNode >> isIdentifierLiteral [
	binding isUnresolved ifFalse: [^binding isLiteral].
	^self ast ifNil: [false] ifNotNil: [:ast | | b |
		b := ast scope resolve: name.
		b isLiteral]
]

{ #category : #testing }
IdentifierNode >> isImmediate [
	^true
]

{ #category : #testing }
IdentifierNode >> isMethodArgument [
	| ast |
	binding isArgument ifFalse: [^false].
	ast := self ast ifNil: [^false].
	^ast arguments includes: self declaration
]

{ #category : #testing }
IdentifierNode >> isMethodTemporary [
	^self ast temporaries includes: self declaration
]

{ #category : #testing }
IdentifierNode >> isSelf [
	^binding isSelf
]

{ #category : #testing }
IdentifierNode >> isSuper [
	^binding isSuper
]

{ #category : #accessing }
IdentifierNode >> name [
	^name
]

{ #category : #evaluating }
IdentifierNode >> name: aString [
	name := aString reduced
]

{ #category : #binding }
IdentifierNode >> resolveAssigning: aBoolean [
	| scope |
	scope := compiler activeScope.
	binding := scope resolve: name.
	binding isUnresolved ifFalse: [^binding].
	(scope hasMultipleBindingsFor: name)
		ifTrue: [self compileError: 'variable belongs in multiple pools'].
	compiler undeclaredErrorAt: self stretch assignment: aBoolean.
	^binding := scope resolve: name
]
