Class {
	#name : #StackEnvironment,
	#superclass : #LocalEnvironment,
	#category : #'Powerlang-SCompiler-Bindings'
}

{ #category : #accessing }
StackEnvironment >> index [
	^nil
]

{ #category : #private }
StackEnvironment >> isStack [
	^true
]
