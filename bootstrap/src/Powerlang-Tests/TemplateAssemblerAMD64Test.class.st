Class {
	#name : #TemplateAssemblerAMD64Test,
	#superclass : #JITAssemblerAMD64Test,
	#category : #'Powerlang-Tests-Assembler-JIT'
}

{ #category : #running }
TemplateAssemblerAMD64Test >> setUp [
	super setUp.
	assembler := JITAssembler new useTemplateAMD64.
	
]
