Extension { #name : #Object }

{ #category : #'*Powerlang-Tools-SmalltalkX' }
Object class >> performedSelectors [
	"Return a list of selectors in this class that are used 
	 via `#perform:...`. 

	 This is used by semi-automated search for possibly dead code.
	"
	^ #()

	"Created: / 11-05-2021 / 19:54:39 / Jan Vrany <jan.vrany@labware.com>"

]
