Class {
	#name : #ClassDefWriter,
	#superclass : #DefWriter,
	#instVars : [
		'classes'
	],
	#category : #'Powerlang-Core-Tools'
}

{ #category : #writing }
ClassDefWriter class >> write: classes to: stream [
	^self new
		classes: classes;
		stream: stream;
		write
]

{ #category : #writing }
ClassDefWriter class >> write: classes toFile: filename [
	filename asFileReference writeStreamDo: [ :stream |
		self write: classes to: stream
	]

]

{ #category : #writing }
ClassDefWriter class >> writeToFile: filename [
	self write: (KernelSegmentBuilder kernel allClasses) toFile: filename
]

{ #category : #accessing }
ClassDefWriter >> classes: aCollection [
	| dependencies |
	
	dependencies := Set new.
	aCollection do:[:cls | cls superclass notNil ifTrue:[dependencies add: cls -> cls superclass ]].
	classes := TopologicalSort sort: dependencies.						
	
	
]

{ #category : #writing }
ClassDefWriter >> write [
	self 
		writeln:'#ifndef DEFINE_CLASS';
		writeln:'#define DEFINE_CLASS(name, super, slots)';
		writeln:'#endif';

		writeln:'#ifndef DEFINE_SLOT';
		writeln:'#define DEFINE_SLOT(name)';
		writeln:'#endif'.
		
	classes do:[:cls| self writeClass: cls]
]

{ #category : #writing }
ClassDefWriter >> writeClass: anRGEnvironment [
	self
		write:'DEFINE_CLASS(';
		write: anRGEnvironment name;
		write:', ';
		write:(anRGEnvironment superclass isNil 
						ifTrue:[ 'NIL' ] 
						ifFalse:[ anRGEnvironment superclass name ]);		
		write:', ';
		nl.
	anRGEnvironment instVarNames do:[:name|
		self
			write:'    DEFINE_SLOT(';
			write:name;
			writeln:')'.
	].
	self
		writeln:')'.

	
	
]
