Class {
	#name : #IterativeTreeEvaluationContext,
	#superclass : #IterativeEvaluationContext,
	#category : #'Powerlang-Core-Execution'
}

{ #category : #'instance creation' }
IterativeTreeEvaluationContext class >> initialize [
	"
	self initialize
	"

	Undermessages := #(_basicAt: #_basicAt:put: _bitShiftLeft: _byteAt: #_byteAt:put: _smallSize _largeSize _isSmallInteger _basicHash _basicHash: _smallIntegerByteAt: _uShortAtOffset: _uShortAtOffset:put:)
]

{ #category : #'instance creation' }
IterativeTreeEvaluationContext class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #visiting }
IterativeTreeEvaluationContext >> beBlock [
	super beBlock.
	work := OrderedCollection new: 5.

]

{ #category : #visiting }
IterativeTreeEvaluationContext >> hasWork [
	^work notEmpty
]

{ #category : #visiting }
IterativeTreeEvaluationContext >> initialize [
	super initialize.
	work := OrderedCollection new: 5
]

{ #category : #visiting }
IterativeTreeEvaluationContext >> popOperation [
	^ work removeLast
]

{ #category : #visiting }
IterativeTreeEvaluationContext >> pushOperation: anSExpression [
	work add: anSExpression
]

{ #category : #visiting }
IterativeTreeEvaluationContext >> restart [
	super restart.
		work reset.

]
