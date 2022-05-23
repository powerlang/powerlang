Class {
	#name : #LMRObject,
	#superclass : #Object,
	#category : #'Powerlang-Core-Execution-LMR'
}

{ #category : #accessing }
LMRObject >> at: index [
	"Return indexed value at given index, starting with 1. This CANNOT be 
	 used for accessing named slots (aka, instance variables), to access 
	 them use #instVarAt:"
	
	self subclassResponsibility  
]

{ #category : #accessing }
LMRObject >> at: index put: value [
	"Set indexed value at given `index` to `value`. This CANNOT be used for 
	 setting named slots (aka, instance variables), to access them use 
	 #instVarAt:put:"
	
	self subclassResponsibility  
]

{ #category : #accessing }
LMRObject >> isBytes [
	^ false
]

{ #category : #accessing }
LMRObject >> isImmediate [
	^false
]
