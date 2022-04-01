Class {
	#name : #SBinding,
	#superclass : #Object,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SBinding class >> decodeUsing: anAstcodeDecoder [
	^self subclassResponsibility
]

{ #category : #testing }
SBinding >> assign: value within: aPowertalkRuntime [
	^ self subclassResponsibility
]

{ #category : #testing }
SBinding >> isArgument [
	^false
]

{ #category : #testing }
SBinding >> isAssociation [
	^false
]

{ #category : #testing }
SBinding >> isClassBinding [
	^false
]

{ #category : #testing }
SBinding >> isClassVar [
	^false
]

{ #category : #testing }
SBinding >> isDynamic [
	^ false
]

{ #category : #testing }
SBinding >> isInstVar [
	^false
]

{ #category : #testing }
SBinding >> isLiteral [
	^false
]

{ #category : #testing }
SBinding >> isPoolVar [
	^false
]

{ #category : #testing }
SBinding >> isSelf [
	^false
]

{ #category : #testing }
SBinding >> isSuper [
	^false
]

{ #category : #testing }
SBinding >> isTemporary [
	^false
]

{ #category : #testing }
SBinding >> name [
	^self printString
]

{ #category : #testing }
SBinding >> valueWithin: anEvaluationContext [
	^ self subclassResponsibility
]
