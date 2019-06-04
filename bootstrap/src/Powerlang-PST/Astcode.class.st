Class {
	#name : #Astcode,
	#superclass : #Object,
	#category : #'Powerlang-PST-Compiling'
}

{ #category : #visiting }
Astcode >> acceptVisitor: visitor [
	^self subclassResponsibility
]
