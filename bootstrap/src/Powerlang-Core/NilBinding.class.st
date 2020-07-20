Class {
	#name : #NilBinding,
	#superclass : #LiteralBinding,
	#category : #'Powerlang-Core-SCompiler-Bindings'
}

{ #category : #accessing }
NilBinding >> emitLoadAusing: anSExpressionNativizer [
	anSExpressionNativizer encodeLoadAwithNil
]

{ #category : #accessing }
NilBinding >> encodeUsing: anAstcodeEmitter [
	anAstcodeEmitter encodeNil
]

{ #category : #accessing }
NilBinding >> name [
	^'nil'
]

{ #category : #evaluating }
NilBinding >> value [
	^nil
]
