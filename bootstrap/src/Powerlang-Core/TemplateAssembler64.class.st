"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #TemplateAssembler64,
	#superclass : #JITAssembler64,
	#category : #'Powerlang-Core-Assembler-JIT'
}

{ #category : #arithmetic }
TemplateAssembler64 >> addAtoR [
	self assembleBytes: #[16r48 16r1 16rD0].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> addDoubleX1toX0 [
	self assembleBytes: #[16rF2 16rF 16r58 16rC1].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> addSPtoT [
	self assembleBytes: #[16r48 16r1 16rE1].
	
]

{ #category : #logic }
TemplateAssembler64 >> addSPwithImmediate: imm [
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
TemplateAssembler64 >> addSslotsToSP [
	self assembleBytes: #[16r48 16r8D 16r24 16rF4].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> addTslotsToSP [
	self assembleBytes: #[16r48 16r8D 16r24 16rCC].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> addTtoR [
	self assembleBytes: #[16r48 16r1 16rC8].
	
]

{ #category : #logic }
TemplateAssembler64 >> andRwithA [
	self assembleBytes: #[16r48 16r21 16rD0].
	
]

{ #category : #logic }
TemplateAssembler64 >> andRwithImmediate: imm [
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

{ #category : #logic }
TemplateAssembler64 >> andTosWithImmediate: imm [
	(-128 <= imm and: [ imm < 128 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16r83 16r24 16r24];
				assembleByte: imm ].
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16r81 16r24 16r24];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r49 16rBB];
		assembleBytes: imm count: 8;
		assembleBytes: #[16r4C 16r21 16r1C 16r24]
]

{ #category : #private }
TemplateAssembler64 >> buildFrame [
	self assembleBytes: #[16r55 16r48 16r89 16rE5].
	
]

{ #category : #private }
TemplateAssembler64 >> callA [
	self assembleBytes: #[16rFF 16rD2].
	
]

{ #category : #private }
TemplateAssembler64 >> callIndirectA [
	self assembleBytes: #[16rFF 16r12].
	
]

{ #category : #private }
TemplateAssembler64 >> callR [
	self assembleBytes: #[16rFF 16rD0].
	
]

{ #category : #integers }
TemplateAssembler64 >> clearAintegerBit [
	self assembleBytes: #[16r48 16rFF 16rCA].
	
]

{ #category : #loading }
TemplateAssembler64 >> clearFPUFlags [
	self assembleBytes: #[16rDB 16rE2].
	
]

{ #category : #integers }
TemplateAssembler64 >> clearRhighHalf [
	self assembleBytes: #[16r89 16rC0].
	
]

{ #category : #integers }
TemplateAssembler64 >> clearRintegerBit [
	self assembleBytes: #[16r48 16rFF 16rC8].
	
]

{ #category : #integers }
TemplateAssembler64 >> clearSafeRintegerBit [
	self assembleBytes: #[16r24 16rFE].
	
]

{ #category : #comparing }
TemplateAssembler64 >> compareAwithImmediate: imm [
	(-128 <= imm and: [ imm < 128 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16r83 16rFA];
				assembleByte: imm ].
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16r81 16rFA];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r49 16rBB];
		assembleBytes: imm count: 8;
		assembleBytes: #[16r4C 16r39 16rDA]
]

{ #category : #loading }
TemplateAssembler64 >> compareEqualLargeX0withAindirect [
	self assembleBytes: #[16rF2 16rF 16rC2 16r2 16r0].
	
]

{ #category : #loading }
TemplateAssembler64 >> compareLessThanLargeX0withAindirect [
	self assembleBytes: #[16rF2 16rF 16rC2 16r2 16r1].
	
]

{ #category : #comparing }
TemplateAssembler64 >> compareRwithA [
	self assembleBytes: #[16r48 16r39 16rD0].
	
]

{ #category : #loading }
TemplateAssembler64 >> compareRwithEindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r3B 16r7]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r3B 16r47];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r3B 16r87];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateAssembler64 >> compareRwithFPindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r3B 16r45 16r0]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r3B 16r45];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r3B 16r85];
				assembleBytes: offset count: 4]
]

{ #category : #comparing }
TemplateAssembler64 >> compareRwithImmediate: imm [
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

{ #category : #comparing }
TemplateAssembler64 >> compareRwithS [
	self assembleBytes: #[16r48 16r39 16rF0].
	
]

{ #category : #loading }
TemplateAssembler64 >> compareRwithSindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r3B 16r6]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r3B 16r46];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r3B 16r86];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateAssembler64 >> compareRwithVindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r49 16r3B 16r3]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r49 16r3B 16r43];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r49 16r3B 16r83];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateAssembler64 >> compareSwithTindex: index [
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
TemplateAssembler64 >> compareTwithImmediate: imm [
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
TemplateAssembler64 >> convertAtoNativeInteger [
	self assembleBytes: #[16r48 16rD1 16rFA].
	
]

{ #category : #integers }
TemplateAssembler64 >> convertAtoSmallInteger [
	self assembleBytes: #[16r48 16rD1 16rE2 16r48 16rFF 16rC2].
	
]

{ #category : #integers }
TemplateAssembler64 >> convertRtoNativeInteger [
	self assembleBytes: #[16r48 16rD1 16rF8].
	
]

{ #category : #integers }
TemplateAssembler64 >> convertRtoSmallInteger [
	self assembleBytes: #[16r48 16rD1 16rE0 16r48 16rFF 16rC0].
	
]

{ #category : #integers }
TemplateAssembler64 >> convertTToNativeInteger [
	self assembleBytes: #[16r48 16rD1 16rF9].
	
]

{ #category : #integers }
TemplateAssembler64 >> convertTosToSmallInteger [
	self assembleBytes: #[16r48 16rD1 16r24 16r24 16r48 16rFF 16r4 16r24].
	
]

{ #category : #integers }
TemplateAssembler64 >> convertTtoNativeInteger [
	self assembleBytes: #[16r48 16rD1 16rF9].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> decR [
	self assembleBytes: #[16r48 16rFF 16rC8].
	
]

{ #category : #private }
TemplateAssembler64 >> decRindirect [
	self assembleBytes: #[16r48 16rFF 16r8].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> divideDoubleX0byX1 [
	self assembleBytes: #[16rF2 16rF 16r5E 16rC1].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> divideRbyT [
	self assembleBytes: #[16r48 16r99 16r48 16rF7 16rF9].
	
]

{ #category : #loading }
TemplateAssembler64 >> dropTopOfFPU [
	self assembleBytes: #[16rDD 16rD8].
	
]

{ #category : #loading }
TemplateAssembler64 >> dummyPointer [
	^16r1BADADD01BADADD0
]

{ #category : #integers }
TemplateAssembler64 >> ensureRintegerBit [
	self assembleBytes: #[16rC 16r1].
	
]

{ #category : #integers }
TemplateAssembler64 >> ensureSafeRintegerBit [
	self assembleBytes: #[16rC 16r1].
	
]

{ #category : #loading }
TemplateAssembler64 >> exchangeRindirectWithT [
	self assembleBytes: #[16r48 16r87 16r8].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> incA [
	self assembleBytes: #[16r48 16rFF 16rC2].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> incC [
	self assembleBytes: #[16r48 16rFF 16rC3].
	
]

{ #category : #private }
TemplateAssembler64 >> initializeS [
	self assembleBytes: #[16r48 16r89 16rC6].
	
]

{ #category : #private }
TemplateAssembler64 >> jumpIndirectA [
	self assembleBytes: #[16rFF 16r22].
	
]

{ #category : #comparing }
TemplateAssembler64 >> jumpToA [
	self assembleBytes: #[16rFF 16rE2].
	
]

{ #category : #comparing }
TemplateAssembler64 >> jumpToS [
	self assembleBytes: #[16rFF 16rE6].
	
]

{ #category : #loading }
TemplateAssembler64 >> jumpToTindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16rFF 16r21]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16rFF 16r61];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16rFF 16rA1];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateAssembler64 >> loadAwithAindex: index [
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
TemplateAssembler64 >> loadAwithEindex: index [
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
TemplateAssembler64 >> loadAwithFPindex: index [
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
TemplateAssembler64 >> loadAwithFalse [
	self assembleBytes: #[16r4C 16r89 16rF2]
]

{ #category : #loading }
TemplateAssembler64 >> loadAwithImmediate: imm [
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16rC7 16rC2];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r48 16rBA];
		assembleBytes: imm count: 8
]

{ #category : #loading }
TemplateAssembler64 >> loadAwithNil [
	self assembleBytes: #[16r4C 16r89 16rE2]
]

{ #category : #loading }
TemplateAssembler64 >> loadAwithR [
	self assembleBytes: #[16r48 16r89 16rC2].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadAwithRindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r10]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r50];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16r90];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateAssembler64 >> loadAwithRoffsetAtA [
	self assembleBytes: #[16r48 16r8B 16r14 16r10].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadAwithS [
	self assembleBytes: #[16r48 16r89 16rF2].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadAwithSindex: index [
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
TemplateAssembler64 >> loadAwithT [
	self assembleBytes: #[16r48 16r89 16rCA].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadAwithTrue [
	self assembleBytes: #[16r4C 16r89 16rEA]
]

{ #category : #integers }
TemplateAssembler64 >> loadEwithAddressOfRatA [
	self assembleBytes: #[16r48 16r8D 16r7C 16rD0 16rF8].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadEwithFPindex: index [
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
TemplateAssembler64 >> loadEwithImmediate: imm [
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16rC7 16rC7];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r48 16rBF];
		assembleBytes: imm count: 8
]

{ #category : #loading }
TemplateAssembler64 >> loadEwithR [
	self assembleBytes: #[16r48 16r89 16rC7].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadFPwithR [
	self assembleBytes: #[16r48 16r89 16rC5].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadFPwithSP [
	self assembleBytes: #[16r48 16r89 16rE5].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadLargeX0withRindirect [
	self assembleBytes: #[16r66 16r48 16rF 16r6E 16r0].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadLargeX1withAindirect [
	self assembleBytes: #[16r66 16r48 16rF 16r6E 16rA].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadLongRWithRAtOffsetA [
	self assembleBytes: #[16r8B 16r4 16r10].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadLongRwithRatOffsetA [
	self assembleBytes: #[16r8B 16r4 16r10].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadMXCSRfromA [
	self assembleBytes: #[16rF 16rAE 16r12].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadRConvertingDoubleRindirect [
	self assembleBytes: #[16rF2 16r48 16rF 16r2C 16r0].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadRconvertingDoublePointedByR [
	self assembleBytes: #[16rF2 16r48 16rF 16r2C 16r0].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadRwithA [
	self assembleBytes: #[16r48 16r89 16rD0].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadRwithArgPointer [
	self assembleBytes: #[16r48 16r8D 16r45 16r10].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadRwithE [
	self assembleBytes: #[16r48 16r89 16rF8].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadRwithEindex: index [
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
TemplateAssembler64 >> loadRwithFP [
	self assembleBytes: #[16r48 16r89 16rE8].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadRwithFPindex: index [
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
TemplateAssembler64 >> loadRwithFalse [
	self assembleBytes: #[16r4C 16r89 16rF0]
]

{ #category : #loading }
TemplateAssembler64 >> loadRwithImmediate: imm [
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16rC7 16rC0];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r48 16rB8];
		assembleBytes: imm count: 8
]

{ #category : #loading }
TemplateAssembler64 >> loadRwithM [
	self assembleBytes: #[16r48 16r89 16rD8]
]

{ #category : #loading }
TemplateAssembler64 >> loadRwithMindex: index [
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
TemplateAssembler64 >> loadRwithNil [
	self assembleBytes: #[16r4C 16r89 16rE0]
]

{ #category : #integers }
TemplateAssembler64 >> loadRwithRatA [
	self assembleBytes: #[16r48 16r8B 16r44 16rD0 16rF8].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadRwithRatOffsetA [
	self assembleBytes: #[16r48 16r8B 16r4 16r10].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadRwithRindex: index [
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
TemplateAssembler64 >> loadRwithS [
	self assembleBytes: #[16r48 16r89 16rF0].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadRwithSPindex: index [
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
TemplateAssembler64 >> loadRwithSindex: index [
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
TemplateAssembler64 >> loadRwithT [
	self assembleBytes: #[16r48 16r89 16rC8].
	
]

{ #category : #storing }
TemplateAssembler64 >> loadRwithTIBatIndexR [
	self assembleBytes: #[16r65 16r48 16r8B 16r4 16rC5 16r0 16r0 16r0 16r0].
	
]

{ #category : #storing }
TemplateAssembler64 >> loadRwithThreadVariableAtIndexR [
	self assembleBytes: #[16r65 16r48 16r8B 16r4 16rC5 16r80 16r14 16r0 16r0].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadRwithTindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r8B 16r1]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r8B 16r41];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r8B 16r81];
				assembleBytes: offset count: 4]
]

{ #category : #loading }
TemplateAssembler64 >> loadRwithTos [
	self assembleBytes: #[16r48 16r8B 16r4 16r24].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadRwithTrue [
	self assembleBytes: #[16r4C 16r89 16rE8]
]

{ #category : #loading }
TemplateAssembler64 >> loadRwithX0 [
	self assembleBytes: #[16r66 16r48 16rF 16r7E 16rC0].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadSPwithFP [
	self assembleBytes: #[16r48 16r89 16rEC].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadSPwithT [
	self assembleBytes: #[16r48 16r89 16rCC].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadSwithA [
	self assembleBytes: #[16r48 16r89 16rD6].
	
]

{ #category : #integers }
TemplateAssembler64 >> loadSwithAddressOfSatA [
	self assembleBytes: #[16r48 16r8D 16r74 16rD6 16rF8].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadSwithFPindex: index [
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
TemplateAssembler64 >> loadSwithImmediate: imm [
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16rC7 16rC6];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r48 16rBE];
		assembleBytes: imm count: 8
]

{ #category : #loading }
TemplateAssembler64 >> loadSwithRindex: index [
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
TemplateAssembler64 >> loadSwithT [
	self assembleBytes: #[16r48 16r89 16rCE].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadTwithA [
	self assembleBytes: #[16r48 16r89 16rD1].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadTwithAindex: index [
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
TemplateAssembler64 >> loadTwithEindex: index [
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
TemplateAssembler64 >> loadTwithFPindex: index [
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
TemplateAssembler64 >> loadTwithImmediate: imm [
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r48 16rC7 16rC1];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r48 16rB9];
		assembleBytes: imm count: 8
]

{ #category : #loading }
TemplateAssembler64 >> loadTwithR [
	self assembleBytes: #[16r48 16r89 16rC1].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadTwithTindex: index [
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
TemplateAssembler64 >> loadVwithImmediate: imm [
	(-16r80000000 <= imm and: [ imm < 16r80000000 ])
		ifTrue: [ ^ self
				assembleBytes: #[16r49 16rC7 16rC3];
				assembleBytes: imm count: 4 ].
	self
		assembleBytes: #[16r49 16rBB];
		assembleBytes: imm count: 8
]

{ #category : #loading }
TemplateAssembler64 >> loadX0withRasDouble [
	self assembleBytes: #[16rF2 16r48 16rF 16r2A 16rC0].
	
]

{ #category : #loading }
TemplateAssembler64 >> loadX1roundingX0 [
	self assembleBytes: #[16r66 16rF 16r3A 16rB 16rC8 16r3].
	
]

{ #category : #integers }
TemplateAssembler64 >> loadZeroExtendByteRwithRatA [
	self assembleBytes: #[16r48 16rF 16rB6 16r44 16r10 16rFF].
	
]

{ #category : #integers }
TemplateAssembler64 >> loadZeroExtendByteRwithSPatA [
	self assembleBytes: #[16r48 16rF 16rB6 16r44 16r14 16rFF].
	
]

{ #category : #integers }
TemplateAssembler64 >> loadZeroExtendLongRwithRatA [
	self assembleBytes: #[16r8B 16r44 16r90 16rFC].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> lock [
	self assembleBytes: #[16rF0].
	
]

{ #category : #'opcodes - integer related' }
TemplateAssembler64 >> moveTslots [
	self assembleBytes: #[16rF3 16r48 16rA5].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> multiplyDoubleX0byX1 [
	self assembleBytes: #[16rF2 16rF 16r59 16rC1].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> multiplyRbyA [
	self assembleBytes: #[16r48 16rF7 16rEA].
	
]

{ #category : #logic }
TemplateAssembler64 >> orRwithA [
	self assembleBytes: #[16r48 16r9 16rD0].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> popA [
	self assembleBytes: #[16r5A].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> popB [
	self assembleBytes: #[16r5B].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> popE [
	self assembleBytes: #[16r5F].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> popFP [
	self assembleBytes: #[16r5D].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> popR [
	self assembleBytes: #[16r58].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> popS [
	self assembleBytes: #[16r5E].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> popSP [
	self assembleBytes: #[16r5C].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> popSPindirect [
	self assembleBytes: #[16r8F 16r4 16r24].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> popT [
	self assembleBytes: #[16r59].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> pushA [
	self assembleBytes: #[16r52].
	
]

{ #category : #loading }
TemplateAssembler64 >> pushAOnFPUStack [
	self assembleBytes: #[16rDD 16r2].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> pushB [
	self assembleBytes: #[16r53].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> pushE [
	self assembleBytes: #[16r57].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> pushEindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16rFF 16r37]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16rFF 16r77];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16rFF 16rB7];
				assembleBytes: offset count: 4]
]

{ #category : #'push/pop' }
TemplateAssembler64 >> pushFP [
	self assembleBytes: #[16r55].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> pushFPindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16rFF 16r75 16r0]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16rFF 16r75];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16rFF 16rB5];
				assembleBytes: offset count: 4]
]

{ #category : #'push/pop' }
TemplateAssembler64 >> pushImmediate: imm [
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
TemplateAssembler64 >> pushIndirectR [
	self assembleBytes: #[16rFF 16r30].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> pushR [
	self assembleBytes: #[16r50].
	
]

{ #category : #loading }
TemplateAssembler64 >> pushROnFPUStack [
	self assembleBytes: #[16rDD 16r0].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> pushS [
	self assembleBytes: #[16r56].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> pushSP [
	self assembleBytes: #[16r54].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> pushSindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16rFF 16r36]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16rFF 16r76];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16rFF 16rB6];
				assembleBytes: offset count: 4]
]

{ #category : #'push/pop' }
TemplateAssembler64 >> pushT [
	self assembleBytes: #[16r51].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> pushTindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16rFF 16r31]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16rFF 16r71];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16rFF 16rB1];
				assembleBytes: offset count: 4]
]

{ #category : #'push/pop' }
TemplateAssembler64 >> pushVindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r41 16rFF 16r33]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r41 16rFF 16r73];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r41 16rFF 16rB3];
				assembleBytes: offset count: 4]
]

{ #category : #epilogue }
TemplateAssembler64 >> restoreCallerEnvironment [
	self assembleBytes: #[16r48 16r8B 16r7D 16rE8].
	
]

{ #category : #epilogue }
TemplateAssembler64 >> restoreCallerFrame [
	self assembleBytes: #[16r48 16r89 16rEC 16r5D].
	
]

{ #category : #epilogue }
TemplateAssembler64 >> restoreCallerM [
	self assembleBytes: #[16r48 16r8B 16r5D 16rF0]
]

{ #category : #epilogue }
TemplateAssembler64 >> restoreCallerSelf [
	self assembleBytes: #[16r48 16r8B 16r75 16rF8].
	
]

{ #category : #integers }
TemplateAssembler64 >> restoreRSmallInteger [
	self assembleBytes: #[16r48 16rD1 16rD0].
	
]

{ #category : #integers }
TemplateAssembler64 >> restoreRsmallInteger [
	self assembleBytes: #[16r48 16rD1 16rD0].
	
]

{ #category : #loading }
TemplateAssembler64 >> saveCallerFrame [
	self assembleBytes: #[16r55 16r48 16r89 16rE5].
	
]

{ #category : #loading }
TemplateAssembler64 >> scaleFloatOnRWithA [
	self assembleBytes: #[16rDD 16r2 16rDD 16r0 16rD9 16rFD 16rDD 16r18 16rDD 16rD8].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> shiftLeftRwithT [
	self assembleBytes: #[16r48 16rD3 16rE0].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> shiftRightRwithT [
	self assembleBytes: #[16r48 16rD3 16rF8].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> sqrtDoubleX0 [
	self assembleBytes: #[16rF2 16rF 16r51 16rC0].
	
]

{ #category : #storing }
TemplateAssembler64 >> storeAinSPatT [
	self assembleBytes: #[16r48 16r89 16r54 16rCC 16rF8].
	
]

{ #category : #storing }
TemplateAssembler64 >> storeAinThreadVariableAtIndexR [
	self assembleBytes: #[16r65 16r48 16r89 16r14 16rC5 16r80 16r14 16r0 16r0].
	
]

{ #category : #storing }
TemplateAssembler64 >> storeAinTindex: index [
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

{ #category : #integers }
TemplateAssembler64 >> storeArgumentsInStack [
	self assembleBytes: #[16r48 16r89 16r4D 16r10 16r48 16r89 16r55 16r18 16r4C 16r89 16r45 16r20 16r4C 16r89 16r4D 16r28].
	
]

{ #category : #storing }
TemplateAssembler64 >> storeByteTinRatA [
	self assembleBytes: #[16r88 16r4C 16r10 16rFF].
	
]

{ #category : #'push/pop' }
TemplateAssembler64 >> storeDoubleResultInRindirect [
	self assembleBytes: #[16r66 16r48 16rF 16r7E 16r0].
	
]

{ #category : #storing }
TemplateAssembler64 >> storeEinAindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r89 16r3A]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r89 16r7A];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r89 16rBA];
				assembleBytes: offset count: 4]
]

{ #category : #storing }
TemplateAssembler64 >> storeEinRindex: index [
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
TemplateAssembler64 >> storeLargeX0inA [
	self assembleBytes: #[16r66 16r48 16rF 16r7E 16r2].
	
]

{ #category : #loading }
TemplateAssembler64 >> storeLargeX0inR [
	self assembleBytes: #[16r66 16r48 16rF 16r7E 16r0].
	
]

{ #category : #loading }
TemplateAssembler64 >> storeLargeX0inT [
	self assembleBytes: #[16r66 16r48 16rF 16r7E 16r1].
	
]

{ #category : #storing }
TemplateAssembler64 >> storeLongTInRAtA [
	self assembleBytes: #[16r89 16r4C 16r90 16rFC].
	
]

{ #category : #storing }
TemplateAssembler64 >> storeLongTinRatA [
	self assembleBytes: #[16r89 16r4C 16r90 16rFC].
	
]

{ #category : #storing }
TemplateAssembler64 >> storeLongTinRatOffsetA [
	self assembleBytes: #[16r89 16rC 16r10].
	
]

{ #category : #loading }
TemplateAssembler64 >> storeMXCSRintoA [
	self assembleBytes: #[16rF 16rAE 16r1A].
	
]

{ #category : #storing }
TemplateAssembler64 >> storeRinAindex: index [
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
TemplateAssembler64 >> storeRinEindex: index [
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
TemplateAssembler64 >> storeRinFPindex: index [
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
TemplateAssembler64 >> storeRinSindex: index [
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
TemplateAssembler64 >> storeRinTindex: index [
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
TemplateAssembler64 >> storeShortTinRatOffsetA [
	self assembleBytes: #[16r66 16r89 16rC 16r10].
	
]

{ #category : #storing }
TemplateAssembler64 >> storeSinAindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r89 16r32]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r89 16r72];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r89 16rB2];
				assembleBytes: offset count: 4]
]

{ #category : #storing }
TemplateAssembler64 >> storeSinRindex: index [
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
TemplateAssembler64 >> storeTIBwithAatIndexR [
	self assembleBytes: #[16r65 16r48 16r89 16r14 16rC5 16r0 16r0 16r0 16r0].
	
]

{ #category : #storing }
TemplateAssembler64 >> storeTInRAtA [
	self assembleBytes: #[16r48 16r89 16r4C 16rD0 16rF8].
	
]

{ #category : #storing }
TemplateAssembler64 >> storeTinAindex: index [
	| offset |
	offset := index - 1 * wordSize.
	offset = 0 ifTrue: [^self assembleBytes: #[16r48 16r89 16rA]].
	(-128 <= offset and: [offset < 128])
		 ifTrue: [
			self
				assembleBytes: #[16r48 16r89 16r4A];
		 		assembleByte: offset]
		ifFalse: [ 
			self
				assembleBytes: #[16r48 16r89 16r8A];
				assembleBytes: offset count: 4]
]

{ #category : #storing }
TemplateAssembler64 >> storeTinRatA [
	self assembleBytes: #[16r48 16r89 16r4C 16rD0 16rF8].
	
]

{ #category : #storing }
TemplateAssembler64 >> storeTinRatOffsetA [
	self assembleBytes: #[16r48 16r89 16rC 16r10].
	
]

{ #category : #storing }
TemplateAssembler64 >> storeTinRindex: index [
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
TemplateAssembler64 >> subAfromR [
	self assembleBytes: #[16r48 16r29 16rD0].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> subAfromT [
	self assembleBytes: #[16r48 16r29 16rD1].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> subDoubleX1fromX0 [
	self assembleBytes: #[16rF2 16rF 16r5C 16rC1].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> subTslotsToSP [
	self assembleBytes: #[16r48 16rF7 16rD9 16r48 16r8D 16r24 16rCC 16r48 16rF7 16rD9].
	
]

{ #category : #integers }
TemplateAssembler64 >> testAintegerBit [
	self assembleBytes: #[16rF6 16rC2 16r1].
	
]

{ #category : #integers }
TemplateAssembler64 >> testRintegerBit [
	self assembleBytes: #[16rA8 16r1].
	
]

{ #category : #loading }
TemplateAssembler64 >> testRwithR [
	self assembleBytes: #[16r48 16r85 16rC0].
	
]

{ #category : #integers }
TemplateAssembler64 >> testTIntegerBit [
	self assembleBytes: #[16rF6 16rC1 16r1].
	
]

{ #category : #integers }
TemplateAssembler64 >> testTintegerBit [
	self assembleBytes: #[16rF6 16rC1 16r1].
	
]

{ #category : #arithmetic }
TemplateAssembler64 >> wordSize: anInteger [
	self ASSERT: anInteger = 8.
	super wordSize: anInteger
]

{ #category : #'opcodes - integer related' }
TemplateAssembler64 >> writeTslots [
	self assembleBytes: #[16rF3 16r48 16rAB].
	
]

{ #category : #logic }
TemplateAssembler64 >> xorAwithR [
	self assembleBytes: #[16r48 16r31 16rC2].
	
]

{ #category : #logic }
TemplateAssembler64 >> xorFPwithFP [
	self assembleBytes: #[16r48 16r31 16rED].
	
]

{ #category : #logic }
TemplateAssembler64 >> xorRwithA [
	self assembleBytes: #[16r48 16r31 16rD0].
	
]
