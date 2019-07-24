Extension { #name : #ReadStream }

{ #category : #'*Powerlang-Core' }
ReadStream >> copyFrom: start to: stop [
	| pos result |
	pos := self position.
	self position: start - 1.
	result := self next: stop - start + 1.
	self position: pos.
	^result
]
