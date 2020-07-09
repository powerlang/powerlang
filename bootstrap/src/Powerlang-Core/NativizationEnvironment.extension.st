Extension { #name : #NativizationEnvironment }

{ #category : #'*Powerlang-Core-OCompiler' }
NativizationEnvironment >> shouldOptimize: method [
	| selector classname |
	selector := method selector.
	classname := method classBinding name.
	^ optimizedMethods anySatisfy: [:m | m selector = selector and: [ m parent name = classname ]  ]
]
