Class {
	#name : #LocalHandle,
	#superclass : #ObjectHandle,
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'as yet unclassified' }
LocalHandle >> asLocalCollection [
	^ oid
]

{ #category : #'as yet unclassified' }
LocalHandle >> asLocalInteger [
	^ oid
]

{ #category : #'as yet unclassified' }
LocalHandle >> asLocalString [
	^ oid asString
]

{ #category : #'as yet unclassified' }
LocalHandle >> getClass [
	| handle |
	handle := runtime handleOn: oid class.
	^ handle mirror asSpeciesMirror
]

{ #category : #'as yet unclassified' }
LocalHandle >> indexOf: varname for: aMirror [
	^ oid class indexOfSlot: varname asString
]

{ #category : #'as yet unclassified' }
LocalHandle >> isLocal [
	^true
]

{ #category : #'as yet unclassified' }
LocalHandle >> nilObject [
	^self handleOn: nil
]

{ #category : #'as yet unclassified' }
LocalHandle >> oid: objectId [
	oid != nil ifTrue: [ self halt ].
	objectId class = ByteString
		ifTrue: [ self halt ].
	oid := objectId
]

{ #category : #'as yet unclassified' }
LocalHandle >> size [
	^ oid basicSize + oid class instSize
]

{ #category : #'as yet unclassified' }
LocalHandle >> slotAt: index [
	| slot |
	slot := oid instVarAt: index.
	^ self handleOn: slot
]
