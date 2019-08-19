Class {
	#name : #ProtoObject,
	#superclass : nil,
	#classVars : [
		'ObjectHeaderMasks',
		'ObjectHeaderOffsets'
	],
	#category : #Kernel
}

{ #category : #'testing' }
ProtoObject >> = other [
	^self == other
]

{ #category : #'testing' }
ProtoObject >> == other [
	<primitive: Equal>
]


