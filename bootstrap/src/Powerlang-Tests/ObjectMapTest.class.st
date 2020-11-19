Class {
	#name : #ObjectMapTest,
	#superclass : #TestCase,
	#instVars : [
		'kernel'
	],
	#category : #'Powerlang-Tests-Building'
}

{ #category : #running }
ObjectMapTest >> setUp [
	super setUp.
	kernel := VirtualSmalltalkImage kernelSpec
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
	| undefined fraction null frac |
	undefined := kernel at: #UndefinedObject.
	fraction := kernel at: #Fraction.
	
	null := ObjectMap new: undefined.
	frac := ObjectMap new: fraction.
	self assert: frac class == SlotObjectMap.
	self assert: frac size == 2.
	
	frac slotAt: 1 put: null.
	frac slotAt: 2 put: frac.
	self assert: (frac slotAt: 1) == null.
	self assert: (frac slotAt: 2) == frac.
	self assert: (frac slotNamed: 'numerator') == null.
	self assert: (frac slotNamed: 'denominator') == frac.
	
	self assert: (frac numerator) == null.
	self assert: (frac denominator) == frac.

	frac slotNamed: 'numerator' put: frac.
	frac slotNamed: 'denominator' put: null.
	self assert: (frac slotAt: 1) == frac.
	self assert: (frac slotAt: 2) == null.
	self assert: (frac slotNamed: 'numerator') == frac.
	self assert: (frac slotNamed: 'denominator') == null.
	
	frac numerator: null.
	frac denominator: frac.
	self assert: (frac slotAt: 1) == null.
	self assert: (frac slotAt: 2) == frac.
	
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
	| undefined array null indexed |
	
	undefined := kernel at: #UndefinedObject.
	array := kernel at: #Array.
	null := ObjectMap new: undefined.
	indexed := ObjectMap new: array size: 2.
	self assert: indexed class == SlotObjectMap.
	self assert: indexed size == 2.
	
	indexed at: 1 put: null.
	indexed at: 2 put: indexed.
	self assert: (indexed at: 1) == null.
	self assert: (indexed at: 2) == indexed.
	
	indexed at: 1 put: indexed.
	indexed at: 2 put: null.
	self assert: (indexed at: 1) == indexed.
	self assert: (indexed at: 2) == null.
	
	self should: [ indexed at: 0 ] raise: Error.
	self should: [ indexed at: 3 ] raise: Error.
	self should: [ indexed at: 0 put: null ] raise: Error.
	self should: [ indexed at: 3 put: null ] raise: Error.
	self should: [ indexed at: 1 put: 1] raise: Error.
	
	
	
	
	
	
]
