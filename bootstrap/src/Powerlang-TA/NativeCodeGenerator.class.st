Class {
	#name : #NativeCodeGenerator,
	#superclass : #Object,
	#instVars : [
		'codeStream'
	],
	#category : #'Powerlang-TA'
}

{ #category : #'as yet unclassified' }
NativeCodeGenerator >> code [
	^codeStream contents 
]

{ #category : #'as yet unclassified' }
NativeCodeGenerator >> initialize [ 
	codeStream := WriteStream on: #[].
]

{ #category : #'as yet unclassified' }
NativeCodeGenerator >> spitAll: bvs [ 
	bvs do: [ :bv |
		self spit: bv ].

]
