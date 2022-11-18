Extension { #name : #ZnCharacterWriteStream }

{ #category : #'*Powerlang-JS' }
ZnCharacterWriteStream >> crtab: anInteger [
	self
		cr;
		tab: anInteger
]

{ #category : #'*Powerlang-JS' }
ZnCharacterWriteStream >> tab: anInteger [
	anInteger timesRepeat: [ self tab]
]
