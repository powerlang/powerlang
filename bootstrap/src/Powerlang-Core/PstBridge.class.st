Class {
	#name : #PstBridge,
	#superclass : #SmalltalkBridge,
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #initialization }
PstBridge >> findFalseObject [
	| s handle |
	s := runtime storage.
	handle := s class = SmalltalkBootstrapper
		ifTrue: [ s falseObject ]
		ifFalse: [ self ASSERT: false ].
	^ falseObj := ObjectHandle on: handle within: runtime
]

{ #category : #initialization }
PstBridge >> findGlobalNamed: name [
	| globals array |
	globals := self smalltalk slotOf: #SmalltalkSystem named: #globals.
	array := globals slotOf: #Dictionary named: 'table'.
	array do: [:slot | | assoc |
		assoc :=  slot asAssociationMirror.
		assoc reflectsNil
			ifFalse: [assoc key asLocalString = name ifTrue: [^assoc value]]].
	self error: 'global not found'
]

{ #category : #initialization }
PstBridge >> findNilObject [
	^ nilObj := ObjectHandle on: ImageSegmentWriter nilOffset within: runtime
]

{ #category : #initialization }
PstBridge >> findRootClasses [
	| object subclasses |
	object := self globalNamed: 'Object'.
	subclasses := object asSpeciesMirror subclasses.
	1 to: subclasses size do: [:i | | subclass name |
		subclass := (subclasses slotAt: i) asSpeciesMirror.
		name := subclass name asLocalString.
		self name: subclass as: name]
]

{ #category : #initialization }
PstBridge >> findRootObjects [
	| class |
	nilObj := self findNilObject.
	class := nilObj mirror reflectedClass.
	[ class reflectsNil ]
		whileFalse: [ | name |
			name := class name asLocalString.
			self name: class as: name.
			class := class superclass ].
	self findRootClasses
	"; findSmalltalk"
]

{ #category : #initialization }
PstBridge >> findSmalltalk [
	| smalltalk |
	smalltalk := self halt.
	self name: smalltalk as: #Smalltalk.
	^smalltalk
]

{ #category : #initialization }
PstBridge >> findTrueObject [
	self ASSERT: false.
	^ trueObj := ObjectHandle on: 0 within: runtime
]
