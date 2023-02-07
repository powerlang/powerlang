"
I represent entities in a remote Runtime. My subclasses determine
which kind of entity: ObjectHandles have an `oid` to uniquely referencing
an object of that runtime, FrameHandles have a `frame` to refer to a
particular stack frame in a frozen process of that runtime.

I could be seen as a lower-level mirror
"
Class {
	#name : #Handle,
	#superclass : #Object,
	#instVars : [
		'runtime'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'meta accessing' }
Handle >> handleOn: objectId [
	^self class on: objectId within: runtime
]

{ #category : #'meta accessing' }
Handle >> isLocal [
	^runtime isLocal
]

{ #category : #'meta accessing' }
Handle >> objectHandleOn: objectId [
	^ ObjectHandle on: objectId within: runtime
]

{ #category : #accessing }
Handle >> runtime [
	^runtime
]

{ #category : #accessing }
Handle >> runtime: aRuntime [
	runtime := aRuntime
]
