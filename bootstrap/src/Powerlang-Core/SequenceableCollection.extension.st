Extension { #name : #SequenceableCollection }

{ #category : #'*Powerlang-Core' }
SequenceableCollection >> beeCopyFrom: start [
	^self beeCopyFrom: start to: self size
]

{ #category : #'*Powerlang-Core' }
SequenceableCollection >> beeCopyFrom: start to: stop [
	| size copy |
	size := stop - start + 1 max: 0.
	copy := self species ofSize: size.
	^copy
		replaceFrom: 1
		to: size
		with: self
		startingAt: start
]
