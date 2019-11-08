Class {
	#name : #KernelSegmentBuilder,
	#superclass : #ImageSegmentBuilder,
	#instVars : [
		'nilObj',
		'trueObj',
		'falseObj',
		'specialObjectsArrayObj'
	],
	#classVars : [
		'DefaultBaseAddress'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #'class initialization' }
KernelSegmentBuilder class >> defaultBaseAddress [
	^DefaultBaseAddress 
]

{ #category : #'class initialization' }
KernelSegmentBuilder class >> defaultBaseAddress: anInteger [
	DefaultBaseAddress := anInteger
]

{ #category : #'class initialization' }
KernelSegmentBuilder class >> initialize [
	DefaultBaseAddress := 16r1ff10000
]

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
	| placeholder |
	
	placeholder := Object new.
	objects add: placeholder.

	nilObj := self makeInstanceOf: #UndefinedObject.
	trueObj := self makeInstanceOf: #True.
	falseObj := self makeInstanceOf: #False.
	specialObjectsArrayObj := self makeInstanceOf: #Array size: 5.
	
	objects remove: specialObjectsArrayObj.
	objects replaceAll: placeholder with: specialObjectsArrayObj.
		
	self makeClasses.
	self makeTOC.
	
	specialObjectsArrayObj at: 1 put: nilObj.
	specialObjectsArrayObj at: 2 put: trueObj.
	specialObjectsArrayObj at: 3 put: falseObj.
 	specialObjectsArrayObj at: 4 put: (classDef2ClassObjMap at: (kernel at: #SmallInteger)).
	specialObjectsArrayObj at: 5 put: (self makeSymbol: #evaluate).
	
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
	 of BeeLoader and send it #start. But for now, computing
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
	self writeTo: aStream baseAddress: self class defaultBaseAddress 
]

{ #category : #writing }
KernelSegmentBuilder >> writeTo: aStream baseAddress: baseAddress [
	ImageSegmentWriter new
		stream: aStream;
		objects: objects; 
		toc: tocObj;
		baseAddress: baseAddress;
		write
]

{ #category : #writing }
KernelSegmentBuilder >> writeToFile: file baseAddress: baseAddress [
	file asFileReference binaryWriteStreamDo: [ :stream |
		"Bit stupid - we write into internal ByteArray backed stream and
		then write it to real file. That's because WriteStream and ZnWriteStream
		are not polymorphic. Sigh"

		stream nextPutAll: (ByteArray streamContents:[:bytes | self writeTo: bytes baseAddress: baseAddress ]).
	]
	
		
]
