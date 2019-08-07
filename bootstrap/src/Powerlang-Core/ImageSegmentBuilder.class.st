Class {
	#name : #ImageSegmentBuilder,
	#superclass : #Object,
	#instVars : [
		'objects',
		'classDef2ClassObjMap',
		'definition'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #building }
ImageSegmentBuilder >> build [
	self halt
]

{ #category : #initialization }
ImageSegmentBuilder >> initialize [
	super initialize.
	objects := OrderedCollection new.
	classDef2ClassObjMap := Dictionary new
]
