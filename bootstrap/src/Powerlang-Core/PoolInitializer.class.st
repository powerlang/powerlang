Class {
	#name : #PoolInitializer,
	#superclass : #Object,
	#instVars : [
		'initialized'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #accessing }
PoolInitializer >> evaluate: aMethod [
	| pools ast stream evaluation source |
	pools := Dictionary new.
	ast := [ Compiler parse: aMethod sourceCode in: nil ]
		on: UndeclaredIdentifierError
		do: [ :e | 
			pools at: e identifier put: PoolDictionary new.
			e proceed ].
	stream := '' writeStream.
	stream nextPutAll: '| '.
	pools keys
		do: [ :id | stream nextPutAll: id ]
		separatedBy: [ stream nextPutAll: ' ' ].
	stream
		nextPutAll: ' |';
		cr.
	ast statements
		do: [ :s | 
			source := s source.
			stream nextPutAll: source.
			(source endsWith: '.') ifFalse: [ stream nextPut: $. ] ].
	stream
		cr;
		nextPutAll: '. Dictionary new '.
	pools
		keysDo: [ :id | 
			stream
				nextPutAll: 'at: #';
				nextPutAll: id;
				nextPutAll: ' put: ';
				nextPutAll: id;
				nextPutAll: ';' ].
	stream nextPutAll: ' yourself'.
	evaluation := Smalltalk compiler evaluate: stream contents.
	initialized addAll: evaluation
]

{ #category : #accessing }
PoolInitializer >> initialize [
	initialized := Dictionary new
]

{ #category : #accessing }
PoolInitializer >> initialize: aBehavior [
	| methods value |
	methods := aBehavior classSide methods
		select: [ :m | m selector beginsWith: 'initialize' ].
	methods do: [ :m | self silentEvaluate: m ].
	aBehavior
		classVariablesDo: [ :var | 
			value := initialized at: var name ifAbsent: nil.
			var propertyNamed: #value put: value ]
]

{ #category : #accessing }
PoolInitializer >> silentEvaluate: aMethod [
	[ self evaluate: aMethod ]
		on: Error
		do: [ Transcript
				print: 'Error evaluating initialization of ';
				print: aMethod; cr ]
]
