Class {
	#name : #VirtualClass,
	#superclass : #VirtualSpecies,
	#instVars : [
		'cvars',
		'names'
	],
	#category : #'Powerlang-Core-Emulation'
}

{ #category : #accessing }
VirtualClass >> allInstVarNames [
	^ spec allInstVarNames
]

{ #category : #accessing }
VirtualClass >> classPool [
^cvars 
]

{ #category : #accessing }
VirtualClass >> createClassAssociationsWith: aVirtualSmalltalkImage [
	| assocs |
	assocs := spec classVariables
		collect: [ :cvar | aVirtualSmalltalkImage newAssociation: cvar name -> nil ].
	cvars := VirtualDictionary withAll: assocs
]

{ #category : #accessing }
VirtualClass >> cvars [
	^cvars
]

{ #category : #accessing }
VirtualClass >> instanceSide [
	^ self
]

{ #category : #accessing }
VirtualClass >> localPools [
	| pools dict name pool |
	pools := cvars associations
		select: [ :assoc | assoc value spec name = #PoolDictionary ].
	dict := Dictionary new.
	pools
		do: [ :assoc | 
			name := assoc key asString.
			pool := assoc value.
			dict at: name put: (VirtualDictionary fromPool: pool) ].
	^ dict
]

{ #category : #accessing }
VirtualClass >> sharedPoolsUsing: globals [
	| pools dicts |
	pools := OrderedCollection new.
	spec sharedPoolsDo: [ :p | pools add: p ].
	dicts := pools
		collect: [ :p | (globals at: p name) association value ].
	^ dicts
		select: [ :d | d spec name = #PoolDictionary ]
		thenCollect: [ :d | VirtualDictionary fromPool: d ]
]

{ #category : #accessing }
VirtualClass >> withAllSuperclasses [
	^ superclass ifNil:
	 [ OrderedCollection with: self ]
		ifNotNil:  [ superclass withAllSuperclasses
				addFirst: self;
				yourself ]
]
