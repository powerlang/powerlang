Class {
	#name : #ProjectSpec,
	#superclass : #Object,
	#instVars : [
		'name',
		'path',
		'module'
	],
	#category : #'Powerlang-Core-Specification'
}

{ #category : #'as yet unclassified' }
ProjectSpec class >> kernel [
		^ProjectSpec new
		name: 'kernel';
		path: '../pst/kernel' asFileReference;
		load.
]

{ #category : #actions }
ProjectSpec >> classNamed: aStringOrNil [
	^module resolveClass: aStringOrNil
]

{ #category : #accessing }
ProjectSpec >> classes [
	^ module classes
]

{ #category : #actions }
ProjectSpec >> compilerFor: classname [
	| class |
	class := self classNamed: classname.
	^Compiler forClass: class
]

{ #category : #initialization }
ProjectSpec >> initialize [
	module := ModuleSpec new
]

{ #category : #actions }
ProjectSpec >> load [
	| project classnames |
	project := path / 'package.st'
		readStreamDo: [ :stream | 
			stream upToAll: 'Package '.
			 STON fromStream: stream ].
	classnames := project at: #classes.
	self loadClasses: classnames
]

{ #category : #actions }
ProjectSpec >> loadClasses: names [
	names
		do: [ :n | self loadEmptyClass: n ];
		do: [ :n | self parseClassDefinition: n ]
]

{ #category : #actions }
ProjectSpec >> loadEmptyClass: classname [
	| class |
	class := ClassSpec new name: classname; module: module.
	module addEmptyClass: class
]

{ #category : #initialization }
ProjectSpec >> module [
	^module
]

{ #category : #accessing }
ProjectSpec >> name [
	^ name
]

{ #category : #accessing }
ProjectSpec >> name: aString [
	name := aString
]

{ #category : #actions }
ProjectSpec >> parseClassDefinition: classname [
	| filename stream parser definition |
	filename := path / (classname , '.st').
	stream := filename asFileReference readStream.
	parser := TonelParser on: stream.
	definition := self classNamed: classname.
	definition fromTonel: parser document within: self
]

{ #category : #accessing }
ProjectSpec >> path [
	^ path
]

{ #category : #accessing }
ProjectSpec >> path: aPath [
	path := aPath
]
