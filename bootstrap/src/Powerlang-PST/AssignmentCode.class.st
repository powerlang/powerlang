Class {
	#name : #AssignmentCode,
	#superclass : #Astcode,
	#instVars : [
		'assignees',
		'expression'
	],
	#category : #'Powerlang-PST-Compiling'
}

{ #category : #'as yet unclassified' }
AssignmentCode class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeAssignment
]

{ #category : #accessing }
AssignmentCode >> assign: anIdentifierCode [
	assignees add: anIdentifierCode
]

{ #category : #accessing }
AssignmentCode >> assignees [
	^assignees
]

{ #category : #accessing }
AssignmentCode >> expression [
	^expression
]

{ #category : #accessing }
AssignmentCode >> expression: anAstcode [
	expression := anAstcode
]

{ #category : #accessing }
AssignmentCode >> initialize [
	assignees := OrderedCollection new
]

{ #category : #testing }
AssignmentCode >> isAssign [
	^true
]

{ #category : #printing }
AssignmentCode >> printOn: aStream [
	aStream nextPutAll: '{AssignmentId. '.
	assignees
		do: [ :identifier | identifier printOn: aStream ]
		separatedBy: [ aStream nextPutAll: '. ' ].
	aStream nextPutAll: '. '.
	expression printOn: aStream.
	aStream nextPutAll: '}'
]
