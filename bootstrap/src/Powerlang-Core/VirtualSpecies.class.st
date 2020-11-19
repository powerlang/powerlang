Class {
	#name : #VirtualSpecies,
	#superclass : #Object,
	#instVars : [
		'spec',
		'superclass',
		'map'
	],
	#category : #'Powerlang-Core-Emulation'
}

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
VirtualSpecies >> map [
	^map
]

{ #category : #accessing }
VirtualSpecies >> map: anObjectMap [ 
	map := anObjectMap 
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
VirtualSpecies >> superclass [
	^superclass
]

{ #category : #accessing }
VirtualSpecies >> superclass: aVirtualClass [ 
	superclass := aVirtualClass
]
