Class {
	#name : #TopologicalSort,
	#superclass : #Object,
	#instVars : [
		'edges',
		'order',
		'graph',
		'open',
		'gray',
		'closed'
	],
	#category : #'Powerlang-Core-Misc'
}

{ #category : #sorting }
TopologicalSort class >> sort: edges [
	^self new
		edges: edges;
		run;
		order.
]

{ #category : #accessing }
TopologicalSort >> cycle [
	^gray asArray
]

{ #category : #accessing }
TopologicalSort >> edges: aCollection [
	edges := aCollection
]

{ #category : #accessing }
TopologicalSort >> order [
	^order
]

{ #category : #private }
TopologicalSort >> prepare [
	order := OrderedCollection new.
	gray := OrderedCollection new.
	graph := Dictionary new.
	open := Set new.
	closed := Set new.
	edges do: [:edge | 
		(graph at: edge key ifAbsentPut: [Set new]) add: edge value.
		open add: edge key; add: edge value]
]

{ #category : #running }
TopologicalSort >> run [
	self prepare.
	[open isEmpty] whileFalse: [self visit: open anyOne].
	^self order
]

{ #category : #private }
TopologicalSort >> visit: node [
	(open includes: node)
		ifTrue: [
			open remove: node.
			gray add: node.
			graph at: node ifPresent: [:nodes | nodes do: [:n | self visit: n]].
			gray remove: node.
			closed add: node.
			order add: node]
		ifFalse: [
			(closed includes: node) ifFalse: [
				gray add: node.
				self error:'Cycle detected!']]
]
