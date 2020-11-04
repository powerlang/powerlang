Class {
	#name : #PopRopcode,
	#superclass : #StackOpcode,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #accessing }
PopRopcode >> nativizeUsing: anAssembler for: messageNativizer [
	messageNativizer popR
]
