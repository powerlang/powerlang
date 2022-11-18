Class {
	#name : #ThreadListModel,
	#superclass : #ComposablePresenter,
	#instVars : [
		'label',
		'classes'
	],
	#category : #'Powerlang-UI'
}

{ #category : #specs }
ThreadListModel class >> defaultSpec [
	^ SpecColumnLayout composed
		add: #label height: self toolbarHeight;
		add: #classes;
		yourself
]

{ #category : #accessing }
ThreadListModel >> classes [
	^ classes
]

{ #category : #initialization }
ThreadListModel >> initializeWidgets [
	classes := self newList.
	classes displayBlock: [ :c | c name ].
	label := self newLabel.
	label label: 'Threads'.
	self focusOrder add: classes
]

{ #category : #api }
ThreadListModel >> items: aCollection [
	classes items: aCollection
]

{ #category : #accessing }
ThreadListModel >> label [
	^ label
]

{ #category : #api }
ThreadListModel >> whenSelectedItemChanged: aBlock [
	classes whenSelectedItemChanged: aBlock
]
