//-------------------------------------------------------------
//  Tech Task 1 - Xilinx
//  Timer Scoreboard
//  Author : Sheshu Ramanandan : krsheshu@gmail.com
//-------------------------------------------------------------


module scoreboard  #(  parameter   TIMER_BITWIDTH    =   32  ,
                                   NB_INSTANCES      =   10  )

                    ( timer_bfm bfm );

  bit [ TIMER_BITWIDTH-1 : 0 ] predicted_counter  [ NB_INSTANCES-1 :0 ] =       ' { NB_INSTANCES { TIMER_BITWIDTH' (1'b0) } } ;
  bit [ TIMER_BITWIDTH-1 : 0 ] predicted_count    [ NB_INSTANCES-1 :0 ] =       ' { NB_INSTANCES { TIMER_BITWIDTH' (1'b0) } } ;

  int scoreboard_counter_success                  [ NB_INSTANCES-1 :0 ] =       ' { NB_INSTANCES { 1'b1 } } ;
  int scoreboard_captured_success                 [ NB_INSTANCES-1 :0 ] =       ' { NB_INSTANCES { 1'b1 } } ;
  int scoreboard_rst_capture_in_success           [ NB_INSTANCES-1 :0 ] =       ' { NB_INSTANCES { 1'b1 } } ;
  int scoreboard_rst_success                      [ NB_INSTANCES-1 :0 ] =       ' { NB_INSTANCES { 1'b1 } } ;
  int scoreboard_rst_an_success                   [ NB_INSTANCES-1 :0 ] =       ' { NB_INSTANCES { 1'b1 } } ;
  int scoreboard_alarm_out_success                [ NB_INSTANCES-1 :0 ] =       ' { NB_INSTANCES { 1'b1 } } ;

  int reached_scoreboard_counter                  [ NB_INSTANCES-1 :0 ] =       ' { NB_INSTANCES { 1'b0 } } ;
  int reached_scoreboard_captured                 [ NB_INSTANCES-1 :0 ] =       ' { NB_INSTANCES { 1'b0 } } ;
  int reached_scoreboard_rst_capture_in           [ NB_INSTANCES-1 :0 ] =       ' { NB_INSTANCES { 1'b0 } } ;
  int reached_scoreboard_rst                      [ NB_INSTANCES-1 :0 ] =       ' { NB_INSTANCES { 1'b0 } } ;
  int reached_scoreboard_rst_an                   [ NB_INSTANCES-1 :0 ] =       ' { NB_INSTANCES { 1'b0 } } ;
  int reached_scoreboard_alarm_out                [ NB_INSTANCES-1 :0 ] =       ' { NB_INSTANCES { 1'b0 } } ;

  bit capture_rising                              [ NB_INSTANCES-1 :0 ] ;
  bit capture_r                                   [ NB_INSTANCES-1 :0 ] ;
  bit start_rising                                [ NB_INSTANCES-1 :0 ] ;
  bit start_r                                     [ NB_INSTANCES-1 :0 ] ;
  bit rst_capture_rising                          [ NB_INSTANCES-1 :0 ] ;
  bit rst_capture_r                               [ NB_INSTANCES-1 :0 ] ;
  bit start_registered                            [ NB_INSTANCES-1 :0 ] ;

  bit [ TIMER_BITWIDTH-1 : 0 ]  counter_cdc       [ NB_INSTANCES-1 :0 ] ;
  bit [ TIMER_BITWIDTH-1 : 0 ]  counter_cdc_r     [ NB_INSTANCES-1 :0 ] ;
  genvar  i ;
