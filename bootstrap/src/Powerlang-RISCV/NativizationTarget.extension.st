Extension { #name : #NativizationTarget }

{ #category : '*Powerlang-RISCV' }
NativizationTarget class >> riscv64_linux_gnu [
	^ self new
		name:'riscv64-linux-gnu';
		wordSize: 8;
		abi: RV64GABI new;
		codeGeneratorClass: RV64GCodeGenerator;
		yourself
]
