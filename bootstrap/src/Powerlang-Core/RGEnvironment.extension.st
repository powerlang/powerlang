Extension { #name : #RGEnvironment }

{ #category : #'*Powerlang-Core' }
RGEnvironment >> associationAt: key ifAbsent: block [
	| assoc |
	
	assoc := self bindingOf: key.
	assoc isNil ifTrue:[ ^ block value ].
	^assoc 

]
