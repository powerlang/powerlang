Class {
	#name : #SendSite,
	#superclass : #Object,
	#instVars : [
		'instructions',
		'selector',
		'cache',
		'tally',
		'format'
	],
	#pools : [
		'SendSiteFlags'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #accessing }
SendSite >> beSuperSend [
	format := format bitOr: IsSuperSend
]

{ #category : #accessing }
SendSite >> initialize [
	tally := 0.
	format := 0
]

{ #category : #accessing }
SendSite >> instructions: aByteArray [
	instructions := aByteArray
]

{ #category : #'as yet unclassified' }
SendSite >> invoke: anSCompiledMethod using: invokeInstructions [
	instructions := invokeInstructions.
	selector := anSCompiledMethod selector.
	cache := anSCompiledMethod
]

{ #category : #accessing }
SendSite >> isSuperSend [
	^(format bitAnd: IsSuperSend) == IsSuperSend
]

{ #category : #'as yet unclassified' }
SendSite >> lookup: aSymbol using: lookupInstructions [
	instructions := lookupInstructions.
	selector := aSymbol
]

{ #category : #accessing }
SendSite >> selector [
	^selector
]

{ #category : #accessing }
SendSite >> selector: aSymbol [
	selector := aSymbol
]
