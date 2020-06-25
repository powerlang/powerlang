Extension { #name : #Object }

{ #category : #'*Powerlang-Core' }
Object >> != anObject [
		^ self ~= anObject
]

{ #category : #'*Powerlang-Core' }
Object >> ASSERT: aBoolean [
	self assert: aBoolean
]

{ #category : #'*Powerlang-Core' }
Object class >> disableCode: aBlock [
	"the block has been disabled"
]

{ #category : #'*Powerlang-Core' }
Object >> evaluate [
	^self
]

{ #category : #'*Powerlang-Core' }
Object >> evaluateWith: anObject [
	^self evaluateWithArguments: {anObject}
]

{ #category : #'*Powerlang-Core' }
Object >> evaluateWithArguments: anArray [
	^self evaluate
]

{ #category : #'*Powerlang-Core' }
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

{ #category : #'*Powerlang-Core' }
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

{ #category : #'*Powerlang-Core' }
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

{ #category : #'*Powerlang-Core' }
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

{ #category : #'*Powerlang-Core' }
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

{ #category : #'*Powerlang-Core' }
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

{ #category : #'*Powerlang-Core' }
Object >> isEmptyOrNil [
	^false
]

{ #category : #'*Powerlang-Core-OCompiler' }
Object >> isInstruction [
	^false
]

{ #category : #'*Powerlang-Core' }
Object >> isSmallInteger [
	^false
]

{ #category : #'*Powerlang-Core' }
Object >> isSpecies [
	^false
]
