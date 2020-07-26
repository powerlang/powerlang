"
Starting with Pharo 8, Ring2 is pre-loaded. Therefore,
only load Ring2 on Pharo 7 (we don't care about older Pharos)
"
(SystemVersion current version beginsWith: 'Pharo7') ifTrue: [
  Metacello new
  baseline: 'Ring2';
  repository: 'github://pavel-krivanek/Ring2/src';
  load;
  load: 'runtimeSupport';
  load: 'calypso'].


"
Load PetitParser and PetitParser analyzer (for eventual debugging)
"
Metacello new
   baseline: 'PetitParser';
   repository: 'github://moosetechnology/PetitParser/src';
   load: 'Core';
   load: 'Analyzer'.

"
Load Roassal
"
Metacello new
    baseline: 'Roassal3';
    repository: 'github://ObjectProfile/Roassal3:v0.9.2';
    load.

Author useAuthor: 'PowerSmalltalkLoader' during: [
    | repo |
    "Based on the same file from the pharo-vm project"
    IceCredentialsProvider useCustomSsh: false.
    repo := IceRepositoryCreator  new
                location: '..' asFileReference;
                createRepository.

    repo register.
    (repo packageNamed: 'Powerlang-Core') load.
    (repo packageNamed: 'Powerlang-UI') load.
    (repo packageNamed: 'Powerlang-Tests') load.
    (repo packageNamed: 'Powerlang-TestsFailing') load.
].

SystemWindow closeTopWindow. "close HelpBrowser"
GTPlayground openContents: 'README.md' asFileReference contents withSqueakLineEndings.

(Smalltalk saveAs: (Smalltalk imageDirectory asFileReference) / 'bootstrap' )
    ifFalse: [ Smalltalk snapshot: false andQuit: true ].
