Extension { #name : #RGEnvironment }

{ #category : #'*Powerlang-Core' }
RGEnvironment >> allClasses [
	| classes |
	
	classes := OrderedCollection new.
	self behaviorsDo:[:class | class isMeta ifFalse:[classes add: class]].
	classes sort:[:a :b | a name < b name ].
	^classes
]
