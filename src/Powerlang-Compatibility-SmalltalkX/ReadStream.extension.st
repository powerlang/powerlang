Extension { #name : #ReadStream }

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
ReadStream >> peek: n [
	| pos data |
	pos := self position.
	data := self nextAvailable: n.
	self position: pos.
	^data

]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
ReadStream >> prev [
	^self position > 0
		ifTrue: [self position: self position - 1; peek]
		ifFalse: [self error: 'read beyond start of stream']
]
