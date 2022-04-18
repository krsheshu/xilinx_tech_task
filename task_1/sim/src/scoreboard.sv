//-------------------------------------------------------------
//  Tech Task 1 - Xilinx
//  Timer Scoreboard
//  Author : Sheshu Ramanandan : krsheshu@gmail.com
//-------------------------------------------------------------


module scoreboard ( timer_bfm bfm );

  bit [31:0] predicted_counter  =     0 ;
  bit [31:0] counter            =     0 ;

  bit [31:0] predicted_count    =     0 ;

  int scoreboard_counter_success        =     1 ;
  int scoreboard_captured_success       =     1 ;
  int scoreboard_rst_capture_in_success =     1 ;
  int scoreboard_rst_success            =     1 ;
  int scoreboard_rst_an_success         =     1 ;
  int scoreboard_alarm_out_success      =     1 ;

  int reached_scoreboard_counter        =     0 ;
  int reached_scoreboard_captured       =     0 ;
  int reached_scoreboard_rst_capture_in =     0 ;
  int reached_scoreboard_rst            =     0 ;
  int reached_scoreboard_rst_an         =     0 ;
  int reached_scoreboard_alarm_out      =     0 ;

  bit capture_rising                    ;
  bit capture_r                         ;
  bit start_rising                      ;
  bit start_r                           ;
  bit rst_capture_rising                ;
  bit rst_capture_r                     ;

