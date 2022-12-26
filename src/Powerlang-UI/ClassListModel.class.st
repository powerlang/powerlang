Class {
	#name : #ClassListModel,
	#superclass : #ComposablePresenter,
	#instVars : [
		'label',
		'classes'
	],
	#category : #'Powerlang-UI'
}

{ #category : #specs }
ClassListModel class >> defaultSpec [
	^ SpecColumnLayout composed
		add: #label height: self toolbarHeight;
		add: #classes;
		yourself
]

{ #category : #accessing }
ClassListModel >> classes [
	^ classes
]

{ #category : #initialization }
ClassListModel >> initializeWidgets [
	classes := self newList.
	classes
		displayBlock: [ :c | c name ].
	label := self newLabel.
	label label: 'Classes'.
	self focusOrder add: classes
]

{ #category : #api }
ClassListModel >> items: aCollection [
	classes items: aCollection
]

{ #category : #accessing }
ClassListModel >> label [
	^ label
]

{ #category : #api }
ClassListModel >> whenSelectedItemChanged: aBlock [
	classes whenSelectedItemChanged: aBlock
]
