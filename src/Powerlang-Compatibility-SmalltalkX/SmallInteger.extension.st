Extension { #name : #SmallInteger }

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
SmallInteger >> bytesCount [
	| value length |

	length := 1.
	value := self.
	value >= 0 ifTrue: [
		[ value > 255 ] whileTrue: [
			value := value bitShift: -8.
			length := length + 1
		]
	] ifFalse: [
		[ value < -255 ] whileTrue: [
			value := value bitShift: -8.
			length := length + 1
		]
	].
	^ length

	"Created: / 03-02-2021 / 11:43:19 / Jan Vrany <jan.vrany@labware.com>"

]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
SmallInteger >> isSmallInteger [
	^ true
]
