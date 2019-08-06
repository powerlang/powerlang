node ( "linux && x86_64" ) { ws {
    stage ( "Checkout" ) {
        checkout scm
    }

    stage ( "Bootstrap" ) {
        sh  """
            make -C bootstrap
            make -C bootstrap test
            """
        junit 'bootstrap/*-Test.xml'
    }
}}