//----------------------------------------------------------------------------------
// Scoreboard for captured bus
//----------------------------------------------------------------------------------

  assign capture_rising  = !capture_r & bfm.capture;

  task scoreboard_captured();

        forever begin

            @( posedge bfm.start );

            forever begin

                    @( posedge bfm.clk );
                    capture_r   <= bfm.capture ;

                    if ( capture_rising == 1'b1 )    begin
                        predicted_count <= predicted_counter;
                        #0.1;
                        if ( bfm.captured != predicted_count )  begin
                            $display("@%08d: Failed scoreboard_captured:  predicted_count: %d, captured: %d ", $time, predicted_count, bfm.captured );
                            scoreboard_captured_success = 0;
                        end else  begin
                          $display("@%08d: Success scoreboard_captured: predicted_count: %d, captured: %d", $time, predicted_count, bfm.captured );
                        end
                        break;
                    end
                    reached_scoreboard_captured = 1;
            end
        end

  endtask : scoreboard_captured


//----------------------------------------------------------------------------------
// Scoreboard for counter
//----------------------------------------------------------------------------------

  assign start_rising  = !start_r & bfm.start;

  task scoreboard_counter();

     @( posedge bfm.start );

     forever begin

            @( posedge bfm.clk );

            start_r   <= bfm.start ;

            if ( start_rising == 1)
              predicted_counter <= 0;
            else
              predicted_counter <= predicted_counter+1;

            #0.1;
            if ( bfm.counter != predicted_counter ) begin
              $display("@%08d: Failed scoreboard_counter:  predicted counter: %d, counter: %d ", $time, predicted_counter, bfm.counter );
              scoreboard_counter_success = 0;
            end
            reached_scoreboard_counter = 1;
      end

  endtask : scoreboard_counter


//----------------------------------------------------------------------------------
// Scoreboard for rst_capture_in
//----------------------------------------------------------------------------------

  assign rst_capture_rising  = !rst_capture_r & bfm.rst_capture;

  task scoreboard_rst_capture_in();

      forever begin

            @( posedge bfm.clk );
            rst_capture_r <= bfm.rst_capture;

            if ( rst_capture_rising == 1'b1 ) begin
                #0.1;
                if ( bfm.captured != 32'b0 ) begin
                    $display("@%08d: Failed scoreboard_rst_capture_in:  predicted value: %d, captured_out: %d ", $time, 32'b0, bfm.captured );
                    scoreboard_rst_capture_in_success = 0;
                end
            end
            reached_scoreboard_rst_capture_in = 1;
      end

  endtask : scoreboard_rst_capture_in

//----------------------------------------------------------------------------------
// Scoreboard for rst
//----------------------------------------------------------------------------------

  task scoreboard_rst();

      forever begin

            @( posedge bfm.clk );

            if ( bfm.rst == 1'b1 ) begin
                #0.1;
                if ( bfm.captured != 32'b0 || bfm.counter != 32'b0 ) begin
                    $display("@%08d: Failed scoreboard_rst:  predicted value: %d, captured_out: %d counter_out: %d ", $time, 32'b0, bfm.captured, bfm.counter );
                    scoreboard_rst_success = 0;
                end
            end
            reached_scoreboard_rst = 1;
      end

  endtask : scoreboard_rst

//----------------------------------------------------------------------------------
// Scoreboard for rst_an
//----------------------------------------------------------------------------------

  task scoreboard_rst_an();

      forever begin

            @( posedge bfm.rst_an );
            #0.1;
            if ( bfm.captured != 32'b0 || bfm.counter != 32'b0 ) begin
                $display("@%08d: Failed scoreboard_rst_an:  predicted value: %d, captured_out: %d counter_out: %d ", $time, 32'b0, bfm.captured, bfm.counter );
                scoreboard_rst_an_success = 0;
            end
            reached_scoreboard_rst_an = 1;
      end

  endtask : scoreboard_rst_an

//----------------------------------------------------------------------------------
// Scoreboard for alarm_out
//----------------------------------------------------------------------------------

  task scoreboard_alarm_out();

      forever begin

            @( posedge bfm.alarm_out );
            #0.1;
            if ( bfm.alarm_en != 1'b1 || bfm.alarm != bfm.counter-1 ) begin
                $display("@%08d: Failed scoreboard_alarm_out:  alarm_en: %d, alarm_in: %d, counter_out: %d ", $time, bfm.alarm_en, bfm.alarm, bfm.counter );
                scoreboard_alarm_out_success = 0;
            end
            reached_scoreboard_alarm_out = 1;
      end

  endtask : scoreboard_alarm_out

//----------------------------------------------------------------------------------
// Main block
//----------------------------------------------------------------------------------

  initial begin
      fork
          begin
              scoreboard_captured;
          end

          begin
              scoreboard_counter;
          end

          begin
              scoreboard_rst_capture_in;
          end

          begin
              scoreboard_rst;
          end

          begin
              scoreboard_rst_an;
          end

          begin
              scoreboard_alarm_out;
          end

      join
  end

  final begin

      $display("\n\n-------------------------------------------");
      $display("------ Final Scoreboard Results -----------");
      $display("-------------------------------------------");

      if ( scoreboard_captured_success == 1 && reached_scoreboard_captured == 1)
              $display("@%08d: Success: scoreboard_captured!",$time);
      else
              $display("@%08d: Failed : scoreboard_captured!",$time);

      if ( scoreboard_counter_success == 1 && reached_scoreboard_counter == 1)
              $display("@%08d: Success: scoreboard_counter!", $time);
      else
              $display("@%08d: Failed : scoreboard_counter!", $time);

      if ( scoreboard_rst_capture_in_success == 1 && reached_scoreboard_rst_capture_in == 1)
              $display("@%08d: Success: scoreboard_rst_capture_in!",$time);
      else
              $display("@%08d: Failed : scoreboard_rst_capture_in!",$time);

      if ( scoreboard_rst_success == 1 && reached_scoreboard_rst == 1)
              $display("@%08d: Success: scoreboard_rst!",$time);
      else
              $display("@%08d: Failed : scoreboard_rst!",$time);

      if ( scoreboard_rst_an_success == 1 && reached_scoreboard_rst_an == 1)
              $display("@%08d: Success: scoreboard_rst_an!",$time);
      else
              $display("@%08d: Failed : scoreboard_rst_an!",$time);

      if ( scoreboard_alarm_out_success == 1 && reached_scoreboard_alarm_out == 1)
              $display("@%08d: Success: scoreboard_alarm_out!",$time);
      else
              $display("@%08d: Failed : scoreboard_alarm_out!",$time);

      $display("-------------------------------------------");
  end
//----------------------------------------------------------------------------------
endmodule : scoreboard
