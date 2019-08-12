Class {
	#name : #KernelSegmentBuilder,
	#superclass : #ImageSegmentBuilder,
	#instVars : [
		'nilObj',
		'trueObj',
		'falseObj'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #building }
KernelSegmentBuilder >> build [
	self shouldNotImplement. "See #genesis instead"
]

{ #category : #acccessing }
KernelSegmentBuilder >> falseObj [
	^ falseObj
]

{ #category : #building }
KernelSegmentBuilder >> genesis [
	"Create the world (should take less than 6 days)"
	
	"
	This is named 'genesis' to remind us those who had done this
	(and much more) before us. Namely SELF people. 
	
	I (JV) would like to use this opportunity and point you to
	
	https://github.com/russellallen/self/blob/2bcf2c4cab23f52bf68ac4f617020e748699a548/vm/src/any/memory/universe.cpp#L79
	"
	
	nilObj := self makeInstanceOf: #UndefinedObject.
	trueObj := self makeInstanceOf: #True.
	falseObj := self makeInstanceOf: #False.
	
	self makeClasses.
	
	self fixHierarchy.
	self fixBehaviors.
	
	"Finally, make sure everythinbg is all right"
	self validate
	
	

]

{ #category : #initialization }
KernelSegmentBuilder >> initialize [
	super initialize.
	definition := kernel
	
]

{ #category : #acccessing }
KernelSegmentBuilder >> nilObj [
	^ nilObj
]

{ #category : #acccessing }
KernelSegmentBuilder >> trueObj [
	^ trueObj
]
