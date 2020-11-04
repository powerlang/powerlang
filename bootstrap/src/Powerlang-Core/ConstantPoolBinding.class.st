Class {
	#name : #ConstantPoolBinding,
	#superclass : #PoolVarBinding,
	#category : #'Powerlang-Core-SCompiler-Bindings'
}

{ #category : #testing }
ConstantPoolBinding >> canBeAssigned [
	^false
]

{ #category : #testing }
ConstantPoolBinding >> emitLoadAusing: anAstcodeEncoder [
	anAstcodeEncoder encodeLoadAwithConstPoolVar: association value
]

{ #category : #testing }
ConstantPoolBinding >> encodeUsing: anAstcodeEmitter [
	anAstcodeEmitter encodePoolConst: self literal
]

{ #category : #testing }
ConstantPoolBinding >> isConstantBinding [
	^true
]

{ #category : #testing }
ConstantPoolBinding >> literal [
	^association value
]
