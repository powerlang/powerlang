Class {
	#name : #AstcodeTest,
	#superclass : #TestCase,
	#instVars : [
		'method',
		'gdb',
		'memory'
	],
	#pools : [
		'AstBindingTypes',
		'AstNodeTypes'
	],
	#category : #'Powerlang-TestsFailing-SExpressions'
}

{ #category : #private }
AstcodeTest >> compile: source in: aSpecies [
	^SCompiler compile: source in: aSpecies
]

{ #category : #private }
AstcodeTest >> connectGdb [
	gdb := RemoteGDBSession host: '192.168.1.64' port: 7000
]

{ #category : #private }
AstcodeTest >> createRAM [
	memory := RemoteRAM gdb: gdb.
	"memory shmemSize: 20*1024*1024."
]

{ #category : #private }
AstcodeTest >> decode: anArray of: aCompiledMethod [
	| decoder |
	decoder := AstcodeDecoder new
		stream: anArray readStream;
		method: aCompiledMethod.
	^decoder decodeMethod
]

{ #category : #private }
AstcodeTest >> encode: source [
	^self encode: source in: UndefinedObject
]

{ #category : #private }
AstcodeTest >> encode: source in: aSpecies [
	| ring compiler |
	ring := VirtualSmalltalkImage kernelSpec bindingOf: aSpecies name.
	compiler := SCompiler forClass: ring value.
	method := compiler compile: source.
	^ method astcodes
]

{ #category : #private }
AstcodeTest >> newNativizer [
	| bootstrapper |
	bootstrapper := KernelSegmentBuilder new
		initialize64BitImage;
		generateModule;
		bootstrapModule;
		initializeNativizer.
	^ bootstrapper nativizer completeInitialization
]

{ #category : #private }
AstcodeTest >> test010emptyMethod [
	| astcodes root |
	astcodes := self encode: 'm'.
	self assert: astcodes = {MethodId}.
	root := self decode: astcodes of: method.
	self assert: root isMethod; assert: root statements isEmpty
]

{ #category : #private }
AstcodeTest >> test020encodeFalse [
	| astcodes root identifier |
	astcodes := self encode: 'm false'.
	self assert: astcodes = {MethodId. {IdentifierId. FalseId}}.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size = 1.
	identifier := root statements first.
	self
		assert: identifier isVariable;
		assert: identifier binding isLiteral;
		assert: identifier binding value = false
]

{ #category : #private }
AstcodeTest >> test020encodeNil [
	| astcodes root identifier |
	astcodes := self encode: 'm nil'.
	self assert: astcodes = {MethodId. {IdentifierId. NilId}}.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size = 1.
	identifier := root statements first.
	self
		assert: identifier isVariable;
		assert: identifier binding isLiteral;
		assert: identifier binding value = nil
]

{ #category : #private }
AstcodeTest >> test020encodeSelf [
	| astcodes root identifier |
	astcodes := self encode: 'm self'.
	self assert: astcodes = {MethodId. {IdentifierId. SelfId}}.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size = 1.
	identifier := root statements first.
	self assert: identifier isVariable; assert: identifier binding isSelf
]

{ #category : #private }
AstcodeTest >> test020encodeTrue [
	| astcodes root identifier |
	astcodes := self encode: 'm true'.
	self assert: astcodes = {MethodId. {IdentifierId. TrueId}}.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size = 1.
	identifier := root statements first.
	self
		assert: identifier isVariable;
		assert: identifier binding isLiteral;
		assert: identifier binding value = true
]

{ #category : #private }
AstcodeTest >> test021encodeClassVar [
	| astcodes root identifier |
	astcodes := self encode: 'm Flags' in: Class.
	self assert: astcodes = {MethodId. {IdentifierId. ClassVarId. 1}}.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size = 1.
	identifier := root statements first.
	self
		assert: identifier isVariable;
		assert: identifier binding isClassVar;
		assert: identifier binding association class = Association;
		assert: identifier binding association key = 'Flags';
		assert: identifier binding association value class = PoolDictionary
]

{ #category : #private }
AstcodeTest >> test021encodeInstVar [
	| astcodes root identifier |
	astcodes := self encode: 'm name' in: Class.
	self assert: astcodes = {MethodId. {IdentifierId. InstVarId. 6}}.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size = 1.
	identifier := root statements first.
	self
		assert: identifier isVariable;
		assert: identifier binding isInstVar;
		assert: identifier binding index = 6
]

{ #category : #private }
AstcodeTest >> test021encodePoolVar [
	| astcodes root identifier |
	astcodes := self encode: 'm Pointers' in: Class.
	self assert: astcodes = {MethodId. {IdentifierId. PoolVarId. 1}}.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size = 1.
	identifier := root statements first.
	self
		assert: identifier isVariable;
		assert: identifier binding isPoolVar;
		assert: identifier binding association class = Association;
		assert: identifier binding association key = 'Pointers';
		assert: identifier binding association value = 16r200
]

{ #category : #private }
AstcodeTest >> test022encodeReturn [
	| astcodes root return identifier |
	astcodes := self encode: 'm ^self'.
	self assert: astcodes = {MethodId. {ReturnId. true. {IdentifierId. SelfId}}}.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size = 1.
	return := root statements first.
	self assert: return isReturn.
	identifier := return expression.
	self assert: identifier isVariable; assert: identifier binding isSelf
]

{ #category : #private }
AstcodeTest >> test023encodeClass [
	| astcodes root return identifier |
	astcodes := self encode: 'm ^Array'.
	self
		assert: astcodes
			= {MethodId. {ReturnId. true. {IdentifierId. GlobalClassId. 1}}}.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size = 1.
	return := root statements first.
	self assert: return isReturn.
	identifier := return expression.
	self
		assert: identifier isVariable;
		assert: identifier binding isClassBinding;
		assert: identifier binding association key = #Array;
		assert: identifier binding association value = Array
]

{ #category : #private }
AstcodeTest >> test024encodeLiteral [
	| astcodes root literal |
	astcodes := self encode: 'm #foo'.
	self assert: astcodes = {MethodId. {LiteralId. 1}}.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size = 1.
	literal := root statements first.
	self
		assert: literal isLiteral;
		assert: literal value = #foo
]

{ #category : #private }
AstcodeTest >> test025encodeReturn42 [
	| astcodes root ret |
	astcodes := self encode: 'm ^42'.
	self assert: astcodes = {MethodId. {ReturnId. true. {LiteralId. 0. 42}}}.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size = 1.
	ret := root statements first.
	self
		assert: ret isReturn;
		assert: ret expression value = 42
]

{ #category : #private }
AstcodeTest >> test030encodeUnaryMessage [
	| astcodes root return message identifier |
	astcodes := self encode: 'm ^self foo'.
	self
		assert: astcodes
			= {MethodId. {ReturnId. true. {MessageId. 1. {IdentifierId. SelfId}}}}.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size = 1.
	return := root statements first.
	self assert: return isReturn.
	message := return expression.
	self assert: message isMessage.
	identifier := message receiver.
	self
		assert: message arguments isEmpty;
		assert: identifier isVariable;
		assert: identifier binding isSelf
]

{ #category : #private }
AstcodeTest >> test035encodeBinaryMessage [
	| astcodes root return message receiver argument |
	astcodes := self encode: 'm ^self foo: true'.
	self
		assert: astcodes
			= {MethodId. {ReturnId. true. {MessageId. 1. {IdentifierId. SelfId}. {IdentifierId. TrueId}}}}.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size = 1.
	return := root statements first.
	self assert: return isReturn.
	message := return expression.
	self assert: message isMessage.
	receiver := message receiver.
	argument := message arguments first.
	self
		assert: receiver isVariable;
		assert: receiver binding isSelf;
		assert: argument isVariable;
		assert: argument binding isLiteral;
		assert: argument binding value = true
]

{ #category : #private }
AstcodeTest >> test036encodeTernaryMessage [
	| astcodes root return message receiver arg1 arg2 |
	astcodes := self encode: 'm ^self foo: true bar: false'.
	self
		assert: astcodes = {MethodId. {ReturnId. true. {MessageId. 1.
					{IdentifierId. SelfId}.
					{IdentifierId. TrueId}.
					{IdentifierId. FalseId}}}}.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size = 1.
	return := root statements first.
	self assert: return isReturn.
	message := return expression.
	self assert: message isMessage.
	receiver := message receiver.
	arg1 := message arguments first.
	arg2 := message arguments second.
	self
		assert: receiver isVariable;
		assert: receiver binding isSelf;
		assert: arg1 isVariable;
		assert: arg1 binding isLiteral;
		assert: arg1 binding value = true;
		assert: arg2 isVariable;
		assert: arg2 binding isLiteral;
		assert: arg2 binding value = false
]

{ #category : #private }
AstcodeTest >> test050instVarAssignment [
	| astcodes root assignment assignee expression |
	astcodes := self encode: 'm name := true' in: Class.
	self
		assert: astcodes
			= {MethodId. {AssignmentId. {IdentifierId. InstVarId. 6}. {IdentifierId. TrueId}}}.
	root := self decode: astcodes of: method.
	self
		assert: root isMethod;
		assert: root statements size = 1.
	assignment := root statements first.
	self
		assert: assignment isAssignment;
		assert: assignment assignees size = 1.
	assignee := assignment assignees first.
	expression := assignment expression.
	self
		assert: assignee isVariable;
		assert: assignee binding isInstVar;
		assert: assignee binding index = 6;
		assert: expression isVariable;
		assert: expression binding isLiteral;
		assert: expression binding value = true
]

{ #category : #private }
AstcodeTest >> test100nativizeReturn42 [
	| astcodes root nativizer |
	astcodes := self encode: 'm ^42'.
	nativizer := self newNativizer halt.

	nativizer nativize: method
]

{ #category : #private }
AstcodeTest >> test200runReturn42 [
	| astcodes nativizer nc wherePC |
	self
		connectGdb;
		createRAM.
	astcodes := self encode: 'm ^42'.
	nativizer := self newNativizer.
	nc := (nativizer nativize: method) nativeCode.
	self halt.
	gdb c.
	wherePC := (gdb getRegister: 'pc') + 4.	"advance past the int3"
	gdb setRegister: 'pc' to: wherePC.
	memory writeBytes: nc code toAddr: wherePC.
	"step through the mov rax,0x55"
	gdb s.
	self assert: (gdb getRegister: 'r1') equals: (42 << 1) + 1.
	"step through the mov rsi,QWORD PTR [rbp-0x8]"
	gdb s.
	self assert: (gdb getRegister: 'rsi') equals: 16r5555555555555555.
	"step through the mov rbx,QWORD PTR [rbp-0x10]"
	gdb s.
	self assert: (gdb getRegister: 'rbx') equals: 16r6666666666666666
]
