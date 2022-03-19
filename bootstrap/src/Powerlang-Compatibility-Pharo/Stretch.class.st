Class {
	#name : #Stretch,
	#superclass : #Object,
	#instVars : [
		'start',
		'end'
	],
	#category : #'Powerlang-Compatibility-Pharo'
}

{ #category : #'instance creation' }
Stretch class >> from: start thru: end [
	^self new start: start; end: end
]

{ #category : #arithmetic }
Stretch >> + delta [
	delta isInteger ifTrue: [^start + delta thru: end + delta].
	delta isPoint ifTrue: [^start + delta x thru: end + delta y].
	^start + delta start thru: end + delta end
]

{ #category : #arithmetic }
Stretch >> - delta [
	^self + delta negated
]

{ #category : #arithmetic }
Stretch >> // anInteger [
	^start // anInteger thru: end // anInteger
]

{ #category : #comparing }
Stretch >> = aStretch [
	self class == aStretch class ifFalse: [^false].
	^start = aStretch start and: [end = aStretch end]
]

{ #category : #arithmetic }
Stretch >> center [
	^start + end // 2
]

{ #category : #arithmetic }
Stretch >> down: anInteger [
	^start thru: end + anInteger
]

{ #category : #accessing }
Stretch >> end [
	^end
]

{ #category : #accessing }
Stretch >> end: anInteger [
	end := anInteger
]

{ #category : #comparing }
Stretch >> hash [
	^start hashWith: end
]

{ #category : #testing }
Stretch >> includes: anInteger [
	^anInteger between: start and: end
]

{ #category : #testing }
Stretch >> intersects: aStretch [
	self isEmpty ifTrue: [^false].
	(aStretch includes: start) ifTrue: [^true].
	^aStretch includes: end
]

{ #category : #testing }
Stretch >> isEmpty [
	^end < start
]

{ #category : #arithmetic }
Stretch >> length [
	^end - start + 1
]

{ #category : #arithmetic }
Stretch >> mask [
	^(2 raisedTo: end) - (2 raisedTo: start - 1)
]

{ #category : #arithmetic }
Stretch >> max [
	^start max: end
]

{ #category : #arithmetic }
Stretch >> min [
	^start min: end
]

{ #category : #arithmetic }
Stretch >> negated [
	^start negated thru: end negated
]

{ #category : #testing }
Stretch >> notEmpty [
	^start <= end
]

{ #category : #printing }
Stretch >> printOn: aStream [
	aStream
		nextPutAll: start asString;
		nextPutAll: ' thru: ';
		nextPutAll: end asString
]

{ #category : #arithmetic }
Stretch >> shift [
	^(start - 1) negated
]

{ #category : #accessing }
Stretch >> start [
	^start
]

{ #category : #accessing }
Stretch >> start: anInteger [
	start := anInteger
]
