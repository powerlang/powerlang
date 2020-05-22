Class {
	#name : #InlineMessageLinker,
	#superclass : #MessageLinker,
	#instVars : [
		'selector',
		'assembler'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #accessing }
InlineMessageLinker class >> availableInliners [
	^ self supported collect: [ :selector | self for: selector ] 
]

{ #category : #'instance creation' }
InlineMessageLinker class >> for: selector [
	^ self new selector: selector 
]

{ #category : #private }
InlineMessageLinker class >> supported [
	| answer selectors | 
	answer := OrderedCollection new.
	selectors := self organization selectorsFor:
		             #'private - instance behavior'.
	selectors do: [ :selector | 
		| cm |
		cm := self >> selector.
		cm literals
			select: [ :literal | 
			literal isString and: [ literal beginsWith: '_' ] ]
			in: answer ].
	^ answer
]

{ #category : #private }
InlineMessageLinker >> argumentCount [
	^selector arity 
]

{ #category : #nativizing }
InlineMessageLinker >> assemble [
	self emitPrologue.
	self assembleForMemory isNil and: [
		self assembleForHeaders isNil and: [
			self assembleForObjects isNil and: [
				self assembleForMath isNil and: [
					self assembleEvents isNil
						and: [self assembleHelpers isNil and: [self ASSERT: false. assembler breakpoint]]]]]] 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleAsFloatInto [
	assembler loadX0withRasDouble; storeLargeX0inA.
	self readFloatStatus 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleAsNative [
	| noninteger |
	noninteger := assembler labeledIntegerBitTestOfR.
	assembler convertRtoNativeInteger; @ noninteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleAsObject [
	assembler clearSafeRintegerBit 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleAsPointer [
	| nonInteger |
	nonInteger := assembler labeledIntegerBitTestOfR.
	assembler convertRtoNativeInteger; @ nonInteger; ensureSafeRintegerBit 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleAsSmallInteger [
	assembler convertRtoSmallInteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleBasicAt [
	| oop |
	oop := assembler labeledIntegerNativizationOfA.
	assembler loadRwithRatA; @ oop 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleBasicAtPut [
	| nonInteger |
	nonInteger := assembler labeledIntegerNativizationOfA.
	assembler storeTinRatA; @ nonInteger; loadRwithT 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleBasicCopyFromToWith [
	assembler
		pushE;
		convertAtoNativeInteger;
		convertTtoNativeInteger;
		loadEwithAddressOfRatA;
		loadSwithAddressOfSatA;
		subAfromT;
		addToTconstant: 1;
		moveTslots;
		popE 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleBasicFlags [
	self emitByteAtOffset: _Flags 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleBasicFlagsPut [
	self emitByteAtOffsetPut: _Flags 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleBasicHash [
	assembler loadZeroExtendShortRwithRoffset: _Hash; convertRtoSmallInteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleBasicHashPut [
	| nonInteger |
	nonInteger := assembler labeledIntegerNativizationOfA.
	assembler storeShortAinRoffset: _Hash; @ nonInteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleBasicSize [
	self emitByteAtOffset: _SmallSize 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleBasicSizePut [
	self emitByteAtOffsetPut: _SmallSize 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleBasicULongAt [
	| nonInteger |
	nonInteger := assembler labeledIntegerNativizationOfA.
	assembler loadZeroExtendLongRwithRatA; @ nonInteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleBasicULongAtPut [
	| nonInteger |
	nonInteger := assembler labeledIntegerNativizationOfA.
	assembler storeLongTinRatA; @ nonInteger; loadRwithT 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleBeCurrent [
	assembler loadRwithRindex: 1; clearSafeRintegerBit; loadFPwithR 
]

{ #category : #'as yet unclassified' }
InlineMessageLinker >> assembleBeEnvironment [
	assembler loadEwithR 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleBeFramePointer [
	assembler storeRinFPindex: 1 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleBitShiftLeft [
	| success |
	success := assembler newLabel.
	assembler
		loadTwithA;
		loadAwithR;
		clearSafeRintegerBit;
		convertTtoNativeInteger;
		shiftLeftRwithT;
		ensureSafeRintegerBit;
		pushR;
		shiftRightRwithT;
		ensureSafeRintegerBit;
		compareRwithA;
		popR;
		shortJumpIfEqualTo: success.
	self loadObject: nil.
	assembler @ success 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleBitShiftRight [
	assembler
		move: assembler regA to: assembler regT;
		convertToNativeInteger: assembler regT;
		shiftRight: assembler regR by: assembler regT b;
		setIntegerBit: assembler regR 
]

{ #category : #'as yet unclassified' }
InlineMessageLinker >> assembleBusyWait [
	| loop |
	loop := assembler newLabel.
	assembler
		loadTwithImmediate: 0;
		@ loop;
		exchangeRindirectWithT;
		compareTwithImmediate: 0;
		shortJumpIfEqualTo: loop 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleByteAt [
	| nonInteger |
	nonInteger := assembler labeledIntegerNativizationOfA.
	assembler
		loadZeroExtendByteRwithRatA;
		convertRtoSmallInteger;
		@ nonInteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleByteAtPut [
	| nonInteger1 nonInteger2 |
	nonInteger1 := assembler labeledIntegerNativizationOfA.
	nonInteger2 := assembler labeledIntegerNativizationOfT.
	assembler
		storeByteTinRatA;
		@ nonInteger1;
		@ nonInteger2;
		loadRwithT;
		convertRtoSmallInteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleCDeclCallWithArguments [
	assembler
		loadZeroExtendByteTwithAindex: _SmallSize + 1;
		shiftTright: assembler wordSizeShift;
		pushS;
		saveCallerFrame;
		subTslotsToSP;
		assemble: 'and' with: assembler regSP with: -16;
		loopTtimes: [
			assembler
				load: assembler regS from: assembler regA atIndexAt: assembler regT;
				store: assembler regS in: assembler regSP indexAt: assembler regT].
	assembler addressSize = 8 ifTrue: [self loadArgumentsIntoRegisters].
	assembler callR; restoreCallerFrame; popS 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleCallWithArguments [
	assembler
		loadZeroExtendByteTwithAindex: _SmallSize + 1;
		shiftTright: assembler wordSizeShift;
		loopTtimes: [assembler pushAatToffset: 0 - assembler addressSize].
	assembler addressSize = 8 ifTrue: [self loadArgumentsIntoRegisters].
	assembler callR 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleEnvironment [
	assembler loadRwithE 
]

{ #category : #'private - instance behavior' }
InlineMessageLinker >> assembleEvents [
	selector = #_busyWait ifTrue: [^self assembleBusyWait].
	selector = #_release ifTrue: [^self assembleRelease].
	^nil 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleExpandInStackSized [
	assembler
		convertAtoNativeInteger;
		loadTwithA;
		loopTtimes: [assembler pushIndirectR; addRconstant: assembler addressSize] 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleExtendedSize [
	assembler
		loadZeroExtendLongRwithRindex: _ExtendedSize;
		convertRtoSmallInteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleFloatEquals [
	"
	first compare magnitudes to set error bit if NaN
	"
	assembler
		pushR;
		loadLargeX0withRindirect;
		compareLessThanLargeX0withAindirect;
		popR;
		loadLargeX0withRindirect;
		compareEqualLargeX0withAindirect;
		loadRwithX0;
		addRconstant: 1;
		convertRtoSmallInteger.
	self readFloatStatus 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleFloatFractionPartInto [
	assembler
		loadLargeX0withRindirect;
		loadX1roundingX0;
		subDoubleX1fromX0;
		storeLargeX0inA.
	self readFloatStatus 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleFloatLessThan [
	assembler
		loadLargeX0withRindirect;
		compareLessThanLargeX0withAindirect;
		loadRwithX0;
		addRconstant: 1;
		convertRtoSmallInteger.
	self readFloatStatus 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleFloatMinusInto [
	assembler
		loadLargeX0withRindirect;
		loadLargeX1withAindirect;
		subDoubleX1fromX0;
		storeLargeX0inT.
	self readFloatStatus 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleFloatMultiplyInto [
	assembler
		loadLargeX0withRindirect;
		loadLargeX1withAindirect;
		multiplyDoubleX0byX1;
		storeLargeX0inT.
	self readFloatStatus 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleFloatPlusInto [
	assembler
		loadLargeX0withRindirect;
		loadLargeX1withAindirect;
		addDoubleX1toX0;
		storeLargeX0inT.
	self readFloatStatus 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleFloatQuotientInto [
	assembler
		loadLargeX0withRindirect;
		loadLargeX1withAindirect;
		divideDoubleX0byX1;
		storeLargeX0inT.
	self readFloatStatus 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleFloatSqrtInto [
	assembler loadLargeX0withRindirect; sqrtDoubleX0; storeLargeX0inA.
	self readFloatStatus 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleFloatTruncated [
	assembler loadRconvertingDoublePointedByR.
	self readFloatStatus.
	assembler convertRtoSmallInteger 
]

{ #category : #'private - instance behavior' }
InlineMessageLinker >> assembleForHeaders [
	selector == #_basicFlags ifTrue: [^self assembleBasicFlags].
	selector == #_basicFlags: ifTrue: [^self assembleBasicFlagsPut].
	selector == #_basicHash ifTrue: [^self assembleBasicHash].
	selector == #_basicHash: ifTrue: [^self assembleBasicHashPut].
	selector == #_smallSize ifTrue: [^self assembleBasicSize].
	selector == #_smallSize: ifTrue: [^self assembleBasicSizePut].
	selector = #_largeSize ifTrue: [^self assembleExtendedSize].
	^nil 
]

{ #category : #'private - instance behavior' }
InlineMessageLinker >> assembleForMath [
	selector == #_readStatusOn: ifTrue: [^self assembleStoreFloatStatusInto].
	selector == #_status: ifTrue: [^self assembleLoadFloatStatusFrom].
	selector == #_timesTwoPower: ifTrue: [^self assembleTimesTwoPower].
	selector == #_bitShiftRight: ifTrue: [^self assembleBitShiftRight].
	selector == #_bitShiftLeft: ifTrue: [^self assembleBitShiftLeft].
	selector == #_leadingZeroBitCount
		ifTrue: [^self assembleLeadingZeroBitCount].
	selector == #_integerMultiplyBy:into:
		ifTrue: [^self assembleIntegerMultiplyByInto].
	selector == #_quotientTowardZero:
		ifTrue: [^self assembleQuotientTowardZero].
	selector == #_remainderTowardZero:
		ifTrue: [^self assembleRemainderTowardZero].
	selector == #_smallIntegerByteAt:
		ifTrue: [^self assembleSmallIntegerByteAt].
	selector == #_floatEquals: ifTrue: [^self assembleFloatEquals].
	selector == #_floatFractionPartInto:
		ifTrue: [^self assembleFloatFractionPartInto].
	selector == #_floatLessThan: ifTrue: [^self assembleFloatLessThan].
	selector == #_floatPlus:into: ifTrue: [^self assembleFloatPlusInto].
	selector == #_floatMinus:into: ifTrue: [^self assembleFloatMinusInto].
	selector == #_floatMultiply:into: ifTrue: [^self assembleFloatMultiplyInto].
	selector == #_floatQuotient:into: ifTrue: [^self assembleFloatQuotientInto].
	selector == #_asFloatInto: ifTrue: [^self assembleAsFloatInto].
	selector == #_floatSqrtInto: ifTrue: [^self assembleFloatSqrtInto].
	selector == #_floatTruncated ifTrue: [^self assembleFloatTruncated].
	^nil 
]

{ #category : #'private - instance behavior' }
InlineMessageLinker >> assembleForMemory [
	selector == #_basicAt: ifTrue: [^self assembleBasicAt].
	selector == #_basicAt:put: ifTrue: [^self assembleBasicAtPut].
	selector == #_basicCopyFrom:to:with:
		ifTrue: [^self assembleBasicCopyFromToWith].
	selector == #_basicULongAt: ifTrue: [^self assembleBasicULongAt].
	selector == #_basicULongAt:put: ifTrue: [^self assembleBasicULongAtPut].
	selector == #_byteAt: ifTrue: [^self assembleByteAt].
	selector == #_byteAt:put: ifTrue: [^self assembleByteAtPut].
	selector == #_objectAtOffset: ifTrue: [^self assembleObjectAtOffset].
	selector == #_objectAtOffset:put: ifTrue: [^self assembleObjectAtOffsetPut].
	selector == #_uLargeAtOffset: ifTrue: [^self assembleULargeAtOffset].
	selector == #_uLargeAtOffset:into:
		ifTrue: [^self assembleULargeAtOffsetInto].
	selector == #_uLargeAtOffset:put: ifTrue: [^self assembleULargeAtOffsetPut].
	selector == #_uLongAtOffset: ifTrue: [^self assembleULongAtOffset].
	selector == #_uLongAtOffset:into: ifTrue: [^self assembleULongAtOffsetInto].
	selector == #_uLongAtOffset:put: ifTrue: [^self assembleULongAtOffsetPut].
	selector == #_uShortAtOffset:put: ifTrue: [^self assembleUShortAtOffsetPut].
	^nil 
]

{ #category : #'private - instance behavior' }
InlineMessageLinker >> assembleForObjects [
	selector = #_halt ifTrue: [^self assembleNativeHalt].
	selector = #_oop ifTrue: [^self assembleOop].
	selector = #_thisContext ifTrue: [^self assembleThisContext].
	selector = #_asSmallInteger ifTrue: [^self assembleAsSmallInteger].
	selector = #_asNative ifTrue: [^self assembleAsNative].
	selector = #_rotate ifTrue: [^self assembleRotate].
	selector = #_unrotate ifTrue: [^self assembleUnrotate].
	selector = #_isSmallInteger ifTrue: [^self assembleTestSmallInteger].
	selector = #_asObject ifTrue: [^self assembleAsObject].
	selector = #_asPointer ifTrue: [^self assembleAsPointer].
	selector = #_high16 ifTrue: [^self assembleHigh16].
	selector = #_low16 ifTrue: [^self assembleLow16].
	selector = #_high32 ifTrue: [^self assembleHigh32].
	selector = #_low32 ifTrue: [^self assembleLow32].
	selector = #_nilSlots: ifTrue: [^self assembleNilSlots].
	selector = #_zeroSlots: ifTrue: [^self assembleZeroSlots].
	^nil 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleFramePointer [
	assembler loadRwithFPindex: 1 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleGetTIBValue [
	| nonInteger |
	nonInteger := assembler labeledIntegerNativizationOfR.
	assembler loadRwithTIBatIndexR; @ nonInteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleGetThreadValue [
	| nonInteger uninitialized |
	nonInteger := assembler labeledIntegerNativizationOfR.
	uninitialized := assembler newLabel.
	assembler
		loadRwithThreadVariableAtIndexR;
		compareRwithImmediate: 0;
		shortJumpIfEqualTo: uninitialized.
	assembler jumpOver: [
		assembler @ uninitialized; @ nonInteger.
		self loadObject: nil] 
]

{ #category : #'private - instance behavior' }
InlineMessageLinker >> assembleHelpers [
	selector == #_framePointer ifTrue: [^self assembleFramePointer].
	selector == #_beFramePointer ifTrue: [^self assembleBeFramePointer].
	selector == #_beCurrent ifTrue: [^self assembleBeCurrent].
	selector == #_stdcallWithArguments:
		ifTrue: [^self assembleCallWithArguments].
	selector == #_cdeclCallWithArguments:
		ifTrue: [^self assembleCDeclCallWithArguments].
	selector == #_storeDoubleResult ifTrue: [^self assembleStoreDoubleResult].
	selector == #_invokeWith:droppingTwoFramesAndAdjusting:
		ifTrue: [^self assembleInvokeWithDroppingTwoFramesAndAdjusting].
	selector == #_transferControlTo: ifTrue: [^self assembleTransferControlTo].
	selector == #_transferControlDiscardingLastArgTo:
		ifTrue: [^self assembleTransferControlDiscardingLastArgTo].
	selector == #_saveCurrentEnvironment
		ifTrue: [^self assembleSaveCurrentEnvironment].
	selector == #_restoreWithContext:
		ifTrue: [^self assembleRestoreWithContext].
	selector == #_beEnvironment ifTrue: [^self assembleBeEnvironment].
	selector == #_restoreAndTransferControlWithContext:
		ifTrue: [^self assembleRestoreAndTransferControlWithContext].
	selector == #_environment ifTrue: [^self assembleEnvironment].
	selector == #_restore ifTrue: [^self assembleRestore].
	selector == #_expandInStackSized:
		ifTrue: [^self assembleExpandInStackSized].
	selector == #_getThreadValue ifTrue: [^self assembleGetThreadValue].
	selector == #_setThreadValue: ifTrue: [^self assembleSetThreadValue].
	selector == #_getThreadInformationBlockValue
		ifTrue: [^self assembleGetTIBValue].
	selector == #_setThreadInformationBlockValue:
		ifTrue: [^self assembleSetTIBValue].
	^nil 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleHigh16 [
	assembler wordSize > 4 ifTrue: [assembler clearRhighHalf].
	assembler shiftRright: 15; ensureSafeRintegerBit 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleHigh32 [
	assembler shiftLogicalRright: 31; ensureSafeRintegerBit 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleIntegerMultiplyByInto [
	assembler
		convertRtoNativeInteger;
		convertAtoNativeInteger;
		multiplyRbyA;
		storeRinTindex: 1;
		storeAinTindex: 2;
		loadRwithT 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleInvokeWithDroppingTwoFramesAndAdjusting [
	assembler
		restoreCallerFrame;
		restoreCallerFrame;
		convertTtoNativeInteger;
		shiftTleft: assembler wordSizeShift;
		addSPtoT;
		pushR;
		pushR;
		loadRwithSPindex: 3;
		storeRinTindex: 1;
		storeAinTindex: 2;
		popA;
		loadSPwithT;
		loadRwithS;
		jumpToA 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleLeadingZeroBitCount [
	assembler
		convertRtoNativeInteger;
		leadingRzeroCount;
		convertRtoSmallInteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleLoadFloatStatusFrom [
	assembler loadMXCSRfromA 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleLow16 [
	assembler andRwithImmediate: 16rFFFF; convertRtoSmallInteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleLow32 [
	assembler wordSize > 4
		ifTrue: [assembler andRwithImmediate: 16rFFFFFFFF; convertRtoSmallInteger] 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleNativeHalt [
	assembler breakpoint 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleNilSlots [
	assembler
		pushE;
		loadEwithR;
		loadRwithPointer: nil;
		loadTwithA;
		convertTtoNativeInteger;
		writeTslots;
		popE 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleObjectAtOffset [
	| nonInteger1 |
	nonInteger1 := assembler labeledIntegerNativizationOfA.
	assembler loadRwithRatOffsetA; @ nonInteger1 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleObjectAtOffsetPut [
	| oop |
	oop := assembler labeledIntegerNativizationOfA.
	assembler
		storeTinRatOffsetA;
		@ oop;
		loadRwithT;
		convertRtoSmallInteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleOop [
	^assembler convertRtoSmallInteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleQuotientTowardZero [
	assembler
		convertRtoNativeInteger;
		convertAtoNativeInteger;
		loadTwithA;
		divideRbyT;
		convertRtoSmallInteger 
]

{ #category : #'as yet unclassified' }
InlineMessageLinker >> assembleRelease [
	assembler lock; decRindirect 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleRemainderTowardZero [
	| adapt convert |
	adapt := assembler newLabel.
	convert := assembler newLabel.
	assembler
		convertRtoNativeInteger;
		convertAtoNativeInteger;
		loadTwithA;
		xorAwithR;
		jumpIfSignTo: adapt;
		divideRbyT;
		loadRwithA;
		jumpTo: convert;
		@ adapt;
		divideRbyT;
		loadRwithA;
		testRwithR;
		jumpIfZeroTo: convert;
		addTtoR;
		@ convert;
		convertRtoSmallInteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleRestore [
	assembler loadEwithR 
]

{ #category : #'as yet unclassified' }
InlineMessageLinker >> assembleRestoreAndTransferControlWithContext [
	assembler
		clearSafeRintegerBit;
		loadFPwithR;
		loadSPwithFP;
		loadRwithA;
		clearSafeRintegerBit;
		loadFPwithR;
		popR;
		loadEwithR;
		restoreCallerSelf;
		loadRwithS;
		return: 0 
]

{ #category : #'as yet unclassified' }
InlineMessageLinker >> assembleRestoreWithContext [
	assembler
		clearSafeRintegerBit;
		loadFPwithR;
		loadSPwithFP;
		loadRwithA;
		clearSafeRintegerBit;
		loadFPwithR 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleRotate [
	assembler rotateRight: assembler regR count: 8 
]

{ #category : #'as yet unclassified' }
InlineMessageLinker >> assembleSaveCurrentEnvironment [
	assembler
		clearSafeRintegerBit;
		pushE;
		popT;
		storeTinRindex: 1;
		ensureSafeRintegerBit 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleSetTIBValue [
	assembler convertRtoNativeInteger; storeTIBwithAatIndexR 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleSetThreadValue [
	| nonInteger |
	nonInteger := assembler labeledIntegerNativizationOfR.
	assembler storeAinThreadVariableAtIndexR; convertRtoSmallInteger.
	assembler @ nonInteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleSmallIntegerByteAt [
	| nonInteger |
	nonInteger := assembler labeledIntegerNativizationOfA.
	assembler
		convertRtoNativeInteger;
		pushR;
		loadZeroExtendByteRwithSPatA;
		convertRtoSmallInteger;
		popA;
		@ nonInteger 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleStoreDoubleResult [
	assembler storeDoubleResultInRindirect 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleStoreFloatStatusInto [
	assembler storeMXCSRintoA 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleTestSmallInteger [
	| integer |
	integer := assembler newLabel.
	assembler testRintegerBit.
	self loadObject: true.
	assembler shortJumpIfNotZeroTo: integer.
	self loadObject: false.
	assembler @ integer 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleThisContext [
	assembler loadRwithFP ensureRintegerBit 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleTimesTwoPower [
	assembler clearFPUFlags scaleFloatOnRWithA clearFPUFlags 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleTransferControlDiscardingLastArgTo [
	assembler restoreCallerFrame; popSPindirect; jumpToA 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleTransferControlTo [
	assembler restoreCallerFrame; loadSwithA; jumpToA 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleULargeAtOffset [
	| overflow1 overflow2 end |
	overflow1 := assembler newLabel.
	overflow2 := assembler newLabel.
	end := assembler newLabel.
	assembler
		convertAtoNativeInteger;
		loadRwithRatOffsetA;
		shiftRleft: 1;
		shortJumpIfCarryTo: overflow1;
		shortJumpIfSignTo: overflow2;
		ensureRintegerBit;
		shortJumpTo: end.
	assembler @ overflow1; @ overflow2.
	self loadObject: nil.
	assembler @ end 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleULargeAtOffsetInto [
	assembler
		convertAtoNativeInteger;
		loadAwithRoffsetAtA;
		storeAinTindex: 1;
		loadRwithT 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleULargeAtOffsetPut [
	| end notSmall |
	notSmall := assembler convertAtoNativeInteger; labeledIntegerBitTestOfT.
	end := assembler newLabel.
	assembler
		convertTtoNativeInteger;
		shortJumpTo: end;
		@ notSmall;
		loadTwithTindex: 1;
		@ end;
		storeTinRatOffsetA 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleULongAtOffset [
	| overflow1 overflow2 end |
	overflow1 := assembler newLabel.
	overflow2 := assembler newLabel.
	end := assembler newLabel.
	assembler
		convertAtoNativeInteger;
		loadLongRwithRatOffsetA;
		shiftRleft: 1;
		shortJumpIfCarryTo: overflow1;
		shortJumpIfSignTo: overflow2;
		ensureRintegerBit;
		shortJumpTo: end.
	assembler @ overflow1; @ overflow2.
	self loadObject: nil.
	assembler @ end 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleULongAtOffsetInto [
	assembler
		convertAtoNativeInteger;
		loadLongRwithRatOffsetA;
		storeRinTindex: 1;
		loadRwithT 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleULongAtOffsetPut [
	| end oop |
	oop := assembler convertAtoNativeInteger; labeledIntegerBitTestOfT.
	end := assembler newLabel.
	assembler
		convertTtoNativeInteger;
		shortJumpTo: end;
		@ oop;
		loadTwithTindex: 1;
		@ end;
		storeLongTinRatOffsetA 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleUShortAtOffsetPut [
	| end notSmall |
	notSmall := assembler convertAtoNativeInteger; labeledIntegerBitTestOfT.
	end := assembler newLabel.
	assembler convertTtoNativeInteger; shortJumpTo: end.
	assembler
		@ notSmall;
		loadTwithTindex: 1;
		@ end;
		storeShortTinRatOffsetA 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleUnrotate [
	assembler rotateLeft: assembler regR count: 8 
]

{ #category : #nativizing }
InlineMessageLinker >> assembleUsing: anAssembler [
	self assembler: anAssembler; assemble 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> assembleZeroSlots [
	assembler
		pushE;
		loadEwithR;
		loadRwithImmediate: 0;
		loadTwithA;
		convertTtoNativeInteger;
		writeTslots;
		popE 
]

{ #category : #accessing }
InlineMessageLinker >> assembler: anAssembler [
	assembler := anAssembler 
]

{ #category : #testing }
InlineMessageLinker >> canInline: aSymbol [
	^selector == aSymbol 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> emitByteAtOffset: offset [
	assembler
		loadZeroExtendByteRwithRindex: offset + 1;
		convertRtoSmallInteger 
]

{ #category : #private }
InlineMessageLinker >> emitByteAtOffsetPut: offset [
	| nonInteger |
	nonInteger := assembler labeledIntegerNativizationOfA.
	assembler
		storeByteAinRindex: offset + 1;
		@ nonInteger 
]

{ #category : #'prologue and epilogue' }
InlineMessageLinker >> emitPrologue [
	| arity |
	arity := selector arity.
	arity > 2 ifTrue: [assembler pop: assembler regS].
	arity > 1 ifTrue: [assembler pop: assembler regT].
	arity > 0 ifTrue: [assembler pop: assembler regA].
	self ASSERT: arity <= 3 
]

{ #category : #nativizing }
InlineMessageLinker >> emitSend: aSymbol using: anAssembler [
	selector := aSymbol.
	self assembleUsing: anAssembler 
]

{ #category : #nativizing }
InlineMessageLinker >> emitSendDebuggable: aSymbol using: anAssembler [
	self ASSERT: aSymbol == selector.
	self assembleUsing: anAssembler 
]

{ #category : #private }
InlineMessageLinker >> falseOop [
	^assembler falseOop 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> loadArgumentsIntoRegisters [
	assembler
		load: rcx from: rsp atIndex: 1;
		load: rdx from: rsp atIndex: 2;
		load: r8 from: rsp atIndex: 3;
		load: r9 from: rsp atIndex: 4;
		assemble: 'movq' with: xmm0 with: rcx;
		assemble: 'movq' with: xmm1 with: rdx;
		assemble: 'movq' with: xmm2 with: r8;
		assemble: 'movq' with: xmm3 with: r9 
]

{ #category : #'opcodes - loading' }
InlineMessageLinker >> loadObject: anObject [
	assembler loadRwithPointer: anObject 
]

{ #category : #printing }
InlineMessageLinker >> printOn: aStream [
	aStream nextPutAll: 'Inliner for: ' , selector storeString 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> readFPUStatus [
	| status |
	status := Float statusVar.
	assembler loadAwithPointer: status; readFPUStatusOnA 
]

{ #category : #'private - assemble' }
InlineMessageLinker >> readFloatStatus [
	| status |
	status := Float statusVar.
	assembler loadAwithPointer: status; storeMXCSRintoA 
]

{ #category : #accessing }
InlineMessageLinker >> selector [
	^selector 
]

{ #category : #accessing }
InlineMessageLinker >> selector: aSymbol [
	selector := aSymbol 
]

{ #category : #private }
InlineMessageLinker >> trueOop [
	^assembler trueOop 
]
