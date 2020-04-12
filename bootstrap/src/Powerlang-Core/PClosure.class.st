Class {
	#name : #PClosure,
	#superclass : #Array,
	#type : #variable,
	#instVars : [
		'block',
		'home'
	],
	#category : #'Powerlang-Core-PST'
}

{ #category : #accessing }
PClosure >> block [
	^block
]

{ #category : #accessing }
PClosure >> block: aPCompiledMethod [
	block := aPCompiledMethod
]

{ #category : #accessing }
PClosure >> home: anObject [
	home := anObject
]

{ #category : #accessing }
PClosure >> value [
	^home evaluateBlock: self
]

{ #category : #accessing }
PClosure >> value: anObject [
	^home evaluateBlock: self with: anObject
]

{ #category : #accessing }
PClosure >> value: anObject1 value: anObject2 [ 
	^ home evaluateBlock: self with: anObject1 with: anObject2
]

{ #category : #accessing }
PClosure >> value: anObject1 value: anObject2 with: anObject3 [
	^ home evaluateBlock: self with: anObject1 with: anObject2 with: anObject3
]
