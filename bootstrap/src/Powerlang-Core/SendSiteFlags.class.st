Class {
	#name : #SendSiteFlags,
	#superclass : #PSharedPool,
	#classVars : [
		'HasBeenReset',
		'IsPolymorphic',
		'IsStaticSend',
		'IsSuperSend'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #'class initialization' }
SendSiteFlags class >> initialize [
		IsStaticSend := 16r1.
		IsSuperSend := 16r2.
		IsPolymorphic := 16r4.
		HasBeenReset := 16r8
	
]
