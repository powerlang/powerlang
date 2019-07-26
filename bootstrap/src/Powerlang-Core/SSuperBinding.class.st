Class {
	#name : #SSuperBinding,
	#superclass : #SSelfBinding,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #testing }
SSuperBinding >> isSelf [
	^false
]

{ #category : #testing }
SSuperBinding >> isSuper [
	^true
]
