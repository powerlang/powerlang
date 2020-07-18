Class {
	#name : #ARMCodeGenerator,
	#superclass : #NativeCodeGenerator,
	#category : #'Powerlang-TA'
}

{ #category : #services }
ARMCodeGenerator class >> compiler [
	^super compiler addPlugin: PDLOpalPlugin 
]

{ #category : #services }
ARMCodeGenerator class >> template [
	^ARMCodeGenerator  >> #templateMethod
]

{ #category : #'as yet unclassified' }
ARMCodeGenerator >> load: r withImmediate: imm [ 
	"TODO: implement things that cant be rotated"
	<armv5: 'mov {r}, #{imm}'> 

]

{ #category : #'as yet unclassified' }
ARMCodeGenerator >> spit: bv [ 
	codeStream nextPutAll: bv asLEByteArray
]

{ #category : #'as yet unclassified' }
ARMCodeGenerator >> templateMethod [
	| instr theEnvironment |
	theEnvironment := Dictionary new .
	1. 2. 3. 4. 5. 6. 7. 8.
	instr := #theInstruction.
	^self spitAll: (instr inEnvironment: theEnvironment)
]
