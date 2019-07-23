Class {
	#name : #PstInterpreter,
	#superclass : #SExpressionInterpreter,
	#classVars : [
		'underprimitives'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'class initialization' }
PstInterpreter class >> initialize [
	"
	self initialize
	"
	underprimitives := #(_basicAt: _basicAt:put: _byteAt: _byteAt:put: _smallSize _largeSize _isSmallInteger)
]

{ #category : #visiting }
PstInterpreter >> dispatch: message to: msgReceiver [
	^msgReceiver _gate dispatch: message from: self
]

{ #category : #visiting }
PstInterpreter >> dispatchSpecial: message [
	| selector mirror gate |
	selector := message selector.
	gate := message receiver _gate.
	mirror := gate mirror.
	selector == #_isLarge
		ifTrue: [^self mirageOnLocalHandle: mirror reflectsLargeObject].
	selector == #_smallSize
		ifTrue: [^self mirageOnLocalHandle: mirror smallSize].
	selector == #_largeSize
		ifTrue: [^self mirageOnLocalHandle: mirror largeSize].
	selector == #_basicFlags
		ifTrue: [^self mirageOnLocalHandle: mirror basicFlags].
	self ASSERT: false
]

{ #category : #visiting }
PstInterpreter >> homeOf: aClosure [ 
	^blocks at: aClosure ifAbsent: [parent homeOf: aClosure]
]

{ #category : #visiting }
PstInterpreter >> isSpecial: selector [
	^underprimitives includes: selector
]
