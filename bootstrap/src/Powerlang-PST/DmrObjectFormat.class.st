"
I represent the format of objects in the DMR. Ask me questions about
the header of an object.
"
Class {
	#name : #DmrObjectFormat,
	#superclass : #ObjectFormat,
	#pools : [
		'ObjectHeaderMasks',
		'ObjectHeaderOffsets'
	],
	#category : #'Powerlang-PST-Metaphysics'
}

{ #category : #services }
DmrObjectFormat >> behaviorOf: oid [
	^ storage uint32of: oid atOffset: BehaviorOffset
]

{ #category : #services }
DmrObjectFormat >> flagsOf: anObject [
	^ storage uint8of: anObject atOffset: FlagsOffset
]

{ #category : #services }
DmrObjectFormat >> integerOf: oid [
	| shifted complement |
	self ASSERT: oid odd.
	shifted := oid bitShift: -1. 
	complement := 1 bitShift: storage wordSize * 8 - 1.
	^ oid >= complement
		ifTrue: [ shifted - complement ]
		ifFalse: [ shifted ]
]

{ #category : #services }
DmrObjectFormat >> isArrayed: anObject [
	^ (self flagsOf: anObject) anyMask: IsArrayed
]

{ #category : #services }
DmrObjectFormat >> isBytes: anObject [
	^ ((self flagsOf: anObject) anyMask: IsBytes)
]

{ #category : #services }
DmrObjectFormat >> isLarge: anObject [
	^(self isSmall: anObject) not
]

{ #category : #services }
DmrObjectFormat >> isNamed: anObject [
	^ (self flagsOf: anObject) anyMask: IsNamed
]

{ #category : #services }
DmrObjectFormat >> isSmall: oid [
	^ (self flagsOf: oid) anyMask: IsSmall
]

{ #category : #sizes }
DmrObjectFormat >> largeSizeOf: oid [
	^ storage uint32of: oid atOffset: LargeSizeOffset
]

{ #category : #sizes }
DmrObjectFormat >> sizeOf: oid [
	^ (self isSmall: oid)
		ifTrue: [ self smallSizeOf: oid ]
		ifFalse: [ self largeSizeOf: oid ]
]

{ #category : #sizes }
DmrObjectFormat >> smallSizeOf: oid [
	^ storage uint8of: oid atOffset: SizeOffset
]
