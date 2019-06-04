Class {
	#name : #StackFrameMirror,
	#superclass : #Mirror,
	#pools : [
		'FrameOffsets'
	],
	#category : #'Powerlang-PST-Mirrors'
}

{ #category : #private }
StackFrameMirror >> argumentAt: index [
	^(handle slotAt: LastArgumentIndex - index + 1) mirror
]

{ #category : #printing }
StackFrameMirror >> currentIp [
	^handle currentIp
]

{ #category : #private }
StackFrameMirror >> method [
	| mirror |
	mirror := (handle slotAt: MethodIndex) mirror asMethodMirror.
	^mirror isValid ifTrue: mirror
]

{ #category : #printing }
StackFrameMirror >> printOn: aStream [
	aStream nextPutAll: 'SFMirror(' , String cr , handle printString , ')'
]

{ #category : #private }
StackFrameMirror >> receiver [
	^(handle slotAt: ReceiverIndex) mirror
]

{ #category : #private }
StackFrameMirror >> returnAddress [
	^handle slotAt: ReturnAddressIndex
]

{ #category : #printing }
StackFrameMirror >> slotAtTop [
	^handle slotAtTop
]
