Extension { #name : #Float }

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
Float >> pointerDouble [
	^ (ByteArray new: ExternalBytes sizeofDouble)
				doubleAt: 1 put: self;
				yourself

	"Created: / 03-02-2021 / 10:19:38 / Jan Vrany <jan.vrany@labware.com>"

]
