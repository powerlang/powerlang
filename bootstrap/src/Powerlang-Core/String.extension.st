Extension { #name : #String }

{ #category : #'*Powerlang-Core' }
String >> withArticle [
	| article |
	article := self first isVowel ifTrue: ['an'] ifFalse: ['a'].
	^article , ' ' , self
]
