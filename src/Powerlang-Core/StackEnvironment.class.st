Class {
	#name : #StackEnvironment,
	#superclass : #LocalEnvironment,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #accessing }
StackEnvironment >> index [
	^nil
]

{ #category : #private }
StackEnvironment >> isStack [
	^true
]
