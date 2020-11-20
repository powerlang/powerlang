Class {
	#name : #BaselineOfPowerlang,
	#superclass : #BaselineOf,
	#category : #BaselineOfPowerlang
}

{ #category : #accessing }
BaselineOfPowerlang >> baseline: spec [
	<baseline>
	spec for: #pharo do: [
		spec baseline: 'PetitParser' with: [
			spec loads: 'Core'. 
			spec loads: 'Analyzer'. 
			spec repository: 'github://shingarov/PetitParser:ULD'
		].
		
		spec baseline: 'Roassal3' with: [
			spec repository: 'github://ObjectProfile/Roassal3:v0.9.2' 
		].
			
		spec package: 'Powerlang-Core' with:[
			spec requires: 'PetitParser'
		].
		spec package: 'Powerlang-Tests'.
		spec	package: 'Powerlang-TestsFailing'.
		spec	package: 'Powerlang-UI' with:[
			spec requires: 'Roassal3'
		]
	]
]

{ #category : #accessing }
BaselineOfPowerlang >> repository [
	^ self packageRepositoryURL
]
