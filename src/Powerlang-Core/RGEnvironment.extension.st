Extension { #name : #RGEnvironment }

{ #category : #'*Powerlang-Core' }
RGEnvironment >> allClasses [
	| classes |
	classes := OrderedCollection new.
	self
		behaviorsDo: [ :class | 
			class isMeta
				ifFalse: [ classes add: class ] ].
	classes sort: [ :a :b | a name < b name ].
	^ classes
		select: [ :c | 
			c isRingResolved
				and: [ c metaclass isRingResolved and: [ c superclass isRingResolved ] ] ]
]

{ #category : #'*Powerlang-Core' }
RGEnvironment >> allExtensionClasses [
	| classes |
	classes := OrderedCollection new.
	self
		behaviorsDo: [ :class | 
			class isMeta
				ifFalse: [ classes add: class ] ].
	classes sort: [ :a :b | a name < b name ].
	^ classes
		select:
			[ :c | c isRingResolved andNot: [ c superclass isRingResolved ] ]
]
