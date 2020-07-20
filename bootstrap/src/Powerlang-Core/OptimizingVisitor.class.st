"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OptimizingVisitor,
	#superclass : #SParseTreeVisitor,
	#instVars : [
		'method',
		'firstBlock',
		'currentBlock'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #unclassified }
OptimizingVisitor class >> new [
	^self basicNew initialize
]

{ #category : #unclassified }
OptimizingVisitor >> initialize [
	firstBlock := OBasicBlock new.
	currentBlock := firstBlock
]

{ #category : #unclassified }
OptimizingVisitor >> insertDefineArgument: name [
	| instruction |
	instruction := ODefineArgument named: name.
	currentBlock add: instruction.
	^instruction
]

{ #category : #unclassified }
OptimizingVisitor >> insertReturnSelf [
	| receiver frame instruction |
	receiver := firstBlock firstInstruction next.
	frame := firstBlock firstInstruction.
	instruction := OReturn new
		source: receiver;
		frame: frame;
		argumentsCount: method argumentCount.
	receiver addUse: instruction at: #source.
	frame addUse: instruction at: #frame.
	currentBlock add: instruction.
	^ instruction
]

{ #category : #unclassified }
OptimizingVisitor >> method: anSCompiledMethod [
	method := anSCompiledMethod
]

{ #category : #unclassified }
OptimizingVisitor >> store: operation into: anIdentifierNode [
	| instruction |
	instruction := OWriteVariable
		binding: anIdentifierNode binding
		valued: operation.
	operation addUse: instruction at: #source.
	currentBlock add: instruction.
	^instruction
]

{ #category : #visiting }
OptimizingVisitor >> visit: aParseNode [
	super visit: aParseNode.
	^firstBlock
]

{ #category : #visiting }
OptimizingVisitor >> visitAssignment: anAssignmentNode [
	| result |
	result := anAssignmentNode expression acceptVisitor: self.
	anAssignmentNode assignees do: [:node | self store: result into: node]
]

{ #category : #visiting }
OptimizingVisitor >> visitBlock: aBlockNode [
	| previous cfg |
	previous := currentBlock.
	cfg := OBasicBlock new.
	currentBlock := cfg.
	self visitScript: aBlockNode.
	currentBlock := previous.
	^OBlockClosure containing: cfg
]

{ #category : #visiting }
OptimizingVisitor >> visitCascade: aCascadeNode [
	| receiver arguments send block |
	block := currentBlock.
	receiver := aCascadeNode receiver acceptVisitor: self.
	aCascadeNode messages
		do: [ :msg | 
			arguments := msg arguments
				collect: [ :node | node acceptVisitor: self ].
			send := OMessageSend
				receiver: receiver
				selector: msg selector value asSymbol
				arguments: arguments.
			receiver addUse: send at: #receiver.
			arguments
				withIndexDo: [ :argument :i | 
					argument isInstruction
						ifTrue: [ argument addUse: send at: i ] ].
			block add: send ].
	^ send
]

{ #category : #visiting }
OptimizingVisitor >> visitIdentifier: anIdentifierNode [
	| load |
	load := OReadVariable binding: anIdentifierNode binding.
	currentBlock add: load.
	^load
]

{ #category : #visiting }
OptimizingVisitor >> visitLiteral: aLiteralNode [
	| load |
	load := OLoadConstant valued: aLiteralNode value.
	currentBlock add: load.
	^load
]

{ #category : #visiting }
OptimizingVisitor >> visitMessage: aMessageNode [
	| receiver arguments send block |
	block := currentBlock.
	receiver := aMessageNode receiver acceptVisitor: self.
	arguments := aMessageNode arguments
		collect: [:node | node acceptVisitor: self].
	send := OMessageSend
		receiver: receiver
		selector: aMessageNode selector value asSymbol
		arguments: arguments.
	receiver addUse: send at: #receiver.
	arguments
		withIndexDo: [:argument :i | argument isInstruction
			ifTrue: [argument addUse: send at: i]].
	block add: send.
	^send
]

{ #category : #visiting }
OptimizingVisitor >> visitMethod: anSMethod [
	| last |
	self insertDefineArgument: #activationRecord; insertDefineArgument: #self.
	1 to: anSMethod argumentCount
		do: [:i | self insertDefineArgument: i printString asSymbol].
	self visitScript: anSMethod.
	last := currentBlock lastValue.
	last isReturn ifFalse: [self insertReturnSelf]
]

{ #category : #visiting }
OptimizingVisitor >> visitNumericLiteral: aNumericLiteralNode [
	^self visitLiteral: aNumericLiteralNode
]

{ #category : #visiting }
OptimizingVisitor >> visitReturn: aReturnNode [
	| source frame instruction |
	source := aReturnNode expression acceptVisitor: self.
	frame := firstBlock firstInstruction.
	instruction := OReturn new
		source: source;
		frame: frame;
		argumentsCount: method argumentCount.
	source addUse: instruction at: #source.
	frame addUse: instruction at: #frame.
	currentBlock add: instruction.
	^ instruction
]

{ #category : #visiting }
OptimizingVisitor >> visitScript: aScriptNode [
	[
		aScriptNode arguments do: [:node | node acceptVisitor: self].
		aScriptNode temporaries do: [:node | node acceptVisitor: self]].
	aScriptNode statements do: [:node | node acceptVisitor: self]
]

{ #category : #visiting }
OptimizingVisitor >> visitSelector: aSelectorNode [
	
]
