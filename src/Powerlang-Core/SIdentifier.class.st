Class {
	#name : #SIdentifier,
	#superclass : #SExpression,
	#instVars : [
		'binding'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SIdentifier class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeIdentifier
]

{ #category : #visiting }
SIdentifier >> acceptVisitor: visitor [
	^visitor visitIdentifier: self
]

{ #category : #accessing }
SIdentifier >> binding [
	^binding
]

{ #category : #visiting }
SIdentifier >> binding: aBinding [
	binding := aBinding
]

{ #category : #visiting }
SIdentifier >> isArgument [
	^binding isArgument
]

{ #category : #visiting }
SIdentifier >> isAssociation [
	^binding isAssociation
]

{ #category : #visiting }
SIdentifier >> isIdentifier [
	^true
]

{ #category : #visiting }
SIdentifier >> isInstVar [
	^binding isInstVar
]

{ #category : #visiting }
SIdentifier >> isLiteral [
	^binding isLiteral
]

{ #category : #visiting }
SIdentifier >> isSelf [
	^binding isSelf
]

{ #category : #visiting }
SIdentifier >> isSelfOrSuper [
	^binding isSelf or: [binding isSuper]
]

{ #category : #visiting }
SIdentifier >> isSuper [
	^binding isSuper
]

{ #category : #visiting }
SIdentifier >> isTemporary [
	^binding isTemporary
]

{ #category : #visiting }
SIdentifier >> isVariable [
	^true
]

{ #category : #visiting }
SIdentifier >> printOn: aStream indent: anInteger [
	aStream
		tab: anInteger;
		nextPutAll: '{IdentifierId. ';
		print: binding;
		nextPutAll: '}'
]
