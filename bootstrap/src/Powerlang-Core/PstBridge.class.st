Class {
	#name : #PstBridge,
	#superclass : #SmalltalkBridge,
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #initialization }
PstBridge >> findFalseObject [
	| s handle |
	s := runtime storage.
	handle := s class = VirtualImage
		ifTrue: [ s false ]
		ifFalse: [ self ASSERT: false ].
	^ falseObj := ObjectHandle on: handle within: runtime
]

{ #category : #initialization }
PstBridge >> findKernelModule [
	| handle |
	handle := nilObj.
	[ handle getClass localName != 'Kernel' ]
		whileTrue: [ handle := handle nextObjectHandle ].

	self name: handle mirror as: #kernel.

]

{ #category : #initialization }
PstBridge >> findNilObject [
	^ nilObj := ObjectHandle
		on: ImageSegmentWriter nilOffset
		within: runtime
]

{ #category : #initialization }
PstBridge >> findObjectNamed: name [
	| namespace array |
	namespace := self kernel slotOf: #Kernel named: #namespace.
	array := namespace slotOf: #Namespace named: 'table'.
	array
		do: [ :slot | 
			| assoc |
			assoc := slot asAssociationMirror.
			assoc reflectsNil
				ifFalse: [ assoc key asLocalString = name
						ifTrue: [ ^ assoc value ] ] ].
	self error: 'object not found'
]

{ #category : #initialization }
PstBridge >> findRootClasses [
	| object subclasses |
	object := self objectNamed: 'Object'.
	subclasses := object asSpeciesMirror subclasses.
	1 to: subclasses size do: [ :i | 
		| subclass name |
		subclass := (subclasses slotAt: i) asSpeciesMirror.
		name := subclass name asLocalString.
		self name: subclass as: name ]
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
	self findRootClasses; findKernelModule
]

{ #category : #initialization }
PstBridge >> findTrueObject [
	self ASSERT: false.
	^ trueObj := ObjectHandle on: 0 within: runtime
]
