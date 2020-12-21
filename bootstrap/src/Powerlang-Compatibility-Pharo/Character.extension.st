Extension { #name : #Character }

{ #category : #'*Powerlang-Compatibility-Pharo' }
Character >> isHexDigit [
	^self isDigit or: [self between: $a and: $f] or: [self between: $A and: $F]
]
