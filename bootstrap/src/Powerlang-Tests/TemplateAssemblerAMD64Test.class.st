Class {
	#name : #TemplateAssemblerAMD64Test,
	#superclass : #AssemblerAMD64Test,
	#category : #'Powerlang-Tests-Assembler-JIT'
}

{ #category : #running }
TemplateAssemblerAMD64Test >> setUp [
	super setUp.
	assembler := TemplateNativizerAMD64 forTarget: NativizationTarget x86_64_linux_gnu.
	
]
