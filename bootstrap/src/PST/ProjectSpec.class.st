Class {
	#name : #ProjectSpec,
	#superclass : #Object,
	#instVars : [
		'name',
		'path',
		'classes'
	],
	#category : #'PST-Specification'
}

{ #category : #actions }
ProjectSpec >> classNamed: aStringOrNil [
	^classes at: aStringOrNil ifAbsent: nil
]

{ #category : #accessing }
ProjectSpec >> classes [
	^ classes values
]

{ #category : #initialization }
ProjectSpec >> initialize [
	classes := OrderedDictionary new
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
	names do: [:name | self loadEmptyClass: name]; do: [ :name | self parseClassDefinition: name ]
]

{ #category : #actions }
ProjectSpec >> loadEmptyClass: name [
	| class |
	class := ClassDefinition new name: name.
	classes at: name put: class
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
	definition loadFrom: parser document within: self
]

{ #category : #accessing }
ProjectSpec >> path [
	^ path
]

{ #category : #accessing }
ProjectSpec >> path: aPath [
	path := aPath
]
