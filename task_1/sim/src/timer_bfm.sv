//-------------------------------------------------------------
//  Tech Task 1 - Xilinx
//  Timer BFM Interface
//  Author : Sheshu Ramanandan : krsheshu@gmail.com
//-------------------------------------------------------------

parameter CLKPERIOD_NS = 8.196       ;   // 122MHz


interface timer_bfm;

//-------------------------------------------------------------
//  Interface signals
//-------------------------------------------------------------


    logic                 clk             ;
    logic                 rst_an          ;
    logic                 rst             ;

    logic                 rst_capture     ;
    logic                 start           ;
    logic                 capture         ;

    logic                 alarm_en        ;
    logic   [ 31: 0 ]     alarm           ;

    logic   [ 31: 0 ]     captured        ;
    logic   [ 31: 0 ]     counter         ;

    logic                 alarm_out       ;


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


//-------------------------------------------------------------
//  Initialize all module input signals
//-------------------------------------------------------------

initial begin
    rst_capture =   0;
    start       =   0;
    capture     =   0;
    alarm_en    =   0;
    alarm       =   0;
end

//----------------------------------------------------------------------------------
// sync_reset_timer
//----------------------------------------------------------------------------------

task sreset_timer_ns ( int nb_clocks );

  rst     = 1'b1    ;
  for ( int i =0; i< nb_clocks ; i++ )
    @( posedge clk )  ;
  rst     = 1'b0    ;
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

task reset_capture_ns( int time_in_ns );

  rst_capture = 1'b1    ;
  #(time_in_ns);
  rst_capture = 1'b0    ;
  repeat ( 2 ) @( posedge clk )  ;

endtask: reset_capture_ns

//----------------------------------------------------------------------------------
// send pulse
//----------------------------------------------------------------------------------


task send_pulse( int pulsewidth_in_clks );

  start   <= 1'b0;
  capture <= 1'b0;
  @( posedge clk );
  start <= 1'b1;
  @( posedge clk );
  start <= 1'b0;
  repeat ( pulsewidth_in_clks - 1 ) @( posedge clk );
  capture <= 1'b1;
  @( posedge clk );
  @( posedge clk );
  capture <= 1'b0;
  repeat ( 10 ) @( posedge clk );
endtask: send_pulse


//----------------------------------------------------------------------------------
// send start pulse
//----------------------------------------------------------------------------------

task send_start_pulse( int pulsewidth_in_clks );

  start   <= 1'b0;
  @( posedge clk );
  start <= 1'b1;
  repeat ( pulsewidth_in_clks ) @ ( posedge clk) ;
  start <= 1'b0;

endtask: send_start_pulse

//----------------------------------------------------------------------------------
// send capture pulse
//----------------------------------------------------------------------------------

task send_capture_pulse( int pulsewidth_in_clks );

  capture   <= 1'b0;
  @( posedge clk );
  capture <= 1'b1;
  repeat ( pulsewidth_in_clks ) @ ( posedge clk ) ;
  capture <= 1'b0;

endtask: send_capture_pulse

//----------------------------------------------------------------------------------
// enable alarm
//----------------------------------------------------------------------------------

task enable_alarm( int alarm_value );

  alarm_en  = 1'b1            ;
  alarm     = alarm_value     ;

endtask: enable_alarm

//----------------------------------------------------------------------------------
// disable alarm
//----------------------------------------------------------------------------------

task disable_alarm( );

  alarm_en  = 1'b0            ;

endtask: disable_alarm


//----------------------------------------------------------------------------------
endinterface
