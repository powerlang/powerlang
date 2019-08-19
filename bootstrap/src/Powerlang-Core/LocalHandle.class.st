Class {
	#name : #LocalHandle,
	#superclass : #Object,
	#instVars : [
		'target',
		'runtime'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'as yet unclassified' }
LocalHandle >> = anObject [
	^anObject class = LocalHandle and: [target = anObject target]
]

{ #category : #'as yet unclassified' }
LocalHandle >> asLocalCollection [
	^target
]

{ #category : #'as yet unclassified' }
LocalHandle >> asLocalInteger [
	^ target
]

{ #category : #'as yet unclassified' }
LocalHandle >> asLocalString [
	^target asString
]

{ #category : #'as yet unclassified' }
LocalHandle >> getClass [
	| handle |
	handle := runtime handleOn: target class.
	^handle mirror asSpeciesMirror

]

{ #category : #'as yet unclassified' }
LocalHandle >> handleOn: anObject [
	^self class on: anObject within: runtime
]

{ #category : #'as yet unclassified' }
LocalHandle >> indexOf: varname for: aMirror [
	^target class indexOfSlot: varname asString
]

{ #category : #'as yet unclassified' }
LocalHandle >> isLocal [
	^true
]

{ #category : #'as yet unclassified' }
LocalHandle >> mirage [
	^MirageGate subjectOn: self
]

{ #category : #'as yet unclassified' }
LocalHandle >> mirror [
	^ObjectMirror on: self
]

{ #category : #'as yet unclassified' }
LocalHandle >> nilObject [
	^self handleOn: nil
]

{ #category : #'as yet unclassified' }
LocalHandle >> oid [
	^ target
]

{ #category : #'as yet unclassified' }
LocalHandle >> runtime [
	^runtime
]

{ #category : #'as yet unclassified' }
LocalHandle >> runtime: aRuntime [
	runtime := aRuntime
]

{ #category : #'as yet unclassified' }
LocalHandle >> size [
	^target basicSize + target class instSize
]

{ #category : #'as yet unclassified' }
LocalHandle >> slotAt: index [
	| slot |
	slot := target instVarAt: index.
	^self handleOn: slot
]

{ #category : #'as yet unclassified' }
LocalHandle >> target [
	^target
]

{ #category : #'as yet unclassified' }
LocalHandle >> target: anObject [
	target := anObject
]
