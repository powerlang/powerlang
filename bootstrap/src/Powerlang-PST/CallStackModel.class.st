Class {
	#name : #CallStackModel,
	#superclass : #ComposablePresenter,
	#instVars : [
		'label',
		'frames'
	],
	#category : #'Powerlang-PST-PharoUI'
}

{ #category : #specs }
CallStackModel class >> defaultSpec [
	^ SpecColumnLayout composed
		add: #frames;
		yourself
]

{ #category : #accessing }
CallStackModel >> frames [
	^ frames
]

{ #category : #initialization }
CallStackModel >> initializeWidgets [
	frames := self newList.
	frames displayBlock: [ :c | c ].
	label := self newLabel.
	label label: 'Call stack'.
	self focusOrder add: frames
]

{ #category : #accessing }
CallStackModel >> items: aCollection [
	frames items: aCollection
]

{ #category : #accessing }
CallStackModel >> label [
	^ label
]

{ #category : #accessing }
CallStackModel >> resetSelection [
	frames resetSelection
]
