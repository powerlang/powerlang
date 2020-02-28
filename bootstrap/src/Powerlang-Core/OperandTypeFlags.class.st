Class {
	#name : #OperandTypeFlags,
	#superclass : #SharedPool,
	#classVars : [
		'ConstantType',
		'ImmediateType',
		'MemoryType',
		'RegisterGP',
		'RegisterGroupMask',
		'RegisterSIMD',
		'RegisterSegment',
		'RegisterSpecific',
		'RegisterType'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #'as yet unclassified' }
OperandTypeFlags class >> initialize [ 
MemoryType := 4.
RegisterGroupMask := 3840.
ConstantType := 2.
RegisterSIMD := 256.
ImmediateType := 1.
RegisterGP := 0.
RegisterType := 8.
RegisterSegment := 512.
RegisterSpecific := 768.

]
