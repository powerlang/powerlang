Class {
	#name : #MinimalTestSegmentBuilder,
	#superclass : #ScriptSegmentBuilder,
	#instVars : [
		'methods'
	],
	#category : #'Powerlang-Tests-Building'
}

{ #category : #building }
MinimalTestSegmentBuilder >> build [
	| scriptDef scriptPkg |
	script := RGEnvironment new.
	scriptPkg := script ensurePackageNamed: #Script.
	scriptDef := script ensureClassNamed: #MinimalTest.
	scriptDef superclass name: #Object.
	scriptDef package: scriptPkg.

	methods do:[:each |
		scriptDef compile: each classified: 'methods'. 
	].	
	self assert: methods size > 0.
	self assert: (scriptDef >> #evaluate) notNil.
	super build.
]

{ #category : #utilities }
MinimalTestSegmentBuilder >> findClassDef: name [
	"Return a class definition (as RGBehavior) for class
	 with given name or nil (if not found in definitions)"
	
	^(definition at: name) ifNil:[script at: name]
]

{ #category : #initialization }
MinimalTestSegmentBuilder >> initialize [
	super initialize.
	methods := OrderedCollection new.
	
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
