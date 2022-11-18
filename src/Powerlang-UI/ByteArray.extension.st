Extension { #name : #ByteArray }

{ #category : #'*Powerlang-UI' }
ByteArray >> disassembledAmd64 [
	| filename output |
	filename := './assembled-binary'.
	filename asFileReference binaryWriteStreamDo: [ :s | s truncate; nextBytesPutAll: self ].
	output := LibC resultOfCommand:
		          'objdump -b binary -D -m i386:x86-64 -Mintel ' , filename.
	^output = '' ifTrue: [ output ] ifFalse: [('<.data>:' split: output) second]
]
