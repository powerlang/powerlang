Extension { #name : #String }

{ #category : #'*Powerlang-PST' }
String >> withArticle [
	| article |
	article := self first isVowel ifTrue: ['an'] ifFalse: ['a'].
	^article , ' ' , self
]
