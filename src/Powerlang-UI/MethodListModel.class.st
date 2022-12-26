Class {
	#name : #MethodListModel,
	#superclass : #ComposablePresenter,
	#instVars : [
		'label',
		'methods'
	],
	#category : #'Powerlang-UI'
}

{ #category : #specs }
MethodListModel class >> defaultSpec [
	^ SpecColumnLayout composed
		add: #label height: self toolbarHeight;
		add: #methods;
		yourself
]

{ #category : #initialization }
MethodListModel >> initializeWidgets [
	methods := self newList.
	methods displayBlock: [ :m | m selector ].
	label := self newLabel.
	label label: 'Methods'.
	self focusOrder add: methods
]

{ #category : #accessing }
MethodListModel >> items: aCollection [
	methods items: aCollection
]

{ #category : #accessing }
MethodListModel >> label [
	^ label
]

{ #category : #accessing }
MethodListModel >> methods [
	^ methods
]

{ #category : #'events-shortcuts' }
MethodListModel >> resetSelection [
methods resetSelection
]

{ #category : #'events-shortcuts' }
MethodListModel >> whenSelectedItemChanged: aBlock [
	methods whenSelectedItemChanged: aBlock
]
