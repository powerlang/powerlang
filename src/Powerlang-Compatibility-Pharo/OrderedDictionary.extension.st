Extension { #name : #OrderedDictionary }

{ #category : #'*Powerlang-Compatibility-Pharo' }
OrderedDictionary >> withIndexDo: aBlock [
	| i |
	i := 1.
	self do: [:each | 
		aBlock value: each value: i.
		i := i + 1]
]
