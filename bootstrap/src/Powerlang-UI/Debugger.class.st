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
		'stackManager',
		'stateManager',
		'smalltalk',
		'native',
		'backtrace',
		'stack',
		'variables',
		'registers',
		'memory',
		'threads'
	],
	#category : #'Powerlang-UI'
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
				newRow: [ :row | 
					row
						add: #smalltalk right: 0.4;
						add: #native ] ]
			right: 0.3;
		newColumn: [ :col | 
			col
				add: #threads height: self buttonHeight * 2.5;
				add: #stackManager height: self buttonHeight * 6;
				add: #stateManager ];
		yourself
]

{ #category : #accessing }
Debugger >> backtrace [
	^ backtrace
]

{ #category : #accessing }
Debugger >> extent [
	^ 1200 @ 600
]

{ #category : #initialization }
Debugger >> initializeMemoryViews [
	| tab |
	variables := self instantiate: VarsListModel.
	variables items: #().
	registers := self instantiate: VarsListModel.
	memory := self instantiate: VarsListModel.
	stateManager := self newTabManager.
	tab := self newTab.
	tab
		presenter: variables;
		label: 'Variables';
		closeable: false.
	stateManager addTab: tab.
	tab := self newTab.
	tab
		presenter: registers;
		label: 'Registers';
		closeable: false.
	tab := self newTab.
	tab
		presenter: memory;
		label: 'Memory';
		closeable: false.
	stateManager addTab: tab
]

{ #category : #initialization }
Debugger >> initializeSourceViews [
	smalltalk := self instantiate: TextPresenter.
	smalltalk
		aboutToStyle: true;
		behavior: Object;
		beForCode.
	native := self instantiate: TextPresenter.
	native
		aboutToStyle: false;
		behavior: Object
]

{ #category : #initialization }
Debugger >> initializeStackViews [
	| tab |
	backtrace := self instantiate: CallStackModel.
	backtrace
		items:
			{}.
	stack := self instantiate: CallStackModel.
	stackManager := self newTabManager.
	tab := self newTab.
	tab
		presenter: backtrace;
		label: 'Backtrace';
		closeable: false.
	stackManager addTab: tab.
	tab := self newTab.
	tab
		presenter: stack;
		label: 'Stack';
		closeable: false.
	stackManager addTab: tab
]

{ #category : #initialization }
Debugger >> initializeStepButtons [
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
]

{ #category : #initialization }
Debugger >> initializeThreadView [
	threads := self instantiate: ThreadListModel
]

{ #category : #initialization }
Debugger >> initializeWidgets [
	self
		initializeStepButtons;
		initializeSourceViews;
		initializeThreadView;
		initializeStackViews;
		initializeMemoryViews
]

{ #category : #accessing }
Debugger >> memory [
	^ memory
]

{ #category : #accessing }
Debugger >> native [
	^ native
]

{ #category : #accessing }
Debugger >> proceed [
	^ proceed
]

{ #category : #accessing }
Debugger >> registers [
	^ registers
]

{ #category : #accessing }
Debugger >> restart [
	^ restart
]

{ #category : #accessing }
Debugger >> smalltalk [
	^ smalltalk
]

{ #category : #accessing }
Debugger >> stack [
	^ stack
]

{ #category : #accessing }
Debugger >> stackManager [
	^ stackManager
]

{ #category : #accessing }
Debugger >> stateManager [
	^ stateManager
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

{ #category : #initialization }
Debugger >> threads [
	^threads
]

{ #category : #accessing }
Debugger >> title [
	^ 'Powerlang Debugger'
]

{ #category : #accessing }
Debugger >> variables [
	^ variables
]
