Class {
	#name : #Prefixes,
	#superclass : #SharedPool,
	#classVars : [
		'AddressSize_Override',
		'LOCK',
		'OperandSize_Override',
		'REP',
		'REPE',
		'REPNE',
		'REPNZ',
		'REPZ',
		'REX',
		'REX_R',
		'REX_W'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #'as yet unclassified' }
Prefixes class >> initialize [
	LOCK := LegacyPrefix basicNew
		instVarAt: 1 put: 'LOCK';
		instVarAt: 2 put: 1;
		instVarAt: 3 put: 240;
		yourself.
	REPNZ := LegacyPrefix basicNew
		instVarAt: 1 put: 'REPNE';
		instVarAt: 2 put: 1;
		instVarAt: 3 put: 242;
		yourself.
	REX := REXPrefix basicNew
		instVarAt: 1 put: 'REX';
		yourself.
	REPNE := LegacyPrefix basicNew
		instVarAt: 1 put: 'REPNE';
		instVarAt: 2 put: 1;
		instVarAt: 3 put: 242;
		yourself.
	REPE := LegacyPrefix basicNew
		instVarAt: 1 put: 'REP';
		instVarAt: 2 put: 1;
		instVarAt: 3 put: 243;
		yourself.
	AddressSize_Override := LegacyPrefix basicNew
		instVarAt: 1 put: 'AddressSize_Override';
		instVarAt: 2 put: 4;
		instVarAt: 3 put: 103;
		yourself.
	REX_W := REXPrefix basicNew
		instVarAt: 1 put: 'REX.W';
		yourself.
	REPZ := LegacyPrefix basicNew
		instVarAt: 1 put: 'REP';
		instVarAt: 2 put: 1;
		instVarAt: 3 put: 243;
		yourself.
	REX_R := REXPrefix basicNew
		instVarAt: 1 put: 'REX.R';
		yourself.
	OperandSize_Override := LegacyPrefix basicNew
		instVarAt: 1 put: 'OperandSize_Override';
		instVarAt: 2 put: 3;
		instVarAt: 3 put: 102;
		yourself.
	REP := LegacyPrefix basicNew
		instVarAt: 1 put: 'REP';
		instVarAt: 2 put: 1;
		instVarAt: 3 put: 243;
		yourself
]
