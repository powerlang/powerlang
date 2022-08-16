"
A JavascriptCodeGeneratorTest is a test class for testing the behavior of JavascriptCodeGenerator
"
Class {
	#name : #JSSExpressionTranspilerTest,
	#superclass : #TestCase,
	#category : #'Powerlang-JS'
}

{ #category : #tests }
JSSExpressionTranspilerTest >> test010emptyMethod [
	| code |
	code := self transpile: 'foo'.
	self
		assert:
			code
				=
					'function (evaluator, frame, literals) {
	return frame.self;
}
'
]

{ #category : #tests }
JSSExpressionTranspilerTest >> test020returnSelf [
	| code |
	code := self transpile: 'foo ^self'.
	self
		assert:
			code
				=
					'function (evaluator, frame, literals) {
	return frame.self;
}
'
]

{ #category : #tests }
JSSExpressionTranspilerTest >> test030returnOne [
	| code |
	code := self transpile: 'foo ^1'.
	self
		assert:
			code
				=
					'function (evaluator, frame, literals) {
	return LMRSmallInteger.new().value_(1);
}
'
]

{ #category : #tests }
JSSExpressionTranspilerTest >> test031returnArgument [
	| code |
	code := self transpile: 'foo: arg ^arg'.
	self
		assert:
			code
				=
					'function (evaluator, frame, literals) {
	return frame.args[0];
}
'
]

{ #category : #tests }
JSSExpressionTranspilerTest >> test032returnTemporary [
	| code |
	code := self transpile: 'foo  | temp | ^temp'.
	self
		assert:
			code
				=
					'function (evaluator, frame, literals) {
	return frame.temps[0];
}
'
]

{ #category : #tests }
JSSExpressionTranspilerTest >> test040returnOnePlusOne [
	| code |
	code := self transpile: 'foo ^1+1'.
	self
		assert:
			code
				=
					'function (evaluator, frame, literals) {
	return evaluator.sendSuperWith_(literals[0], false, LMRSmallInteger.new().value_(1), LMRSmallInteger.new().value_(1));
}
'
]

{ #category : #tests }
JSSExpressionTranspilerTest >> transpile: aString [
	| method |
	method := SCompiler new compile: aString.
	^ (JSSExpressionTranspiler new
				nativize: method sexpressions) source
]
