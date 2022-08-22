Class {
	#name : #JSMethodTranspiler,
	#superclass : #Object,
	#instVars : [
		'stream',
		'method',
		'tabs',
		'currentBlock',
		'imports',
		'classMethod'
	],
	#category : #'Powerlang-JS'
}

{ #category : #visiting }
JSMethodTranspiler class >> translateIdentifier: aString [
	aString = 'arguments'
		ifTrue: [ ^ '_arguments' ].
	aString = 'class'
		ifTrue: [ ^ '_class' ].
	aString = 'Dictionary'
		ifTrue: [ ^ 'Map' ].
	aString = 'IdentityDictionary'
		ifTrue: [ ^ 'Map' ].
		
	aString = 'OrderedCollection'
		ifTrue: [ ^ 'Array' ].
	aString = 'ByteArray'
		ifTrue: [ ^ 'Array' ].
	aString = 'BlockClosure'
		ifTrue: [ ^ 'Function' ].
	^ aString
]

{ #category : #visiting }
JSMethodTranspiler >> basicVisitMessageNode: anRBMessageNode [
	| recv parentheses selector signature |
	
	recv := anRBMessageNode receiver.
	parentheses := recv isBlock or: [ recv isLiteralNode ].
	parentheses
		ifTrue: [ stream nextPut: $( ].
	recv acceptVisitor: self.
	parentheses
		ifTrue: [ stream nextPut: $) ].
			selector := anRBMessageNode selector.
	signature := self transpileSelector: selector.
	stream
		nextPut: $.;
		nextPutAll: signature;
		nextPut: $(.
	anRBMessageNode arguments
		do: [ :arg | arg acceptVisitor: self ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream nextPut: $)
]

{ #category : #visiting }
JSMethodTranspiler >> imports [
	^ imports
]

{ #category : #initialization }
JSMethodTranspiler >> initialize [
	tabs := 2.
	stream := '' writeStream.
	imports := OrderedCollection new.
	classMethod  := false
]

{ #category : #visiting }
JSMethodTranspiler >> isSpecialSelector: selector [
	"	^ #(ifTrue: ifFalse: #ifTrue:ifFalse: whileTrue whileFalse whileTrue: whileFalse:)"

	^ #(#bitsAt: + - * / & | << >> bitAnd: bitOr: ) includes: selector	" #(ifTrue: ifFalse:) includes: selector"
]

{ #category : #accessing }
JSMethodTranspiler >> method [
	^ method
]

{ #category : #accessing }
JSMethodTranspiler >> method: aCompiledMethod [ 
	method := aCompiledMethod 
]

{ #category : #visiting }
JSMethodTranspiler >> methodHasNonLocal: anRBMethodNode [
	^anRBMethodNode blockNodes anySatisfy: [ :b | b returnCount > 0 ]
]

{ #category : #private }
JSMethodTranspiler >> methodSignatureFrom: anRBMethodNode [
	| selector translated |
	selector := self transpileSelector: anRBMethodNode selector.
	^ String
		streamContents: [ :s | 
			s
				nextPutAll: selector;
				nextPutAll: '('.
			anRBMethodNode arguments
				do: [ :arg | translated := self translateIdentifier: arg name. s nextPutAll: translated ]
				separatedBy: [ s nextPutAll: ', ' ].
			s nextPutAll: ')' ]
]

{ #category : #visiting }
JSMethodTranspiler >> result [
	^stream contents
]

{ #category : #accessing }
JSMethodTranspiler >> stream [
	^ stream
]

{ #category : #accessing }
JSMethodTranspiler >> stream: aWriteStream [
	stream := aWriteStream
]

{ #category : #accessing }
JSMethodTranspiler >> translateIdentifier: aString [
	^self class translateIdentifier: aString
]

{ #category : #accessing }
JSMethodTranspiler >> transpile [
	method ast
		acceptVisitor: self
]

{ #category : #private }
JSMethodTranspiler >> transpileBinarySelector: selector [
	selector = #/
		ifTrue: [ ^ #_slash ].
	selector = #, ifTrue: [ ^#_comma ].
	selector = #!= ifTrue: [ ^#_notEqual ].
	selector = #= ifTrue: [ ^#_equal ].
	selector = #== ifTrue: [ ^#_equalEqual ].
	selector = #+ ifTrue: [ ^#_plus ].
	selector = #- ifTrue: [ ^#_minus ].
	selector = #* ifTrue: [ ^#_times ].
	selector = #// 	ifTrue: [ ^ #_integerQuotient ].
	selector = #< ifTrue: [ ^#_lessThan ].
	selector = #<= ifTrue: [ ^#_lessEqualThan ].
	selector = #> ifTrue: [ ^#_greaterThan ].
	selector = #>= ifTrue: [ ^#_greaterEqualThan ].
	selector = #| ifTrue: [ ^#_or ].
	selector = #-> ifTrue: [ ^#_arrow ].
	selector = #<< ifTrue: [ ^#_shiftLeft ].
	selector = #>> ifTrue: [ ^#_shiftRight ].
	selector = #\\ ifTrue: [ ^#_modulo ].


	self ASSERT: false
]

{ #category : #accessing }
JSMethodTranspiler >> transpileClassMethod [
	classMethod := true.
	self transpile
]

{ #category : #private }
JSMethodTranspiler >> transpileSelector: selector [
	| first part |
	selector isBinary
		ifTrue: [ ^ self transpileBinarySelector: selector ].
	selector isKeyword
		ifFalse: [ ^ selector ].
	^ String
		streamContents: [ :s | 
			first := true.
			(selector findTokens: $:)
				do: [ :token | 
					part := first
						ifTrue: [ token ]
						ifFalse: [ token capitalized ].
					s nextPutAll: part.
					first := false ]. (selector last == $:) ifTrue: [s nextPut: $_]]
]

{ #category : #visiting }
JSMethodTranspiler >> visitArgumentNode: anRBArgumentNode [
	| translated |
	translated := self translateIdentifier: anRBArgumentNode name.
	stream nextPutAll: translated
]

{ #category : #visiting }
JSMethodTranspiler >> visitArrayNode: aRBArrayNode [ 
	stream nextPut: $[.
	aRBArrayNode statements do: [:s | s acceptVisitor: self] separatedBy: [ stream nextPutAll: ', ' ].
	stream nextPut: $]
]

{ #category : #visiting }
JSMethodTranspiler >> visitAssignmentNode: anRBAssignmentNode [ 
	anRBAssignmentNode variable acceptVisitor: self.
	stream nextPutAll: ' = '.
	anRBAssignmentNode value acceptVisitor: self
]

{ #category : #visiting }
JSMethodTranspiler >> visitBitsAt: message [
	| argument stretch offset |
	argument := message arguments first.
	self ASSERT: argument isGlobal.
	stretch := argument binding value.
	self ASSERT: stretch class == Stretch.
	stream nextPutAll: '(('. message receiver acceptVisitor: self.
	offset := stretch start - 1.
	offset > 0
		ifTrue: [ stream
				nextPutAll: ' >> ';
				print: offset ].
	stream
		nextPutAll: ') & 0x';
		nextPutAll: ((1 << stretch length) - 1) printStringHex;
		nextPutAll: ')'
]

{ #category : #visiting }
JSMethodTranspiler >> visitBlockNode: anRBBlockNode [
	| prev translated |
	prev := currentBlock.
	currentBlock := anRBBlockNode.
	tabs := tabs + 1.
	stream nextPutAll: '('.
	anRBBlockNode arguments
		do: [ :arg | 
			translated := self translateIdentifier: arg name.
			stream nextPutAll: translated ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream
		nextPutAll: ') => {';
		crtab: tabs.
	self visitBlockStatements: anRBBlockNode statements inline: false.
	tabs := tabs - 1.
	stream
		crtab: tabs;
		nextPut: $}.
	currentBlock := prev
]

{ #category : #visiting }
JSMethodTranspiler >> visitBlockStatements: statements inline: aBoolean [
	| last separator |
	statements isEmpty
		ifTrue: [ aBoolean
				ifFalse: [ stream nextPutAll: 'return ' ].
			^ stream nextPutAll: 'nil' ].
	separator := aBoolean ifTrue: [ $, ] ifFalse: [ $; ].
	statements allButLast
		do: [ :statement | 
			statement acceptVisitor: self.
			stream
				nextPut: separator;
				crtab: tabs ].
	last := statements last.
	(last isReturn or: [ aBoolean ])
		ifFalse: [ stream nextPutAll: 'return ' ].
	last acceptVisitor: self
]

{ #category : #visiting }
JSMethodTranspiler >> visitCascadeMessageNode: anRBMessageNode [
	| signature |
	signature := self transpileSelector: anRBMessageNode selector.
	stream
		nextPutAll: '_recv';
		nextPut: $.;
		nextPutAll: signature;
		nextPut: $(.
	anRBMessageNode arguments
		do: [ :arg | arg acceptVisitor: self ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream nextPut: $)
]

{ #category : #visiting }
JSMethodTranspiler >> visitCascadeNode: anRBCascadeNode [
	| receiver messages |
	messages := anRBCascadeNode messages.
	receiver := messages first receiver.
	stream nextPutAll: '_cascade('.
	receiver acceptVisitor: self.
	tabs := tabs + 1.
	stream
		nextPutAll: ', (_recv) => {';
		crtab: tabs.
	messages
		allButLastDo: [ :m | 
			self visitCascadeMessageNode: m.
			stream
				nextPut: $;;
				crtab: tabs ].
	stream nextPutAll: 'return '.
	self visitCascadeMessageNode: messages last.
	stream nextPut: $;.
	tabs := tabs - 1.
	stream nextPutAll: '})'
]

{ #category : #visiting }
JSMethodTranspiler >> visitGlobalNode: anRBGlobalNode [
	| translated binding |
	translated := self translateIdentifier: anRBGlobalNode name.
	binding := anRBGlobalNode binding .
	binding
	 isClassVariable
		ifTrue: [ binding isFromSharedPool ifFalse: [classMethod
				ifTrue: [ stream nextPutAll: 'this._' ]
				ifFalse: [ stream nextPutAll: 'this.constructor._' ]] ]
		ifFalse: [ imports add: translated ].
	stream nextPutAll: translated
]

{ #category : #visiting }
JSMethodTranspiler >> visitIf: message true: aBoolean [
	
	| block statements |
	block := message arguments first.
	block isBlock ifFalse: [^self basicVisitMessageNode: message]. 
	statements := block statements.
	statements size > 1 ifTrue: [ ^self basicVisitMessageNode: message ].
	stream nextPutAll: 'if ('.
	aBoolean ifFalse: [ stream nextPut: $! ].
	message receiver acceptVisitor: self.
	stream nextPut: $); crtab: tabs; nextPut: ${.
	tabs := tabs + 1.
	self visitBlockStatements: statements inline: true. 
	tabs := tabs - 1.
	stream nextPut: $}; crtab: tabs.

]

{ #category : #visiting }
JSMethodTranspiler >> visitInstanceVariableNode: anRBInstanceVariableNode [
	| translated |
	translated := self translateIdentifier: anRBInstanceVariableNode name.
	stream
		nextPutAll: 'this._';
		nextPutAll: translated
]

{ #category : #visiting }
JSMethodTranspiler >> visitLiteralArrayNode: anRBLiteralArrayNode [ 
	stream nextPut: $[.
	anRBLiteralArrayNode contents do: [:elem | elem acceptVisitor: self] separatedBy: [stream nextPutAll: ', '].
	stream nextPut: $]
]

{ #category : #visiting }
JSMethodTranspiler >> visitLiteralValueNode: anRBLiteralValueNode [
 	| v |
	v := anRBLiteralValueNode value.
	v ifNil: [ ^stream nextPutAll: 'nil' ].
	v isCharacter ifTrue: [^ stream nextPut: $"; nextPut: v; nextPut: $" ].
	STONJSON put: v onStream: stream
]

{ #category : #visiting }
JSMethodTranspiler >> visitMessageNode: anRBMessageNode [

	| selector |
	selector := anRBMessageNode selector.
	(self isSpecialSelector: selector)
		ifTrue: [ self visitSpecialMessage: anRBMessageNode  ]
		ifFalse: [ self basicVisitMessageNode: anRBMessageNode  ]
]

{ #category : #visiting }
JSMethodTranspiler >> visitMethodNode: anRBMethodNode [
	| signature nonlocal temps statements |
	signature := self methodSignatureFrom: anRBMethodNode.
	stream tab: 1.
	classMethod
		ifTrue: [ stream nextPutAll: 'static ' ].
	stream
		nextPutAll: signature;
		nextPutAll: ' {';
		crtab: tabs.
	temps := anRBMethodNode temporaries.
	temps isEmpty
		ifFalse: [ stream nextPutAll: 'let '.
			temps
				do: [ :t | stream nextPutAll: (self translateIdentifier: t name) ]
				separatedBy: [ stream nextPutAll: ', ' ].
			stream
				nextPut: $;;
				crtab: tabs ].
	nonlocal := self methodHasNonLocal: anRBMethodNode.
	nonlocal
		ifTrue: [ stream
				nextPutAll: 'const _home =  {};';
				crtab: tabs;
				nextPutAll: 'try {'.
			tabs := tabs + 1.
			stream crtab: tabs ].
	statements := anRBMethodNode statements.
	statements
		do: [ :s | 
			s acceptVisitor: self.
			stream nextPut: $; ]
		separatedBy: [ stream crtab: tabs ].
	statements isEmpty
		ifFalse: [ statements last isReturn
				ifFalse: [ stream
						crtab: tabs;
						nextPutAll: 'return this;' ] ].
	nonlocal
		ifTrue: [ tabs := tabs - 1.
			stream
				crtab: tabs;
				nextPutAll: '} catch(e) { if (e[0] == _home) return e[1]; else throw(e); }' ].
	stream
		crtab: 1;
		nextPutAll: '}';
		cr;
		cr
]

{ #category : #visiting }
JSMethodTranspiler >> visitReturnNode: anRBReturnNode [
	currentBlock
		ifNil: [ stream nextPutAll: 'return '.
			anRBReturnNode value acceptVisitor: self ]
		ifNotNil: [ stream nextPutAll: 'throw [_home, '.
			anRBReturnNode value acceptVisitor: self.
			stream nextPutAll: ']' ]
]

{ #category : #visiting }
JSMethodTranspiler >> visitSelfNode: aRBSelfNode [
	stream nextPutAll: 'this'
]

{ #category : #visiting }
JSMethodTranspiler >> visitSpecialIntegerBinaryMessage: message [
self visitSpecialIntegerBinaryMessage: message selector: message selector
]

{ #category : #visiting }
JSMethodTranspiler >> visitSpecialIntegerBinaryMessage: message selector: operand [
	stream nextPutAll: '('.
	message receiver acceptVisitor: self.
	stream nextPutAll: operand.
	message arguments first acceptVisitor: self.
	stream	nextPutAll: ')'
]

{ #category : #visiting }
JSMethodTranspiler >> visitSpecialMessage: message [
	| selector |
	selector := message selector.
	selector == #+ ifTrue: [ ^self visitSpecialIntegerBinaryMessage: message].
	selector == #- ifTrue: [ ^self visitSpecialIntegerBinaryMessage: message].
	selector == #* ifTrue: [ ^self visitSpecialIntegerBinaryMessage: message].
	selector == #/ ifTrue: [ ^self visitSpecialIntegerBinaryMessage: message].
	selector == #| ifTrue: [ ^self visitSpecialIntegerBinaryMessage: message].
	selector == #& ifTrue: [ ^self visitSpecialIntegerBinaryMessage: message].
	selector == #bitOr: ifTrue: [ ^self visitSpecialIntegerBinaryMessage: message selector: '|'].
	selector == #bitAnd: ifTrue: [ ^self visitSpecialIntegerBinaryMessage: message selector: '&'].
	selector == #bitsAt:
		ifTrue: [ ^ self visitBitsAt: message ].
	selector == #ifTrue:
		ifTrue: [ ^ self visitIf: message true: true ].
	selector == #ifFalse:
		ifTrue: [ self visitIf: message true: false ].
	selector == #ifTrue:ifFalse:
		ifTrue: [ self visitIfTrueIfFalse: message ].
	selector == #whileTrue
		ifTrue: [ self visitWhileTrue: message ].
	selector == #whileFalse
		ifTrue: [ self visitWhileFalse: message ].
	selector == #whileTrue:
		ifTrue: [ self visitWhileTrue_: message ].
	selector == #whileFalse:
		ifTrue: [ self visitWhileFalse_: message ]
]

{ #category : #visiting }
JSMethodTranspiler >> visitSuperNode: anRBSuperNode [ 
	stream nextPutAll: 'super'

]

{ #category : #visiting }
JSMethodTranspiler >> visitTemporaryNode: anRBTemporaryNode [
	| translated |
	translated := self translateIdentifier: anRBTemporaryNode name.

	stream nextPutAll: translated
]
