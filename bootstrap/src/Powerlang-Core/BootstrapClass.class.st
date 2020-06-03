Class {
	#name : #BootstrapClass,
	#superclass : #Object,
	#instVars : [
		'spec',
		'map',
		'cvars'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #'instance creation' }
BootstrapClass class >> spec: anRGBehavior map: anObjectMap cvars: aBootstrapDictionary [
	^ self new
		spec: anRGBehavior;
		map: anObjectMap;
		cvars: aBootstrapDictionary
]

{ #category : #accessing }
BootstrapClass >> allInstVarNames [
	^spec allInstVarNames
]

{ #category : #accessing }
BootstrapClass >> allSharedPools [
	| pools class |
	pools := Set new.
	class := self.
	[ class isNil ]
		whileFalse: [ pools addAll: class sharedPools.
			class := class superclass ].
	^ pools
]

{ #category : #accessing }
BootstrapClass >> classPool [
^cvars 
]

{ #category : #accessing }
BootstrapClass >> cvars: aBootstrapDictionary [
cvars:= aBootstrapDictionary
]

{ #category : #accessing }
BootstrapClass >> instanceSide [
	^ spec isMeta ifTrue: [ spec instanceSide properties at: #wrapper] ifFalse: [ self  ]
]

{ #category : #accessing }
BootstrapClass >> localPools [
	| pools dict name entries pool |
	spec isMeta
		ifTrue: [ ^ self instanceSide sharedPools ].

	pools := cvars associations
		select: [ :assoc | assoc value spec name = #PoolDictionary ].
	dict := Dictionary new.
	pools
		do: [ :assoc | 
			name := assoc key asString.
			pool := assoc value.
			entries := pool table slots
				select: [ :s | s spec name = #Association ].
			dict
				at: name
				put:
					(BootstrapDictionary
						withAll: entries
						constant: pool constant asBoolean) ].
	^ dict
]

{ #category : #accessing }
BootstrapClass >> map: anObjectMap [
	map := anObjectMap
]

{ #category : #printing }
BootstrapClass >> printOn: aStream [
	aStream nextPut: $<; print: spec; nextPut: $>
]

{ #category : #accessing }
BootstrapClass >> sharedPools [
	| pools |
	spec isMeta
		ifTrue: [ ^ self instanceSide sharedPools ].
	pools := OrderedCollection new.
	spec sharedPoolsDo: [ :p | pools add: p ].
	^ pools
]

{ #category : #accessing }
BootstrapClass >> spec [
	^spec
]

{ #category : #accessing }
BootstrapClass >> spec: anRGBehavior [
	spec := anRGBehavior.
	spec properties at: #wrapper put: self
]

{ #category : #accessing }
BootstrapClass >> superclass [
	^spec superclass ifNotNil: [:s | s properties at: #wrapper ]

]

{ #category : #accessing }
BootstrapClass >> withAllSuperclasses [ 
	^ spec withAllSuperclasses collect: [ :s | s properties at: #wrapper ]
]
