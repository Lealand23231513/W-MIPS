module decoder_2_4(
    input wire [1:0] in,
    input wire valid,
    output reg [3:0] out,
    output wire valid_o
    );
    assign valid_o=valid;
    always @(*) begin
        if (valid) begin
            case(in) 
                2'd0: out=4'b0001;
                2'd1: out=4'b0010;       
                2'd2: out=4'b0100;
                2'd3: out=4'b1000;
            endcase
        end
        else out=4'b0000;
    end
endmodule