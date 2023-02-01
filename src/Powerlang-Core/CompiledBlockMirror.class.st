Class {
	#name : #CompiledBlockMirror,
	#superclass : #ObjectMirror,
	#classVars : [
		'Flags'
	],
	#pools : [
		'CompiledBlockFormatMasks'
	],
	#category : #'Powerlang-Core-Mirrors'
}

{ #category : #private }
CompiledBlockMirror >> structureType [
	^ #CompiledBlock
]
