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

{ #category : #'*Powerlang-Core' }
ReadStream >> peek: n [
	| pos safe data |
	pos := self position.
	safe := n min: self sizeToEnd.
	data := self next: safe.
	self position: pos.
	^data
]

{ #category : #'*Powerlang-Core' }
ReadStream >> prev [
	^self position > 0
		ifTrue: [self position: self position - 1; peek]
		ifFalse: [self error: 'read beyond start of stream']
]
