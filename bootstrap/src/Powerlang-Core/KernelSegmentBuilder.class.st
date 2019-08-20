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
	self makeTOC.
	
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

{ #category : #building }
KernelSegmentBuilder >> makeLoadAction [
	| messageSendObj |
	
	messageSendObj := self makeInstanceOf: #MessageSend.
	
	"CRAP crap to be easily grepped.
 	 This obviously bogus, we should make an instance
	 of BeeLoader and send it #start. But for now, comuting
	 #gcd: is challenging enough."
	
	messageSendObj receiver: (self makeSmallInteger: 10).
	messageSendObj selector: (self makeSymbol: #gcd:).
	messageSendObj arguments: (self makeArray: { self makeSmallInteger: 15} ).
	
	^messageSendObj 
]

{ #category : #building }
KernelSegmentBuilder >> makeTOC [
	tocObj := self makeInstanceOf: #BeeModuleTOC.
	tocObj classes: (self makeArray: classDef2ClassObjMap values).
	tocObj actions: (self makeArray: { self makeLoadAction. self nilObj })
	
]

{ #category : #acccessing }
KernelSegmentBuilder >> nilObj [
	^ nilObj
]

{ #category : #acccessing }
KernelSegmentBuilder >> trueObj [
	^ trueObj
]

{ #category : #writing }
KernelSegmentBuilder >> writeTo: aStream [
	ImageSegmentWriter new
		stream: aStream;
		objects: objects; 
		toc: tocObj;
		baseAddress: 16r1ff10000;
		write
]
