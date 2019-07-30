Class {
	#name : #TrueBinding,
	#superclass : #LiteralBinding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #accessing }
TrueBinding >> encodeUsing: anAstcodeEmitter [
	anAstcodeEmitter encodeTrue
]

{ #category : #accessing }
TrueBinding >> name [
	^'true'
]

{ #category : #evaluating }
TrueBinding >> value [
	^true
]
