import Common::*;
import Mem::*;

module BenchRAM();

    logic clk;
    logic rst;
    Signals i_signals;
    Signals o_signals;
    

    RAM RAM(
        .clk(clk),
        .rst(rst),
        .i_signals(i_signals),
        .o_signals(o_signals)
    );
    

    initial begin
        clk = 0;
        forever begin
            #1 clk = ~clk;
        end
    end
    
    typedef enum int {
        RESET_RELEASE,
        STORE_WORD_0,
        READ_WORD_0_WAIT, 
        READ_WORD_0_CHECK,
        STORE_BYTE_4,
        STORE_BYTE_5,
        STORE_BYTE_6,
        STORE_BYTE_7,
        READ_WORD_4_WAIT, 
        READ_WORD_4_SETUP,
        READ_WORD_4_CHECK,
        READ_BYTE_4_WAIT, 
        READ_BYTE_4_CHECK,
        READ_BYTE_5_WAIT, 
        READ_BYTE_5_CHECK,
        READ_BYTE_6_WAIT, 
        READ_BYTE_6_CHECK,
        READ_BYTE_7_WAIT, 
        READ_BYTE_7_CHECK,
        STORE_HALF_8,
        READ_HALF_8_WAIT, 
        READ_HALF_8_CHECK,
        STORE_HALF_10,
        READ_HALF_10_WAIT, 
        READ_HALF_10_CHECK,
        READ_WORD_8_WAIT, 
        READ_WORD_8_SETUP,
        READ_WORD_8_CHECK,
        STORE_BYTE_12,
        READ_SBYTE_12_WAIT, 
        READ_SBYTE_12_CHECK,
        READ_UBYTE_12_WAIT, 
        READ_UBYTE_12_CHECK,
        STORE_WORD_HIGH,
        READ_WORD_HIGH_WAIT, 
        READ_WORD_HIGH_CHECK,
    
        DONE
    } test_state_t;
    
    test_state_t test_state;
    int passed;
    int total;
    
    initial begin
        rst = 1;
        #2
        rst = 0;
        test_state = RESET_RELEASE;
        passed = 0;
        total = 0;
    end
    

    always @(posedge clk) begin
        case (test_state)  
            RESET_RELEASE: begin
                rst <= 0;
                $display("Test 1: Store Word at address 0");
                i_signals.memw <= 1;
                i_signals.memr <= 0;
                i_signals.memt <= StoreWord;
                i_signals.wdata <= 32'h0; // Address 0
                i_signals.reg2 <= 32'hACDFABED; // Data to write
                test_state <= STORE_WORD_0;
            end
            
            STORE_WORD_0: begin
                i_signals.memw <= 0;
                $display("Test 2: Load Word from address 0");
                i_signals.memr <= 1;
                i_signals.memw <= 0;
                i_signals.memt <= LoadWord;
                i_signals.wdata <= 32'h0; // Address 0
                test_state <= READ_WORD_0_WAIT;
            end
            
            READ_WORD_0_WAIT: begin
                test_state <= READ_WORD_0_CHECK;
            end
            READ_WORD_0_CHECK: begin
                total += 1;
                if (o_signals.wdata[31:0] === 32'hACDFABED) begin
                    passed += 1;
                    $display("PASS: Read word matches written word: 0x%h", o_signals.wdata[31:0]);
                end else
                    $display("FAIL: Read word doesn't match. Expected: 0xACDFABED, Got: 0x%h", o_signals.wdata[31:0]);
                
 
                test_state <= STORE_BYTE_4;
            end
            
            STORE_BYTE_4: begin
                $display("Test 3: Store individual bytes");
                i_signals.memw <= 1;
                i_signals.memr <= 0;
                i_signals.memt <= StoreByte;
                i_signals.wdata <= 32'h4; // Address 4
                i_signals.reg2 <= 32'h11; // Byte to write

                test_state <= STORE_BYTE_5;
            end
            
            STORE_BYTE_5: begin
                i_signals.wdata <= 32'h5; // Address 5
                i_signals.reg2 <= 32'h22; // Byte to write
                test_state <= STORE_BYTE_6;
            end
            
            STORE_BYTE_6: begin
                i_signals.wdata <= 32'h6; // Address 5
                i_signals.reg2 <= 32'h33; // Byte to write
                test_state <= STORE_BYTE_7;
            end
            
            STORE_BYTE_7: begin
                i_signals.wdata <= 32'h7; // Address 5
                i_signals.reg2 <= 32'h44; // Byte to write

                test_state <= READ_WORD_4_SETUP;
            end
            
            READ_WORD_4_SETUP: begin
                i_signals.memw <= 0;
                $display("Test 4: Load entire word to verify byte writes");
                i_signals.memr <= 1;
                i_signals.memt <= LoadWord;
                i_signals.wdata <= 32'h4; // Address 4
                test_state <= READ_WORD_4_WAIT;
            end
            READ_WORD_4_WAIT: begin
                #2
                test_state <= READ_WORD_4_CHECK;
            end

            READ_WORD_4_CHECK: begin

                total += 1;
                if (o_signals.wdata[31:0] === 32'h44332211) begin
                    passed += 1;
                    $display("PASS: Read word matches assembled bytes: 0x%h", o_signals.wdata[31:0]);
                end else
                    $display("FAIL: Read word doesn't match. Expected: 0x44332211, Got: 0x%h", o_signals.wdata[31:0]);
                
                $display("Test 5: Read individual bytes");
                i_signals.memt <= LoadByte;
                i_signals.wdata <= 32'h4;
                test_state <= READ_BYTE_4_WAIT;
            end
            
            READ_BYTE_4_WAIT: begin
                // #2
                test_state <= READ_BYTE_4_CHECK;
            end

            
            READ_BYTE_4_CHECK: begin
                total += 1;
                if ($signed(o_signals.wdata[31:0]) === $signed(8'h11)) begin
                    passed += 1;
                    $display("PASS: Byte at address 4 matches: 0x%h", o_signals.wdata[7:0]);
                end else
                    $display("FAIL: Byte at address 4 doesn't match. Expected: 0x11, Got: 0x%h", o_signals.wdata[7:0]);
                
                i_signals.wdata <= 32'h5;
                test_state <= READ_BYTE_5_WAIT;
            end
            
            READ_BYTE_5_WAIT: begin
                #2
                test_state <= READ_BYTE_5_CHECK;
            end
            

            READ_BYTE_5_CHECK: begin
                total += 1;
                if ($signed(o_signals.wdata[31:0]) === $signed(8'h22)) begin
                    passed += 1;
                    $display("PASS: Byte at address 5 matches: 0x%h", o_signals.wdata[7:0]);
                end else
                    $display("FAIL: Byte at address 5 doesn't match. Expected: 0x22, Got: 0x%h", o_signals.wdata[7:0]);
                
                i_signals.wdata <= 32'h6;
                test_state <= READ_BYTE_6_WAIT;
            end
            
            READ_BYTE_6_WAIT: begin
                #2
                test_state <= READ_BYTE_6_CHECK;
            end
            

            
            READ_BYTE_6_CHECK: begin
                total += 1;
                if ($signed(o_signals.wdata[31:0]) === $signed(8'h33)) begin
                    passed += 1;
                    $display("PASS: Byte at address 6 matches: 0x%h", o_signals.wdata[7:0]);
                end else
                    $display("FAIL: Byte at address 6 doesn't match. Expected: 0x33, Got: 0x%h", o_signals.wdata[7:0]);
                
                i_signals.wdata <= 32'h7;
                test_state <= READ_BYTE_7_WAIT;
            end
            
            READ_BYTE_7_WAIT: begin
                #2
                test_state <= READ_BYTE_7_CHECK;
            end
            
            READ_BYTE_7_CHECK: begin
                total += 1;
                if ($signed(o_signals.wdata[31:0]) === $signed(8'h44)) begin
                    passed += 1;
                    $display("PASS: Byte at address 7 matches: 0x%h", o_signals.wdata[7:0]);
                end else
                    $display("FAIL: Byte at address 7 doesn't match. Expected: 0x44, Got: 0x%h", o_signals.wdata[7:0]);
                
                
                i_signals.memw <= 1;
                i_signals.memr <= 0;
                i_signals.memt <= StoreHalf;
                i_signals.wdata <= 32'h8; // Address 8
                i_signals.reg2 <= 32'hABCD; // Half-word to write
                $display("Test 6: Store half-word: 0xABCD at address 8",);
                test_state <= STORE_HALF_8;
            end
            
            STORE_HALF_8: begin
                i_signals.memw <= 0;
                $display("Test 7: Load half-word from address 8");
                i_signals.memr <= 1;
                i_signals.memt <= LoadHalf;
                i_signals.wdata <= 32'h8; // Address 8
                test_state <= READ_HALF_8_WAIT;
            end
            
            READ_HALF_8_WAIT: begin
                #2
                test_state <= READ_HALF_8_CHECK;
            end

            READ_HALF_8_CHECK: begin
                total += 1;
                if ($signed(o_signals.wdata[31:0]) === $signed(16'hABCD)) begin
                    passed += 1;
                    $display("PASS: Half-word at address 8 matches: 0x%h", o_signals.wdata[15:0]);
                end else
                    $display("FAIL: Half-word at address 8 doesn't match. Expected: 0xABCD, Got: 0x%h", o_signals.wdata[15:0]);
                
                $display("Test 8: Store half-word at address 10");
                i_signals.memw <= 1;
                i_signals.memr <= 0;
                i_signals.memt <= StoreHalf;
                i_signals.wdata <= 32'hA; 
                i_signals.reg2 <= 32'hEF01; 
                test_state <= STORE_HALF_10;
            end
            STORE_HALF_10: begin
                i_signals.memw <= 0;
                $display("Test 9: Load half-word from address 10");
                i_signals.memr <= 1;
                i_signals.memt <= LoadHalf;
                i_signals.wdata <= 32'hA; 
                test_state <= READ_HALF_10_WAIT;
            end
            
            READ_HALF_10_WAIT: begin
                #2
                test_state <= READ_HALF_10_CHECK;
            end

            READ_HALF_10_CHECK: begin
                total += 1;
                if ($signed(o_signals.wdata[31:0]) === $signed(16'hEF01)) begin
                    passed += 1;
                    $display("PASS: Half-word at address 10 matches: 0x%h", o_signals.wdata[15:0]);
                end else
                    $display("FAIL: Half-word at address 10 doesn't match. Expected: 0xEF01, Got: 0x%h", o_signals.wdata[15:0]);
                
                test_state <= READ_WORD_8_SETUP;
            end
            READ_WORD_8_SETUP: begin
                i_signals.memw <= 0;
                $display("Test 10: Load word to verify both half-words");
                i_signals.memr <= 1;
                i_signals.memt <= LoadWord;
                i_signals.wdata <= 32'h8;
                test_state <= READ_WORD_8_WAIT;
            end

            READ_WORD_8_WAIT: begin
                #2
                test_state <= READ_WORD_8_CHECK;
            end
            
            READ_WORD_8_CHECK: begin
                total += 1;
                if (o_signals.wdata[31:0] === 32'hEF01ABCD) begin
                    passed += 1;
                    $display("PASS: Word containing both half-words matches: 0x%h", o_signals.wdata[31:0]);
                end else
                    $display("FAIL: Word containing both half-words doesn't match. Expected: 0xEF01ABCD, Got: 0x%h", o_signals.wdata[31:0]);
                
                $display("Test 11: Test unsigned vs signed byte loads");
                i_signals.memw <= 1;
                i_signals.memr <= 0;
                i_signals.memt <= StoreByte;
                i_signals.wdata <= 32'h0C; // Address 12
                i_signals.reg2 <= 32'hFF;
                test_state <= STORE_BYTE_12;
            end
            
            STORE_BYTE_12: begin
                i_signals.memw <= 0;
                i_signals.memr <= 1;
                i_signals.memt <= LoadByte;
                test_state <= READ_SBYTE_12_WAIT;
            end
        
            
            READ_SBYTE_12_WAIT: begin
                #2
                test_state <= READ_SBYTE_12_CHECK;
            end
            
            READ_SBYTE_12_CHECK: begin
                total += 1;
                if ($signed(o_signals.wdata[31:0]) === -1) begin
                    passed += 1;
                    $display("PASS: Signed byte load properly sign-extended: 0x%h (%0d)", o_signals.wdata[31:0], $signed(o_signals.wdata[31:0]));
                end else
                    $display("FAIL: Signed byte load incorrectly extended. Expected: 0xFFFFFFFF, Got: 0x%h", o_signals.wdata[31:0]);
                
                i_signals.memt <= ULoadByte;
                test_state <= READ_UBYTE_12_WAIT;
            end
            
            
            READ_UBYTE_12_WAIT: begin
                #2
                test_state <= READ_UBYTE_12_CHECK;
            end
            
            READ_UBYTE_12_CHECK: begin
                total += 1;
                if (o_signals.wdata[31:0] === 32'h000000FF) begin
                    passed += 1;
                    $display("PASS: Unsigned byte load properly zero-extended: 0x%h", o_signals.wdata[31:0]);
                end else
                    $display("FAIL: Unsigned byte load incorrectly extended. Expected: 0x000000FF, Got: 0x%h", o_signals.wdata[31:0]);
                
                $display("Test 12: Test Vram Partiton");
                i_signals.memw <= 1;
                i_signals.memr <= 0;
                i_signals.memt <= StoreWord;
                i_signals.wdata <= 32'h01000000; // Address with bit 24 set
                i_signals.reg2 <= 32'hABCDEF01; // Data to write
                test_state <= STORE_WORD_HIGH;
            end
            
            STORE_WORD_HIGH: begin
                i_signals.memw <= 0;
                i_signals.memr <= 1;
                i_signals.memt <= LoadWord;
                test_state <= READ_WORD_HIGH_WAIT;
            end

            READ_WORD_HIGH_WAIT: begin
                #2
                test_state <= READ_WORD_HIGH_CHECK;
            end
            
            READ_WORD_HIGH_CHECK: begin
                total += 1;
                if (o_signals.wdata[31:0] === i_signals.wdata[31:0]) begin
                    passed += 1;
                    $display("PASS: Vram Partitioned correctly (returns address)");
                end else
                    $display("FAIL: Vram Partitioned incorrectly Expected: 0x%h, Got: 0x%h", i_signals.wdata[31:0], o_signals.wdata[31:0]);
                
                $display("Testbench completed: %0d/%0d tests passed", passed, total);
                test_state <= DONE;
            end
            
            DONE: begin
                $finish;
            end
        endcase
    end
endmodule