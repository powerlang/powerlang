Class {
	#name : #BehaviorMirror,
	#superclass : #ObjectMirror,
	#category : #'Powerlang-Core-Mirrors'
}

{ #category : #accessing }
BehaviorMirror >> at: i [
	self ASSERT: false
]

{ #category : #accessing }
BehaviorMirror >> classBinding [
	| class |
	class := self getInstVarNamed: #class.
	^class asSpeciesMirror
]

{ #category : #nativizing }
BehaviorMirror >> compiledMethodFor: aSymbol [
	| method next |
	method := self methodDictionary compiledMethodFor: aSymbol.
	method ifNotNil: [^method].
	next := self next.
	^next reflectsNil ifFalse: [next compiledMethodFor: aSymbol]
]

{ #category : #accessing }
BehaviorMirror >> instanceClass [
	| behavior class |
	behavior := self.
	10
		timesRepeat: [ class := behavior classBinding.
			class reflectsNil
				ifFalse: [ ^ class ].
			behavior := self next.
			behavior reflectsNil 
				ifTrue: [ self error: 'behavior does not have a class' ] ].
	self error: 'could not find the class corresponding to this behavior'
]

{ #category : #accessing }
BehaviorMirror >> methodDictionary [
	| slot |
	slot := handle slotAt: 1.
	^self methodDictionaryMirrorOn: slot
]

{ #category : #accessing }
BehaviorMirror >> next [
	| slot |
	slot := handle slotAt: 2.
	^self behaviorMirrorOn: slot
]

{ #category : #private }
BehaviorMirror >> structureType [
	^#Behavior
]
