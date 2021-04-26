Extension { #name : #Smalltalk }

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
Smalltalk class >> host [
	"Return current host identification string (that is, identification
	of machine the smalltalk is currently running on). 

	The format of the string is that of GNU triplets except that 'vendor'
	part is ommited (mostly unused these days anyway). 

	Examples:   
					* x86_64-linux-gnu 
					* x86_64-win32
					* riscv64-linux-gnu
	"

	| triplet i1 i2 |

	triplet := self configuration.
	i1 := triplet indexOf: $-.
	i2 := triplet indexOf: $- startingAt: i1 + 1.
	^ (triplet copyTo: i1 -1 ) , '-' , (triplet copyFrom: i2 + 1)

	"
	Smalltalk host
	ABI currentClass
	"

	"Created: / 13-04-2021 / 14:54:17 / Jan Vrany <jan.vrany@labware.com>"

]
