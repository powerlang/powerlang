Extension { #name : #ClassOrganization }

{ #category : #'*Powerlang-Core' }
ClassOrganization >> selectorsFor: aString [
	| protocol |
	protocol := self protocolNamed: aString.
	^protocol methodSelectors

]
