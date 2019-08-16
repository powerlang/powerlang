Class {
	#name : #ClassDefWriter,
	#superclass : #DefWriter,
	#category : #'Powerlang-Core-Tools'
}

{ #category : #writing }
ClassDefWriter class >> writeToFile: filename [
	self write: (KernelSegmentBuilder kernel allClasses) toFile: filename
]

{ #category : #accessing }
ClassDefWriter >> objects: classes [
	| dependencies |
	
	dependencies := Set new.
	classes do:[:cls | cls superclass notNil ifTrue:[dependencies add: cls -> cls superclass ]].
	objects := TopologicalSort sort: dependencies.						
	
	
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
		
	super write.
]

{ #category : #writing }
ClassDefWriter >> write1: anRGEnvironment [
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
