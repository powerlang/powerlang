Class {
	#name : #RVMemoryReference,
	#superclass : #Object,
	#instVars : [
		'length',
		'base',
		'index',
		'scale',
		'displacement'
	],
	#pools : [
		'Registers'
	],
	#category : #'Powerlang-RISCV-Code Generator'
}

{ #category : #'instance creation' }
RVMemoryReference class >> new [
	"return an initialized instance"

	^ self basicNew initialize.
]

{ #category : #accessing }
RVMemoryReference >> base [
	^ base
]

{ #category : #accessing }
RVMemoryReference >> base:register [
	base := register.
]

{ #category : #accessing }
RVMemoryReference >> displacement [
	^ displacement
]

{ #category : #accessing }
RVMemoryReference >> displacement:something [
	displacement := something.
]

{ #category : #accessing }
RVMemoryReference >> index [
	^ index
]

{ #category : #accessing }
RVMemoryReference >> index:register [
	index := register.
]

{ #category : #initialization }
RVMemoryReference >> initialize [
	"Invoked when a new instance is created."

	"  please change as required (and remove this comment)"
	"length := nil."
	"base := nil."
	index := 0.
	scale := 1.
	displacement := 0.

	"  super initialize.   -- commented since inherited method does nothing"
]

{ #category : #accessing }
RVMemoryReference >> length [
	^ length
]

{ #category : #accessing }
RVMemoryReference >> length:anInteger [
	length := anInteger.
]

{ #category : #'printing & storing' }
RVMemoryReference >> printOn:aStream [
]

{ #category : #accessing }
RVMemoryReference >> scale [
	^ scale
]

{ #category : #accessing }
RVMemoryReference >> scale:integer [
	self ASSERT: (#(1 2 4 8) includes: integer).
	scale := integer.
]
