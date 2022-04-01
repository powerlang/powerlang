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
SpeciesMap >> localPools [
	^self subclassResponsibility
]

{ #category : #accessing }
SpeciesMap >> lookupInModule: aSymbol [
	| species |
	species := self.
	[ (species spec module includesKey: aSymbol)
		ifTrue: [ ^SGlobalBinding new name: aSymbol; dictionary: species ].
	species := species superclass.
	species notNil ] whileTrue.
	^nil
]

{ #category : #accessing }
SpeciesMap >> storeCvar: aSymbol with: anObject [
	| species cvars |
	species := self. 
	[ cvars := species classVariables.
	cvars isNil ifFalse: [ 
	(cvars includesKey: aSymbol)
		ifTrue: [ ^ cvars at: aSymbol put: anObject ].
	species localPools
		do: [ :pool | pool at: aSymbol ifPresent: [ :value | ^ value ] ]].
	species := species superclass.
	species isNil ] whileFalse.
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
