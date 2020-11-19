Class {
	#name : #LibrarySegmentBuilder,
	#superclass : #ImageSegmentBuilder,
	#instVars : [
		'kernelBuilder',
		'requiredSpecs',
		'imports'
	],
	#classVars : [
		'KernelSpec'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #building }
LibrarySegmentBuilder >> addClasses [

]

{ #category : #building }
LibrarySegmentBuilder >> importKernelObjects [
	self addImport: image nil; addImport: image true; addImport: image false
]

{ #category : #initialization }
LibrarySegmentBuilder >> initialize [
	super initialize.
	kernelBuilder := KernelSegmentBuilder new.

]

{ #category : #initialization }
LibrarySegmentBuilder >> spec [
	^ spec
]

{ #category : #initialization }
LibrarySegmentBuilder >> spec: anRGEnvironment [
	spec := anRGEnvironment
]
