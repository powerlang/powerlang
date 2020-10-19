Extension { #name : #Dictionary }

{ #category : #'*Powerlang-Core' }
Dictionary >> removeAllSuchThat: aBlock [
	"Evaluate aBlock for each element and remove all that elements from
	the receiver for that aBlock evaluates to true.  Use a copy to enumerate 
	collections whose order changes when an element is removed (i.e. Sets)."
	self copy
		keysAndValuesDo: [:key :each | (aBlock evaluateWith: each)
			ifTrue: [self removeKey: key]]
]
