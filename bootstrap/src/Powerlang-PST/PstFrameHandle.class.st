Class {
	#name : #PstFrameHandle,
	#superclass : #Handle,
	#instVars : [
		'frame'
	],
	#category : #'Powerlang-PST-Metaphysics'
}

{ #category : #'as yet unclassified' }
PstFrameHandle class >> on: frame within: runtime [
	^self new frame: frame; runtime: runtime
]

{ #category : #accessing }
PstFrameHandle >> currentIp [
	^frame currentIp
]

{ #category : #accessing }
PstFrameHandle >> frame: aFrame [
	frame := aFrame
]

{ #category : #services }
PstFrameHandle >> objectAtSlot: index [
	| slot |
	slot := frame slotAt: index.
	^self objectHandleOn: slot
]

{ #category : #printing }
PstFrameHandle >> printOn: aStream [
	aStream nextPutAll: 'FH with: ' , String cr , frame printString
]

{ #category : #services }
PstFrameHandle >> slotAt: index [
	^self objectAtSlot: index
]

{ #category : #services }
PstFrameHandle >> slotAtTop [
	^frame slotAtTop
]
