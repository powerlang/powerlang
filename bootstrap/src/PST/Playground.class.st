Class {
	#name : #Playground,
	#superclass : #ComposablePresenter,
	#instVars : [
		'classBrowser',
		'debugger',
		'transcript',
		'workspace'
	],
	#category : #'PST-PharoUI'
}

{ #category : #specs }
Playground class >> defaultSpec [
	^ SpecColumnLayout composed
		newRow: [ :row | 
			row
				add: #classBrowser;
				add: #debugger ]
			height: self buttonHeight;
		"newRow: [ :row | row add: #transcript ];
		newRow: [ :row | row add: #workspace ];"
			yourself
]

{ #category : #accessing }
Playground >> classBrowser [
	^classBrowser
]

{ #category : #accessing }
Playground >> debugger [
	^ debugger
]

{ #category : #initialization }
Playground >> initializeWidgets [
	classBrowser := self newButton
		label: 'ClassBrowser';
		icon: (self iconNamed: #smallWindow).
	debugger := self newButton
		label: 'Debugger';
		icon: (self iconNamed: #smallDebug)
]

{ #category : #initialization }
Playground >> title [
	^ 'PowerST Playground'
]
