Class {
	#name : #VirtualMetaclass,
	#superclass : #VirtualSpecies,
	#instVars : [
		'class'
	],
	#category : #'Powerlang-Core-Emulation'
}

{ #category : #'accessing - parallel hierarchy' }
VirtualMetaclass >> allInstVarNames [
	^(spec environment at: #Class) allInstVarNames, spec allInstVarNames
]

{ #category : #'accessing - parallel hierarchy' }
VirtualMetaclass >> class: aVirtualClass [
	class := aVirtualClass
]

{ #category : #'accessing - parallel hierarchy' }
VirtualMetaclass >> classPool [
	^ class classPool
]

{ #category : #'accessing - parallel hierarchy' }
VirtualMetaclass >> createClassAssociationsWith: aVirtualSmalltalkImage [

]

{ #category : #'accessing - parallel hierarchy' }
VirtualMetaclass >> instanceSide [
	^class
]

{ #category : #'accessing - parallel hierarchy' }
VirtualMetaclass >> localPools [
	^ class localPools
]

{ #category : #'accessing - parallel hierarchy' }
VirtualMetaclass >> sharedPoolsUsing: globals [
	^class sharedPoolsUsing: globals
]
