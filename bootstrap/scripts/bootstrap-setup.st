Metacello new
  baseline: 'Ring2';
  repository: 'github://pavel-krivanek/Ring2/src';
  load;
  load: 'runtimeSupport';
  load: 'calypso'.

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
].

SystemWindow closeTopWindow. "close HelpBrowser"
GTPlayground openContents: 'README.md' asFileReference contents withSqueakLineEndings.

(Smalltalk saveAs: (Smalltalk imageDirectory asFileReference) / 'bootstrap' )
    ifFalse: [ Smalltalk snapshot: false andQuit: true ].
