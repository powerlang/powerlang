Class {
	#name : #ObjectMapTest,
	#superclass : #TestCase,
	#instVars : [
		'kernel'
	],
	#category : #'Powerlang-Tests-Building'
}

{ #category : #accessing }
ObjectMapTest class >> resources [
	^ { KernelResource }
]

{ #category : #running }
ObjectMapTest >> setUp [
	super setUp.
	kernel := KernelResource current get
]

{ #category : #running }
ObjectMapTest >> tearDown [
	super tearDown.
	kernel := nil
]

{ #category : #tests }
ObjectMapTest >> test_01a [
	| map |
	
	map := ObjectMap new: (kernel at: #Object).
	self assert: map class == SlotObjectMap.
	self assert: map size == 0.
	
]

{ #category : #tests }
ObjectMapTest >> test_01b [
	| null frac |
	
	null := ObjectMap new: (kernel at: #UndefinedObject).
	frac := ObjectMap new: (kernel at: #Fraction).
	self assert: frac class == SlotObjectMap.
	self assert: frac size == 2.
	
	frac slotAt: 1 put: null.
	frac slotAt: 2 put: frac.
	self assert: (frac slotAt: 1) == null.
	self assert: (frac slotAt: 2) == frac.
	self assert: (frac slotNamed: 'numerator') == null.
	self assert: (frac slotNamed: 'denominator') == frac.
	
	frac slotNamed: 'numerator' put: frac.
	frac slotNamed: 'denominator' put: null.
	self assert: (frac slotAt: 1) == frac.
	self assert: (frac slotAt: 2) == null.
	self assert: (frac slotNamed: 'numerator') == frac.
	self assert: (frac slotNamed: 'denominator') == null.
	
	self should: [ frac slotAt: 0 ] raise: Error.
	self should: [ frac slotAt: 3 ] raise: Error.
	self should: [ frac slotAt: 0 put: null ] raise: Error.
	self should: [ frac slotAt: 3 put: null ] raise: Error.
	self should: [ frac slotAt: 1 put: 1 ] raise: Error.
	
	self should: [ frac slotNamed: 'bogus' ] raise: Error.
	self should: [ frac slotNamed: 'bogus' put: null] raise: Error.

	
	
	
	
	
	
]

{ #category : #tests }
ObjectMapTest >> test_01c [
	| null frac |
	
	null := ObjectMap new: (kernel at: #UndefinedObject).
	frac := ObjectMap new: (kernel at: #Array) size: 2.
	self assert: frac class == SlotObjectMap.
	self assert: frac size == 2.
	
	frac at: 1 put: null.
	frac at: 2 put: frac.
	self assert: (frac at: 1) == null.
	self assert: (frac at: 2) == frac.
	
	frac at: 1 put: frac.
	frac at: 2 put: null.
	self assert: (frac at: 1) == frac.
	self assert: (frac at: 2) == null.
	
	self should: [ frac at: 0 ] raise: Error.
	self should: [ frac at: 3 ] raise: Error.
	self should: [ frac at: 0 put: null ] raise: Error.
	self should: [ frac at: 3 put: null ] raise: Error.
	self should: [ frac at: 1 put: 1] raise: Error.
	
	
	
	
	
	
]
