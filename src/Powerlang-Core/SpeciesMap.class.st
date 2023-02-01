Class {
	#name : #SpeciesMap,
	#superclass : #SlotObjectMap,
	#instVars : [
		'instanceSpec',
		'slotNames'
	],
	#category : #'Powerlang-Core-Execution-Ring'
}

{ #category : #'instance creation' }
SpeciesMap class >> classFor: anRGBehavior [
	^self
]

{ #category : #accessing }
SpeciesMap >> allInstVarNames [
	^self subclassResponsibility
]

{ #category : #accessing }
SpeciesMap >> allSlotNames [
	^ slotNames ifNil: [ self computeAllSlotNames ]
]

{ #category : #accessing }
SpeciesMap >> instanceSpec [
	^instanceSpec
]

{ #category : #accessing }
SpeciesMap >> instanceSpec: anRGBehavior [
	instanceSpec := anRGBehavior
]

{ #category : #accessing }
SpeciesMap >> storeCvar: aSymbol with: anObject [
	| species namespaces |
	species := self. 
	[ namespaces := species namespaces.
	namespaces slotsDo: [ :namespace |
	(namespace includesKey: aSymbol)
		ifTrue: [ ^ namespace at: aSymbol put: anObject ]].
	species := species superclass.
	species isNil 
	] whileFalse.
	^ nil


]

{ #category : #accessing }
SpeciesMap >> storeNamed: aSymbol with: anObjectMap [
	(self storeCvar: aSymbol with: anObjectMap) ifNotNil: [ :value | ^ value ].
	^ self module namespace
		at: aSymbol
		put: anObjectMap
]

{ #category : #accessing }
SpeciesMap >> superclass [
	^ self slotNamed: #superclass
]

{ #category : #accessing }
SpeciesMap >> superclass: aSpeciesMap [
	^ self slotNamed: #superclass put: aSpeciesMap
]
