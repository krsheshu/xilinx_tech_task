
//-------------------------------------------------------------
//  Tech Task 1 - Xilinx
//  Tester  tb top
//  Author : Sheshu Ramanandan : krsheshu@gmail.com
//-------------------------------------------------------------


module tb_timer_top;

  timer_bfm     bfm();
  scoreboard    scoreboard_i ( bfm );
  tester        tester_i ( bfm );


  timer dut

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

                  .alarm_out              (  bfm.alarm_out     )

        );



endmodule
