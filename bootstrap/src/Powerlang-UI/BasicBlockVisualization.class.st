Class {
	#name : #BasicBlockVisualization,
	#superclass : #Object,
	#instVars : [
		'root',
		'canvas'
	],
	#category : #'Powerlang-UI'
}

{ #category : #initialization }
BasicBlockVisualization >> addBlocks [
		| eb blocks |
	blocks := RSGroup new.
	root reversePostOrderDo: [:b | blocks add: (self shapeFrom: b) @ RSDraggable ].
	eb := RSEdgeBuilder verticalBezier .
	"eb shape markerEnd:
		((RSShapeFactory arrow color: Color black; size: 20)
			asMarker offsetRatio: 0.43)."
	eb 
		canvas: canvas; moveBehind; width: 2;
		shapes: blocks; connectToAll: #successors.
	RSSugiyamaLayout  on: blocks 
]

{ #category : #initialization }
BasicBlockVisualization >> canvas [
	^canvas
]

{ #category : #initialization }
BasicBlockVisualization >> initialize [
	super initialize.
	canvas := RSCanvas new.

	"The canvas can be zoomed in / out using keys I and O"
	"It can also be navigated using scrollbars"
	canvas @ RSCanvasController.

]

{ #category : #initialization }
BasicBlockVisualization >> root: anOBasicBlock [
	root := anOBasicBlock
]

{ #category : #initialization }
BasicBlockVisualization >> shapeFrom: anOBasicBlock [
	| text label insts bound contents all |
	text := RSGroup new.
	label := RSLabel new text: anOBasicBlock name.
	insts := RSGroup new.
	text add: label.
	anOBasicBlock instructionsDo: [ :i |
				label := RSLabel new 	text: i printString; 	model: i.
				insts add: label ].
	text addAll: insts.
	RSVerticalLineLayout on: text.
	bound := RSShapeFactory box
		border: (RSBorder new width: 2; color: Color black);
		cornerRadius: 5;
		color: (Color gray: 0.9);
		width: text encompassingRectangle width + 16;
		height: text encompassingRectangle height + 16.
	contents := text asShape.
	all := RSComposite new model: anOBasicBlock; shapes: { bound. contents }.
	RSLocation new center; outer; stick: contents on: bound.
	canvas add: all.
	^all
	
]
