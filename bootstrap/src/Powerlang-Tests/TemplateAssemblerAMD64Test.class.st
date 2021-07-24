Class {
	#name : #TemplateAssemblerAMD64Test,
	#superclass : #JITAssemblerAMD64Test,
	#category : #'Powerlang-Tests-Assembler-JIT'
}

{ #category : #running }
TemplateAssemblerAMD64Test >> setUp [
	super setUp.
	assembler := TemplateAssemblerAMD64 new wordSize: 8.
	
]
