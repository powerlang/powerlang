Class {
	#name : #StaticBinder,
	#superclass : #IdentifierBinder,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'instance creation' }
StaticBinder class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #accessing }
StaticBinder >> at: aString [
	^contents at: aString ifAbsent: nil
]

{ #category : #accessing }
StaticBinder >> at: aString ifAbsentPut: aBlock [
	^contents at: aString ifAbsentPut: aBlock
]

{ #category : #accessing }
StaticBinder >> at: aString put: aBinding [
	contents at: aString put: aBinding
]

{ #category : #accessing }
StaticBinder >> define: aString as: aBinding [
	contents at: aString put: aBinding
]

{ #category : #accessing }
StaticBinder >> defines: identifier [
	^contents includesKey: identifier
]

{ #category : #accessing }
StaticBinder >> do: aBlock [
	contents do: aBlock
]

{ #category : #initialization }
StaticBinder >> initialize [
	super initialize.
	contents := OrderedDictionary new
]

{ #category : #printing }
StaticBinder >> printOn: aStream indent: anInteger [
	aStream tab: anInteger; nextPut: $<.
	contents keys
		do: [:name | name printOn: aStream]
		separatedBy: [aStream space].
	aStream nextPut: $>
]

{ #category : #accessing }
StaticBinder >> select: aBlock [
	^contents select: aBlock
]

{ #category : #accessing }
StaticBinder >> values [
	^contents values
]

{ #category : #accessing }
StaticBinder >> withIndexDo: aBlock [
	contents withIndexDo: aBlock
]
