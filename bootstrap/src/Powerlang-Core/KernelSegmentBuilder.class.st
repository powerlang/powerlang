Class {
	#name : #KernelSegmentBuilder,
	#superclass : #ImageSegmentBuilder,
	#instVars : [
		'smalltalk',
		'hash',
		'symbols'
	],
	#classVars : [
		'KernelSpec'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #building }
KernelSegmentBuilder >> addGenesisObjects [
	objects
		add: image nil;
		add: image false;
		add: image true;
		add: module.
	globals valuesDo: [ :obj | objects add: obj ].
	smalltalk ifNotNil: [ objects add: smalltalk value ]
]

{ #category : #building }
KernelSegmentBuilder >> generateModule [
	| wordsize lasthash |
	super generateModule.
	smalltalk := runtime globals associationAt: #Smalltalk.
	wordsize := runtime globals associationAt: #WordSize.
	lasthash := runtime globals associationAt: #LastHash.
	runtime send: #add: to: module exports with: {wordsize}.
	runtime send: #add: to: module exports with: {lasthash}
]

{ #category : #initialization }
KernelSegmentBuilder >> methodSubset: aDictionary [
	| all species m |
	all := aDictionary
		flatCollect: [ :assoc | 
			species := self => assoc key.
			assoc value
				collect: [ :sel | 
					m := species >> sel.
					self ASSERT: m notNil.
					m ] ].
	^ all asOrderedCollection
]

{ #category : #building }
KernelSegmentBuilder >> moduleName [
	^'Kernel'
]

{ #category : #initialization }
KernelSegmentBuilder >> spec [
	^image kernel
]

{ #category : #initialization }
KernelSegmentBuilder >> undermethods [
	^ (self => #ProtoObject) methods
		select: [ :m | m category = 'header access' ]
]

{ #category : #initialization }
KernelSegmentBuilder >> writer [
	^ super writer space: smalltalk value memory edenSpace
]
