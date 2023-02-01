Class {
	#name : #BootstrapStorage,
	#superclass : #Storage,
	#instVars : [
		'bootstrapper'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'instance creation' }
BootstrapStorage class >> on: aSmalltalkBootstrapper [
	^ self new bootstrapper: aSmalltalkBootstrapper
]

{ #category : #storage }
BootstrapStorage >> arrayedSlotOf: oid at: index put: anotherOid [
	"fixme: this message should be sent to ObjectFormat"
	^ oid at: index put: anotherOid
]

{ #category : #storage }
BootstrapStorage >> bootstrapper: aSmalltalkBootstrapper [
	bootstrapper := aSmalltalkBootstrapper
]

{ #category : #storage }
BootstrapStorage >> new: oid [
	| meta base behavior |
	meta := oid spec.
	self ASSERT: meta isMeta.
	base := meta baseClass.
	behavior := bootstrapper instanceBehaviorOfSpec: base.
	^ (ObjectMap new: base) behavior: behavior; atAllPut: bootstrapper nilObject
]

{ #category : #storage }
BootstrapStorage >> new: oid sized: anInteger [
	| meta base behavior |
	meta := oid spec.
	self ASSERT: meta isMeta.
	base := meta baseClass.
	behavior := bootstrapper instanceBehaviorOfSpec: base.
	^ (ObjectMap new: base size: anInteger)
		behavior: behavior;
		atAllPut: bootstrapper nilObject
]

{ #category : #storage }
BootstrapStorage >> newClosure: anObjectHandle [
	| size |
	size := anObjectHandle target size.
	^ bootstrapper new: #Closure sized: size
]

{ #category : #storage }
BootstrapStorage >> slotOf: anObjectMap at: index put: value [
	index <= anObjectMap size
		ifTrue: [ anObjectMap slotAt: index put: value ]
		ifFalse: [ anObjectMap at: index put: value ].
	^ value
]
