"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #TemplateNativizerAMD64,
	#superclass : #Nativizer,
	#instVars : [
		'wordSize'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #arithmetic }
TemplateNativizerAMD64 >> addAtoR [
	self assembleBytes: #[16r48 16r1 16rD0].
	
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> addDoubleX1toX0 [
	self assembleBytes: #[16rF2 16rF 16r58 16rC1].
	
]

{ #category : #logic }
TemplateNativizerAMD64 >> addSPwithImmediate: imm [
	(-128 <= imm and: [ imm < 128 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16r83 16rC4];
				assembleByte: imm ].
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16r81 16rC4];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r49 16rBB];
		assembleBytes: imm count: 8;
		assembleBytes: #[16r4C 16r1 16rDC]
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> addTtoR [
	self assembleBytes: #[16r48 16r1 16rC8].
	
]

{ #category : #logic }
TemplateNativizerAMD64 >> andRwithA [
	self assembleBytes: #[16r48 16r21 16rD0].
	
]

{ #category : #logic }
TemplateNativizerAMD64 >> andRwithImmediate: imm [
	(-128 <= imm and: [ imm < 128 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16r83 16rE0];
				assembleByte: imm ].
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16r25];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r49 16rBB];
		assembleBytes: imm count: 8;
		assembleBytes: #[16r4C 16r21 16rD8]
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> assembleByte: anInteger [
	codegen assembleByte: anInteger
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> assembleBytes: aByteArray [
	codegen assembleBytes: aByteArray
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> assembleBytes: value count: count [
	codegen assembleBytes: value count: count

]

{ #category : #private }
TemplateNativizerAMD64 >> buildFrame [
	self assembleBytes: #[16r55 16r48 16r89 16rE5].
	
]

{ #category : #private }
TemplateNativizerAMD64 >> callIndirectA [
	self assembleBytes: #[16rFF 16r12].
	
]

{ #category : #private }
TemplateNativizerAMD64 >> callR [
	self assembleBytes: #[16rFF 16rD0].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> clearFPUFlags [
	self assembleBytes: #[16rDB 16rE2].
	
]

{ #category : #integers }
TemplateNativizerAMD64 >> clearRhigh32 [
	self assembleBytes: #[16r89 16rC0].
	
]

{ #category : #integers }
TemplateNativizerAMD64 >> clearRintegerBit [
	self assembleBytes: #[16r48 16rFF 16rC8].
	
]

{ #category : #integers }
TemplateNativizerAMD64 >> clearSafeRintegerBit [
	self assembleBytes: #[16r24 16rFE].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> compareEqualDoubleX0withAindirect [
	self assembleBytes: #[16rF2 16rF 16rC2 16r2 16r0].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> compareLessThanDoubleX0withAindirect [
	self assembleBytes: #[16rF2 16rF 16rC2 16r2 16r1].
	
]

{ #category : #comparing }
TemplateNativizerAMD64 >> compareRwithA [
	self assembleBytes: #[16r48 16r39 16rD0].
	
]

{ #category : #comparing }
TemplateNativizerAMD64 >> compareRwithImmediate: imm [
	(-128 <= imm and: [ imm < 128 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16r83 16rF8];
				assembleByte: imm ].
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16r3D];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r49 16rBB];
		assembleBytes: imm count: 8;
		assembleBytes: #[16r4C 16r39 16rD8]
]

{ #category : #loading }
TemplateNativizerAMD64 >> compareSwithTindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r3B 16r31]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r3B 16r71];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r3B 16rB1];
				assembleBytes: offset count: 4]
]

{ #category : #comparing }
TemplateNativizerAMD64 >> compareTwithImmediate: imm [
	(-128 <= imm and: [ imm < 128 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16r83 16rF9];
				assembleByte: imm ].
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16r81 16rF9];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r49 16rBB];
		assembleBytes: imm count: 8;
		assembleBytes: #[16r4C 16r39 16rD9]
]

{ #category : #integers }
TemplateNativizerAMD64 >> convertAtoNativeInteger [
	self assembleBytes: #[16r48 16rD1 16rFA].
	
]

{ #category : #integers }
TemplateNativizerAMD64 >> convertRtoNativeInteger [
	self assembleBytes: #[16r48 16rD1 16rF8].
	
]

{ #category : #integers }
TemplateNativizerAMD64 >> convertRtoSmallInteger [
	self assembleBytes: #[16r48 16rD1 16rE0 16r48 16rFF 16rC0].
	
]

{ #category : #integers }
TemplateNativizerAMD64 >> convertTtoNativeInteger [
	self assembleBytes: #[16r48 16rD1 16rF9].
	
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> divideDoubleX0byX1 [
	self assembleBytes: #[16rF2 16rF 16r5E 16rC1].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> dropTopOfFPU [
	self assembleBytes: #[16rDD 16rD8].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> exchangeRindirectWithT [
	self assembleBytes: #[16r48 16r87 16r8].
	
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> extendRtoAandDividebyT [
	self assembleBytes: #[16r48 16r99 16r48 16rF7 16rF9].
	
]

{ #category : #private }
TemplateNativizerAMD64 >> initializeS [
	self assembleBytes: #[16r48 16r89 16rC6].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadAwithAindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r12]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r52];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16r92];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadAwithEindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r17]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r57];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16r97];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadAwithFPindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r55 16r0]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r55];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16r95];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadAwithFalse [
	self assembleBytes: #[16r4C 16r89 16rF2]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadAwithImmediate: imm [
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16rC7 16rC2];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r48 16rBA];
		assembleBytes: imm count: 8
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadAwithNil [
	self assembleBytes: #[16r4C 16r89 16rE2]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadAwithR [
	self assembleBytes: #[16r48 16r89 16rC2].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadAwithRoffsetAtA [
	self assembleBytes: #[16r48 16r8B 16r14 16r10].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadAwithS [
	self assembleBytes: #[16r48 16r89 16rF2].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadAwithSindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r16]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r56];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16r96];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadAwithTrue [
	self assembleBytes: #[16r4C 16r89 16rEA]
]

{ #category : #integers }
TemplateNativizerAMD64 >> loadEwithAddressOfRatA [
	self assembleBytes: #[16r48 16r8D 16r7C 16rD0 16rF8].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadEwithFPindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r7D 16r0]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r7D];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16rBD];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadEwithR [
	self assembleBytes: #[16r48 16r89 16rC7].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadFPwithR [
	self assembleBytes: #[16r48 16r89 16rC5].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadFPwithSP [
	self assembleBytes: #[16r48 16r89 16rE5].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadLargeX0withRindirect [
	self assembleBytes: #[16r66 16r48 16rF 16r6E 16r0].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadLargeX1withAindirect [
	self assembleBytes: #[16r66 16r48 16rF 16r6E 16rA].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadLongRwithRatOffsetA [
	self assembleBytes: #[16r8B 16r4 16r10].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadMXCSRfromA [
	self assembleBytes: #[16rF 16rAE 16r12].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> loadMwithA [
	self assembleBytes: #[16r48 16r89 16rD3]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRconvertingDoublePointedByR [
	self assembleBytes: #[16rF2 16r48 16rF 16r2C 16r0].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithA [
	self assembleBytes: #[16r48 16r89 16rD0].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithArgPointer [
	self assembleBytes: #[16r48 16r8D 16r45 16r10].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithE [
	self assembleBytes: #[16r48 16r89 16rF8].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithEindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r7]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r47];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16r87];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithFP [
	self assembleBytes: #[16r48 16r89 16rE8].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithFPindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r45 16r0]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r45];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16r85];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithFalse [
	self assembleBytes: #[16r4C 16r89 16rF0]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithImmediate: imm [
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16rC7 16rC0];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r48 16rB8];
		assembleBytes: imm count: 8
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithM [
	self assembleBytes: #[16r48 16r89 16rD8]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithMindex: index [
	| offset |
	offset := (index - 1) * wordSize.
	offset = 0
		ifTrue: [ ^ self assembleBytes: #[16r48 16r8B 16r03] ].
	(-128 <= offset and: [ offset < 128 ])
		ifTrue: [ self
				assembleBytes: #[16r48 16r8B 16r43];
				assembleByte: offset ]
		ifFalse: [ self
				assembleBytes: #[16r48 16r8B 16r83];
				assembleBytes: offset count: 4 ]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithNil [
	self assembleBytes: #[16r4C 16r89 16rE0]
]

{ #category : #integers }
TemplateNativizerAMD64 >> loadRwithRatA [
	self assembleBytes: #[16r48 16r8B 16r44 16rD0 16rF8].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithRatOffsetA [
	self assembleBytes: #[16r48 16r8B 16r4 16r10].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithRindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r0]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r40];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16r80];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithS [
	self assembleBytes: #[16r48 16r89 16rF0].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithSPindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r4 16r24]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r44 16r24];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16r84 16r24];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithSindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r6]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r46];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16r86];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithT [
	self assembleBytes: #[16r48 16r89 16rC8].
	
]

{ #category : #storing }
TemplateNativizerAMD64 >> loadRwithTIBatR [
	self assembleBytes: #[16r65 16r48 16r8B 16r4 16rC5 16r0 16r0 16r0 16r0].
	
]

{ #category : #storing }
TemplateNativizerAMD64 >> loadRwithThreadVariableAtR [
	self assembleBytes: #[16r65 16r48 16r8B 16r4 16rC5 16r80 16r14 16r0 16r0].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadRwithTrue [
	self assembleBytes: #[16r4C 16r89 16rE8]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadSPwithFP [
	self assembleBytes: #[16r48 16r89 16rEC].
	
]

{ #category : #integers }
TemplateNativizerAMD64 >> loadSwithAddressOfSatA [
	self assembleBytes: #[16r48 16r8D 16r74 16rD6 16rF8].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadSwithFPindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r75 16r0]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r75];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16rB5];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadSwithRindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r30]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r70];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16rB0];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadTwithA [
	self assembleBytes: #[16r48 16r89 16rD1].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadTwithAindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16rA]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r4A];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16r8A];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadTwithEindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16rF]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r4F];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16r8F];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadTwithFPindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r4D 16r0]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r4D];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16r8D];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadTwithImmediate: imm [
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16rC7 16rC1];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r48 16rB9];
		assembleBytes: imm count: 8
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadTwithR [
	self assembleBytes: #[16r48 16r89 16rC1].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadTwithTindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r9]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r49];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16r89];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> loadX0withRasDouble [
	self assembleBytes: #[16rF2 16r48 16rF 16r2A 16rC0].
	
]

{ #category : #integers }
TemplateNativizerAMD64 >> loadZeroExtendByteRwithRatA [
	self assembleBytes: #[16r48 16rF 16rB6 16r44 16r10 16rFF].
	
]

{ #category : #integers }
TemplateNativizerAMD64 >> loadZeroExtendByteRwithSPatA [
	self assembleBytes: #[16r48 16rF 16rB6 16r44 16r14 16rFF].
	
]

{ #category : #integers }
TemplateNativizerAMD64 >> loadZeroExtendLongRwithRatA [
	self assembleBytes: #[16r8B 16r44 16r90 16rFC].
	
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> lock [
	self assembleBytes: #[16rF0].
	
]

{ #category : #'opcodes - integer related' }
TemplateNativizerAMD64 >> moveTslots [
	self assembleBytes: #[16rF3 16r48 16rA5].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> moveX0toR [
	self assembleBytes: #[16r66 16r48 16rF 16r7E 16rC0].
	
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> multiplyDoubleX0byX1 [
	self assembleBytes: #[16rF2 16rF 16r59 16rC1].
	
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> multiplyRbyAwideningToA [
	self assembleBytes: #[16r48 16rF7 16rEA].
	
]

{ #category : #logic }
TemplateNativizerAMD64 >> orRwithA [
	self assembleBytes: #[16r48 16r9 16rD0].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> popA [
	self assembleBytes: #[16r5A].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> popE [
	self assembleBytes: #[16r5F].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> popFP [
	self assembleBytes: #[16r5D].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> popR [
	self assembleBytes: #[16r58].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> popS [
	self assembleBytes: #[16r5E].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> popSPindirect [
	self assembleBytes: #[16r8F 16r4 16r24].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> popT [
	self assembleBytes: #[16r59].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> pushA [
	self assembleBytes: #[16r52].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> pushAOnFPUStack [
	self assembleBytes: #[16rDD 16r2].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> pushE [
	self assembleBytes: #[16r57].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> pushFP [
	self assembleBytes: #[16r55].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> pushImmediate: imm [
	(-128 <= imm and: [ imm < 128 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r6A];
				assembleByte: imm ].
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r68];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r49 16rBB];
		assembleBytes: imm count: 8;
		assembleBytes: #[16r41 16r53]
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> pushIndirectR [
	self assembleBytes: #[16rFF 16r30].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> pushR [
	self assembleBytes: #[16r50].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> pushROnFPUStack [
	self assembleBytes: #[16rDD 16r0].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> pushS [
	self assembleBytes: #[16r56].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> pushT [
	self assembleBytes: #[16r51].
	
]

{ #category : #epilogue }
TemplateNativizerAMD64 >> restoreCallerEnvironment [
	self assembleBytes: #[16r48 16r8B 16r7D 16rE8].
	
]

{ #category : #epilogue }
TemplateNativizerAMD64 >> restoreCallerFrame [
	self assembleBytes: #[16r48 16r89 16rEC 16r5D].
	
]

{ #category : #epilogue }
TemplateNativizerAMD64 >> restoreCallerM [
	self assembleBytes: #[16r48 16r8B 16r5D 16rF0]
]

{ #category : #epilogue }
TemplateNativizerAMD64 >> restoreCallerSelf [
	self assembleBytes: #[16r48 16r8B 16r75 16rF8].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> roundDoubleX0intoX1 [
	self assembleBytes: #[16r66 16rF 16r3A 16rB 16rC8 16r3].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> saveCallerFrame [
	self assembleBytes: #[16r55 16r48 16r89 16rE5].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> scaleFloatOnRWithA [
	self assembleBytes: #[16rDD 16r2 16rDD 16r0 16rD9 16rFD 16rDD 16r18 16rDD 16rD8].
	
]

{ #category : #integers }
TemplateNativizerAMD64 >> setRintegerBit [
	self assembleBytes: #[16rC 16r1].
	
]

{ #category : #integers }
TemplateNativizerAMD64 >> setSafeRintegerBit [
	self assembleBytes: #[16rC 16r1].
	
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> shiftLeftRwithT [
	self assembleBytes: #[16r48 16rD3 16rE0].
	
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> shiftRightRwithT [
	self assembleBytes: #[16r48 16rD3 16rF8].
	
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> sqrtDoubleX0 [
	self assembleBytes: #[16rF2 16rF 16r51 16rC0].
	
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeAinThreadVariableAtIndexR [
	self assembleBytes: #[16r65 16r48 16r89 16r14 16rC5 16r80 16r14 16r0 16r0].
	
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeAinTindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r89 16r11]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r89 16r51];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r89 16r91];
				assembleBytes: offset count: 4]
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeByteTinRatA [
	self assembleBytes: #[16r88 16r4C 16r10 16rFF].
	
]

{ #category : #'push/pop' }
TemplateNativizerAMD64 >> storeDoubleResultInRindirect [
	self assembleBytes: #[16r66 16r48 16rF 16r7E 16r0].
	
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeEinRindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r89 16r38]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r89 16r78];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r89 16rB8];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateNativizerAMD64 >> storeLargeX0inA [
	self assembleBytes: #[16r66 16r48 16rF 16r7E 16r2].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> storeLargeX0inT [
	self assembleBytes: #[16r66 16r48 16rF 16r7E 16r1].
	
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeLongTinRatA [
	self assembleBytes: #[16r89 16r4C 16r90 16rFC].
	
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeLongTinRatOffsetA [
	self assembleBytes: #[16r89 16rC 16r10].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> storeMXCSRintoA [
	self assembleBytes: #[16rF 16rAE 16r1A].
	
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeRinAindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r89 16r2]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r89 16r42];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r89 16r82];
				assembleBytes: offset count: 4]
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeRinEindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r89 16r7]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r89 16r47];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r89 16r87];
				assembleBytes: offset count: 4]
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeRinFPindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r89 16r45 16r0]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r89 16r45];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r89 16r85];
				assembleBytes: offset count: 4]
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeRinSindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r89 16r6]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r89 16r46];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r89 16r86];
				assembleBytes: offset count: 4]
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeRinTindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r89 16r1]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r89 16r41];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r89 16r81];
				assembleBytes: offset count: 4]
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeShortTinRatOffsetA [
	self assembleBytes: #[16r66 16r89 16rC 16r10].
	
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeSinRindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r89 16r30]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r89 16r70];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r89 16rB0];
				assembleBytes: offset count: 4]
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeTIBatRwithA [
	self assembleBytes: #[16r65 16r48 16r89 16r14 16rC5 16r0 16r0 16r0 16r0].
	
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeTinRatA [
	self assembleBytes: #[16r48 16r89 16r4C 16rD0 16rF8].
	
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeTinRatOffsetA [
	self assembleBytes: #[16r48 16r89 16rC 16r10].
	
]

{ #category : #storing }
TemplateNativizerAMD64 >> storeTinRindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r89 16r8]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r89 16r48];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r89 16r88];
				assembleBytes: offset count: 4]
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> subAfromR [
	self assembleBytes: #[16r48 16r29 16rD0].
	
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> subAfromT [
	self assembleBytes: #[16r48 16r29 16rD1].
	
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> subDoubleX1fromX0 [
	self assembleBytes: #[16rF2 16rF 16r5C 16rC1].
	
]

{ #category : #arithmetic }
TemplateNativizerAMD64 >> subTslotsToSP [
	self assembleBytes: #[16r48 16rF7 16rD9 16r48 16r8D 16r24 16rCC 16r48 16rF7 16rD9].
	
]

{ #category : #initialization }
TemplateNativizerAMD64 >> target: aNativizationTarget [
	super target: aNativizationTarget.
	wordSize := aNativizationTarget wordSize.
]

{ #category : #integers }
TemplateNativizerAMD64 >> testRintegerBit [
	self assembleBytes: #[16rA8 16r1].
	
]

{ #category : #loading }
TemplateNativizerAMD64 >> testRwithR [
	self assembleBytes: #[16r48 16r85 16rC0].
	
]

{ #category : #'opcodes - integer related' }
TemplateNativizerAMD64 >> writeTslots [
	self assembleBytes: #[16rF3 16r48 16rAB].
	
]

{ #category : #logic }
TemplateNativizerAMD64 >> xorAwithR [
	self assembleBytes: #[16r48 16r31 16rC2].
	
]

{ #category : #logic }
TemplateNativizerAMD64 >> xorFPwithFP [
	self assembleBytes: #[16r48 16r31 16rED].
	
]

{ #category : #logic }
TemplateNativizerAMD64 >> xorRwithA [
	self assembleBytes: #[16r48 16r31 16rD0].
	
]
