//-------------------------------------------------------------
//  Tech Task 1 - Xilinx
//  Timer BFM Interface
//  Author : Sheshu Ramanandan : krsheshu@gmail.com
//-------------------------------------------------------------


interface timer_bfm  #(
                          parameter   TIMER_BITWIDTH  =   32    ,
                                      NB_INTERFACES   =   10
                      )

                    ( );

import clock_period_pkg::*;

//-------------------------------------------------------------
//  Interface signals
//-------------------------------------------------------------


    logic                                             clk             ;
    logic                                             rst_an          ;
    logic                                             rst             ;

    logic                 [ NB_INTERFACES-1 : 0 ]     rst_capture     ;
    logic                 [ NB_INTERFACES-1 : 0 ]     start           ;
    logic                 [ NB_INTERFACES-1 : 0 ]     capture         ;

    logic                 [ NB_INTERFACES-1 : 0 ]     alarm_en        ;

    logic   [ TIMER_BITWIDTH*NB_INTERFACES -1 : 0 ]   alarm           ;

    logic   [ TIMER_BITWIDTH*NB_INTERFACES -1 : 0 ]   captured        ;
    logic   [ TIMER_BITWIDTH*NB_INTERFACES -1 : 0 ]   counter         ;

    logic                                             clk_alarm       ;
    logic                 [ NB_INTERFACES-1 : 0 ]     alarm_out       ;


//-------------------------------------------------------------
//  Clk Description
//-------------------------------------------------------------

initial begin
    clk   =   0;
    forever begin
      # (CLKPERIOD_NS/2);
      clk = ~clk;
    end
end

initial begin
    clk_alarm   =   0;
    forever begin
      # (CLKPERIOD_ALARM__NS/2);
      clk_alarm = ~clk_alarm;
    end
end

//-------------------------------------------------------------
//  Initialize all module input signals
//-------------------------------------------------------------

initial begin
  for ( int i=0 ;i<NB_INTERFACES; i++) begin
    rst_capture [i] =   0;
    start       [i] =   0;
    capture     [i] =   0;
    alarm_en    [i] =   0;
    alarm       [ i*TIMER_BITWIDTH +: TIMER_BITWIDTH ] =   0;
  end
end

//----------------------------------------------------------------------------------
// sync_reset_timer
//----------------------------------------------------------------------------------

task sreset_timer_ns ( int nb_clocks );

  rst     <= 1'b1    ;
  for ( int i =0; i< nb_clocks ; i++ )
    @( posedge clk )  ;
  rst     <= 1'b0    ;
  repeat ( 2 ) @( posedge clk )  ;

endtask: sreset_timer_ns

//----------------------------------------------------------------------------------
// async_reset_timer
//----------------------------------------------------------------------------------

task areset_timer_ns( int time_in_ns );

  rst_an  = 1'b0    ;
  #(time_in_ns);
  rst_an  = 1'b1    ;
  repeat ( 2 ) @( posedge clk )  ;

endtask: areset_timer_ns

//----------------------------------------------------------------------------------
// reset_capture
//----------------------------------------------------------------------------------

task reset_capture_ns( int time_in_ns, int nb_interface );

  rst_capture [ nb_interface] <= 1'b1    ;
  #(time_in_ns);
  rst_capture [ nb_interface] <= 1'b0    ;
  repeat ( 2 ) @( posedge clk )  ;

endtask: reset_capture_ns

//----------------------------------------------------------------------------------
// send pulse
//----------------------------------------------------------------------------------


task send_pulse( int pulsewidth_in_clks, int nb_interface );

  start   [ nb_interface ] <= 1'b0;
  capture [ nb_interface ] <= 1'b0;
  @( posedge clk );
  start   [ nb_interface ] <= 1'b1;
  @( posedge clk );
  start  [ nb_interface ]  <= 1'b0;
  repeat ( pulsewidth_in_clks - 1 ) @( posedge clk );
  capture  [ nb_interface ]  <= 1'b1;
  @( posedge clk );
  @( posedge clk );
  capture  [ nb_interface ]  <= 1'b0;
  repeat ( 10 ) @( posedge clk );
endtask: send_pulse


//----------------------------------------------------------------------------------
// send start pulse
//----------------------------------------------------------------------------------

task send_start_pulse( int pulsewidth_in_clks, int nb_interface );

  start  [ nb_interface ] <= 1'b0;
  @( posedge clk );
  start  [ nb_interface ]  <= 1'b1;
  repeat ( pulsewidth_in_clks ) @ ( posedge clk) ;
  start  [ nb_interface ]  <= 1'b0;

endtask: send_start_pulse

//----------------------------------------------------------------------------------
// send capture pulse
//----------------------------------------------------------------------------------

task send_capture_pulse( int pulsewidth_in_clks, int nb_interface );

  capture  [ nb_interface ]  <= 1'b0;
  @( posedge clk );
  capture  [ nb_interface ]  <= 1'b1;
  repeat ( pulsewidth_in_clks ) @ ( posedge clk ) ;
  capture  [ nb_interface ]  <= 1'b0;

endtask: send_capture_pulse

//----------------------------------------------------------------------------------
// enable alarm
//----------------------------------------------------------------------------------

task enable_alarm( int alarm_value, int nb_interface );

  alarm_en   [ nb_interface ] = 1'b1            ;
  alarm      [ nb_interface ] = alarm_value     ;

endtask: enable_alarm

//----------------------------------------------------------------------------------
// disable alarm
//----------------------------------------------------------------------------------

task disable_alarm( int nb_interface );

  alarm_en   [ nb_interface ]  = 1'b0           ;

endtask: disable_alarm


//----------------------------------------------------------------------------------
endinterface
