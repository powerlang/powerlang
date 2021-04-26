Class {
	#name : #LazyLinker,
	#superclass : #LookupLinker,
	#instVars : [
		'sends'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #'instance creation' }
LazyLinker class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #nativizing }
LazyLinker >> emitSend: aSymbol using: anAssembler [
	| send |
	send := super emitSend: aSymbol using: anAssembler.
	sends add: send
]

{ #category : #nativizing }
LazyLinker >> initialize [
	super initialize.
	sends := OrderedCollection new

]

{ #category : #nativizing }
LazyLinker >> sends [
	^sends

]
