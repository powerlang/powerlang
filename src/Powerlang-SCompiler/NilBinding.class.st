Class {
	#name : #NilBinding,
	#superclass : #LiteralBinding,
	#category : #'Powerlang-SCompiler-Bindings'
}

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
