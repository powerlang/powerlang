Class {
	#name : #VarsListModel,
	#superclass : #ComposablePresenter,
	#instVars : [
		'label',
		'variables'
	],
	#category : #'PST-PharoUI'
}

{ #category : #specs }
VarsListModel class >> defaultSpec [
	^ SpecColumnLayout composed
		add: #label height: self toolbarHeight;
		add: #variables;
		yourself
]

{ #category : #initialization }
VarsListModel >> initializeWidgets [
	variables := self newList.
	variables displayBlock: [ :varname | varname ].
	label := self newLabel.
	label label: 'Variables'.
	self focusOrder add: variables
]

{ #category : #initialization }
VarsListModel >> items: aCollection [
	variables items: aCollection
]

{ #category : #accessing }
VarsListModel >> label [
	^ label
]

{ #category : #accessing }
VarsListModel >> label: anObject [
	label := anObject
]

{ #category : #initialization }
VarsListModel >> resetSelection [
variables resetSelection
]

{ #category : #accessing }
VarsListModel >> variables [
	^ variables
]

{ #category : #'events-shortcuts' }
VarsListModel >> whenSelectedItemChanged: aBlock [
	variables whenSelectedItemChanged: aBlock
]
