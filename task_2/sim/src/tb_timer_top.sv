
//-------------------------------------------------------------
//  Tech Task 1 - Xilinx
//  Tester  tb top
//  Author : Sheshu Ramanandan : krsheshu@gmail.com
//-------------------------------------------------------------


module tb_timer_top   #(  parameter   TIMER_BITWIDTH    =   32  ,
                                      NB_CAPTURES       =   10  );

      //------------- Parallel Timer BFMs

      timer_bfm      #(
                          .TIMER_BITWIDTH         ( TIMER_BITWIDTH      ),
                          .NB_INTERFACES          ( NB_CAPTURES         )
                      )
             bfm      ();




      //------------- Parallel Scoreboards
      scoreboard     #(
                          .TIMER_BITWIDTH         ( TIMER_BITWIDTH      ),
                          .NB_INSTANCES           ( NB_CAPTURES         )
                      )
            scoreboard_i ( bfm );





      //------------- Parallel Testers
      tester          #(
                          .TIMER_BITWIDTH         ( TIMER_BITWIDTH      ),
                          .NB_INSTANCES           ( NB_CAPTURES         )
                      )
            tester_i ( bfm );


      //------------- DUT

      timer     #(
                  .TIMER_BITWIDTH         ( TIMER_BITWIDTH      ),
                  .NB_CAPTURES            ( NB_CAPTURES         )
                )
        dut
          (
                  .clk_in                 (  bfm.clk           ),
                  .rst_an_in              (  bfm.rst_an        ),
                  .rst_in                 (  bfm.rst           ),

                  .rst_capture_in         (  bfm.rst_capture   ),
                  .start_in               (  bfm.start         ),
                  .capture_in             (  bfm.capture       ),

                  .alarm_en_in            (  bfm.alarm_en      ),
                  .alarm_in               (  bfm.alarm         ),

                  .captured_out           (  bfm.captured      ),
                  .counter_out            (  bfm.counter       ),

                  .clk_alarm_in           (  bfm.clk_alarm     ),
                  .alarm_out              (  bfm.alarm_out     )

        );



endmodule
