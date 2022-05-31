Class {
	#name : #JSMethodTranspiler,
	#superclass : #Object,
	#instVars : [
		'stream',
		'method',
		'tabs'
	],
	#category : #'Powerlang-JS'
}

{ #category : #initialization }
JSMethodTranspiler >> initialize [
	tabs := 2
]

{ #category : #accessing }
JSMethodTranspiler >> method [
	^ method
]

{ #category : #accessing }
JSMethodTranspiler >> method: aCompiledMethod [ 
	method := aCompiledMethod 
]

{ #category : #private }
JSMethodTranspiler >> methodSignatureFrom: anRBMethodNode [
	| selector |
	selector := self transpileSelector: anRBMethodNode selector.
	^ String
		streamContents: [ :s | 
			s nextPutAll: selector; nextPutAll: '('.
			anRBMethodNode arguments
				do: [ :arg | s nextPutAll: arg name ]
				separatedBy: [ s nextPutAll: ', ' ].
			s nextPutAll: ')' ]
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
					first := false ].
			]
]

{ #category : #visiting }
JSMethodTranspiler >> visitArgumentNode: anRBArgumentNode [ 
	stream nextPutAll: anRBArgumentNode name
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
JSMethodTranspiler >> visitBlockNode: anRBBlockNode [
	tabs := tabs + 1.
	stream nextPutAll: 'function ('.
	anRBBlockNode arguments
		do: [ :arg | stream nextPutAll: arg name ]
		separatedBy: [ stream nextPutAll: ', ' ].
	stream
		nextPutAll: ') {';
		crtab: tabs.
	anRBBlockNode statements
		do: [ :statement | 
			statement acceptVisitor: self.
			stream nextPut: $; ]
		separatedBy: [ stream crtab: tabs ].
	tabs := tabs - 1.
	stream
		crtab: tabs;
		nextPut: $}
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
	stream
		nextPut: $}
]

{ #category : #visiting }
JSMethodTranspiler >> visitGlobalNode: anRBGlobalNode [ 
	stream nextPutAll: anRBGlobalNode name.
]

{ #category : #visiting }
JSMethodTranspiler >> visitInstanceVariableNode: anRBInstanceVariableNode [ 
	stream nextPutAll: 'this.'; nextPutAll: anRBInstanceVariableNode name
]

{ #category : #visiting }
JSMethodTranspiler >> visitLiteralArrayNode: anRBLiteralArrayNode [ 
	stream nextPut: $[.
	anRBLiteralArrayNode contents do: [:elem | elem acceptVisitor: self] separatedBy: [stream nextPutAll: ', '].
	stream nextPut: $]
]

{ #category : #visiting }
JSMethodTranspiler >> visitLiteralValueNode: anRBLiteralValueNode [ 
	STON put: anRBLiteralValueNode value onStream: stream
]

{ #category : #visiting }
JSMethodTranspiler >> visitMessageNode: anRBMessageNode [
	| signature |
	anRBMessageNode receiver acceptVisitor: self.
	signature := self transpileSelector: anRBMessageNode selector.
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
JSMethodTranspiler >> visitMethodNode: anRBMethodNode [
	| signature |
	signature := self methodSignatureFrom: anRBMethodNode.
	stream
		tab: 1;
		nextPutAll: signature;
		nextPutAll: ' {';
		crtab: tabs.
	anRBMethodNode statements
		do: [ :s | 
			s acceptVisitor: self. stream nextPut: $;] separatedBy: [ 
			stream
				crtab: tabs ].
	stream
		crtab: 1;
		nextPutAll: '}';
		cr;
		cr
]

{ #category : #visiting }
JSMethodTranspiler >> visitReturnNode: anRBReturnNode [
	stream nextPutAll: 'return '.
	anRBReturnNode value acceptVisitor: self
]

{ #category : #visiting }
JSMethodTranspiler >> visitSelfNode: aRBSelfNode [ 
	stream nextPutAll: 'this'
]

{ #category : #visiting }
JSMethodTranspiler >> visitSuperNode: anRBSuperNode [ 
	stream nextPutAll: 'super'

]

{ #category : #visiting }
JSMethodTranspiler >> visitTemporaryNode: anRBTemporaryNode [ 
	stream nextPutAll: anRBTemporaryNode name
]
