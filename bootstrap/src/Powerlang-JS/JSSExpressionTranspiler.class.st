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
	stream
		nextPutAll: ' = ';
		print: value
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

{ #category : #services }
JSSExpressionTranspiler >> false [
	stream nextPutAll: 'evaluator._falseObj'
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
JSSExpressionTranspiler >> inline: anSMessage binaryWhile: aBoolean [
	"we put while in a lambda to be able to use it as a js expression"
	stream nextPutAll: '( () => {while ('.
	aBoolean
		ifTrue: [ stream nextPutAll: 'evaluator._trueObj===' ]
		ifFalse: [ stream nextPutAll: 'evaluator._falseObj===' ].
	stream nextPut: $(.
	self visitStatements: anSMessage receiver statements.
	stream nextPutAll: ')) {'.
	self visitStatements: anSMessage arguments first statements.
	stream nextPutAll: '} })()'
]

{ #category : #accessing }
JSSExpressionTranspiler >> inline: anSMessage ifTrue: aBoolean [
	stream nextPut: $(.
	aBoolean
		ifTrue: [ stream nextPutAll: 'evaluator._trueObj===' ]
		ifFalse: [ stream nextPutAll: 'evaluator._falseObj===' ].
	stream nextPut: $(.
	anSMessage receiver acceptVisitor: self.
	stream nextPutAll: ') ? ('.
	self visitStatements: anSMessage arguments first statements.
	stream nextPutAll: ') : evaluator._nilObj)'
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

{ #category : #accessing }
JSSExpressionTranspiler >> inlineToDo: anSMessage [
	"we put while in a lambda to be able to use it as a js expression"

	| compare cindex increment incindex args limit block ipos |
	compare := SMessage new selector: greaterThan.
	cindex := self addLiteral: compare.
	increment := SMessage new selector: plus.
	incindex := self addLiteral: increment.
	args := anSMessage arguments.
	limit := args first.
	block := args second.
	ipos := block inlinedArgs first.
	stream nextPutAll: '( () => { for ('.
	tabs := tabs + 1.
	stream crtab: tabs.
	self
		temps;
		index: ipos.
	stream nextPutAll: ' = '.
	anSMessage receiver acceptVisitor: self.
	stream
		nextPut: $;;
		crtab: tabs;
		nextPutAll: 'evaluator._falseObj===evaluator.sendSuperToWith_('.
	self literalAt: cindex.
	stream nextPutAll: ', false, '.
	self stackTemporaryAt: ipos.
	stream nextPutAll: ', [('.
	limit acceptVisitor: self.
	stream
		nextPutAll: ')]);';
		crtab: tabs.
	self
		temps;
		index: ipos.
	stream nextPutAll: ' = '.
	stream nextPutAll: 'evaluator.sendSuperToWith_('.
	self literalAt: incindex.
	stream nextPutAll: ', false,'.
	self stackTemporaryAt: ipos.
	stream nextPutAll: ', ['.
	self loadLiteral: one.
	stream
		nextPutAll: ']))';
		crtab: tabs - 1;
		nextPutAll: '{';
		crtab: tabs.
	self visitStatements: block statements.
	tabs := tabs - 1.
	stream
		crtab: tabs;
		nextPutAll: '}}) ()'
]

{ #category : #accessing }
JSSExpressionTranspiler >> inlinedMessage: anSMessage with: nativizer [
	| selector |
	selector := anSMessage selector.
	selector == ifTrueIfFalse
		ifTrue: [ ^ self inline: anSMessage ifTrueIfFalse: true ].
	selector == ifTrue
		ifTrue: [ ^ self inline: anSMessage ifTrue: true ].
	selector == ifFalse
		ifTrue: [ ^ self inline: anSMessage ifTrue: false ].
	selector == toDo
		ifTrue: [ ^ self inlineToDo: anSMessage ].
	selector == whileTrue
		ifTrue: [ ^ self inline: anSMessage unitaryWhile: true ].
	selector == whileFalse
		ifTrue: [ ^ self inline: anSMessage unitaryWhile: true ].
	selector == whileTrue_
		ifTrue: [ ^ self inline: anSMessage binaryWhile: true ].
	selector == whileFalse_
		ifTrue: [ ^ self inline: anSMessage binaryWhile: true ].
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
JSSExpressionTranspiler >> loadLiteral: value [
	| index |

	"runtime isSmallInteger: value"
	value isImmediate
		ifTrue: [ ^ self smallInteger: value value ].
	index := self addLiteral: value.
	self literalAt: index
]

{ #category : #'as yet unclassified' }
JSSExpressionTranspiler >> loadVMLiteral: value [
	| index |
	index := self addLiteral: value.
	self literalAt: index
]

{ #category : #accessing }
JSSExpressionTranspiler >> message: anSMessage super: aBoolean [
	| args |
	args := anSMessage arguments.
	stream nextPutAll: 'evaluator.sendSuperToWith'.
	stream nextPutAll: '_('.
	self loadVMLiteral: anSMessage.
	stream
		nextPutAll: ', ';
		print: aBoolean;
		nextPutAll: ', '.
	anSMessage receiver acceptVisitor: self.
	stream nextPutAll: ', ['.

	args
		do: [ :code | 
			code acceptVisitor: self ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream nextPutAll: '])'.

]

{ #category : #services }
JSSExpressionTranspiler >> nativize: anSMethod [
	self visitMethod: anSMethod.
	^ JSNativeCode new
		source: self result;
		literals: self literals
]

{ #category : #services }
JSSExpressionTranspiler >> nil [
	stream nextPutAll: 'evaluator._nilObj'
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
	stream return: [stream nextPutAll: 'frame.__self']
]

{ #category : #accessing }
JSSExpressionTranspiler >> runtime: aPowertalkRuntime [
	runtime := aPowertalkRuntime.
	one := runtime newInteger: 1.
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
	stream nextPutAll: 'frame._temporaries'
]

{ #category : #services }
JSSExpressionTranspiler >> true [
	stream nextPutAll: 'evaluator._trueObj'
]

{ #category : #accessing }
JSSExpressionTranspiler >> visitAssignment: anSAssignment [
	| result assignees |
	result := self collect: [ 	anSAssignment expression acceptVisitor: self ].
	assignees := anSAssignment assignees.
	assignees size = 1 ifTrue: [ 
		^assignees first binding assign: result within: self.
		 ].
	
	stream nextPutAll: '_cascade('.

	stream nextPutAll: ', (__result) => {'.
	assignees
		do: [ :identifier | identifier binding assign: '__result' within: self ]
		separatedBy: [ stream nextPutAll: '; ' ].
	stream nextPutAll: '})'
]

{ #category : #accessing }
JSSExpressionTranspiler >> visitBlock: anSBlock [
	stream nextPutAll: 'frame.captureClosure_('.
	self loadVMLiteral: anSBlock.
	stream nextPut: $)
]

{ #category : #accessing }
JSSExpressionTranspiler >> visitIdentifier: anSIdentifier [
	| binding |
	binding := anSIdentifier binding.
	binding isDynamic
		ifTrue: [ self loadVMLiteral: anSIdentifier.
			stream nextPutAll: '._binding.valueWithin_(frame)' ]
		ifFalse: [ binding valueWithin: self ]
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
	aCollection
		do: [ :sexpression | sexpression acceptVisitor: self ]
		separatedBy: [ stream nextPutAll: ','; crtab: tabs ]
]
