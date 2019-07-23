Class {
	#name : #Mirror,
	#superclass : #Object,
	#instVars : [
		'handle'
	],
	#category : #'Powerlang-Core-Mirrors'
}

{ #category : #'instance creation' }
Mirror class >> on: handle [
	^self new handle: handle
]

{ #category : #'meta accessing' }
Mirror >> asLocalInteger [
	^handle asLocalInteger
]

{ #category : #'meta accessing' }
Mirror >> associationMirrorOn: methodDictionaryHandle [
	^AssociationMirror on: methodDictionaryHandle
]

{ #category : #'meta accessing' }
Mirror >> behaviorMirrorOn: behaviorHandle [
	^BehaviorMirror on: behaviorHandle
]

{ #category : #'meta accessing' }
Mirror >> classMirrorOn: classHandle [
	^ClassMirror on: classHandle
]

{ #category : #'meta accessing' }
Mirror >> compiledMethodMirrorOn: methodDictionaryHandle [
	^CompiledMethodMirror on: methodDictionaryHandle
]

{ #category : #'meta accessing' }
Mirror >> dictionaryMirrorOn: classHandle [
	^DictionaryMirror on: classHandle
]

{ #category : #'meta accessing' }
Mirror >> handle [
	^handle
]

{ #category : #'meta accessing' }
Mirror >> handle: anObjectHandle [
	handle := anObjectHandle
]

{ #category : #'meta accessing' }
Mirror >> metaclassMirrorOn: classHandle [
	^MetaclassMirror on: classHandle
]

{ #category : #'meta accessing' }
Mirror >> methodDictionaryMirrorOn: methodDictionaryHandle [
	^MethodDictionaryMirror on: methodDictionaryHandle
]

{ #category : #'meta accessing' }
Mirror >> objectMirrorOn: objectHandle [
	^ObjectMirror on: objectHandle
]

{ #category : #'meta accessing' }
Mirror >> speciesMirrorOn: classHandle [
	^SpeciesMirror on: classHandle
]
