Class {
	#name : #MethodScope,
	#superclass : #ScriptScope,
	#instVars : [
		'pseudo'
	],
	#category : #'Powerlang-SCompiler-Parser'
}

{ #category : #private }
MethodScope >> captureEnvironment: aScriptNode [
	self ASSERT: aScriptNode == script
]

{ #category : #services }
MethodScope >> captureLocal: aLocalBinding [
	self ASSERT: (self resolveLocal: aLocalBinding name) notNil.
	^aLocalBinding
]

{ #category : #services }
MethodScope >> captureSelf [
	captureSelf := true.

]

{ #category : #services }
MethodScope >> environmentIndexOf: aScriptNode [
	self ASSERT: aScriptNode == script.
	^nil
]

{ #category : #initialization }
MethodScope >> initialize [
	super initialize.
	self initializePseudoVars
]

{ #category : #initialization }
MethodScope >> initializePseudoVars [
	pseudo := StaticBinder new.
	pseudo
		at: 'nil' put: NilBinding new;
		at: 'true' put: TrueBinding new;
		at: 'false' put: FalseBinding new;
		at: 'self' put: SelfBinding new;
		at: 'super' put: SuperBinding new
]

{ #category : #services }
MethodScope >> resolve: aString [
	(self resolveLocal: aString) ifNotNil: [ :binding | ^ binding ].
	(self resolvePseudo: aString) ifNotNil: [ :binding | ^ binding ].
	^ DynamicBinding named: aString
]

{ #category : #'as yet unclassified' }
MethodScope >> resolvePseudo: aString [
	^pseudo at: aString

]

{ #category : #services }
MethodScope >> scriptDefining: aString [
	(self resolveLocal: aString) ifNotNil: [^script].
	self ASSERT: false.
	^nil
]

{ #category : #private }
MethodScope >> transferLocal: name [
	^self resolveLocal: name
]
