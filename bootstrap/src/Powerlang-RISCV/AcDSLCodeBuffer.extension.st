Extension { #name : #AcDSLCodeBuffer }

{ #category : #'*Powerlang-RISCV' }
AcDSLCodeBuffer >> applyFixupsWith: aNativizer [
	| env cur |

	env := aNativizer labels copy.
	cur := address.
	instructions do: [:insn |
		insn binaryEncoding isSymbolic ifTrue: [ 
			aNativizer labels keysAndValuesDo: [ :label :target |
				env at: label put: target - cur
			].
			insn binaryEncoding: (insn binaryEncoding inEnvironment: env)  
		].
		cur := cur + (insn width // 8).
	].
]

{ #category : #'*Powerlang-RISCV' }
AcDSLCodeBuffer >> currentAddress [
	^ instructions inject: address into: [ :cursor :nextInsn | cursor + (nextInsn width // 8) ]
]

{ #category : #'*Powerlang-RISCV' }
AcDSLCodeBuffer >> reset [
]
