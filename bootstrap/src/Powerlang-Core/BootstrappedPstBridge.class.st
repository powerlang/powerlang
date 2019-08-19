Class {
	#name : #BootstrappedPstBridge,
	#superclass : #SmalltalkBridge,
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #initialization }
BootstrappedPstBridge >> findNilObject [
	^ nilObj := ObjectHandle on: runtime storage nilObject within: runtime
]

{ #category : #initialization }
BootstrappedPstBridge >> findRootObjects [
	nilObj := ObjectHandle
		on: runtime storage nilObject
		within: runtime.
		
	trueObj := ObjectHandle
		on: runtime storage trueObject
		within: runtime.
		
	falseObj := ObjectHandle
		on: runtime storage falseObject
		within: runtime.
]
