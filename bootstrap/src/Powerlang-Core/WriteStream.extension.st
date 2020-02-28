Extension { #name : #WriteStream }

{ #category : #'*Powerlang-Core' }
WriteStream >> peek [
	^self atEnd ifFalse: [collection at: position + 1]
]
