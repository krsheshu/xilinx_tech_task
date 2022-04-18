//-------------------------------------------------------------
//  Tech Task 1 - Xilinx
//  Tester Block
//  Author : Sheshu Ramanandan : krsheshu@gmail.com
//-------------------------------------------------------------

module tester    #(  parameter    TIMER_BITWIDTH    =   32  ,
                                  NB_INSTANCES      =   10
                  )
                  (   timer_bfm bfm ) ;

import clock_period_pkg::CLKPERIOD_NS;

//----------------------------------------------------------------------------------
// Test Suite 1
//----------------------------------------------------------------------------------

task test_suite_1( int random_test_cases, int nb_instance );

    automatic int nb_clks   ;

    $display("-------------------------------------------");
    for ( int i=1; i<=random_test_cases; i++ )  begin
        nb_clks = $urandom & 16'hFFFF ;
        $display("@%08d: Scoreboard Instance nb: %8d, Test Case %8d: nb_clks: %8d",$time, nb_instance, i, nb_clks);
        bfm.send_pulse( nb_clks, nb_instance );
    end
    $display("-------------------------------------------");

endtask : test_suite_1

//----------------------------------------------------------------------------------
// Test Suite 2
//----------------------------------------------------------------------------------

task test_suite_2( int nb_instance );

    $display("-------------------------------------------");
    $display("@%08d: Scoreboard Instance nb: %8d, Test Case %8d: capture pulse ",$time, nb_instance, 1 );
    $display("-------------------------------------------");
    bfm.send_start_pulse(100, nb_instance);
    #500;
    bfm.send_capture_pulse(100, nb_instance);
    bfm.send_capture_pulse(50, nb_instance);


endtask : test_suite_2

//----------------------------------------------------------------------------------
// Test Suite 3
//----------------------------------------------------------------------------------

task test_suite_3( int nb_instance );

    $display("-------------------------------------------");
    $display("@%08d: Scoreboard Instance nb: %8d, Test Case %8d: rst_capture ",$time, nb_instance, 1 );
    $display("-------------------------------------------");
    #500;
    bfm.send_start_pulse(100, nb_instance);
    #500;
    bfm.reset_capture_ns(10, nb_instance);
    #200;
    bfm.send_start_pulse(100, nb_instance);
    #1815;
    bfm.send_capture_pulse(100, nb_instance);


endtask : test_suite_3

//----------------------------------------------------------------------------------
// Test Suite 4
//----------------------------------------------------------------------------------

task test_suite_4( int random_test_cases, int nb_instance );

    int alarm_time_in_clks ;
    $display("-------------------------------------------");
    for ( int i=0; i<random_test_cases; i++ ) begin
        alarm_time_in_clks = $urandom & 16'hFFFF;
        $display("@%08d: Scoreboard Instance nb: %8d, Test Case %8d: alarm_time_in_clks: %8d",$time, nb_instance, i, alarm_time_in_clks);
        bfm.enable_alarm( alarm_time_in_clks, nb_instance );
        #500;
        bfm.send_start_pulse( 100, nb_instance );
        #( alarm_time_in_clks * CLKPERIOD_NS );
        #200;
    end
    $display("-------------------------------------------");

endtask : test_suite_4

//----------------------------------------------------------------------------------
// Tester Block
//----------------------------------------------------------------------------------


initial begin

    automatic int test_cases = 0;
    // Run Reset tests
    bfm.areset_timer_ns   ( 100 );
    #50;
    bfm.sreset_timer_ns   ( 10  );
    #100;
    for ( int i=0; i<NB_INSTANCES; i++ )  begin

        bfm.reset_capture_ns  ( 500, i  );

    end

          for ( int i=0; i<NB_INSTANCES; i++ )  begin


            begin
                // Run Test Suite 1
                test_cases = 100;
                $display("*********************************************************");
                $display("@%08d: Scoreboard Instance nb: %8d,  Running Test Suite 1",$time, i);
                $display("@%08d: %4d Test cases by sending an event ( start->capture) with randomized number of clks",$time,test_cases);
                test_suite_1( test_cases, i );
                $display("*********************************************************");
            end

            begin
                // Run Test Suite 2
                $display("*********************************************************");
                $display("@%08d: Scoreboard Instance nb: %8d, Running Test Suite 2",$time, i);
                $display("@%08d: Tests by sending an event ( start->capture->capture) with fixed number of clks",$time);
                test_suite_2( i );
                $display("*********************************************************");
            end

            begin
                // Run Test Suite 3
                $display("*********************************************************");
                $display("@%08d: Scoreboard Instance nb: %8d, Running Test Suite 3",$time, i);
                $display("@%08d: Tests by sending an event ( start->capture->start->capture) with fixed number of clks",$time);
                test_suite_3( i );
                $display("*********************************************************");
            end
            begin
                // Run Test Suite 4
                test_cases = 25;
                $display("*********************************************************");
                $display("@%08d: Scoreboard Instance nb: %8d, Running Test Suite 4",$time, i);
                $display("@%08d: %4d Test cases by sending an event ( alarm ) with randomized number of clks for alarm_in",$time,test_cases);
                test_suite_4(test_cases, i);
                $display("*********************************************************");
            end
        end

    #5000;
    $finish;
end


//----------------------------------------------------------------------------------
endmodule
