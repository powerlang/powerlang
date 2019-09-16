Class {
	#name : #MinimalTestSegmentBuilder,
	#superclass : #KernelSegmentBuilder,
	#instVars : [
		'mintests',
		'methods'
	],
	#category : #'Powerlang-Tests-Building'
}

{ #category : #building }
MinimalTestSegmentBuilder >> build [
	| mintestDef |
	mintests := RGEnvironment new.
	mintestDef := mintests ensureClassNamed: #MinimalTest.
	mintestDef superclass name: #Object.

	methods do:[:each |
		mintestDef compile: each classified: 'methods'. 
	].	
	self assert: methods size > 0.
	self assert: (mintestDef >> #evaluate) notNil.
	super genesis
]

{ #category : #utilities }
MinimalTestSegmentBuilder >> findClassDef: name [
	"Return a class definition (as RGBehavior) for class
	 with given name or nil (if not found in definitions)"
	
	^(definition at: name) ifNil:[mintests at: name]
]

{ #category : #building }
MinimalTestSegmentBuilder >> genesis [
	self shouldNotImplement. "Use #build instead"
]

{ #category : #initialization }
MinimalTestSegmentBuilder >> initialize [
	super initialize.
	methods := OrderedCollection new.
	
]

{ #category : #'building-private' }
MinimalTestSegmentBuilder >> makeClasses [
	super makeClasses.
	self makeClasses: mintests 
]

{ #category : #building }
MinimalTestSegmentBuilder >> makeLoadAction [
	^self makeInstanceOf: #MinimalTest.
]

{ #category : #initialization }
MinimalTestSegmentBuilder >> method: source [
	"Add method to test class. Any number of methods can be added,
	 each MUST HAVE different selector. One of the method MUST have
	 selector #evaluate - that's the entry point. 
	
	 Note, that these constraints are not validated, use is responsible
	 for making sure all is sound.
	 "
	 methods add: source
]
