Extension { #name : #OrderedDictionary }

{ #category : #'*Powerlang-Core' }
OrderedDictionary >> withIndexDo: aBlock [
	| i |
	i := 1.
	self do: [:each | 
		aBlock value: each value: i.
		i := i + 1]
]
