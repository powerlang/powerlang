Class {
	#name : #BinaryMessageOptimizer,
	#superclass : #Object,
	#instVars : [
		'emitter',
		'message',
		'selector',
		'receiver',
		'argument'
	],
	#pools : [
		'AstBindingTypes',
		'AstNodeTypes'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #'as yet unclassified' }
BinaryMessageOptimizer class >> on: aMessageNode using: anAstcodeEmitter [
	^self new emitter: anAstcodeEmitter; message: aMessageNode 
]

{ #category : #'as yet unclassified' }
BinaryMessageOptimizer class >> optimizesMessage: selector [
	^#(== = < <= >= > + - * / // \\ |  & << >> bitOr: bitAnd: bitXor: bitShift:)
		includes: selector 
]

{ #category : #private }
BinaryMessageOptimizer >> argumentIsSmallInteger [
	^argument isLiteral and: [argument value isSmallInteger] 
]

{ #category : #private }
BinaryMessageOptimizer >> argumentOverwritesR [
	argument isLiteral ifTrue: [^false].
	argument isVariable ifTrue: [^false].
	^true 
]

{ #category : #private }
BinaryMessageOptimizer >> emitOpcodes [
	(selector == #'==' or: [selector == #'!==']) ifTrue: [^self loadOperands].
	(#(= + - != < > <= >= | & << >> * / // \\ bitOr: bitAnd: bitXor: bitShift:)
		includes: selector)
		ifTrue: [^self loadSmallIntegerOperands].
	self ASSERT: false 
]

{ #category : #accessing }
BinaryMessageOptimizer >> emitter: anAstcodeEmitter [
	emitter := anAstcodeEmitter 
]

{ #category : #private }
BinaryMessageOptimizer >> ensureAisSmallInteger [
	emitter nextPut: EnsureAisSmallIntegerId 
]

{ #category : #private }
BinaryMessageOptimizer >> ensureRisSmallInteger [
	emitter nextPut: EnsureRisSmallIntegerId 
]

{ #category : #private }
BinaryMessageOptimizer >> genericLoadArgument [
	emitter nextPut: LoadAvisitingArgumentId 
]

{ #category : #private }
BinaryMessageOptimizer >> genericLoadReceiver [
	emitter nextPut: LoadRvisitingReceiverId 
]

{ #category : #private }
BinaryMessageOptimizer >> hasImmediateArgument [
	^argument isLiteral or: [argument isIdentifier] 
]

{ #category : #private }
BinaryMessageOptimizer >> loadArgument [
	self hasImmediateArgument
		ifTrue: [argument emitLoadAusing: emitter]
		ifFalse: [self genericLoadArgument] 
]

{ #category : #private }
BinaryMessageOptimizer >> loadOperands [
	| strict push |
	strict := message needsStrictEvaluationOrder.
	strict
		ifTrue: [
			emitter encodeLoadRvisitingReceiver.
			push := self hasImmediateArgument not.
			push ifTrue: [emitter encodePushR].
			self loadArgument.
			push ifTrue: [emitter encodePopR]]
		ifFalse: [
			self loadArgument.
			emitter encodeLoadRvisitingReceiver] 
]

{ #category : #private }
BinaryMessageOptimizer >> loadSmallIntegerOperands [
	self loadOperands.
	self receiverIsSmallInteger ifFalse: [self ensureRisSmallInteger].
	self argumentIsSmallInteger ifFalse: [self ensureAisSmallInteger] 
]

{ #category : #accessing }
BinaryMessageOptimizer >> message: aMessageNode [
	message := aMessageNode.
	selector := aMessageNode selector value.
	receiver := aMessageNode receiver.
	argument := aMessageNode arguments first 
]

{ #category : #private }
BinaryMessageOptimizer >> receiverIsSmallInteger [
	^receiver isLiteral and: [receiver value isSmallInteger] 
]
