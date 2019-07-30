Extension { #name : #String }

{ #category : #'*Powerlang-Core' }
String >> existingSymbol [
	^Symbol findInterned: self
]

{ #category : #'*Powerlang-Core' }
String >> reduced [
	^self
]

{ #category : #'*Powerlang-Core' }
String >> withArticle [
	| article |
	article := self first isVowel ifTrue: ['an'] ifFalse: ['a'].
	^article , ' ' , self
]
