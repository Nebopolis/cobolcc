      *
      *===============================================================
       IDENTIFICATION DIVISION.
      *===============================================================
      *
       PROGRAM-ID. MQSERVER.
      *
      *---------------------------------------------------------------
      *
      *REMARKS
      *
      *---------------------------------------------------------------
      *
      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      *
      *  Module Name      : MQSERVER
      *
      *  Description      : Program to process requests.
      *
      *  Function         : This program receives a request message
      *                     and performs the "business logic"
      *                     returns a reply message.
      *  
      *  Source           : This program was found at 
      *                     http://www.capitalware.biz/
      *                     mq_code_cobol.html  
      *
      * *************************************************************
      *
      *===============================================================
       ENVIRONMENT DIVISION.
      *===============================================================
      *
      *---------------------------------------------------------------
      *
      *
      *---------------------------------------------------------------
      *
      *===============================================================
       DATA DIVISION.
      *===============================================================

      *
      *===============================================================
       WORKING-STORAGE SECTION.
      *===============================================================
      *
      *---------------------------------------------------------------
      *                GENERAL WORKING-STORAGE FIELDS
      *---------------------------------------------------------------
      *
       01  WS-PRINT-LINE               PIC X(79).
       01  PROG-RETURN-CODE            PIC S9(04) BINARY  VALUE ZERO.
       01  WS-MORE-FLAG                PIC X VALUE 'N'.
       01  WS-INPUT-BUFFER             PIC X(1000).
       01  WS-OUTPUT-BUFFER            PIC X(1000).
       01  INPUT-BUFFER-LENGTH         PIC S9(9) BINARY VALUE 1000.
       01  OUTPUT-BUFFER-LENGTH        PIC S9(9) BINARY VALUE 1000.
       01  COMP-CODE                   PIC S9(9) BINARY.
       01  REASON-CODE                 PIC S9(9) BINARY.


      *---------------------------------------------------------------
      *    Queue Manager fields
      *---------------------------------------------------------------

       01  WS-QUEUE-MGR                PIC X(48) VALUE 'MQA1'.
       01  CON-HANDLE                  PIC S9(9) BINARY.

      *---------------------------------------------------------------
      *    Output Queue fields
      *---------------------------------------------------------------

       01  WS-OUTPUT-Q                 PIC X(48) VALUE 'TEST.CLIENT'.
       01  OPO-OPTIONS                 PIC S9(9) BINARY.
       01  OPO-Q-HANDLE                PIC S9(9) BINARY.

      *---------------------------------------------------------------
      *    Input Queue fields
      *---------------------------------------------------------------

       01  WS-INPUT-Q                  PIC X(12) VALUE 'TEST.SERVER'.
       01  OPI-OPTIONS                 PIC S9(9) BINARY.
       01  OPI-Q-HANDLE                PIC S9(9) BINARY.
       01  RETURNED-LENGTH             PIC S9(9) BINARY.

      *---------------------------------------------------------------
      *    Close Options
      *---------------------------------------------------------------

       01  CLS-OPTIONS          PIC S9(9) BINARY.
      *
      *
      *
       01  PRT-LOG-MESSAGE.
           05  PRT-LOG-TIME        PIC X(8).
           05  FILLER              PIC X(2) VALUE SPACES.
           05  PRT-COMMAND         PIC X(10).
           05  FILLER              PIC X(13) VALUE ' COMP CODE = '.
           05  PRT-COMP-CODE       PIC 9(1).
           05  FILLER              PIC X(10) VALUE ' REASON = '.
           05  PRT-REASON-CODE     PIC 9(4).
           05  FILLER              PIC X(37) VALUE SPACES.
      *
      *
      *
       01  MQM-OBJECT-DESCRIPTOR.
           COPY "D:\Program Files\MQSeries\tools\COBOL\COPYBOOK\CMQODV.CPY".
      *    COPY "CMQODV.CBL".

       01  MQM-MESSAGE-DESCRIPTOR.
           COPY "D:\Program Files\MQSeries\tools\COBOL\COPYBOOK\CMQMDV.CPY".
      *    COPY "CMQMDV".

       01  MQM-GET-MESSAGE-OPTIONS.
           COPY "D:\Program Files\MQSeries\tools\COBOL\COPYBOOK\CMQGMOV.CPY".
      *    COPY "CMQGMOV".

       01  MQM-PUT-MESSAGE-OPTIONS.
           COPY "D:\Program Files\MQSeries\tools\COBOL\COPYBOOK\CMQPMOV.CPY".
      *    COPY "CMQPMOV".
      *
       01  MQM-CONSTANTS.
           COPY "D:\Program Files\MQSeries\tools\COBOL\COPYBOOK\CMQV.CPY".
      *    COPY "CMQV".
      *
      *===============================================================
       PROCEDURE DIVISION.
      *===============================================================
      *
       1000-MAIN SECTION.

           PERFORM 2000-MQ-CONNECT.
           IF COMP-CODE NOT = MQCC-OK
                   GO TO 1000-MAIN-END.

           PERFORM 3000-MQ-OPEN-IN.
           IF COMP-CODE NOT = MQCC-OK
                   GO TO 1000-MAIN-DISCONNECT.

           PERFORM 3500-MQ-OPEN-OUT.
           IF COMP-CODE NOT = MQCC-OK
                   GO TO 1000-MAIN-DISCONNECT.
      *
      *
      *
           PERFORM 4500-MQ-GET.
           IF COMP-CODE NOT = MQCC-OK
                   GO TO 1000-MAIN-DISCONNECT.
      *
       1000-MAIN-LOOP.
      *
      *    business logic
      *    put your code here
      *    ........
      *    ........
      *
           PERFORM 4000-MQ-PUT.
           IF COMP-CODE NOT = MQCC-OK
                   GO TO 1000-MAIN-DISCONNECT.
      *
      *    Get next message - if there are more.
      *
           PERFORM 4500-MQ-GET.
           IF COMP-CODE NOT = MQCC-OK
                   GO TO 1000-MAIN-DISCONNECT.

           GO TO 1000-MAIN-LOOP.
      *
       1000-MAIN-DISCONNECT.
           PERFORM 5500-MQ-CLOSE-OUT.
           PERFORM 5000-MQ-CLOSE-IN.
           PERFORM 6000-MQ-DISCONNECT.

       1000-MAIN-END.
           STOP RUN.
      * -------------------------------------------------------------
      *                  End of main logic
      * -------------------------------------------------------------

      *
      * Connect to the local queue manager.
      *
       2000-MQ-CONNECT SECTION.

           CALL 'MQCONN' USING WS-QUEUE-MGR
                               CON-HANDLE
                               COMP-CODE
                               REASON-CODE.

           MOVE 'MQCONN'     TO PRT-COMMAND.
           MOVE COMP-CODE    TO PRT-COMP-CODE.
           MOVE REASON-CODE  TO PRT-REASON-CODE.
           ACCEPT PRT-LOG-TIME   FROM TIME.
           MOVE PRT-LOG-MESSAGE  TO WS-PRINT-LINE.
           PERFORM 8000-PRINT-LINE.

       2000-MQ-CONNECT-EXIT.
           EXIT.

      *
      * Open input queue
      *
       3000-MQ-OPEN-IN SECTION.
      *
           MOVE MQOT-Q      TO MQOD-OBJECTTYPE.
           MOVE WS-INPUT-Q  TO MQOD-OBJECTNAME.
      *
           COMPUTE OPI-OPTIONS = MQOO-INPUT-AS-Q-DEF  +
                                 MQOO-FAIL-IF-QUIESCING.
      *
           CALL 'MQOPEN' USING CON-HANDLE
                               MQOD
                               OPI-OPTIONS
                               OPI-Q-HANDLE
                               COMP-CODE
                               REASON-CODE.
      *
           MOVE 'MQOPEN'      TO PRT-COMMAND.
           MOVE COMP-CODE     TO PRT-COMP-CODE.
           MOVE REASON-CODE   TO PRT-REASON-CODE.
           ACCEPT PRT-LOG-TIME   FROM TIME.
           MOVE PRT-LOG-MESSAGE TO WS-PRINT-LINE.
           PERFORM 8000-PRINT-LINE.

       3000-MQ-OPEN-IN-EXIT.
           EXIT.

      *
      * Open output queue
      *
       3500-MQ-OPEN-OUT SECTION.

           MOVE MQOT-Q           TO MQOD-OBJECTTYPE.
           MOVE WS-OUTPUT-Q      TO MQOD-OBJECTNAME.
           COMPUTE OPO-OPTIONS = MQOO-OUTPUT +
                                 MQOO-FAIL-IF-QUIESCING.
      *
           CALL 'MQOPEN' USING CON-HANDLE
                               MQOD
                               OPO-OPTIONS
                               OPO-Q-HANDLE
                               COMP-CODE
                               REASON-CODE.

      *
           MOVE 'MQOPEN'      TO PRT-COMMAND.
           MOVE COMP-CODE     TO PRT-COMP-CODE.
           MOVE REASON-CODE   TO PRT-REASON-CODE.
           ACCEPT PRT-LOG-TIME   FROM TIME.
           MOVE PRT-LOG-MESSAGE TO WS-PRINT-LINE.
           PERFORM 8000-PRINT-LINE.

       3500-MQ-OPEN-OUT-EXIT.
           EXIT.

      *
      * Write a message to a queue.
      *
       4000-MQ-PUT SECTION.

           COMPUTE MQPMO-OPTIONS = MQPMO-NO-SYNCPOINT +
                                   MQPMO-FAIL-IF-QUIESCING.
           MOVE MQMT-REPLY TO MQMD-MSGTYPE.
      *
           CALL 'MQPUT' USING  CON-HANDLE
                               OPO-Q-HANDLE
                               MQMD
                               MQPMO
                               OUTPUT-BUFFER-LENGTH
                               WS-OUTPUT-BUFFER
                               COMP-CODE
                               REASON-CODE.
      *
           MOVE 'MQPUT'       TO PRT-COMMAND.
           MOVE COMP-CODE     TO PRT-COMP-CODE.
           MOVE REASON-CODE   TO PRT-REASON-CODE.
           ACCEPT PRT-LOG-TIME  FROM TIME.
           MOVE PRT-LOG-MESSAGE TO WS-PRINT-LINE.
           PERFORM 8000-PRINT-LINE.

       4000-MQ-PUT-EXIT.
           EXIT.

      *
      * Read a message from the queue.
      *
       4500-MQ-GET SECTION.

           MOVE MQMI-NONE TO MQMD-MSGID.
           MOVE MQCI-NONE TO MQMD-CORRELID.
      *
           COMPUTE MQGMO-OPTIONS = MQGMO-WAIT +
                                   MQGMO-ACCEPT-TRUNCATED-MSG +
                                   MQGMO-NO-SYNCPOINT +
                                   MQGMO-FAIL-IF-QUIESCING.
      *    Wait up to 30 seconds.
           MOVE 30000 TO MQGMO-WAITINTERVAL.
      *
           CALL 'MQGET' USING CON-HANDLE
                              OPI-Q-HANDLE
                              MQMD
                              MQGMO
                              INPUT-BUFFER-LENGTH
                              WS-OUTPUT-BUFFER
                              RETURNED-LENGTH
                              COMP-CODE
                              REASON-CODE.

      *
           MOVE 'MQGET'           TO PRT-COMMAND.
           MOVE COMP-CODE         TO PRT-COMP-CODE.
           MOVE REASON-CODE       TO PRT-REASON-CODE.
           ACCEPT PRT-LOG-TIME  FROM TIME.
           MOVE PRT-LOG-MESSAGE   TO WS-PRINT-LINE.
           PERFORM 8000-PRINT-LINE.

       4500-MQ-GET-EXIT.
           EXIT.

      *
      * Close input queue
      *
       5000-MQ-CLOSE-IN SECTION.
      *
           MOVE MQCO-NONE  TO CLS-OPTIONS.
      *
           CALL 'MQCLOSE' USING CON-HANDLE
                                OPI-Q-HANDLE
                                CLS-OPTIONS
                                COMP-CODE
                                REASON-CODE.
      *
           MOVE 'CLOSE'       TO PRT-COMMAND.
           MOVE COMP-CODE     TO PRT-COMP-CODE.
           MOVE REASON-CODE   TO PRT-REASON-CODE.
           ACCEPT PRT-LOG-TIME   FROM TIME.
           MOVE PRT-LOG-MESSAGE TO WS-PRINT-LINE.
           PERFORM 8000-PRINT-LINE.

       5000-MQ-CLOSE-IN-EXIT.
           EXIT.

      *
      * Close output queue
      *
       5500-MQ-CLOSE-OUT SECTION.

           MOVE MQCO-NONE TO CLS-OPTIONS.
      *
           CALL 'MQCLOSE' USING CON-HANDLE
                                OPO-Q-HANDLE
                                CLS-OPTIONS
                                COMP-CODE
                                REASON-CODE.

      *
           MOVE 'CLOSE'       TO PRT-COMMAND.
           MOVE COMP-CODE     TO PRT-COMP-CODE.
           MOVE REASON-CODE   TO PRT-REASON-CODE.
           ACCEPT PRT-LOG-TIME  FROM TIME.
           MOVE PRT-LOG-MESSAGE TO WS-PRINT-LINE.
           PERFORM 8000-PRINT-LINE.

       5500-MQ-CLOSE-OUT-EXIT.
           EXIT.

      *
      * Disconnect from the queue manager
      *
       6000-MQ-DISCONNECT SECTION.

           CALL 'MQDISC' USING CON-HANDLE
                               COMP-CODE
                               REASON-CODE.

      *
           ACCEPT PRT-LOG-TIME  FROM TIME.
           MOVE 'MQDISC'      TO PRT-COMMAND.
           MOVE COMP-CODE     TO PRT-COMP-CODE.
           MOVE REASON-CODE   TO PRT-REASON-CODE.
           MOVE PRT-LOG-MESSAGE TO WS-PRINT-LINE.
           PERFORM 8000-PRINT-LINE.

       6000-MQ-DISCONNECT-EXIT.
           EXIT.
      *
      *    This section prints all data lines produced by the program
      *
       8000-PRINT-LINE SECTION.

           DISPLAY WS-PRINT-LINE.
           MOVE SPACES TO WS-PRINT-LINE.
      *
       8000-PRINT-LINE-END.
           EXIT.
      *
      * -------------------------------------------------------------
      *                  End of the program
      * -------------------------------------------------------------
