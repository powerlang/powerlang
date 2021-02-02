Class {
	#name : #CompositeMessageLinker,
	#superclass : #MessageLinker,
	#instVars : [
		'candidates'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #'instance creation' }
CompositeMessageLinker class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #services }
CompositeMessageLinker >> add: aMessageLinker [
	candidates add: aMessageLinker
]

{ #category : #services }
CompositeMessageLinker >> dispatchLinkerFor: selector [
	^candidates
		detect: [:linker | linker canInline: selector]
		ifNone: [self error: 'cannot dispatch ', selector storeString]
]

{ #category : #services }
CompositeMessageLinker >> emitSend: selector using: anAssembler [
	| linker |
	linker := self dispatchLinkerFor: selector.
	linker emitSend: selector using: anAssembler

]

{ #category : #services }
CompositeMessageLinker >> emitSendSuper: selector from: aClass using: anAssembler [
	| linker |
	linker := self dispatchLinkerFor: selector.
	linker emitSendSuper: selector from: aClass using: anAssembler
]

{ #category : #services }
CompositeMessageLinker >> initialize [
	candidates := OrderedCollection new
]
