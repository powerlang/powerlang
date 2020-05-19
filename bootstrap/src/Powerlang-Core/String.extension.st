Extension { #name : #String }

{ #category : #'*Powerlang-Core' }
String >> arity [
	^self numArgs
]

{ #category : #'*Powerlang-Core' }
String >> existingSymbol [
	^Symbol findInterned: self
]

{ #category : #'*Powerlang-Core' }
String >> includesString: aString [
	^ self includesSubstring: aString
]

{ #category : #'*Powerlang-Core' }
String >> indexOfString: aString from: start to: stop [
	| n limit base i |
	n := aString size.
	limit := stop - n.
	base := start - 1.
	i := 1.
	[
		base > limit ifTrue: [^0].
		i <= n]
		whileTrue: [
			i := (self at: base + i) = (aString at: i) ifTrue: [i + 1] ifFalse: [
				base := base + 1.
				1]].
	^i > 1 ifTrue: [base + 1] ifFalse: [0]


]

{ #category : #'*Powerlang-Core' }
String >> indexOfSubcollection: aCollection startingAt: anInteger [
	| m n i first |
	m := aCollection size.
	m = 0 ifTrue: [^0].
	n := self size - m + 1.
	i := anInteger.
	first := aCollection at: 1.
	[i <= n] whileTrue: [| j |
		(self at: i) = first ifTrue: [
			j := 2.
			[j <= m and: [(self at: i + j - 1) = (aCollection at: j)]]
				whileTrue: [j := j + 1].
			j > m ifTrue: [^i]].
		i := i + 1].
	^0
]

{ #category : #'*Powerlang-Core' }
String >> reduced [
	^self
]

{ #category : #'*Powerlang-Core' }
String >> replaceAllSubstrings: aString with: anotherString [
	| string strm index fragment n |
	string := aString asString.
	string isEmpty ifTrue: [^self].
	index := self indexOfSubcollection: string startingAt: 1.
	index = 0 ifTrue: [^self].
	strm := self asString class new writeStream.
	fragment := self copyFrom: 1 to: index - 1.
	strm nextPutAll: fragment.
	n := string size.
	[index > 0] whileTrue: [| next limit |
		next := self indexOfString: string from: index + n to: self size.
		limit := next = 0 ifTrue: [self size + 1] ifFalse: [next].
		fragment := self copyFrom: index + n - 1 + 1 to: limit - 1.
		strm nextPutAll: anotherString; nextPutAll: fragment.
		index := next].
	^strm contents
]

{ #category : #'*Powerlang-Core' }
String >> trimBlanks [
	^self trim
]

{ #category : #'*Powerlang-Core' }
String >> withArticle [
	| article |
	article := self first isVowel ifTrue: ['an'] ifFalse: ['a'].
	^article , ' ' , self
]
