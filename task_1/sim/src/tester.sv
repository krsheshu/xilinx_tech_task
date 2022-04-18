//-------------------------------------------------------------
//  Tech Task 1 - Xilinx
//  Tester Block
//  Author : Sheshu Ramanandan : krsheshu@gmail.com
//-------------------------------------------------------------

module tester ( timer_bfm bfm ) ;

import clock_period_pkg::CLKPERIOD_NS;

//----------------------------------------------------------------------------------
// Test Suite 1
//----------------------------------------------------------------------------------

task test_suite_1( int random_test_cases );

    automatic int nb_clks                 ;

    for ( int i=1; i<=random_test_cases; i++ )  begin
        nb_clks = $urandom & 16'hFFFF ;
        $display("-------------------------------------------");
        $display("@%08d: Test Case %d: nb_clks: %d",$time, i, nb_clks);
        $display("-------------------------------------------");
        bfm.send_pulse( nb_clks );
    end

endtask : test_suite_1

//----------------------------------------------------------------------------------
// Test Suite 2
//----------------------------------------------------------------------------------

task test_suite_2( );

    $display("-------------------------------------------");
    $display("@%08d: Test Case %d: capture pulse ",$time, 1 );
    $display("-------------------------------------------");
    bfm.send_start_pulse(100);
    #500;
    bfm.send_capture_pulse(100);
    bfm.send_capture_pulse(50);


endtask : test_suite_2

//----------------------------------------------------------------------------------
// Test Suite 3
//----------------------------------------------------------------------------------

task test_suite_3( );

    $display("-------------------------------------------");
    $display("@%08d: Test Case %d: rst_capture ",$time, 1 );
    $display("-------------------------------------------");
    #500;
    bfm.send_start_pulse(100);
    #500;
    bfm.reset_capture_ns(10);
    #200;
    bfm.send_start_pulse(100);
    #1815;
    bfm.send_capture_pulse(100);


endtask : test_suite_3

//----------------------------------------------------------------------------------
// Test Suite 4
//----------------------------------------------------------------------------------

task test_suite_4( int random_test_cases );

    int alarm_time_in_clks ;
    for ( int i=0; i<random_test_cases; i++ ) begin
        alarm_time_in_clks = $urandom & 16'hFFFF;
        $display("-------------------------------------------");
        $display("@%08d: Test Case %d: alarm_time_in_clks: %d",$time, i, alarm_time_in_clks);
        $display("-------------------------------------------");
        bfm.enable_alarm( alarm_time_in_clks );
        #500;
        bfm.send_start_pulse( 100 );
        #( alarm_time_in_clks * CLKPERIOD_NS );
        #200;
    end

endtask : test_suite_4

//----------------------------------------------------------------------------------
// Tester Block
//----------------------------------------------------------------------------------


initial begin

    automatic int test_cases = 0;

    // reset the timer
    fork
        bfm.sreset_timer_ns   ( 10  );
        bfm.areset_timer_ns   ( 100 );
        bfm.reset_capture_ns  ( 50  );
    join

    test_cases = 100;
    // Run Test Suite 1
    $display("*********************************************************");
    $display("@%08d: Running Test Suite 1",$time);
    $display("@%08d: %4d Test cases by sending an event ( start->capture) with randomized number of clks",$time, test_cases);
    test_suite_1( test_cases );
    $display("*********************************************************");

    // Run Test Suite 2
    $display("*********************************************************");
    $display("@%08d: Running Test Suite 2",$time);
    $display("@%08d: Tests by sending an event ( start->capture->capture) with fixed number of clks",$time);
    test_suite_2( );
    $display("*********************************************************");

    // Run Test Suite 3
    $display("*********************************************************");
    $display("@%08d: Running Test Suite 3",$time);
    $display("@%08d: Tests by sending an event ( start->capture->start->capture) with fixed number of clks",$time);
    test_suite_3( );
    $display("*********************************************************");

    // Run Test Suite 4
    test_cases = 25;
    $display("*********************************************************");
    $display("@%08d: Running Test Suite 4",$time);
    $display("@%08d: %4d Test cases by sending an event ( alarm ) with randomized number of clks for alarm_in",$time, test_cases);
    test_suite_4( test_cases );
    $display("*********************************************************");

    $finish;
end


//----------------------------------------------------------------------------------
endmodule
