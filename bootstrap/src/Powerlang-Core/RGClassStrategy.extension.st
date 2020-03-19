Extension { #name : #RGClassStrategy }

{ #category : #'*Powerlang-Core' }
RGClassStrategy >> localPools [
	| values |
	values := self classVariables collect: [ :c | c propertyNamed: #value].
	^values select: [:v | v class = PoolDictionary ]
]
