Extension { #name : #OrderedDictionary }

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
OrderedDictionary >> withIndexDo: aBlock [
	| i |
	i := 1.
	self do: [:each | 
		aBlock value: each value: i.
		i := i + 1]
]
