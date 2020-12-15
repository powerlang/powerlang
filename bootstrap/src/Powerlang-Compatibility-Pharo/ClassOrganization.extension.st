Extension { #name : #ClassOrganization }

{ #category : #'*Powerlang-Compatibility-Pharo' }
ClassOrganization >> selectorsFor: aString [
	| protocol |
	protocol := self protocolNamed: aString.
	^protocol methodSelectors

]
