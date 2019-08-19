Class {
	#name : #PharoBridge,
	#superclass : #SmalltalkBridge,
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #initialization }
PharoBridge >> findRootObjects [
	nilObj := LocalHandle new target: nil; runtime: runtime.
	trueObj := LocalHandle new target: true; runtime: runtime.
	falseObj := LocalHandle new target: false; runtime: runtime
]
