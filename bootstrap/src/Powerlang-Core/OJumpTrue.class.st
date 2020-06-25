"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OJumpTrue,
	#superclass : #OJumpConditional,
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OJumpTrue >> basicAcceptVisitor: aVisitor [
	^aVisitor visitJumpTrue: self
]

{ #category : #unclassified }
OJumpTrue >> basicPrintString [
	^'[jump true ' , variable primitivePrintString , ' to ' , target name
		, ' or fall to '
		, implicitTarget name
		, ']'
]

{ #category : #unclassified }
OJumpTrue >> isJumpFalse [
	^false
]

{ #category : #unclassified }
OJumpTrue >> isJumpTrue [
	^true
]

{ #category : #unclassified }
OJumpTrue >> primitivePrintString [
	^'{jump true}'
]

{ #category : #printing }
OJumpTrue >> printStringUsing: names [
	^'jump true ' , (names at: variable) , ' to ' , (names at: target)
		, ' or fall to '
		, (names at: implicitTarget)
]
