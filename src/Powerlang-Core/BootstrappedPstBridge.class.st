Class {
	#name : #BootstrappedPstBridge,
	#superclass : #SmalltalkBridge,
	#instVars : [
		'bootstrapper'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #accessing }
BootstrappedPstBridge >> bootstrapper: aSmalltalkBootstrapper [
	bootstrapper := aSmalltalkBootstrapper
]

{ #category : #initialization }
BootstrappedPstBridge >> findNilObject [
	^ nilObj := ObjectHandle
		on: runtime storage nilObject
		within: runtime
]

{ #category : #initialization }
BootstrappedPstBridge >> findRootObjects [
	nilObj := ObjectHandle on: bootstrapper nilObject within: runtime.
	trueObj := ObjectHandle on: bootstrapper trueObject within: runtime.
	falseObj := ObjectHandle on: bootstrapper falseObject within: runtime
]

{ #category : #accessing }
BootstrappedPstBridge >> updateGlobals [
	bootstrapper globals keysAndValuesDo: [:name :obj | objects at: name put: obj ]
]
