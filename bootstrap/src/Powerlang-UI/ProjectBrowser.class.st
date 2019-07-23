Class {
	#name : #ProjectBrowser,
	#superclass : #ComposablePresenter,
	#instVars : [
		'project',
		'classes',
		'instVars',
		'organization',
		'methods',
		'source'
	],
	#category : #'Powerlang-UI'
}

{ #category : #specs }
ProjectBrowser class >> defaultSpec [
	^ SpecLayout composed
		newRow: [ :row | 
			row
				add: #classes;
				add: #instVars;
				add: #organization;
				add: #methods ]
			origin: 0 @ 0
			corner: 1 @ 0.5;
		newRow: [ :row | row add: #source ] origin: 0 @ 0.5 corner: 1 @ 1;
		yourself
]

{ #category : #accessing }
ProjectBrowser >> classes [
	^ classes
]

{ #category : #api }
ProjectBrowser >> extent [
	^800 @ 600
]

{ #category : #api }
ProjectBrowser >> initializePresenter [
	classes
		whenSelectedItemChanged: [ :class | 
			self updateClass: class].
	instVars
		whenSelectedItemChanged: [ :ivar | ivar ifNotNil: [ organization resetSelection ] ].
	organization
		whenSelectedItemChanged: [ :category | category ifNotNil: [ methods resetSelection ] ]
]

{ #category : #api }
ProjectBrowser >> initializeWidgets [
	classes := self instantiate: ClassListModel.
	instVars := self instantiate: VarsListModel.
	organization := self instantiate: CategoryListModel.
	methods := self instantiate: MethodListModel.
	source := self instantiate: TextPresenter.
	source
		aboutToStyle: true;
		behavior: Object;
		beForCode
]

{ #category : #accessing }
ProjectBrowser >> instVars [
	^ instVars
]

{ #category : #accessing }
ProjectBrowser >> methods [
	^ methods
]

{ #category : #accessing }
ProjectBrowser >> organization [
	^ organization
]

{ #category : #accessing }
ProjectBrowser >> project: aProjectSpec [
	project := aProjectSpec. classes items: project classes
]

{ #category : #accessing }
ProjectBrowser >> source [
	^ source
]

{ #category : #api }
ProjectBrowser >> title [
	^ 'PowerST Class Browser'
]

{ #category : #api }
ProjectBrowser >> updateClass: aClassDefinition [
	| ivars categories |
	instVars resetSelection.
	organization resetSelection.
	methods resetSelection.
	aClassDefinition
		ifNil: [ ivars := categories := #() ]
		ifNotNil: [ ivars := aClassDefinition allInstVars
				, aClassDefinition allClassVars.
			categories := aClassDefinition protocols asSortedCollection ].
	instVars items: ivars.
	organization items: categories
]
