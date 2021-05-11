Extension { #name : #OptimizingBlockInliner }

{ #category : #'*Powerlang-Tools-SmalltalkX' }
OptimizingBlockInliner class >> performedSelectors [
	^ super performedSelectors , 
	  self basicNew inliners collect: [ :e | #inline , e capitalized , 'in:' ]

	"
	self supported
	"

]
