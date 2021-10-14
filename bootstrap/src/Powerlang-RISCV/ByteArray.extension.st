Extension { #name : #ByteArray }

{ #category : #'*Powerlang-RISCV' }
ByteArray >> disassembledRV64 [
	| isa |
	
	isa := AcProcessorDescriptions riscv64.
	^String streamContents: [ :out |
		1 to: self size by: 4 do: [ :idx |
			| enc insn |

			enc := self longAt: idx bigEndian: isa endian == Endian big.
			idx - 1 printOn: out. out tab.
			[
				insn := isa decode: enc. 
				out nextPutAll: insn disassemble.
			] on: Error do:[
				out nextPutAll: 'invalid'					
			].
			out cr.
		] 	
	].
]
