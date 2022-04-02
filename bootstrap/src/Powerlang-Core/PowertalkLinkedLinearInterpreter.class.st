Class {
	#name : #PowertalkLinkedLinearInterpreter,
	#superclass : #PowertalkIterativeLinkedInterpreter,
	#instVars : [
		'linearizer'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #visiting }
PowertalkLinkedLinearInterpreter >> evaluate [
	| operation |
	[ operation := context nextOperation. operation notNil]
		whileTrue: [ 			operation acceptVisitor: self ].
	Transcript print: 'MessageCount: ' , messageCount asString; cr.
	^ regR
]

{ #category : #visiting }
PowertalkLinkedLinearInterpreter >> evaluationContextClass [
	^ LinkedLinearEvaluationContext
]

{ #category : #visiting }
PowertalkLinkedLinearInterpreter >> initialize [
	super initialize.
	linearizer := SExpressionLinearizer new.

]

{ #category : #visiting }
PowertalkLinkedLinearInterpreter >> initializePrimitives [
	super initializePrimitives.
	linearizer primitives: primitives
]

{ #category : #visiting }
PowertalkLinkedLinearInterpreter >> prepareDispatch: dispatch [
	context work:  {dispatch}
]

{ #category : #private }
PowertalkLinkedLinearInterpreter >> prepareFor: anSCompiledMethod [
	| operations array |
	operations := runtime sexpressionsOf: anSCompiledMethod.
	operations isCollection
		ifFalse: [ linearizer visitMethod: operations.
			array := linearizer operations asArray.
			operations optimizedCode: array.
			operations := array].
	context work: operations
]

{ #category : #visiting }
PowertalkLinkedLinearInterpreter >> prepareForBlock: sblock [
	| operations |
	operations := sblock optimizedCode.
	context work: operations; restart .
	^ nilObj
]

{ #category : #visiting }
PowertalkLinkedLinearInterpreter >> underprimitiveRestart [
	^ [ :receiver :arguments | 
	context
		restart]
]

{ #category : #visiting }
PowertalkLinkedLinearInterpreter >> visitOpPrimitive: anSOpPrimtive [
	regR := anSOpPrimtive block value
]
