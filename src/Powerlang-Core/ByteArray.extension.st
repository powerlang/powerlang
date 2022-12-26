Extension { #name : #ByteArray }

{ #category : #'*Powerlang-Core' }
ByteArray >> asLittleEndianNegativeInteger [
	| integer |
	integer := LargeNegativeInteger new: self size.
	self withIndexDo: [ :value :i | integer at: i put: 255 - value ].
	^ integer - 1
]

{ #category : #'*Powerlang-Core' }
ByteArray >> asLittleEndianPositiveInteger [
	| integer |
	integer := LargePositiveInteger new: self size.
	self withIndexDo: [ :value :i | integer at: i put: value ].
	^ integer normalize
	

]
