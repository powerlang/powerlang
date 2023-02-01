Extension { #name : #RGClassVariable }

{ #category : #'*Powerlang-Core' }
RGClassVariable >> association [
	^ self propertyNamed: #association
]

{ #category : #'*Powerlang-Core' }
RGClassVariable >> association: arg1 [
	^ self propertyNamed: #association put: arg1
]
