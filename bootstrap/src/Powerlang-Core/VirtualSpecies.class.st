Class {
	#name : #VirtualSpecies,
	#superclass : #Object,
	#instVars : [
		'spec',
		'superclass',
		'map',
		'module'
	],
	#category : #'Powerlang-Core-Emulation'
}

{ #category : #accessing }
VirtualSpecies >> allInstVarNames [
	^self subclassResponsibility
]

{ #category : #accessing }
VirtualSpecies >> allSharedPoolsUsing: globals [
	| pools class |
	pools := Set new.
	class := self.
	[ class isNil ]
		whileFalse: [ pools addAll: (class sharedPoolsUsing: globals).
			class := class superclass ].
	^ pools
]

{ #category : #accessing }
VirtualSpecies >> loadCvar: aSymbol [
	| species |
	species := self.
	[ species cvars at: aSymbol ifPresent: [ :value | ^ value ].
	species localPools
		do: [ :pool | pool at: aSymbol ifPresent: [ :value | ^ value ] ].
	species := species superclass.
	species notNil ] whileTrue.
	^ nil
]

{ #category : #accessing }
VirtualSpecies >> loadIvar: aSymbol of: receiver [
	| ivar |
	ivar := self allInstVarNames indexOf: aSymbol.
	^ivar > 0 ifTrue: [receiver slotAt: ivar ].
	
]

{ #category : #accessing }
VirtualSpecies >> loadNamed: aSymbol in: receiver [
	(self loadIvar: aSymbol of: receiver) ifNotNil: [:value | ^value].
	(self loadCvar: aSymbol) ifNotNil: [:value | ^value].
	^self module at: aSymbol ifAbsent: [self error: 'unbound variable: ', aSymbol]
	
]

{ #category : #accessing }
VirtualSpecies >> localPools [
	^self subclassResponsibility
]

{ #category : #accessing }
VirtualSpecies >> lookupInModule: aSymbol [
	| species |
	species := self.
	[ (species spec module includesKey: aSymbol)
		ifTrue: [ ^SGlobalBinding new name: aSymbol; dictionary: species ].
	species := species superclass.
	species notNil ] whileTrue.
	^nil
]

{ #category : #accessing }
VirtualSpecies >> map [
	^map
]

{ #category : #accessing }
VirtualSpecies >> map: anObjectMap [ 
	map := anObjectMap 
]

{ #category : #accessing }
VirtualSpecies >> module [
	^module
]

{ #category : #accessing }
VirtualSpecies >> module: aVirtualDictionary [
	module := aVirtualDictionary
]

{ #category : #accessing }
VirtualSpecies >> name [
	^spec name
]

{ #category : #printing }
VirtualSpecies >> printOn: aStream [
	aStream nextPut: $<; print: spec; nextPut: $>
]

{ #category : #accessing }
VirtualSpecies >> spec [
	^spec
]

{ #category : #accessing }
VirtualSpecies >> spec: anRGBehavior [
	spec := anRGBehavior
]

{ #category : #accessing }
VirtualSpecies >> storeCvar: aSymbol with: anObject [
	| species cvars |
	species := self. 
	[ cvars := species cvars.
	(cvars includesKey: aSymbol)
		ifTrue: [ ^ cvars at: aSymbol put: anObject ].
	species := species superclass.
	species notNil ] whileTrue.
	^ nil
]

{ #category : #accessing }
VirtualSpecies >> storeIvar: aSymbol of: receiver with: anObject [
	| ivar |
	ivar := self allInstVarNames indexOf: aSymbol.
	^ ivar > 0
		ifTrue: [ receiver slotAt: ivar put: anObject]
]

{ #category : #accessing }
VirtualSpecies >> storeNamed: aSymbol in: receiver with: anObject [
	(self storeIvar: aSymbol of: receiver with: anObject)
		ifNotNil: [ :value | ^ value ].
	(self storeCvar: aSymbol with: anObject)
		ifNotNil: [ :value | ^ value ].
	^ self module at: aSymbol put: anObject
]

{ #category : #accessing }
VirtualSpecies >> superclass [
	^superclass
]

{ #category : #accessing }
VirtualSpecies >> superclass: aVirtualClass [ 
	superclass := aVirtualClass
]
