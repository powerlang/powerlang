Class {
	#name : #BootstrapObjectFormat,
	#superclass : #ObjectFormat,
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #public }
BootstrapObjectFormat >> behaviorOf: oid [
	^oid behavior
]

{ #category : #public }
BootstrapObjectFormat >> bytesOf: oid count: size [
	^oid contents copyFrom: 1 to: size
]

{ #category : #public }
BootstrapObjectFormat >> classOf: anObjectHandle [
	| oid behavior handle class |
	oid := anObjectHandle oid.
	(self isInteger: oid) ifTrue: [ 
		class := storage classNamed: 'SmallInteger'.
		^(anObjectHandle runtime handleOn: class) mirror asClassMirror].
	behavior := self behaviorOf: oid.
	handle := anObjectHandle runtime handleOn: behavior.
	^handle mirror asBehaviorMirror instanceClass
]

{ #category : #public }
BootstrapObjectFormat >> integerOf: oid [
	self ASSERT: oid isImmediate.
	^ oid value
]

{ #category : #public }
BootstrapObjectFormat >> isBytes: oid [
	^oid isBytes
]

{ #category : #public }
BootstrapObjectFormat >> isInteger: oid [
	^oid isImmediate
]

{ #category : #public }
BootstrapObjectFormat >> labelFor: oid [
	^(self isInteger: oid) 
		ifTrue: [ 'SMI 0x', (self integerOf: oid) printString ]
		ifFalse: [ (storage nameOf: oid) ifNil: [ 'unknown' ]]
]

{ #category : #public }
BootstrapObjectFormat >> newClosure: aPCompiledBlock [
	^ storage newClosure: aPCompiledBlock
]

{ #category : #public }
BootstrapObjectFormat >> newInteger: anInteger [
	^storage newSmallInteger: anInteger
]

{ #category : #public }
BootstrapObjectFormat >> print: oid on: aStream [
	| label |
	label := self labelFor: oid.
	aStream
		nextPut: $@;
		nextPutAll: label;
		nextPutAll: ' [size: 0x';
		nextPutAll: (self sizeOf: oid) printStringHex;
		nextPut: $].

]

{ #category : #public }
BootstrapObjectFormat >> sizeOf: oid [
	^oid size
]

{ #category : #public }
BootstrapObjectFormat >> slotOf: oid at: index [
	^ oid slotAt: index
]

{ #category : #public }
BootstrapObjectFormat >> stringOf: oid count: size [
	^(oid bytes copyFrom: 1 to: size) asString
]
