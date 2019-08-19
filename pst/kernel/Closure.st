Class {
	#name : #Closure,
	#superclass : #Object,
	#instVars : [
		'block',
		'homeFrame'
	],
	#classVars : [
		'Flags'
	],
	#category : #Kernel
}


{ #category : #'evaluating' }
Closure >> value [
	<primitive: ClosureValue>
]

