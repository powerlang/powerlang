Extension { #name : #OptimizingInstructionFragmenter }

{ #category : #'*Powerlang-Tools-SmalltalkX' }
OptimizingInstructionFragmenter class >> performedSelectors [
	^ super performedSelectors ,
	 (self selectors select: [:e | e startsWith: 'fragment' ])

	"
	self supported
	"

]
