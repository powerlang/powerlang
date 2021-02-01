Extension { #name : #ReadStream }

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
ReadStream >> peek: n [
	| pos safe data |
	pos := self position.
	safe := n min: self sizeToEnd.
	data := self next: safe.
	self position: pos.
	^data
]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
ReadStream >> prev [
	^self position > 0
		ifTrue: [self position: self position - 1; peek]
		ifFalse: [self error: 'read beyond start of stream']
]