//----------------------------------------------------------------------------------
// Scoreboard for captured bus
//----------------------------------------------------------------------------------

  generate

      for ( i=0 ; i<NB_INSTANCES; i++ ) begin
          assign capture_rising [i]  = !capture_r [i] & bfm.capture [i];

          always @( posedge bfm.clk )
              capture_r [i] <= bfm.capture [i];


          always @( posedge bfm.clk, negedge bfm.rst_an ) begin

              if ( bfm.rst_an == 1'b0 )
                  start_registered[i]       <= 1'b0;
              else if ( bfm.rst == 1'b1 || rst_capture_rising [i] == 1'b1 )
                  start_registered[i]       <= 1'b0;
              else if ( start_rising [i] == 1'b1  )
                    start_registered [i]    <= 1'b1;
              else if ( capture_rising [i] == 1'b1 && start_registered [i] == 1'b1 )    begin
                  predicted_count [i]       <= predicted_counter[i];
                  start_registered[i]       <= 1'b0;
                  #0.1;
                  if ( bfm.captured [i*TIMER_BITWIDTH +: TIMER_BITWIDTH] != predicted_count [i] )  begin
                      $display("@%08d: Failed scoreboard_captured:  predicted_count: %d, captured: %d ",
                                          $time, predicted_count [i], bfm.captured [i*TIMER_BITWIDTH +: TIMER_BITWIDTH] );
                      scoreboard_captured_success [i] = 0;
                  end else  begin
                    $display("@%08d: Success scoreboard_captured: predicted_count: %d, captured: %d",
                                          $time, predicted_count [i], bfm.captured [i*TIMER_BITWIDTH +: TIMER_BITWIDTH] );
                    reached_scoreboard_captured [i] = 1;
                  end
              end
          end

      end
  endgenerate


//----------------------------------------------------------------------------------
// Scoreboard for counter
//----------------------------------------------------------------------------------

  generate
      for ( i=0 ; i<NB_INSTANCES; i++ ) begin
          assign start_rising [i] = !start_r [i] & bfm.start [i];

          always @( posedge bfm.clk )
              start_r[i] <= bfm.start[i];


          always @( posedge bfm.clk ) begin
                if ( bfm.rst_an == 1'b0 )
                    predicted_counter [i] <= 'h0;
                else if ( start_rising [i] == 1 || bfm.rst == 1'b1 )
                    predicted_counter [i] <= 'h0;
                else
                    predicted_counter [i] <= predicted_counter [i]+1;

                    #0.1;
                    if ( bfm.rst == 1'b0 && (bfm.counter [i*TIMER_BITWIDTH +: TIMER_BITWIDTH] != predicted_counter [i] ) ) begin
                      $display("@%08d: Failed scoreboard_counter:  predicted counter: %d, counter: %d ",
                                        $time, predicted_counter [i], bfm.counter [i*TIMER_BITWIDTH +: TIMER_BITWIDTH] );
                      scoreboard_counter_success [i] = 0;
                    end
                    reached_scoreboard_counter [i] = 1;

          end
      end
  endgenerate



//----------------------------------------------------------------------------------
// Scoreboard for rst_capture_in
//----------------------------------------------------------------------------------

  generate
      for ( i=0 ; i<NB_INSTANCES; i++ ) begin
          assign rst_capture_rising [i] = !rst_capture_r [i] & bfm.rst_capture [i];

          always @( posedge bfm.clk )
              rst_capture_r [i] <= bfm.rst_capture [i];

          always @( posedge bfm.clk ) begin

              if ( rst_capture_rising [i] == 1'b1 ) begin
                  #0.1;
                  if ( bfm.captured [i*TIMER_BITWIDTH +: TIMER_BITWIDTH] != 32'b0 ) begin
                      $display("@%08d: Failed scoreboard_rst_capture_in:  predicted value: %d, captured_out: %d ",
                                        $time, 32'b0, bfm.captured [i*TIMER_BITWIDTH +: TIMER_BITWIDTH] );
                      scoreboard_rst_capture_in_success [i] = 0;
                  end
                  reached_scoreboard_rst_capture_in [i] = 1;
              end
          end
      end

  endgenerate

//----------------------------------------------------------------------------------
// Scoreboard for rst
//----------------------------------------------------------------------------------

  generate

      for ( i=0 ; i<NB_INSTANCES; i++ ) begin

          always @( posedge bfm.clk )
              rst_capture_r [i] <= bfm.rst_capture [i];

            always @( posedge bfm.clk ) begin

                if ( bfm.rst  == 1'b1 ) begin
                    #0.1;
                    if ( bfm.captured [i*TIMER_BITWIDTH +: TIMER_BITWIDTH] != 32'b0 || bfm.counter [i*TIMER_BITWIDTH +: TIMER_BITWIDTH] != 32'b0 ) begin
                        $display("@%08d: Failed scoreboard_rst:  predicted value: %d, captured_out: %d counter_out: %d ",
                                          $time, 32'b0, bfm.captured [i*TIMER_BITWIDTH +: TIMER_BITWIDTH], bfm.counter [i*TIMER_BITWIDTH +: TIMER_BITWIDTH] );
                        scoreboard_rst_success [i] = 0;
                    end
                    reached_scoreboard_rst [i] = 1;
                end
            end
      end

  endgenerate

//----------------------------------------------------------------------------------
// Scoreboard for rst_an
//----------------------------------------------------------------------------------

  generate

      for ( i=0 ; i<NB_INSTANCES; i++ ) begin

            always @( posedge bfm.rst_an ) begin
                #0.1;
                if ( bfm.captured [i*TIMER_BITWIDTH +: TIMER_BITWIDTH] != 32'b0 || bfm.counter [i*TIMER_BITWIDTH +: TIMER_BITWIDTH] != 32'b0 ) begin
                    $display("@%08d: Failed scoreboard_rst_an:  predicted value: %d, captured_out: %d counter_out: %d ",
                                      $time, 32'b0, bfm.captured [i*TIMER_BITWIDTH +: TIMER_BITWIDTH], bfm.counter [i*TIMER_BITWIDTH +: TIMER_BITWIDTH] );
                    scoreboard_rst_an_success [i] = 0;
                end
                reached_scoreboard_rst_an [i] = 1;
            end
      end

  endgenerate

//----------------------------------------------------------------------------------
// Scoreboard for alarm_out
//----------------------------------------------------------------------------------

  generate

      for ( i=0 ; i<NB_INSTANCES; i++ ) begin

          always @( posedge bfm.clk_alarm ) begin
              counter_cdc[i]    <= bfm.counter[i*TIMER_BITWIDTH +: TIMER_BITWIDTH]-1;
              counter_cdc_r[i]  <= counter_cdc[i];
          end

          always @( posedge bfm.alarm_out [i] )   begin
              #0.1;
              if ( bfm.alarm_en [i] != 1'b1 || bfm.alarm [i*TIMER_BITWIDTH +: TIMER_BITWIDTH] != counter_cdc_r[i] ) begin
                  $display("@%08d: Failed scoreboard_alarm_out:  alarm_en: %d, alarm_in: %d, counter_out: %d ",
                                $time, bfm.alarm_en [i], bfm.alarm [i*TIMER_BITWIDTH +: TIMER_BITWIDTH], counter_cdc_r [i] );
                  scoreboard_alarm_out_success [i] = 0;
              end
              reached_scoreboard_alarm_out [i] = 1;
          end

      end

  endgenerate

//----------------------------------------------------------------------------------
// Main block
//----------------------------------------------------------------------------------

  final begin

      $display("\n\n-------------------------------------------");
      $display("------ Final Scoreboard Results -----------");
      $display("-------------------------------------------");

      for ( int i=0 ; i<NB_INSTANCES; i++ ) begin

          if ( scoreboard_captured_success [i] == 1 && reached_scoreboard_captured [i] == 1)
                  $display("@%08d: Success: Scoreboard Instance nb: %8d  , Scoreboard Name: scoreboard_captured!",$time, i );
          else
                  $display("@%08d: Failed : Scoreboard Instance nb: %8d  , Scoreboard Name: scoreboard_captured!",$time, i );

          if ( scoreboard_counter_success [i] == 1 && reached_scoreboard_counter [i] == 1)
                  $display("@%08d: Success: Scoreboard Instance nb: %8d  , Scoreboard Name: scoreboard_counter!", $time, i );
          else
                  $display("@%08d: Failed : Scoreboard Instance nb: %8d  , Scoreboard Name: scoreboard_counter!", $time, i );

          if ( scoreboard_rst_capture_in_success [i] == 1 && reached_scoreboard_rst_capture_in [i] == 1)
                  $display("@%08d: Success: Scoreboard Instance nb: %8d  , Scoreboard Name: scoreboard_rst_capture_in!",$time, i );
          else
                  $display("@%08d: Failed : Scoreboard Instance nb: %8d  , Scoreboard Name: scoreboard_rst_capture_in!",$time, i );

          if ( scoreboard_rst_success [i] == 1 && reached_scoreboard_rst [i] == 1)
                  $display("@%08d: Success: Scoreboard Instance nb: %8d  , Scoreboard Name: scoreboard_rst!",$time, i );
          else
                  $display("@%08d: Failed : Scoreboard Instance nb: %8d  , Scoreboard Name: scoreboard_rst!",$time, i );

          if ( scoreboard_rst_an_success [i] == 1 && reached_scoreboard_rst_an [i] == 1)
                  $display("@%08d: Success: Scoreboard Instance nb: %8d  , Scoreboard Name: scoreboard_rst_an!",$time, i );
          else
                  $display("@%08d: Failed : Scoreboard Instance nb: %8d  , Scoreboard Name: scoreboard_rst_an!",$time, i );

          if ( scoreboard_alarm_out_success [i] == 1 && reached_scoreboard_alarm_out [i] == 1)
                  $display("@%08d: Success: Scoreboard Instance nb: %8d  , Scoreboard Name: scoreboard_alarm_out!",$time, i );
          else
                  $display("@%08d: Failed : Scoreboard Instance nb: %8d  , Scoreboard Name: scoreboard_alarm_out!",$time, i );
      end
      $display("-------------------------------------------");
  end
//----------------------------------------------------------------------------------
endmodule : scoreboard
