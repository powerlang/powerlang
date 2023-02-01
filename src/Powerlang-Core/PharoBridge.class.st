Class {
	#name : #PharoBridge,
	#superclass : #SmalltalkBridge,
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #initialization }
PharoBridge >> findRootObjects [
	nilObj := LocalHandle on: nil within: runtime.
	trueObj := LocalHandle on: true within: runtime.
	falseObj := LocalHandle on: false within: runtime
]
