Class {
	#name : #Debugger,
	#superclass : #ComposablePresenter,
	#instVars : [
		'proceed',
		'restart',
		'stepInto',
		'stepThrough',
		'stepOver',
		'stepOut',
		'source',
		'stack',
		'variables'
	],
	#category : #'Powerlang-PST-PharoUI'
}

{ #category : #specs }
Debugger class >> defaultSpec [
	^ SpecRowLayout composed
		newColumn: [ :col | 
			col
				newRow: [ :row | 
					row
						add: #proceed;
						add: #restart;
						add: #stepInto;
						add: #stepThrough;
						add: #stepOver;
						add: #stepOut ]
					height: self buttonHeight;
				add: #source ] right: 0.4;
		newColumn: [ :col | 
			col
				add: #stack;
				add: #variables ];
		yourself
]

{ #category : #accessing }
Debugger >> extent [
	^ 1200 @ 600
]

{ #category : #initialization }
Debugger >> initializeWidgets [
	proceed := self newButton
		label: 'Proceed';
		icon: (self iconNamed: #glamorousGo).
	restart := self newButton
		label: 'Restart';
		icon: (self iconNamed: #glamorousRestart).
	stepInto := self newButton
		label: 'Step Into';
		icon: (self iconNamed: #glamorousInto).
	stepThrough := self newButton
		label: 'Step Through';
		icon: (self iconNamed: #glamorousThrough).
	stepOver := self newButton
		label: 'Step Over';
		icon: (self iconNamed: #glamorousOver).
	stepOut := self newButton
		label: 'Step Out';
		icon: (self iconNamed: #glamorousUp).
	source := self instantiate: TextPresenter.
	source
		aboutToStyle: true;		behavior: Object;
		beForCode.
	stack := self instantiate: CallStackModel.
	variables := self instantiate: VarsListModel
]

{ #category : #accessing }
Debugger >> proceed [
	^ proceed
]

{ #category : #accessing }
Debugger >> restart [
	^ restart
]

{ #category : #accessing }
Debugger >> source [
	^ source
]

{ #category : #accessing }
Debugger >> stack [
	^ stack
]

{ #category : #accessing }
Debugger >> stepInto [
	^ stepInto
]

{ #category : #accessing }
Debugger >> stepOut [
	^ stepOut
]

{ #category : #accessing }
Debugger >> stepOver [
	^ stepOver
]

{ #category : #accessing }
Debugger >> stepThrough [
	^ stepThrough
]

{ #category : #accessing }
Debugger >> title [
	^'PowerST Debugger'
]

{ #category : #accessing }
Debugger >> variables [
	^ variables
]
