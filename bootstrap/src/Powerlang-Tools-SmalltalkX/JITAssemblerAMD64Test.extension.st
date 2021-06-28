Extension { #name : #JITAssemblerAMD64Test }

{ #category : '*Powerlang-Tools-SmalltalkX' }
JITAssemblerAMD64Test >> assert: anObject equals: anotherObject [
	| asm |

	((anObject ~= anotherObject) and:[anObject isByteArray and:[anotherObject isByteArray]]) ifTrue: [ 
		(Smalltalk at: #UDIS86) isNil ifTrue: [ 
			Smalltalk loadPackage: 'jv:dragonfly/udis86sx'.
		].
		(Smalltalk at: #UDIS86) notNil ifTrue: [ 
			asm :=  Character cr 
					, ((Smalltalk at: #UDIS86) disassemble: anObject) 
					, Character cr , '---' , Character cr , Character cr
					, ((Smalltalk at: #UDIS86) disassemble: anotherObject) 
		].
	].

		self assert: anObject = anotherObject
				description: anObject printString, ' is not equal to ', anotherObject printString.

]
