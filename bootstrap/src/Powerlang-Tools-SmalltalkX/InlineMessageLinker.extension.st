Extension { #name : #InlineMessageLinker }

{ #category : #'*Powerlang-Tools-SmalltalkX' }
InlineMessageLinker class >> performedSelectors [
	^ self supported collect: [ :assoc | assoc value ]

	"
	self supported
	"

]
