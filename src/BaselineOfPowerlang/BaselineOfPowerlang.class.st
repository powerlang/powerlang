Class {
	#name : #BaselineOfPowerlang,
	#superclass : #BaselineOf,
	#category : #BaselineOfPowerlang
}

{ #category : #accessing }
BaselineOfPowerlang >> baseline: spec [
	<baseline>
	spec for: #common do: [
		spec baseline: 'PetitParser' with: [
			spec loads: 'Core'.
			spec loads: 'Analyzer'.
			spec repository: 'github://shingarov/PetitParser:ULD'
		].

		spec package: 'Powerlang-Compatibility-Pharo'.
		spec package: 'Powerlang-SCompiler'.
		spec package: 'Powerlang-Core' with:[
			spec requires: 'Powerlang-Compatibility-Pharo'.
			spec requires: 'Powerlang-SCompiler'.
			spec requires: 'PetitParser'
		].
		spec package: 'Powerlang-Tests'.
		spec package: 'Powerlang-TestsFailing'.
		spec package: 'Powerlang-UI'.

		"compiler group: just compiler and compiler tests"
		spec group: 'base-compiler' with: #(
											'Powerlang-Compatibility-Pharo'
											'Powerlang-SCompiler'
											'Powerlang-SCompiler-Tests').
		"base group: just core boostrapping code and tests"
		spec group: 'base' with: #(
											'Powerlang-Compatibility-Pharo'
											'Powerlang-SCompiler'
											'Powerlang-Core'
											'Powerlang-SCompiler-Tests'
											'Powerlang-Tests'
											'Powerlang-TestsFailing').

		"devel group: base, tests and custom dev tools"
		spec group: 'devel' with: #('base'
		                            'Powerlang-UI').

		"default group: loaded when group is not specified"
		spec group: 'default' with: #('devel').
	].

	spec for: #'pharo8.x' do: [
		spec baseline: 'Roassal3' with: [
			spec repository: 'github://ObjectProfile/Roassal3:v0.9.2'
		].
		spec package: 'Powerlang-UI' with:[
			spec requires: 'Roassal3'
		].
	]
]

{ #category : #accessing }
BaselineOfPowerlang >> repository [
	^ self packageRepositoryURL
]
