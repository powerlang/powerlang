Class {
	#name : #AMD64TemplateAssemblerTest,
	#superclass : #AMD64CodeGeneratorTest,
	#category : #'Powerlang-Tests-Assembler-JIT'
}

{ #category : #running }
AMD64TemplateAssemblerTest >> setUp [
	super setUp.
	assembler := AMD64TemplateAssembler forTarget: NativizationTarget x86_64_linux_gnu.
	
]
