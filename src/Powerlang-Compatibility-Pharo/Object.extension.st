Extension { #name : #Object }

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> != anObject [
		^ self ~= anObject
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> ASSERT: aBoolean [
	self assert: aBoolean
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> DENY: aBoolean [
	self ASSERT: aBoolean not
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object class >> disableCode: aBlock [
	"the block has been disabled"
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> evaluate [
	^self
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> evaluateWithArguments: anArray [
	^self evaluate
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> hashWith: a [
	^self
		hashedWith: a
		with: nil
		with: nil
		with: nil
		with: nil
		with: nil
		count: 2
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> hashWith: a with: b [
	^ self
		hashedWith: a
		with: b
		with: nil
		with: nil
		with: nil
		with: nil
		count: 3
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> hashWith: a with: b with: c [
	^self
		hashedWith: a
		with: b
		with: c
		with: nil
		with: nil
		with: nil
		count: 4

]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> hashWith: a with: b with: c with: d [
	^ self
		hashedWith: a
		with: b
		with: c
		with: d
		with: nil
		with: nil
		count: 5
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> hashWith: a with: b with: c with: d with: e [
	^ self
		hashedWith: a
		with: b
		with: c
		with: d
		with: e
		with: nil
		count: 6
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> hashedWith: a
with: b
with: c
with: d
with: e
with: f
count: n [
	| hash |
	hash := n hashMultiply bitXor: self hash.
	hash := hash hashMultiply bitXor: a hash.
	n = 2 ifTrue: [^hash].
	hash := hash hashMultiply bitXor: b hash.
	n = 3 ifTrue: [^hash].
	hash := hash hashMultiply bitXor: c hash.
	n = 4 ifTrue: [^hash].
	hash := hash hashMultiply bitXor: d hash.
	n = 5 ifTrue: [^hash].
	hash := hash hashMultiply bitXor: e hash.
	n = 6 ifTrue: [^hash].
	hash := hash hashMultiply bitXor: f hash.
	n = 7 ifTrue: [^hash].
	self error: 'Invalid argument count'
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> isBoolean [
	^false
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> isEmptyOrNil [
	^false
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> isSmallInteger [
	^false
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> isSpecies [
	^false
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Object >> primitivePrintString [
	^self printString
]
