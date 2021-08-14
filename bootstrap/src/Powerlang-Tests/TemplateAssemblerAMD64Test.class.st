Class {
	#name : #TemplateAssemblerAMD64Test,
	#superclass : #AssemblerAMD64Test,
	#category : #'Powerlang-Tests-Assembler-JIT'
}

{ #category : #running }
TemplateAssemblerAMD64Test >> setUp [
	super setUp.
	assembler := TemplateAssemblerAMD64 new useAMD64.
	
]
