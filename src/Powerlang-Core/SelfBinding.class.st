Class {
	#name : #SelfBinding,
	#superclass : #Binding,
	#category : #'Powerlang-Core-SCompiler-Bindings'
}

{ #category : #actions }
SelfBinding >> beReferencedFrom: aScriptNode [
	aScriptNode useSelf
]

{ #category : #testing }
SelfBinding >> canBeAssigned [
	^false
]

{ #category : #testing }
SelfBinding >> encodeUsing: anAstcodeEmitter [
	anAstcodeEmitter encodeSelf
]

{ #category : #testing }
SelfBinding >> isSelf [
	^true
]

{ #category : #accessing }
SelfBinding >> name [
	^'self'
]
