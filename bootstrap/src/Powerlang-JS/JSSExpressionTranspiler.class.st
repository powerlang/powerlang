Class {
	#name : #JSSExpressionTranspiler,
	#superclass : #Object,
	#instVars : [
		'runtime',
		'evaluator',
		'stream',
		'literals',
		'tabs',
		'currentBlock',
		'one',
		'plus',
		'greaterThan',
		'equalsEquals',
		'not',
		'ifTrue',
		'ifFalse',
		'ifTrueIfFalse',
		'ifFalseIfTrue',
		'ifNil',
		'ifNotNil',
		'ifNilIfNotNil',
		'ifNotNilIfNil',
		'repeat',
		'whileTrue',
		'whileFalse',
		'whileTrue_',
		'whileFalse_',
		'timesRepeat',
		'toDo',
		'toByDo',
		'andNot',
		'orNot'
	],
	#category : #'Powerlang-JS'
}

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> addLiteral: anObject [
	literals add: anObject.
	^literals size 
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> args [
	stream nextPutAll: 'frame.__arguments'
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> argumentAt: index [
	self args; index: index
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> argumentAt: index in: environmentIndex [
	environmentIndex ifNil: [ ^ self argumentAt: index ].
	self loadEnvironmentFor: environmentIndex; index: index
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> assign: value [
	stream nextPutAll: ' = '; print: value
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> currentEnv [
	stream nextPutAll: 'frame.env'
]

{ #category : #services }
JSSExpressionTranspiler >> end [
	stream
		nextPutAll: '})';
		cr
]

{ #category : #accessing }
JSSExpressionTranspiler >> evaluator: aJSPowertalkEvaluator [ 
 evaluator := aJSPowertalkEvaluator.
	self runtime: evaluator runtime
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> index: anInteger [
	stream
		nextPutAll: '[';
		print: anInteger -1;
		nextPut: $]
]

{ #category : #services }
JSSExpressionTranspiler >> initialize [
	tabs := 2.
	stream := '' writeStream.
	literals := OrderedCollection new
]

{ #category : #accessing }
JSSExpressionTranspiler >> inline: anSMessage ifTrueIfFalse: aBoolean [
	stream nextPut: $(.
	aBoolean
	ifTrue: [ stream nextPutAll: 'evaluator._trueObj===' ]
		ifFalse: [ stream nextPutAll: 'evaluator._falseObj===' ].
	stream nextPut: $(.
	anSMessage receiver acceptVisitor: self.
	stream nextPutAll: ') ? ('.
	self visitStatements: anSMessage arguments first statements.
	stream nextPutAll: ') : ('.
	self visitStatements: anSMessage arguments second statements.
	stream nextPutAll: '))'
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> inline: anSMessage ifTrueIfFalse: aBoolean with: nativizer [
	stream nextPut: $(.
	aBoolean
		ifFalse: [ stream nextPut: $! ].
	anSMessage receiver acceptVisitor: self.
	stream nextPutAll: ' ? '.
	nativizer visitStatements: anSMessage arguments first statements.
	stream nextPutAll: ' : '.
	nativizer visitStatements: anSMessage arguments second statements.
	stream nextPut: $)
]

{ #category : #accessing }
JSSExpressionTranspiler >> inlinedMessage: anSMessage with: nativizer [
	| selector |
	selector := anSMessage selector.
	selector == ifTrueIfFalse
		ifTrue: [ ^self inline: anSMessage ifTrueIfFalse: true ].
	self ASSERT: false
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> literalAt: index [
	stream nextPutAll: 'literals'.
	self
		index: index
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> literals [
	^literals
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> loadEnvironmentFor: anInteger [
	"
	-1: inlined argument.
	 0: current env.
 	>0: index of env in current env. "

	anInteger = 0
		ifTrue: [ ^ self currentEnv ].
	anInteger = -1
		ifTrue: [ ^ self temps ].
	^ self currentEnv; index: anInteger
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> loadLiteral: anSLiteral [
	| value index |
	value := anSLiteral value.
	"runtime isSmallInteger: value"
	value isImmediate
		ifTrue: [ ^ self smallInteger: value value ].
	index := self addLiteral: value.
	self literalAt: index
]

{ #category : #accessing }
JSSExpressionTranspiler >> message: anSMessage super: aBoolean [
	| args index |
	args := anSMessage arguments.
	stream nextPutAll: 'evaluator.sendSuperToWith'.
	stream nextPutAll: '_('.
	index := self addLiteral: anSMessage.
	self literalAt: index.
	stream
		nextPutAll: ', ';
		print: aBoolean;
		nextPutAll: ', '.
	anSMessage receiver acceptVisitor: self.
	stream nextPutAll: ', ['.
	tabs := tabs + 1.
	args
		do: [ :code | 
			stream crtab: tabs.
			code acceptVisitor: self ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream nextPutAll: '])'.
	tabs := tabs - 1
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> message: anSMessage super: aBoolean with: nativizer [
	| args index |
	args := anSMessage arguments.
	stream nextPutAll: 'evaluator.sendSuperToWith'.
	stream nextPutAll: '_('.
	index := self addLiteral: anSMessage.
	self literalAt: index.
	stream
		nextPutAll: ', ';
		print: aBoolean;
		nextPutAll: ', '.
	anSMessage receiver acceptVisitor: nativizer.
	stream nextPutAll: ', ['.
	args
		do: [ :code | stream crtab: 2. code acceptVisitor: nativizer ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream nextPutAll: '])'
]

{ #category : #services }
JSSExpressionTranspiler >> nativize: anSMethod [
	self visitMethod: anSMethod.
	^ JSNativeCode new
		source: self result;
		literals: self literals
]

{ #category : #services }
JSSExpressionTranspiler >> receiver [
	stream nextPutAll: 'frame.__self'
]

{ #category : #services }
JSSExpressionTranspiler >> result [
	^stream contents
]

{ #category : #services }
JSSExpressionTranspiler >> return [
	stream nextPutAll: 'return '
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> returnSelf [
	stream
		nextPutAll: 'return frame.__self;';
		cr
]

{ #category : #accessing }
JSSExpressionTranspiler >> runtime: aPowertalkRuntime [
	| literal |
	runtime := aPowertalkRuntime.
	literal := runtime newInteger: 1.
	one := SLiteral new value: literal.
	plus := runtime symbolFromLocal: #+.
	greaterThan := runtime symbolFromLocal: #>.
	equalsEquals := runtime symbolFromLocal: #==.
	not := runtime symbolFromLocal: #not.
	ifTrue := runtime symbolFromLocal: #ifTrue:.
	ifFalse := runtime symbolFromLocal: #ifFalse:.
	ifTrueIfFalse := runtime symbolFromLocal: #ifTrue:ifFalse:.
	ifFalseIfTrue := runtime symbolFromLocal: #ifFalse:ifTrue:.
	ifNil := runtime symbolFromLocal: #ifNil:.
	ifNotNil := runtime symbolFromLocal: #ifNotNil:.
	ifNilIfNotNil := runtime symbolFromLocal: #ifNil:ifNotNil:.
	ifNotNilIfNil := runtime symbolFromLocal: #ifNotNil:ifNil:.
	repeat := runtime symbolFromLocal: #repeat.
	whileTrue := runtime symbolFromLocal: #whileTrue.
	whileFalse := runtime symbolFromLocal: #whileFalse.
	whileTrue_ := runtime symbolFromLocal: #whileTrue:.
	whileFalse_ := runtime symbolFromLocal: #whileFalse:.
	timesRepeat := runtime symbolFromLocal: #timesRepeat:.
	toDo := runtime symbolFromLocal: #to:do:.
	toByDo := runtime symbolFromLocal: #to:by:do:.
	andNot := runtime symbolFromLocal: #andNot:.
	orNot := runtime symbolFromLocal: #orNot:
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> smallInteger: value [
	stream
		nextPutAll: 'LMRSmallInteger.new().value_(';
		print: value;
		nextPut: $)
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> stackTemporaryAt: index [
	self temps; index: index

]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> stackTemporaryAt: index put: value [
	self
		temps;
		index: index;
		assign: value
]

{ #category : #services }
JSSExpressionTranspiler >> start [
	stream
		reset;
		nextPutAll: '(function (evaluator, frame, literals) {';
		crtab
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> statementEnd [
	stream nextPut: $;; cr
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> stream: aWriteStream [
stream := aWriteStream 
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> temporaryAt: index in: environmentIndex [
	environmentIndex ifNil: [ ^ self stackTemporaryAt: index ].
	self
		loadEnvironmentFor: environmentIndex;
		index: index
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> temporaryAt: index in: environmentIndex put: value [
	environmentIndex ifNil: [ ^ self stackTemporaryAt: index put: value].
	self
		loadEnvironmentFor: environmentIndex;
		index: index.
		stream nextPutAll: ' = '; nextPutAll: value
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> temps [
	stream
		nextPutAll: 'frame.temps'
]

{ #category : #accessing }
JSSExpressionTranspiler >> visitAssignment: anSAssignment [
	stream nextPutAll: '_cascade('.
	anSAssignment expression acceptVisitor: self.
	stream nextPutAll: ', (__result) => {'.
	anSAssignment assignees
		do:
			[ :identifier | identifier binding assign: '__result' within: self ]
		separatedBy: [ stream nextPutAll: '; ' ].
	stream nextPutAll: '})'
]

{ #category : #accessing }
JSSExpressionTranspiler >> visitBlock: anSBlock [
	| index |
	index := self addLiteral: anSBlock.
	stream nextPutAll: 'frame.captureClosure_('.
	self literalAt: index.
	stream nextPut: $)
]

{ #category : #accessing }
JSSExpressionTranspiler >> visitIdentifier: anSIdentifier [
	anSIdentifier binding valueWithin: self
]

{ #category : #accessing }
JSSExpressionTranspiler >> visitLiteral: anSLiteral [
	self loadLiteral: anSLiteral
]

{ #category : #accessing }
JSSExpressionTranspiler >> visitMessage: anSMessage [
	anSMessage isInlined
		ifTrue: [ self inlinedMessage: anSMessage with: self ]
		ifFalse: [ self message: anSMessage super: false ]
]

{ #category : #accessing }
JSSExpressionTranspiler >> visitMethod: anSMethod [
	| statements primitive index |
	self start.
	anSMethod pragma
		ifNotNil: [ primitive := evaluator primitiveFor: anSMethod primitive.
			stream nextPutAll: 'return '.
			index := self addLiteral: primitive.
			self literalAt: index.
			stream nextPutAll: '()'.
			^ self end ].
	statements := anSMethod statements.
	statements
		do: [ :node | 
			node acceptVisitor: self.
			self statementEnd ].
	(statements isEmpty orNot: [ statements last isReturn ])
		ifTrue: [ self returnSelf ].
	self end
]

{ #category : #visiting }
JSSExpressionTranspiler >> visitReturn: anSReturn [
	self return.
	anSReturn expression acceptVisitor: self
]

{ #category : #accessing }
JSSExpressionTranspiler >> visitStatements: aCollection [
		aCollection do: [ :sexpression | sexpression acceptVisitor: self ] separatedBy: [ stream nextPutAll: ', ' ]
]
