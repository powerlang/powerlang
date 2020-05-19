Class {
	#name : #NativeCode,
	#superclass : #Object,
	#instVars : [
		'code',
		'references',
		'entryPoints',
		'fresh'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #'as yet unclassified' }
NativeCode class >> code: code references: references [
	^self new code: code references: references
]

{ #category : #'as yet unclassified' }
NativeCode >> code [
	^code
]

{ #category : #'as yet unclassified' }
NativeCode >> code: bytes references: aCollection [
	code := bytes.
	references := aCollection asArray.
	fresh := false.

]

{ #category : #'as yet unclassified' }
NativeCode >> disassembledAmd64 [
	| filename output |
	filename := './assembled-binary'.
	filename asFileReference binaryWriteStreamDo: [ :s | 
		s nextBytesPutAll: code ].
	output := LibC resultOfCommand:
		  'objdump -b binary -D -m i386:x86-64 -Mintel ' , filename.
	^('<.data>:' split: output) second
]
