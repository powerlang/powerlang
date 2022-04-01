Class {
	#name : #PowertalkIterativeLinearInterpreter,
	#superclass : #PowertalkIterativeInterpreter,
	#instVars : [
		'linearizer'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #visiting }
PowertalkIterativeLinearInterpreter >> evaluate [
	| operation |
	[ operation := context nextOperation. operation notNil]
		whileTrue: [ 			operation acceptVisitor: self ].
	Transcript print: 'MessageCount: ' , messageCount asString; cr.
	^ regR
]

{ #category : #visiting }
PowertalkIterativeLinearInterpreter >> evaluationContextClass [
	^ IterativeLinearEvaluationContext
]

{ #category : #visiting }
PowertalkIterativeLinearInterpreter >> initialize [
	super initialize.
	linearizer := SExpressionLinearizer new.

]

{ #category : #visiting }
PowertalkIterativeLinearInterpreter >> initializePrimitives [
	super initializePrimitives.
	linearizer primitives: primitives
]

{ #category : #visiting }
PowertalkIterativeLinearInterpreter >> prepareDispatch: dispatch [
	context work:  {dispatch}
]

{ #category : #visiting }
PowertalkIterativeLinearInterpreter >> prepareFor: anSCompiledMethod [
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
PowertalkIterativeLinearInterpreter >> prepareForBlock: sblock [
	| operations |
	operations := sblock optimizedCode.
	context work: operations; restart .
	^ nilObj
]

{ #category : #visiting }
PowertalkIterativeLinearInterpreter >> underprimitiveRestart [
	^ [ :receiver :arguments | 
	context
		restart]
]

{ #category : #visiting }
PowertalkIterativeLinearInterpreter >> visitOpPrimitive: anSOpPrimtive [
	regR := anSOpPrimtive block value
]
