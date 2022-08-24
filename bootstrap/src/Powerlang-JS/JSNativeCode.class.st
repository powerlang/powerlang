Class {
	#name : #JSNativeCode,
	#superclass : #Object,
	#instVars : [
		'code',
		'literals'
	],
	#category : #'Powerlang-JS'
}

{ #category : #accessing }
JSNativeCode >> code [
	^ code
]

{ #category : #accessing }
JSNativeCode >> executeFor: evaluator in: aNativeJSEvaluatioContext [
	^ code
		value: evaluator
		value: aNativeJSEvaluatioContext
		value: literals
]

{ #category : #accessing }
JSNativeCode >> literals [
	^ literals
]

{ #category : #accessing }
JSNativeCode >> literals: aCollection [
	literals := aCollection
]

{ #category : #accessing }
JSNativeCode >> source: aString [

	code := self eval: aString
]
