Extension { #name : #LMRSlotObject }

{ #category : #'*Powerlang-JS' }
LMRSlotObject >> classInstSize [
	"assuming this is a behavior object (on the js world we are not creating LMRBehavioObject instances anymore)"

	^ ((self slotAt: 1) slotAt: 3) value & 16r7F
]
