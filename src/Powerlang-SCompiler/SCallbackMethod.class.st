Class {
	#name : #SCallbackMethod,
	#superclass : #SCompiledMethod,
	#type : #variable,
	#instVars : [
		'receiver',
		'descriptor'
	],
	#category : #'Powerlang-SCompiler-Backend'
}

{ #category : #'as yet unclassified' }
SCallbackMethod class >> behaviorNativeCodeSlot [
	"callback methods have a special machine code. Its bytes are of
	class ByteArray, but the behavior of this ByteArray is special:
	it has an extra slot that allows to find the native code object
	corresponding to this callback"
	^4
]

{ #category : #accessing }
SCallbackMethod >> descriptor [
	^descriptor
]

{ #category : #accessing }
SCallbackMethod >> descriptor: anFFIDescriptor [
	descriptor := anFFIDescriptor 
]

{ #category : #accessing }
SCallbackMethod >> isCallback [
	^true
]

{ #category : #accessing }
SCallbackMethod >> pragma: anSPragmaNode [
	descriptor := anSPragmaNode info
]
