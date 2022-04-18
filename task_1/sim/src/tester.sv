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

    automatic int nb_pulses                 ;

    for ( int i=1; i<=random_test_cases; i++ )  begin
        nb_pulses = $urandom & 16'hFFFF ;
        $display("-------------------------------------------");
        $display("@%08d: Test Case %d: nb_pulses: %d",$time, i, nb_pulses);
        $display("-------------------------------------------");
        bfm.send_pulse( nb_pulses );
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

    // reset the timer
    fork
        bfm.sreset_timer_ns   ( 10  );
        bfm.areset_timer_ns   ( 100 );
        bfm.reset_capture_ns  ( 50  );
    join

    // Run Test Suite 1
    $display("@%08d: Running Test Suite 1",$time);
    test_suite_1( 100 );

    // Run Test Suite 2
    $display("@%08d: Running Test Suite 2",$time);
    test_suite_2( );

    // Run Test Suite 3
    $display("@%08d: Running Test Suite 3",$time);
    test_suite_3( );

    // Run Test Suite 4
    $display("@%08d: Running Test Suite 4",$time);
    test_suite_4( 25 );

    $finish;
end


//----------------------------------------------------------------------------------
endmodule
