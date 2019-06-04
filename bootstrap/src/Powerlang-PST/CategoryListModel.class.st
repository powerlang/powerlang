Class {
	#name : #CategoryListModel,
	#superclass : #ComposablePresenter,
	#instVars : [
		'label',
		'categories'
	],
	#category : #'Powerlang-PST-PharoUI'
}

{ #category : #specs }
CategoryListModel class >> defaultSpec [
	^ SpecColumnLayout composed
		add: #label height: self toolbarHeight;
		add: #categories;
		yourself
]

{ #category : #accessing }
CategoryListModel >> categories [
	^categories
]

{ #category : #initialization }
CategoryListModel >> initializeWidgets [
	categories := self newList.
	label := self newLabel.
	label label: 'Protocol'.
	self focusOrder add: categories
]

{ #category : #accessing }
CategoryListModel >> items: aCollection [
	categories items: aCollection
]

{ #category : #accessing }
CategoryListModel >> label [
	^label
]

{ #category : #accessing }
CategoryListModel >> label: aText [
label label: aText
]

{ #category : #accessing }
CategoryListModel >> resetSelection [
	categories resetSelection
]

{ #category : #accessing }
CategoryListModel >> whenSelectedItemChanged: aBlock [
	categories whenSelectedItemChanged: aBlock
]
