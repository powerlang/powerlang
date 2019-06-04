"
I am a proxy to a remote object given by my `handle`. My main goal is
to abstract semantics with which messages sent to me will be executed.
My subclasses implement those different semantics: 
 - DirectGate executes locally, doing lookup within the remote behavior
   of object.
 - MirageGate executes locally, doing lookup within a local specification
   of the behavior of the remote object.
"
Class {
	#name : #Gate,
	#superclass : #Object,
	#instVars : [
		'handle'
	],
	#category : #'Powerlang-Metaphysics'
}

{ #category : #'instance creation' }
Gate class >> on: handle [
	^self new handle: handle
]

{ #category : #'instance creation' }
Gate class >> subjectOn: handle [
	^(self on: handle) subject
]

{ #category : #accessing }
Gate >> asLocalCollection [
	^handle asLocalCollection
]

{ #category : #accessing }
Gate >> asLocalString [
	^handle asLocalString
]

{ #category : #accessing }
Gate >> dispatch: aMessage [
	^self dispatch: aMessage from: nil
]

{ #category : #accessing }
Gate >> dispatch: aMessage from: parentInterpreter [
	^self subclassResponsibility
]

{ #category : #accessing }
Gate >> handle [
	^handle
]

{ #category : #accessing }
Gate >> handle: anObjectHandle [
	handle := anObjectHandle
]

{ #category : #accessing }
Gate >> handleOn: objectHandle [
	^handle handleOn: objectHandle
]

{ #category : #private }
Gate >> maneuvererOn: objectHandle [
	^DirectGate subjectOn: objectHandle
]

{ #category : #private }
Gate >> mirageOn: objectHandle [
	^MirageGate subjectOn: objectHandle
]

{ #category : #accessing }
Gate >> mirror [
	^handle mirror
]

{ #category : #private }
Gate >> subject [
	^Subject new _gate: self
]
