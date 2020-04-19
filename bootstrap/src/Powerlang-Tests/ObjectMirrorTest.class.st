Class {
	#name : #ObjectMirrorTest,
	#superclass : #TestCase,
	#instVars : [
		'storage'
	],
	#category : #'Powerlang-Tests-Metaphysics'
}

{ #category : #accessing }
ObjectMirrorTest >> runtime [
	| builder writer |
	builder := SmalltalkBootstrapper fromSpec build.
	writer := builder writer write.
	^ Runtime forSimulating: SmalltalkBootstrapper spec memory: writer image
]

{ #category : #private }
ObjectMirrorTest >> test010nilObjectHandle [
	| runtime handle |
	runtime := self runtime.
	handle := runtime nil.
	self
		assert: handle isFixed;
		assert: handle isSmall;
		assert: handle size = 0
]

{ #category : #private }
ObjectMirrorTest >> test015nilObjectMirror [
	| runtime handle mirror |
	runtime := self runtime.
	handle := runtime nil.
	mirror := handle mirror.
	self
		assert: mirror = handle mirror;
		assert: mirror reflectsNil;
		deny: mirror reflectsInteger;
		assert: mirror size = 0;
		deny: mirror reflectsLargeObject;
		deny: mirror reflectsBytesObject;
		assert: mirror reflectedClass localName = 'UndefinedObject'
]

{ #category : #private }
ObjectMirrorTest >> test040UndefinedObjectMirror [
	| runtime nilMirror mirror |
	runtime := self runtime.
	nilMirror := runtime nil mirror.
	mirror := nilMirror reflectedBehavior methodDictionary.
	self
		assert: mirror reflectsMethodDictionary
]

{ #category : #private }
ObjectMirrorTest >> test100findSmalltalk [
	| smalltalk |
	"smalltalk := self runtime globalNamed: 'Smalltalk'."
	self
		assert: smalltalk reflectedClass localName
		equals: 'SmalltalkSystem'
]
