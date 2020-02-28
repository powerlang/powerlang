"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #SegmentPrefix,
	#superclass : #InstructionPrefix,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #'instance creation' }
SegmentPrefix class >> cs [
	^self new name: 'cs:'; value: 16r2E
]

{ #category : #'instance creation' }
SegmentPrefix class >> ds [
	^self new name: 'ds:'; value: 16r3E
]

{ #category : #'instance creation' }
SegmentPrefix class >> es [
	^self new name: 'es:'; value: 16r26
]

{ #category : #'instance creation' }
SegmentPrefix class >> fs [
	^self new name: 'fs:'; value: 16r64
]

{ #category : #'instance creation' }
SegmentPrefix class >> gs [
	^self new name: 'gs:'; value: 16r65
]

{ #category : #'instance creation' }
SegmentPrefix class >> named: aString [
	| string char |
	aString size < 2 ifTrue: [^nil].
	string := aString asLowercase.
	(string at: 2) = $s ifFalse: [^nil].
	char := string at: 1.
	char = $c ifTrue: [^self cs].
	char = $s ifTrue: [^self ss].
	char = $d ifTrue: [^self ds].
	char = $e ifTrue: [^self es].
	char = $f ifTrue: [^self fs].
	char = $g ifTrue: [^self gs].
	^nil
]

{ #category : #services }
SegmentPrefix class >> peekFrom: aStream [
	(aStream peekFor: 16r2E) ifTrue: [^self cs].
	(aStream peekFor: 16r3E) ifTrue: [^self ds].
	(aStream peekFor: 16r26) ifTrue: [^self es].
	(aStream peekFor: 16r64) ifTrue: [^self fs].
	(aStream peekFor: 16r65) ifTrue: [^self gs].
	^nil
]

{ #category : #'instance creation' }
SegmentPrefix class >> ss [
	^self new name: 'ss:'; value: 16r36
]

{ #category : #testing }
SegmentPrefix >> isSegment [
	^true
]

{ #category : #services }
SegmentPrefix >> register [
	^Register named: name allButLast
]

{ #category : #accessing }
SegmentPrefix >> value [
	^value
]

{ #category : #accessing }
SegmentPrefix >> value: aInteger [
	value := aInteger
]

{ #category : #writing }
SegmentPrefix >> writeOn: instruction [
	instruction writeSegmentPrefix: value
]
