Class {
	#name : #SSmalltalkParser,
	#superclass : #Object,
	#instVars : [
		'compiler',
		'scanner',
		'token',
		'next'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #parsing }
SSmalltalkParser >> addBodyTo: aMethodNode [
	self
		addTemporariesTo: aMethodNode;
		addPragmaTo: aMethodNode;
		addStatementsTo: aMethodNode
]

{ #category : #private }
SSmalltalkParser >> addByteTo: aCollection [
	| byte |
	byte := token isLiteral ifTrue: [token value] ifFalse: [token literalValue].
	byte isInteger ifFalse: [self nonIntegerToken].
	(byte between: 0 and: 255) ifFalse: [self invalidByteValue].
	aCollection add: byte
]

{ #category : #'api support' }
SSmalltalkParser >> addPragmaTo: aMethodNode [
	(self attachPragmaTo: aMethodNode) ifTrue: [self step]
]

{ #category : #parsing }
SSmalltalkParser >> addStatementsTo: aMethodNode [
	aMethodNode
		position: token position;
		addStatements: self statements;
		end: token position;
		moveCommentsFrom: token.
	token isEnd
		ifFalse: [^self unexpectedStatementError: aMethodNode statements]
]

{ #category : #parsing }
SSmalltalkParser >> addTemporariesTo: aMethodNode [
	aMethodNode temporaries: self temporaries
]

{ #category : #arrays }
SSmalltalkParser >> arrayBody [
	| literals position |
	literals := OrderedCollection new.
	position := token position.
	[
		self step.
		(token is: $)) or: [token isEnd]]
		whileFalse: [| element |
			element := self arrayElement.
			literals add: element].
	token isEnd ifTrue: [self missingToken: ')'].
	^self buildNode: compiler literalNode at: position with: literals asArray
]

{ #category : #arrays }
SSmalltalkParser >> arrayElement [
	token isLiteral ifTrue: [^token value].
	token isNameToken ifTrue: [^self pseudoLiteralValue].
	token isKeyword ifTrue: [^self literalKeyword].
	(token is: #'-') ifTrue: [^self negativeNumberOrBinary].
	token hasSymbol ifTrue: [^token value].
	(token is: $() ifTrue: [^self arrayBody value].
	(token is: #'#(') ifTrue: [^self arrayBody value].
	(token is: #'#[') ifTrue: [^self byteArrayBody value].
	self invalidArrayToken
]

{ #category : #private }
SSmalltalkParser >> assignment [
	| position variable delimiter expression assignment |
	position := token position.
	variable := self step asIdentifierNode moveCommentsFrom: token.
	delimiter := self step.
	expression := self expression.
	expression isAssign
		ifTrue: [^expression assign: variable operator: delimiter].
	expression moveCommentsFrom: token.
	assignment := self buildNode: compiler assignmentNode at: position.
	^assignment assign: variable with: expression operator: delimiter
]

{ #category : #private }
SSmalltalkParser >> attachPragmaTo: aMethodNode [
	| start pragma |
	(aMethodNode isHeadless orNot: [token is: #'<']) ifTrue: [^false].
	start := token position.
	self step.
	pragma := token isKeyword
		ifTrue: [self ffiOrPrimitive: aMethodNode]
		ifFalse: [self symbolicPragma].
	pragma position: start; end: token position.
	aMethodNode pragma: pragma.
	(token is: #'>') ifFalse: [self missingToken: '>'].
	^true
]

{ #category : #binary }
SSmalltalkParser >> binaryMessage: aMessageNode [
	| selector primary argument |
	selector := self step.
	primary := self primary.
	primary isNil ifTrue: [
		((selector is: $:) and: [token is: #'='])
			ifTrue: [self
				error: 'stray whitespaces left in assignment'
				at: token position - 1]
			ifFalse: [self error: 'primary missing']].
	argument := self unarySequence: primary.
	aMessageNode
		selector: selector asSelectorNode;
		end: argument end;
		arguments: {argument}
]

{ #category : #binary }
SSmalltalkParser >> binarySequence: aParseNode [
	| node rcvr |
	node := aParseNode.
	[
		rcvr := node.
		self hasBinarySelector]
		whileTrue: [
			node := self buildMessageNode: rcvr.
			self binaryMessage: node].
	^node
]

{ #category : #binary }
SSmalltalkParser >> binarySignature [
	| selector arguments |
	((token isStringToken and: [token hasSymbol])
		or: [token is: $^]
		or: [token is: $:])
		ifFalse: [^nil].
	selector := self step asSelectorNode.
	token isNameToken ifFalse: [self missingArgument].
	self validateLocalName: token.
	arguments := {token asIdentifierNode}.
	self step.
	token moveCommentsTo: selector.
	^self buildMethodNode: selector arguments: arguments
]

{ #category : #blocks }
SSmalltalkParser >> block [
	| block |
	block := self buildNode: compiler blockNode at: token position.
	block parent: compiler activeScript.
	compiler activate: block while: [
		token moveCommentsTo: block.
		self step.
		block
			arguments: self blockArguments;
			temporaries: self temporaries;
			addStatements: self statements.
		(token is: $]) ifFalse: [self missingToken: ']'].
		block end: token position.
		token moveCommentsTo: block.
		self step].
	^block
]

{ #category : #blocks }
SSmalltalkParser >> blockArguments [
	| arguments |
	(token is: $:) ifFalse: [^#()].
	arguments := OrderedCollection new.
	[
		self step.
		token isNameToken ifFalse: [self missingArgument].
		self validateLocalName: token.
		arguments add: self step asIdentifierNode.
		token is: $:] whileTrue.
	token isBar ifTrue: [self step] ifFalse: [
		(token is: #'||')
			ifTrue: [token value: #'|']
			ifFalse: [self missingToken: '|']].
	^arguments
]

{ #category : #arrays }
SSmalltalkParser >> braceBody [
	| elements position |
	elements := OrderedCollection new.
	position := token position.
	self step.
	[
		token isEnd ifTrue: [self missingToken: '}'].
		token is: $}]
		whileFalse: [
			elements add: self expression.
			(token is: $.) ifTrue: [self step]].
	^self buildBraceNode: elements at: position
]

{ #category : #arrays }
SSmalltalkParser >> bracedArray [
	| array |
	array := self braceBody.
	self step.
	^array
]

{ #category : #private }
SSmalltalkParser >> buildBraceNode: elements at: position [
	| node |
	node := self buildNode: compiler braceNode at: position.
	^node elements: elements
]

{ #category : #private }
SSmalltalkParser >> buildCascadeMessageNode: receiver [
	| node |
	node := self buildNode: compiler cascadeMessageNode at: receiver position.
	^node receiver: receiver
]

{ #category : #private }
SSmalltalkParser >> buildMessageNode: receiver [
	| node |
	node := self buildNode: compiler messageNode at: receiver position.
	^node receiver: receiver
]

{ #category : #private }
SSmalltalkParser >> buildMethodNode: selector arguments: arguments [
	| node |
	node := self buildNode: compiler methodNode at: selector position.
	compiler activeScript: node.
	^node selector: selector; arguments: arguments
]

{ #category : #private }
SSmalltalkParser >> buildNode: aParserNode at: anInteger [
	^aParserNode position: anInteger; end: token position
]

{ #category : #private }
SSmalltalkParser >> buildNode: aParseNode at: anInteger with: anObject [
	| node |
	node := scanner buildToken: aParseNode at: anInteger with: anObject.
	^node end: token position
]

{ #category : #arrays }
SSmalltalkParser >> byteArrayBody [
	| bytes save start array node |
	bytes := OrderedCollection new.
	save := token.
	start := token position.
	[
		self step.
		token isLiteral or: [token isPoolLiteral]]
		whileTrue: [self addByteTo: bytes].
	(token is: $]) ifFalse: [
		token isNameToken
			ifTrue: [self missingLiteral]
			ifFalse: [self missingToken: ']']].
	array := ByteArray new: bytes size.
	bytes withIndexDo: [:b :i | array at: i put: b].
	node := self buildNode: compiler literalNode at: start with: array.
	^node moveCommentsFrom: save
]

{ #category : #private }
SSmalltalkParser >> cascadeMessage: aMessageNode [
	| msg |
	self hasUnarySelector ifTrue: [^self unaryMessage: aMessageNode].
	self hasBinarySelector ifTrue: [^self binaryMessage: aMessageNode].
	self hasKeywordSelector ifTrue: [^self keywordMessage: aMessageNode].
	msg := token value = ''
		ifTrue: ['unfinished cascade']
		ifFalse: [token value asString , ' not allowed in cascade'].
	self error: msg
]

{ #category : #parsing }
SSmalltalkParser >> cascadeSequence: aMessageNode [
	| cascade receiver messages msg node |
	(token is: $;) ifFalse: [^aMessageNode].
	cascade := self buildNode: compiler cascadeNode at: aMessageNode position.
	receiver := aMessageNode receiver.
	cascade receiver: receiver.
	node := compiler cascadeMessageNode from: aMessageNode.
	node cascade: cascade.
	messages := OrderedCollection with: node.
	[token is: $;] whileTrue: [
		self step.
		msg := self buildCascadeMessageNode: receiver.
		msg
			cascade: cascade;
			position: token position;
			moveCommentsFrom: token.
		messages add: msg.
		self cascadeMessage: msg].
	^cascade messages: messages asArray; end: msg end
]

{ #category : #accessing }
SSmalltalkParser >> compiler [
	^compiler
]

{ #category : #accessing }
SSmalltalkParser >> compiler: aSmalltalkCompiler [
	compiler := aSmalltalkCompiler.
	scanner := compiler scanner
]

{ #category : #errors }
SSmalltalkParser >> error: aString [
	self error: aString at: token position
]

{ #category : #errors }
SSmalltalkParser >> error: aString at: position [
	^compiler error: aString at: position
]

{ #category : #parsing }
SSmalltalkParser >> expression [
	| primary expression |
	(token isNameToken and: [self peek isAssignment]) ifTrue: [^self assignment].
	primary := self primary ifNil: [^self missingExpression].
	expression := self unarySequence: primary.
	expression := self binarySequence: expression.
	expression := self keywordSequence: expression.
	expression == primary
		ifFalse: [expression := self cascadeSequence: expression].
	token endsExpression ifFalse: [self errorIn: primary].
	^expression
]

{ #category : #private }
SSmalltalkParser >> ffiArguments [
	| args type |
	args := OrderedCollection new.
	self step.
	token value != $(
		ifTrue: [ self error: 'expected "("' ].
	self peek value = $)
		ifTrue: [ self step.
			^ args ].
	[ type := self ffiType.
	args add: type.
	self step.
	token value = #, ] whileTrue.
	token value != $)
		ifTrue: [ self error: 'expected ")"' ].
	^ args
]

{ #category : #private }
SSmalltalkParser >> ffiCall: aBoolean method: aMethodNode [
	| cc return name args descriptor |
	cc := token value.
	return := self ffiType.
	aBoolean
		ifTrue: [ self step.
			name := token value ifNil: [ self error: 'invalid function name' ] ].
	args := self ffiArguments.
	args size = aMethodNode selector arity
		ifFalse:
			[ ^ self error: 'method arity does not match with function arguments' ].
	self step.
	descriptor := SFFIDescriptor ret: return args: args cc: cc.
	^ compiler pragmaNode ffi: cc name: name with: descriptor
]

{ #category : #private }
SSmalltalkParser >> ffiOrPrimitive: aMethodNode [
	| tag |
	tag := token value asLowercase.
	tag last = $: ifFalse: [self invalidPragma].
	tag := tag allButLast.
	token value: tag.
	tag = 'primitive' ifTrue: [^self primitive].
	tag = 'callback' ifTrue: [ ^self ffiCall: false method: aMethodNode ].
	tag = 'callout' ifTrue: [ ^self ffiCall: true method: aMethodNode ].	
	self invalidPragma
]

{ #category : #private }
SSmalltalkParser >> ffiType [
	| type |
	self step.
	token isNameToken ifFalse: [self error: 'expected type name'].
	type := token value.
	type = 'struct' ifFalse: [ ^type].
	self step.
	token isNameToken ifFalse: [self error: 'expected type name'].	
	^token value
]

{ #category : #binary }
SSmalltalkParser >> hasBinarySelector [
	^(token isStringToken and: [token hasSymbol])
		or: [token is: $^]
		or: [token is: $:]
]

{ #category : #private }
SSmalltalkParser >> hasKeywordSelector [
	^token isKeyword
]

{ #category : #private }
SSmalltalkParser >> hasUnarySelector [
	^token isNameToken
]

{ #category : #productions }
SSmalltalkParser >> headlessMethod [
	| method |
	self step.
	method := compiler methodNode.
	compiler activeScript: method.
	self addBodyTo: method.
	^method
]

{ #category : #errors }
SSmalltalkParser >> invalidArrayToken [
	self error: 'invalid literal entry'
]

{ #category : #errors }
SSmalltalkParser >> invalidByteValue [
	self error: 'value not between 0 and 255'
]

{ #category : #private }
SSmalltalkParser >> invalidPragma [
	| position stretch |
	position := token position.
 	stretch := position thru: position.
	^SInvalidPragmaError new stretch: stretch; signal
]

{ #category : #private }
SSmalltalkParser >> keywordArgument [
	| arg |
	arg := self primary ifNil: [self missingArgument].
	arg := self unarySequence: arg.
	^self binarySequence: arg
]

{ #category : #private }
SSmalltalkParser >> keywordMessage: aMessageNode [
	| selector arguments node |
	node := self buildNode: compiler selectorNode at: token position.
	selector := '' writeStream.
	arguments := OrderedCollection new.
	[token isKeyword] whileTrue: [
		selector nextPutAll: token value.
		node addKeyword: self step.
		arguments add: self keywordArgument].
	node symbol: selector contents; end: token prevPosition.
	aMessageNode
		arguments: arguments;
		end: token prevPosition;
		selector: node
]

{ #category : #private }
SSmalltalkParser >> keywordSequence: aParseNode [
	| expression |
	self hasKeywordSelector ifFalse: [^aParseNode].
	expression := self buildMessageNode: aParseNode.
	self keywordMessage: expression.
	^expression
]

{ #category : #parsing }
SSmalltalkParser >> keywordSignature [
	| selector arguments node |
	selector := '' writeStream.
	arguments := OrderedCollection new.
	node := self buildNode: compiler selectorNode at: token position.
	[token isKeyword] whileTrue: [
		selector nextPutAll: token value.
		node addKeyword: token asSelectorNode.
		self step.
		token isNameToken ifFalse: [self missingArgument].
		arguments add: token asIdentifierNode.
		self step].
	arguments isEmpty ifTrue: [^nil].
	node
		symbol: selector contents;
		end: token end;
		moveCommentsFrom: token.
	^self buildMethodNode: node arguments: arguments
]

{ #category : #arrays }
SSmalltalkParser >> literalArray [
	| array |
	array := self arrayBody.
	self step.
	^array
]

{ #category : #arrays }
SSmalltalkParser >> literalByteArray [
	| node |
	node := self byteArrayBody.
	self step.
	^node
]

{ #category : #private }
SSmalltalkParser >> literalKeyword [
	| keyword |
	keyword := token value , scanner nextKeyword value.
	^keyword reduced asSymbol
]

{ #category : #productions }
SSmalltalkParser >> method [
	| method |
	self step.
	method := self methodSignature.
	method isNil ifTrue: [^nil].
	self addBodyTo: method.
	^method
]

{ #category : #productions }
SSmalltalkParser >> methodFragment [
	| method |
	self step.
	method := self methodSignature.
	method isNil ifTrue: [^nil].
	[self addBodyTo: method] on: SCompilationError do: [].
	^method
]

{ #category : #parsing }
SSmalltalkParser >> methodPragma [
	self step.
	^[| method |
		method := self methodSignature.
		self addTemporariesTo: method; attachPragmaTo: method.
		method pragma]
		on: SCompilationError
		do: [:ex | ex return: compiler pragmaNode]
]

{ #category : #productions }
SSmalltalkParser >> methodSelector [
	self step.
	^self methodSignature ifNotNil: [:m | m selectorNode]
]

{ #category : #parsing }
SSmalltalkParser >> methodSignature [
	self keywordSignature ifNotNil: [:m | ^m].
	self binarySignature ifNotNil: [:m | ^m].
	self unarySignature ifNotNil: [:m | ^m].
	self error: 'method signature expected'
]

{ #category : #errors }
SSmalltalkParser >> missingArgument [
	self error: 'argument missing'
]

{ #category : #errors }
SSmalltalkParser >> missingExpression [
	self error: 'missing expression'
]

{ #category : #errors }
SSmalltalkParser >> missingLiteral [
	self error: 'missing literal or named literal'
]

{ #category : #errors }
SSmalltalkParser >> missingToken: aString [
	self error: 'missing ' , aString
]

{ #category : #private }
SSmalltalkParser >> namedPrimitive [
	| name pragma |
	token isNameToken
		ifFalse: [ self invalidPragma ].
	name := token value.
	pragma := self buildNode: compiler pragmaNode at: token position.
	^ pragma primitive: 0 name: name asSymbol
]

{ #category : #private }
SSmalltalkParser >> negativeNumber [
	token := nil.
	^self negativeNumberOrBinary; step
]

{ #category : #arrays }
SSmalltalkParser >> negativeNumberOrBinary [
	self peek isNumberNode
		ifTrue: [token := self next negate position: token position - 1].
	^token value
]

{ #category : #accessing }
SSmalltalkParser >> next [
	token := next.
	next := nil.
	^token ifNil: [token := scanner next]
]

{ #category : #errors }
SSmalltalkParser >> nonIntegerToken [
	self error: 'non-integer token'
]

{ #category : #errors }
SSmalltalkParser >> notify: aString [
	compiler notify: aString at: token position
]

{ #category : #errors }
SSmalltalkParser >> notify: aString at: position [
	compiler notify: aString at: position
]

{ #category : #private }
SSmalltalkParser >> numberedPrimitive [
	| number pragma |
	number := token value.
	number isInteger ifFalse: [self invalidPragma].
	pragma := self buildNode: compiler pragmaNode at: token position.
	^pragma primitive: number name: nil
]

{ #category : #accessing }
SSmalltalkParser >> on: aString [
	scanner on: aString
]

{ #category : #parsing }
SSmalltalkParser >> parenthesizedExpression [
	| start open expression |
	start := token position.
	open := self step.
	expression := self expression.
	expression moveCommentsFrom: open.
	(token is: $)) ifFalse: [self missingToken: ')'].
	expression isImmediate
		ifFalse: [expression position: start; end: token position].
	self step.
	^expression
]

{ #category : #services }
SSmalltalkParser >> parse: aString [
	^self on: aString; method
]

{ #category : #services }
SSmalltalkParser >> parseExpression: aString [
	^self on: aString; headlessMethod
]

{ #category : #services }
SSmalltalkParser >> parseFragment: aString [
	| method |
	self on: aString; step.
	[
		method := self methodSignature.
		method notNil ifTrue: [self addBodyTo: method]]
		on: SCompilationError
		do: [].
	^method
]

{ #category : #services }
SSmalltalkParser >> parseTemporaries: aString [
	self on: aString; step.
	^self methodSignature notNil ifTrue: [self temporaries]
]

{ #category : #accessing }
SSmalltalkParser >> peek [
	| comments |
	next ifNotNil: [^next].
	next := scanner next.
	next isComment ifFalse: [^next].
	comments := OrderedCollection new: 2.
	[
		comments add: next.
		next := scanner next.
		next isComment] whileTrue.
	^next comments: comments
]

{ #category : #parsing }
SSmalltalkParser >> primary [
	token isNameToken ifTrue: [^self step asIdentifierNode].
	token isLiteral ifTrue: [^self step].
	(token is: $[) ifTrue: [^self block].
	(token is: $() ifTrue: [^self parenthesizedExpression].
	(token is: #'#(') ifTrue: [^self literalArray].
	(token is: #'#[') ifTrue: [^self literalByteArray].
	(compiler supportsBraceNodes and: [token is: ${]) ifTrue: [^self bracedArray].
	(token is: #'-') ifTrue: [^self negativeNumber].
	(token is: #'<') ifTrue: [^self taggedNode].
	^nil
]

{ #category : #private }
SSmalltalkParser >> primitive [
	| primitive |
	self step.
	primitive := token isNumberNode
		ifTrue: [self numberedPrimitive]
		ifFalse: [self namedPrimitive].
	self step.
	^primitive
]

{ #category : #private }
SSmalltalkParser >> pseudoLiteralValue [
	| value |
	token isPoolLiteral ifTrue: [^token literalValue].
	value := token value.
	value = 'nil' ifTrue: [^nil].
	value = 'true' ifTrue: [^true].
	value = 'false' ifTrue: [^false].
	^token isPoolLiteral ifTrue: [token literalValue] ifFalse: [value asSymbol]
]

{ #category : #parsing }
SSmalltalkParser >> return [
	| return expression end node |
	return := self step.
	expression := self expression.
	expression moveCommentsFrom: token.
	end := token position.
	self skipDots.
	node := self buildNode: compiler returnNode at: return position.
	^node
		return: return;
		end: end;
		expression: expression;
		moveCommentsFrom: return
]

{ #category : #private }
SSmalltalkParser >> skipDots [
	[token is: $.] whileTrue: [self step]
]

{ #category : #parsing }
SSmalltalkParser >> statement [
	| expression |
	((token is: $^) or: [token is: $↑]) ifTrue: [^self return].
	expression := self expression.
	token moveCommentsTo: expression.
	^expression
]

{ #category : #parsing }
SSmalltalkParser >> statements [
	| statements |
	statements := OrderedCollection new.
	[
		token endsExpression ifTrue: [^statements].
		statements add: self statement.
		token is: $.]
		whileTrue: [self skipDots].
	^statements
]

{ #category : #parsing }
SSmalltalkParser >> step [
	| save comments |
	save := token.
	self next isComment ifFalse: [^save].
	comments := OrderedCollection new: 2.
	[
		comments add: token.
		self next isComment] whileTrue.
	token comments: comments.
	^save
]

{ #category : #'ffi support' }
SSmalltalkParser >> symbolicPragma [
	| position symbol pragma |
	position := token position.
	symbol := self step value.
	pragma := self buildNode: compiler pragmaNode at: position.
	^pragma symbol: symbol
]

{ #category : #parsing }
SSmalltalkParser >> temporaries [
	| temporaries |
	(token is: #'||') ifTrue: [
		self step.
		^#()].
	token isBar ifFalse: [^#()].
	temporaries := OrderedCollection new.
	[
		self step.
		token isNameToken]
		whileTrue: [
			self validateLocalName: token.
			temporaries add: token asIdentifierNode].
	token isBar ifFalse: [self missingToken: '|'].
	self step.
	^temporaries
]

{ #category : #accessing }
SSmalltalkParser >> token [
	^token
]

{ #category : #parsing }
SSmalltalkParser >> unaryMessage: aMessageNode [
	| selector |
	selector := self unarySelector.
	aMessageNode
		selector: selector;
		end: selector end;
		arguments: #();
		moveCommentsFrom: selector
]

{ #category : #parsing }
SSmalltalkParser >> unarySelector [
	| selector start end node |
	selector := token value.
	start := token position.
	end := start + selector size - 1.
	self step.
	node := self buildNode: compiler selectorNode at: start.
	^node
		symbol: selector;
		end: end;
		moveCommentsFrom: token
]

{ #category : #parsing }
SSmalltalkParser >> unarySequence: aParseNode [
	| node receiver |
	node := aParseNode.
	node isNameToken ifTrue: [node := node asIdentifierNode].
	[
		receiver := node.
		self hasUnarySelector]
		whileTrue: [
			node := self buildMessageNode: receiver.
			self unaryMessage: node].
	^node moveCommentsFrom: token
]

{ #category : #parsing }
SSmalltalkParser >> unarySignature [
	self hasUnarySelector ifFalse: [^nil].
	^self buildMethodNode: self unarySelector arguments: #()
]

{ #category : #private }
SSmalltalkParser >> validateLocalName: aSmalltalkToken [
	aSmalltalkToken isDelimitedIdentifier ifTrue: [^self].
	(aSmalltalkToken value includes: $.)
		ifTrue: [self error: 'invalid embedded dot']
]

{ #category : #errors }
SSmalltalkParser >> warning: aString [
	compiler warning: aString at: token position
]

{ #category : #errors }
SSmalltalkParser >> warning: aString at: position [
	compiler warning: aString at: position
]
