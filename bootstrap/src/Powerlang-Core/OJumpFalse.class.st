"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OJumpFalse,
	#superclass : #OJumpConditional,
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OJumpFalse >> basicAcceptVisitor: aVisitor [
	^aVisitor visitJumpFalse: self
]

{ #category : #unclassified }
OJumpFalse >> basicPrintString [
	^'[jump false ' , variable primitivePrintString , ' to ' , target name
		, ' or fall to '
		, implicitTarget name
		, ']'
]

{ #category : #unclassified }
OJumpFalse >> isJumpFalse [
	^true
]

{ #category : #unclassified }
OJumpFalse >> isJumpTrue [
	^false
]

{ #category : #unclassified }
OJumpFalse >> primitivePrintString [
	^'{jump false}'
]

{ #category : #unclassified }
OJumpFalse >> printStringUsing: names [
	^'jump false ' , (names at: variable ifAbsent: ['missing']) , ' to '
		, (names at: target ifAbsent: 'missing')
		, ' or fall to '
		, (names at: implicitTarget ifAbsent: 'missing')
]
