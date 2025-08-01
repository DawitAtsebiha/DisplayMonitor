module DIG_Sub #(
    parameter Bits = 2
)
(
    input [(Bits-1):0] a,
    input [(Bits-1):0] b,
    input c_i,
    output [(Bits-1):0] s,
    output c_o
);
    wire [Bits:0] temp;

    assign temp = a - b - c_i;
    assign s = temp[(Bits-1):0];
    assign c_o = temp[Bits];
endmodule


module DIG_CounterPreset #(
    parameter Bits = 2,
    parameter maxValue = 4
)
(
    input C,
    input en,
    input clr,
    input dir,
    input [(Bits-1):0] in,
    input ld,
    output [(Bits-1):0] out,
    output ovf
);

    reg [(Bits-1):0] count = 'h0;

    function [(Bits-1):0] maxVal (input [(Bits-1):0] maxv);
        if (maxv == 0)
            maxVal = (1 << Bits) - 1;
        else
            maxVal = maxv;
    endfunction

    assign out = count;
    assign ovf = ((count == maxVal(maxValue) & dir == 1'b0)
                  | (count == 'b0 & dir == 1'b1))? en : 1'b0;

    always @ (posedge C) begin
        if (clr == 1'b1)
            count <= 'h0;
        else if (ld == 1'b1)
            count <= in;
        else if (en == 1'b1) begin
            if (dir == 1'b0) begin
                if (count == maxVal(maxValue))
                    count <= 'h0;
                else
                    count <= count + 1'b1;
            end
            else begin
                if (count == 'h0)
                    count <= maxVal(maxValue);
                else
                    count <= count - 1;
            end
        end
    end
endmodule


module CompUnsigned #(
    parameter Bits = 1
)
(
    input [(Bits -1):0] a,
    input [(Bits -1):0] b,
    output \> ,
    output \= ,
    output \<
);
    assign \> = a > b;
    assign \= = a == b;
    assign \< = a < b;
endmodule

module DIG_D_FF_1bit
#(
    parameter Default = 0
)
(
   input D,
   input C,
   output Q,
   output \~Q
);
    reg state;

    assign Q = state;
    assign \~Q = ~state;

    always @ (posedge C) begin
        state <= D;
    end

    initial begin
        state = Default;
    end
endmodule


module timing (
  input enable,
  input clock,
  input [15:0] resolution,
  input [15:0] front_porch,
  input [15:0] sync,
  input [15:0] back_porch,
  input negative,
  output [15:0] V,
  output pulse,
  output next
);
  wire [15:0] s0;
  wire next_temp;
  wire [15:0] V_temp;
  wire [15:0] s1;
  wire [15:0] s2;
  wire [15:0] s3;
  wire s4;
  wire s5;
  wire s6;
  wire s7;
  DIG_Sub #(
    .Bits(16)
  )
  DIG_Sub_i0 (
    .a( resolution ),
    .b( 16'b1 ),
    .c_i( 1'b0 ),
    .s( s1 )
  );
  DIG_Sub #(
    .Bits(16)
  )
  DIG_Sub_i1 (
    .a( 16'b0 ),
    .b( back_porch ),
    .c_i( 1'b0 ),
    .s( s2 )
  );
  DIG_Sub #(
    .Bits(16)
  )
  DIG_Sub_i2 (
    .a( s2 ),
    .b( sync ),
    .c_i( 1'b0 ),
    .s( s3 )
  );
  DIG_Sub #(
    .Bits(16)
  )
  DIG_Sub_i3 (
    .a( s3 ),
    .b( front_porch ),
    .c_i( 1'b0 ),
    .s( s0 )
  );
  DIG_CounterPreset #(
    .Bits(16),
    .maxValue(0)
  )
  DIG_CounterPreset_i4 (
    .en( enable ),
    .C( clock ),
    .dir( 1'b0 ),
    .in( s0 ),
    .ld( next_temp ),
    .clr( 1'b0 ),
    .out( V_temp )
  );
  CompUnsigned #(
    .Bits(16)
  )
  CompUnsigned_i5 (
    .a( V_temp ),
    .b( s1 ),
    .\= ( next_temp )
  );
  assign pulse = (s4 ^ negative);
  CompUnsigned #(
    .Bits(16)
  )
  CompUnsigned_i6 (
    .a( V_temp ),
    .b( s2 ),
    .\= ( s5 )
  );
  CompUnsigned #(
    .Bits(16)
  )
  CompUnsigned_i7 (
    .a( V_temp ),
    .b( s3 ),
    .\= ( s6 )
  );
  assign s7 = (~ s5 & (s6 | s4));
  DIG_D_FF_1bit #(
    .Default(0)
  )
  DIG_D_FF_1bit_i8 (
    .D( s7 ),
    .C( clock ),
    .Q( s4 )
  );
  assign V = V_temp;
  assign next = next_temp;
endmodule

module sync (
  input clock,
  input [15:0] resolution_x,
  input [15:0] front_porch_x,
  input [15:0] sync_x,
  input [15:0] back_porch_x,
  input [15:0] resolution_y,
  input [15:0] front_porch_y,
  input [15:0] sync_y,
  input [15:0] back_porch_y,
  input negative,
  output Horizontal,
  output Vertical,
  output picture,
  output [15:0] X,
  output [15:0] Y
);
  wire [15:0] X_temp;
  wire s0;
  wire [15:0] Y_temp;
  wire s1;
  wire s2;
  timing timing_i0 (
    .enable( 1'b1 ),
    .clock( clock ),
    .resolution( resolution_x ),
    .front_porch( front_porch_x ),
    .sync( sync_x ),
    .back_porch( back_porch_x ),
    .negative( negative ),
    .V( X_temp ),
    .pulse( Horizontal ),
    .next( s2 )
  );
  CompUnsigned #(
    .Bits(16)
  )
  CompUnsigned_i1 (
    .a( X_temp ),
    .b( resolution_x ),
    .\< ( s0 )
  );
  timing timing_i2 (
    .enable( s2 ),
    .clock( clock ),
    .resolution( resolution_y ),
    .front_porch( front_porch_y ),
    .sync( sync_y ),
    .back_porch( back_porch_y ),
    .negative( negative ),
    .V( Y_temp ),
    .pulse( Vertical )
  );
  CompUnsigned #(
    .Bits(16)
  )
  CompUnsigned_i3 (
    .a( Y_temp ),
    .b( resolution_y ),
    .\< ( s1 )
  );
  assign picture = (s0 & s1);
  assign X = X_temp;
  assign Y = Y_temp;
endmodule

module character_position (
  input [15:0] X,
  input [15:0] Y,
  output [4:0] row,
  output [3:0] column,
  output [7:0] CX,
  output [7:0] CY
);
  assign column = X[3:0];
  assign CX = X[11:4];
  assign row = Y[4:0];
  assign CY = Y[12:5];
endmodule

module Mux_4x1_NBits #(
    parameter Bits = 2
)
(
    input [1:0] sel,
    input [(Bits - 1):0] in_0,
    input [(Bits - 1):0] in_1,
    input [(Bits - 1):0] in_2,
    input [(Bits - 1):0] in_3,
    output reg [(Bits - 1):0] out
);
    always @ (*) begin
        case (sel)
            2'h0: out = in_0;
            2'h1: out = in_1;
            2'h2: out = in_2;
            2'h3: out = in_3;
            default:
                out = 'h0;
        endcase
    end
endmodule


module Mux_2x1_NBits #(
    parameter Bits = 2
)
(
    input [0:0] sel,
    input [(Bits - 1):0] in_0,
    input [(Bits - 1):0] in_1,
    output reg [(Bits - 1):0] out
);
    always @ (*) begin
        case (sel)
            1'h0: out = in_0;
            1'h1: out = in_1;
            default:
                out = 'h0;
        endcase
    end
endmodule


module strings (
  input [7:0] CX,
  input [7:0] CY,
  input [11:0] foreground,
  input [11:0] background,
  input [6:0] character,
  input [11:0] \foreground_(colour) ,
  input [11:0] \background_(colour) ,
  input [5:0] \CX_(colour) ,
  input [7:0] \CY(colour) ,
  input [6:0] Character_0,
  input [6:0] Character_1,
  input [6:0] Character_2,
  input [6:0] Character_3,
  input [7:0] cutoff,
  input enable,
  output [7:0] CX_o,
  output [7:0] CY_o,
  output [11:0] foreground_o,
  output [11:0] background_o,
  output [6:0] character_o
);
  wire s0;
  wire [6:0] s1;
  wire [5:0] s2;
  wire s3;
  wire s4;
  wire s5;
  wire [1:0] s6;
  CompUnsigned #(
    .Bits(8)
  )
  CompUnsigned_i0 (
    .a( CY ),
    .b( \CY(colour)  ),
    .\= ( s4 )
  );
  CompUnsigned #(
    .Bits(8)
  )
  CompUnsigned_i1 (
    .a( cutoff ),
    .b( CY ),
    .\= ( s5 )
  );
  assign s6 = CX[1:0];
  assign s2 = CX[7:2];
  CompUnsigned #(
    .Bits(6)
  )
  CompUnsigned_i2 (
    .a( s2 ),
    .b( \CX_(colour)  ),
    .\= ( s3 )
  );
  Mux_4x1_NBits #(
    .Bits(7)
  )
  Mux_4x1_NBits_i3 (
    .sel( s6 ),
    .in_0( Character_0 ),
    .in_1( Character_1 ),
    .in_2( Character_2 ),
    .in_3( Character_3 ),
    .out( s1 )
  );
  assign s0 = (s3 & enable & s5 & s4);
  Mux_2x1_NBits #(
    .Bits(7)
  )
  Mux_2x1_NBits_i4 (
    .sel( s0 ),
    .in_0( character ),
    .in_1( s1 ),
    .out( character_o )
  );
  Mux_2x1_NBits #(
    .Bits(12)
  )
  Mux_2x1_NBits_i5 (
    .sel( s0 ),
    .in_0( foreground ),
    .in_1( \foreground_(colour)  ),
    .out( foreground_o )
  );
  Mux_2x1_NBits #(
    .Bits(12)
  )
  Mux_2x1_NBits_i6 (
    .sel( s0 ),
    .in_0( background ),
    .in_1( \background_(colour)  ),
    .out( background_o )
  );
  assign CX_o = CX;
  assign CY_o = CY;
endmodule
module DIG_D_FF_Nbit
#(
    parameter Bits = 2,
    parameter Default = 0
)
(
   input [(Bits-1):0] D,
   input C,
   output [(Bits-1):0] Q,
   output [(Bits-1):0] \~Q
);
    reg [(Bits-1):0] state;

    assign Q = state;
    assign \~Q = ~state;

    always @ (posedge C) begin
        state <= D;
    end

    initial begin
        state = Default;
    end
endmodule


module Mux_16x1
(
    input [3:0] sel,
    input in_0,
    input in_1,
    input in_2,
    input in_3,
    input in_4,
    input in_5,
    input in_6,
    input in_7,
    input in_8,
    input in_9,
    input in_10,
    input in_11,
    input in_12,
    input in_13,
    input in_14,
    input in_15,
    output reg out
);
    always @ (*) begin
        case (sel)
            4'h0: out = in_0;
            4'h1: out = in_1;
            4'h2: out = in_2;
            4'h3: out = in_3;
            4'h4: out = in_4;
            4'h5: out = in_5;
            4'h6: out = in_6;
            4'h7: out = in_7;
            4'h8: out = in_8;
            4'h9: out = in_9;
            4'ha: out = in_10;
            4'hb: out = in_11;
            4'hc: out = in_12;
            4'hd: out = in_13;
            4'he: out = in_14;
            4'hf: out = in_15;
            default:
                out = 'h0;
        endcase
    end
endmodule


module text (
  input H_input,
  input V_input,
  input picture,
  input [4:0] row,
  input [3:0] column,
  input clock,
  input [11:0] foreground,
  input [11:0] background,
  input [6:0] character,
  input [15:0] Character_Data,
  output [3:0] R,
  output [3:0] G,
  output [3:0] B,
  output H_output,
  output V_output,
  output [10:0] Character_Address
);
  wire [6:0] s0;
  wire s1;
  wire [5:0] s2;
  wire [5:0] s3;
  wire s4;
  wire s5;
  wire [1:0] s6;
  wire [11:0] s7;
  wire [11:0] s8;
  wire [11:0] s9;
  wire [3:0] s10;
  wire s11;
  wire s12;
  wire s13;
  wire s14;
  wire s15;
  wire s16;
  wire s17;
  wire s18;
  wire s19;
  wire s20;
  wire s21;
  wire s22;
  wire s23;
  wire s24;
  wire s25;
  wire s26;
  DIG_Sub #(
    .Bits(7)
  )
  DIG_Sub_i0 (
    .a( character ),
    .b( 7'b100000 ),
    .c_i( 1'b0 ),
    .s( s0 ),
    .c_o( s1 )
  );
  DIG_D_FF_Nbit #(
    .Bits(4),
    .Default(0)
  )
  DIG_D_FF_Nbit_i1 (
    .D( column ),
    .C( clock ),
    .Q( s10 )
  );
  DIG_D_FF_1bit #(
    .Default(0)
  )
  DIG_D_FF_1bit_i2 (
    .D( V_input ),
    .C( clock ),
    .Q( V_output )
  );
  DIG_D_FF_1bit #(
    .Default(0)
  )
  DIG_D_FF_1bit_i3 (
    .D( H_input ),
    .C( clock ),
    .Q( H_output )
  );
  DIG_D_FF_Nbit #(
    .Bits(12),
    .Default(0)
  )
  DIG_D_FF_Nbit_i4 (
    .D( foreground ),
    .C( clock ),
    .Q( s8 )
  );
  DIG_D_FF_Nbit #(
    .Bits(12),
    .Default(0)
  )
  DIG_D_FF_Nbit_i5 (
    .D( background ),
    .C( clock ),
    .Q( s7 )
  );
  DIG_D_FF_1bit #(
    .Default(0)
  )
  DIG_D_FF_1bit_i6 (
    .D( picture ),
    .C( clock ),
    .Q( s5 )
  );
  assign s26 = Character_Data[0];
  assign s25 = Character_Data[1];
  assign s24 = Character_Data[2];
  assign s23 = Character_Data[3];
  assign s22 = Character_Data[4];
  assign s21 = Character_Data[5];
  assign s20 = Character_Data[6];
  assign s19 = Character_Data[7];
  assign s18 = Character_Data[8];
  assign s17 = Character_Data[9];
  assign s16 = Character_Data[10];
  assign s15 = Character_Data[11];
  assign s14 = Character_Data[12];
  assign s13 = Character_Data[13];
  assign s12 = Character_Data[14];
  assign s11 = Character_Data[15];
  Mux_16x1 Mux_16x1_i7 (
    .sel( s10 ),
    .in_0( s11 ),
    .in_1( s12 ),
    .in_2( s13 ),
    .in_3( s14 ),
    .in_4( s15 ),
    .in_5( s16 ),
    .in_6( s17 ),
    .in_7( s18 ),
    .in_8( s19 ),
    .in_9( s20 ),
    .in_10( s21 ),
    .in_11( s22 ),
    .in_12( s23 ),
    .in_13( s24 ),
    .in_14( s25 ),
    .in_15( s26 ),
    .out( s4 )
  );
  assign s2 = s0[5:0];
  Mux_2x1_NBits #(
    .Bits(6)
  )
  Mux_2x1_NBits_i8 (
    .sel( s1 ),
    .in_0( s2 ),
    .in_1( 6'b0 ),
    .out( s3 )
  );
  assign s6[0] = s4;
  assign s6[1] = s5;
  assign Character_Address[4:0] = row;
  assign Character_Address[10:5] = s3;
  Mux_4x1_NBits #(
    .Bits(12)
  )
  Mux_4x1_NBits_i9 (
    .sel( s6 ),
    .in_0( 12'b0 ),
    .in_1( 12'b0 ),
    .in_2( s7 ),
    .in_3( s8 ),
    .out( s9 )
  );
  assign B = s9[3:0];
  assign G = s9[7:4];
  assign R = s9[11:8];
endmodule

module Mux_4x1
(
    input [1:0] sel,
    input in_0,
    input in_1,
    input in_2,
    input in_3,
    output reg out
);
    always @ (*) begin
        case (sel)
            2'h0: out = in_0;
            2'h1: out = in_1;
            2'h2: out = in_2;
            2'h3: out = in_3;
            default:
                out = 'h0;
        endcase
    end
endmodule


module display (
  input clock,
  input [1:0] enable,
  input [15:0] Character_Data,
  output [3:0] R,
  output [3:0] G,
  output [3:0] B,
  output H_output,
  output V_output,
  output [10:0] Character_Address
);
  wire [15:0] s0;
  wire [15:0] s1;
  wire [4:0] s2;
  wire [3:0] s3;
  wire [7:0] s4;
  wire [7:0] s5;
  wire s6;
  wire [7:0] s7;
  wire [7:0] s8;
  wire [11:0] s9;
  wire [11:0] s10;
  wire [6:0] s11;
  wire s12;
  wire s13;
  wire s14;
  wire [11:0] s15;
  wire [11:0] s16;
  wire [6:0] s17;
  wire [3:0] s18;
  wire [3:0] s19;
  wire [3:0] s20;
  wire s21;
  wire s22;
  wire [10:0] s23;
  wire [7:0] s24;
  wire [7:0] s25;
  wire [11:0] s26;
  wire [11:0] s27;
  wire [6:0] s28;
  wire [7:0] s29;
  wire [7:0] s30;
  wire [11:0] s31;
  wire [11:0] s32;
  wire [6:0] s33;
  wire [7:0] s34;
  wire [7:0] s35;
  wire [11:0] s36;
  wire [11:0] s37;
  wire [6:0] s38;
  wire [15:0] s39;
  wire [15:0] s40;
  wire [4:0] s41;
  wire [3:0] s42;
  wire [7:0] s43;
  wire [7:0] s44;
  wire s45;
  wire [7:0] s46;
  wire [7:0] s47;
  wire [11:0] s48;
  wire [11:0] s49;
  wire [6:0] s50;
  wire s51;
  wire s52;
  wire s53;
  wire [11:0] s54;
  wire [11:0] s55;
  wire [6:0] s56;
  wire [3:0] s57;
  wire [3:0] s58;
  wire [3:0] s59;
  wire s60;
  wire s61;
  wire [10:0] s62;
  wire [7:0] s63;
  wire [7:0] s64;
  wire [11:0] s65;
  wire [11:0] s66;
  wire [6:0] s67;
  wire [7:0] s68;
  wire [7:0] s69;
  wire [11:0] s70;
  wire [11:0] s71;
  wire [6:0] s72;
  wire [7:0] s73;
  wire [7:0] s74;
  wire [11:0] s75;
  wire [11:0] s76;
  wire [6:0] s77;
  wire [15:0] s78;
  wire [15:0] s79;
  wire [4:0] s80;
  wire [3:0] s81;
  wire [7:0] s82;
  wire [7:0] s83;
  wire s84;
  wire [7:0] s85;
  wire [7:0] s86;
  wire [11:0] s87;
  wire [11:0] s88;
  wire [6:0] s89;
  wire s90;
  wire s91;
  wire s92;
  wire [11:0] s93;
  wire [11:0] s94;
  wire [6:0] s95;
  wire [3:0] s96;
  wire [3:0] s97;
  wire [3:0] s98;
  wire s99;
  wire s100;
  wire [10:0] s101;
  wire [7:0] s102;
  wire [7:0] s103;
  wire [11:0] s104;
  wire [11:0] s105;
  wire [6:0] s106;
  wire [7:0] s107;
  wire [7:0] s108;
  wire [11:0] s109;
  wire [11:0] s110;
  wire [6:0] s111;
  wire [7:0] s112;
  wire [7:0] s113;
  wire [11:0] s114;
  wire [11:0] s115;
  wire [6:0] s116;
  sync sync_i0 (
    .clock( clock ),
    .resolution_x( 16'b1010000000 ),
    .front_porch_x( 16'b10000 ),
    .sync_x( 16'b1100000 ),
    .back_porch_x( 16'b110000 ),
    .resolution_y( 16'b111100000 ),
    .front_porch_y( 16'b1011 ),
    .sync_y( 16'b10 ),
    .back_porch_y( 16'b100001 ),
    .negative( 1'b1 ),
    .Horizontal( s51 ),
    .Vertical( s52 ),
    .picture( s53 ),
    .X( s39 ),
    .Y( s40 )
  );
  CompUnsigned #(
    .Bits(2)
  )
  CompUnsigned_i1 (
    .a( enable ),
    .b( 2'b10 ),
    .\< ( s45 )
  );
  CompUnsigned #(
    .Bits(2)
  )
  CompUnsigned_i2 (
    .a( enable ),
    .b( 2'b10 ),
    .\= ( s6 )
  );
  CompUnsigned #(
    .Bits(2)
  )
  CompUnsigned_i3 (
    .a( enable ),
    .b( 2'b10 ),
    .\> ( s84 )
  );
  sync sync_i4 (
    .clock( clock ),
    .resolution_x( 16'b10100000000 ),
    .front_porch_x( 16'b1101110 ),
    .sync_x( 16'b101000 ),
    .back_porch_x( 16'b11011100 ),
    .resolution_y( 16'b1011010000 ),
    .front_porch_y( 16'b110 ),
    .sync_y( 16'b101 ),
    .back_porch_y( 16'b10100 ),
    .negative( 1'b0 ),
    .Horizontal( s90 ),
    .Vertical( s91 ),
    .picture( s92 ),
    .X( s78 ),
    .Y( s79 )
  );
  sync sync_i5 (
    .clock( clock ),
    .resolution_x( 16'b1100100000 ),
    .front_porch_x( 16'b101000 ),
    .sync_x( 16'b10000000 ),
    .back_porch_x( 16'b1011000 ),
    .resolution_y( 16'b1001011000 ),
    .front_porch_y( 16'b10 ),
    .sync_y( 16'b100 ),
    .back_porch_y( 16'b10111 ),
    .negative( 1'b0 ),
    .Horizontal( s12 ),
    .Vertical( s13 ),
    .picture( s14 ),
    .X( s0 ),
    .Y( s1 )
  );
  character_position character_position_i6 (
    .X( s0 ),
    .Y( s1 ),
    .row( s2 ),
    .column( s3 ),
    .CX( s4 ),
    .CY( s5 )
  );
  character_position character_position_i7 (
    .X( s39 ),
    .Y( s40 ),
    .row( s41 ),
    .column( s42 ),
    .CX( s43 ),
    .CY( s44 )
  );
  character_position character_position_i8 (
    .X( s78 ),
    .Y( s79 ),
    .row( s80 ),
    .column( s81 ),
    .CX( s82 ),
    .CY( s83 )
  );
  strings strings_i9 (
    .CX( s4 ),
    .CY( s5 ),
    .foreground( 12'b10011110 ),
    .background( 12'b0 ),
    .character( 7'b1000000 ),
    .\foreground_(colour) ( 12'b111111111111 ),
    .\background_(colour) ( 12'b111100000000 ),
    .\CX_(colour) ( 6'b100 ),
    .\CY(colour) ( 8'b1001 ),
    .Character_0( 7'b111000 ),
    .Character_1( 7'b101101 ),
    .Character_2( 7'b1000010 ),
    .Character_3( 7'b1010101 ),
    .cutoff( 8'b1001 ),
    .enable( s6 ),
    .CX_o( s7 ),
    .CY_o( s8 ),
    .foreground_o( s9 ),
    .background_o( s10 ),
    .character_o( s11 )
  );
  strings strings_i10 (
    .CX( s43 ),
    .CY( s44 ),
    .foreground( 12'b10011110 ),
    .background( 12'b0 ),
    .character( 7'b1000000 ),
    .\foreground_(colour) ( 12'b111111111111 ),
    .\background_(colour) ( 12'b111100000000 ),
    .\CX_(colour) ( 6'b1 ),
    .\CY(colour) ( 8'b111 ),
    .Character_0( 7'b111000 ),
    .Character_1( 7'b101101 ),
    .Character_2( 7'b1000010 ),
    .Character_3( 7'b1010101 ),
    .cutoff( 8'b111 ),
    .enable( s45 ),
    .CX_o( s46 ),
    .CY_o( s47 ),
    .foreground_o( s48 ),
    .background_o( s49 ),
    .character_o( s50 )
  );
  strings strings_i11 (
    .CX( s82 ),
    .CY( s83 ),
    .foreground( 12'b10011110 ),
    .background( 12'b0 ),
    .character( 7'b1000000 ),
    .\foreground_(colour) ( 12'b111111111111 ),
    .\background_(colour) ( 12'b111100000000 ),
    .\CX_(colour) ( 6'b111 ),
    .\CY(colour) ( 8'b1010 ),
    .Character_0( 7'b111000 ),
    .Character_1( 7'b101101 ),
    .Character_2( 7'b1000010 ),
    .Character_3( 7'b1010101 ),
    .cutoff( 8'b1010 ),
    .enable( s84 ),
    .CX_o( s85 ),
    .CY_o( s86 ),
    .foreground_o( s87 ),
    .background_o( s88 ),
    .character_o( s89 )
  );
  strings strings_i12 (
    .CX( s7 ),
    .CY( s8 ),
    .foreground( s9 ),
    .background( s10 ),
    .character( s11 ),
    .\foreground_(colour) ( 12'b0 ),
    .\background_(colour) ( 12'b11011110010 ),
    .\CX_(colour) ( 6'b101 ),
    .\CY(colour) ( 8'b1001 ),
    .Character_0( 7'b1010100 ),
    .Character_1( 7'b100000 ),
    .Character_2( 7'b1001101 ),
    .Character_3( 7'b1001001 ),
    .cutoff( 8'b1001 ),
    .enable( s6 ),
    .CX_o( s24 ),
    .CY_o( s25 ),
    .foreground_o( s26 ),
    .background_o( s27 ),
    .character_o( s28 )
  );
  strings strings_i13 (
    .CX( s46 ),
    .CY( s47 ),
    .foreground( s48 ),
    .background( s49 ),
    .character( s50 ),
    .\foreground_(colour) ( 12'b0 ),
    .\background_(colour) ( 12'b11011110010 ),
    .\CX_(colour) ( 6'b10 ),
    .\CY(colour) ( 8'b111 ),
    .Character_0( 7'b1010100 ),
    .Character_1( 7'b100000 ),
    .Character_2( 7'b1001101 ),
    .Character_3( 7'b1001001 ),
    .cutoff( 8'b111 ),
    .enable( s45 ),
    .CX_o( s63 ),
    .CY_o( s64 ),
    .foreground_o( s65 ),
    .background_o( s66 ),
    .character_o( s67 )
  );
  strings strings_i14 (
    .CX( s85 ),
    .CY( s86 ),
    .foreground( s87 ),
    .background( s88 ),
    .character( s89 ),
    .\foreground_(colour) ( 12'b0 ),
    .\background_(colour) ( 12'b11011110010 ),
    .\CX_(colour) ( 6'b1000 ),
    .\CY(colour) ( 8'b1010 ),
    .Character_0( 7'b1010100 ),
    .Character_1( 7'b100000 ),
    .Character_2( 7'b1001101 ),
    .Character_3( 7'b1001001 ),
    .cutoff( 8'b1010 ),
    .enable( s84 ),
    .CX_o( s102 ),
    .CY_o( s103 ),
    .foreground_o( s104 ),
    .background_o( s105 ),
    .character_o( s106 )
  );
  strings strings_i15 (
    .CX( s24 ),
    .CY( s25 ),
    .foreground( s26 ),
    .background( s27 ),
    .character( s28 ),
    .\foreground_(colour) ( 12'b111100010111 ),
    .\background_(colour) ( 12'b11111111 ),
    .\CX_(colour) ( 6'b110 ),
    .\CY(colour) ( 8'b1001 ),
    .Character_0( 7'b1000111 ),
    .Character_1( 7'b1001000 ),
    .Character_2( 7'b1010100 ),
    .Character_3( 7'b1011001 ),
    .cutoff( 8'b1001 ),
    .enable( s6 ),
    .CX_o( s29 ),
    .CY_o( s30 ),
    .foreground_o( s31 ),
    .background_o( s32 ),
    .character_o( s33 )
  );
  strings strings_i16 (
    .CX( s63 ),
    .CY( s64 ),
    .foreground( s65 ),
    .background( s66 ),
    .character( s67 ),
    .\foreground_(colour) ( 12'b111100010111 ),
    .\background_(colour) ( 12'b11111111 ),
    .\CX_(colour) ( 6'b11 ),
    .\CY(colour) ( 8'b111 ),
    .Character_0( 7'b1000111 ),
    .Character_1( 7'b1001000 ),
    .Character_2( 7'b1010100 ),
    .Character_3( 7'b1011001 ),
    .cutoff( 8'b111 ),
    .enable( s45 ),
    .CX_o( s68 ),
    .CY_o( s69 ),
    .foreground_o( s70 ),
    .background_o( s71 ),
    .character_o( s72 )
  );
  strings strings_i17 (
    .CX( s102 ),
    .CY( s103 ),
    .foreground( s104 ),
    .background( s105 ),
    .character( s106 ),
    .\foreground_(colour) ( 12'b111100010111 ),
    .\background_(colour) ( 12'b11111111 ),
    .\CX_(colour) ( 6'b1001 ),
    .\CY(colour) ( 8'b1010 ),
    .Character_0( 7'b1000111 ),
    .Character_1( 7'b1001000 ),
    .Character_2( 7'b1010100 ),
    .Character_3( 7'b1011001 ),
    .cutoff( 8'b1010 ),
    .enable( s84 ),
    .CX_o( s107 ),
    .CY_o( s108 ),
    .foreground_o( s109 ),
    .background_o( s110 ),
    .character_o( s111 )
  );
  strings strings_i18 (
    .CX( s29 ),
    .CY( s30 ),
    .foreground( s31 ),
    .background( s32 ),
    .character( s33 ),
    .\foreground_(colour) ( 12'b10001010001 ),
    .\background_(colour) ( 12'b111011111111 ),
    .\CX_(colour) ( 6'b111 ),
    .\CY(colour) ( 8'b1001 ),
    .Character_0( 7'b100000 ),
    .Character_1( 7'b1010110 ),
    .Character_2( 7'b1000111 ),
    .Character_3( 7'b1000001 ),
    .cutoff( 8'b1001 ),
    .enable( s6 ),
    .CX_o( s34 ),
    .CY_o( s35 ),
    .foreground_o( s36 ),
    .background_o( s37 ),
    .character_o( s38 )
  );
  strings strings_i19 (
    .CX( s68 ),
    .CY( s69 ),
    .foreground( s70 ),
    .background( s71 ),
    .character( s72 ),
    .\foreground_(colour) ( 12'b10001010001 ),
    .\background_(colour) ( 12'b111011111111 ),
    .\CX_(colour) ( 6'b100 ),
    .\CY(colour) ( 8'b111 ),
    .Character_0( 7'b100000 ),
    .Character_1( 7'b1010110 ),
    .Character_2( 7'b1000111 ),
    .Character_3( 7'b1000001 ),
    .cutoff( 8'b111 ),
    .enable( s45 ),
    .CX_o( s73 ),
    .CY_o( s74 ),
    .foreground_o( s75 ),
    .background_o( s76 ),
    .character_o( s77 )
  );
  strings strings_i20 (
    .CX( s107 ),
    .CY( s108 ),
    .foreground( s109 ),
    .background( s110 ),
    .character( s111 ),
    .\foreground_(colour) ( 12'b10001010001 ),
    .\background_(colour) ( 12'b111011111111 ),
    .\CX_(colour) ( 6'b1010 ),
    .\CY(colour) ( 8'b1010 ),
    .Character_0( 7'b100000 ),
    .Character_1( 7'b1010110 ),
    .Character_2( 7'b1000111 ),
    .Character_3( 7'b1000001 ),
    .cutoff( 8'b1010 ),
    .enable( s84 ),
    .CX_o( s112 ),
    .CY_o( s113 ),
    .foreground_o( s114 ),
    .background_o( s115 ),
    .character_o( s116 )
  );
  strings strings_i21 (
    .CX( s73 ),
    .CY( s74 ),
    .foreground( s75 ),
    .background( s76 ),
    .character( s77 ),
    .\foreground_(colour) ( 12'b1101000010 ),
    .\background_(colour) ( 12'b11101001 ),
    .\CX_(colour) ( 6'b101 ),
    .\CY(colour) ( 8'b111 ),
    .Character_0( 7'b100000 ),
    .Character_1( 7'b110100 ),
    .Character_2( 7'b111000 ),
    .Character_3( 7'b110000 ),
    .cutoff( 8'b111 ),
    .enable( s45 ),
    .foreground_o( s54 ),
    .background_o( s55 ),
    .character_o( s56 )
  );
  strings strings_i22 (
    .CX( s34 ),
    .CY( s35 ),
    .foreground( s36 ),
    .background( s37 ),
    .character( s38 ),
    .\foreground_(colour) ( 12'b1101000010 ),
    .\background_(colour) ( 12'b11101001 ),
    .\CX_(colour) ( 6'b1000 ),
    .\CY(colour) ( 8'b1001 ),
    .Character_0( 7'b100000 ),
    .Character_1( 7'b110110 ),
    .Character_2( 7'b110000 ),
    .Character_3( 7'b110000 ),
    .cutoff( 8'b1001 ),
    .enable( s6 ),
    .foreground_o( s15 ),
    .background_o( s16 ),
    .character_o( s17 )
  );
  strings strings_i23 (
    .CX( s112 ),
    .CY( s113 ),
    .foreground( s114 ),
    .background( s115 ),
    .character( s116 ),
    .\foreground_(colour) ( 12'b1101000010 ),
    .\background_(colour) ( 12'b11101001 ),
    .\CX_(colour) ( 6'b1011 ),
    .\CY(colour) ( 8'b1010 ),
    .Character_0( 7'b100000 ),
    .Character_1( 7'b110111 ),
    .Character_2( 7'b110010 ),
    .Character_3( 7'b110000 ),
    .cutoff( 8'b1010 ),
    .enable( s84 ),
    .foreground_o( s93 ),
    .background_o( s94 ),
    .character_o( s95 )
  );
  text text_i24 (
    .H_input( s12 ),
    .V_input( s13 ),
    .picture( s14 ),
    .row( s2 ),
    .column( s3 ),
    .clock( clock ),
    .foreground( s15 ),
    .background( s16 ),
    .character( s17 ),
    .Character_Data( Character_Data ),
    .R( s18 ),
    .G( s19 ),
    .B( s20 ),
    .H_output( s21 ),
    .V_output( s22 ),
    .Character_Address( s23 )
  );
  text text_i25 (
    .H_input( s51 ),
    .V_input( s52 ),
    .picture( s53 ),
    .row( s41 ),
    .column( s42 ),
    .clock( clock ),
    .foreground( s54 ),
    .background( s55 ),
    .character( s56 ),
    .Character_Data( Character_Data ),
    .R( s57 ),
    .G( s58 ),
    .B( s59 ),
    .H_output( s60 ),
    .V_output( s61 ),
    .Character_Address( s62 )
  );
  text text_i26 (
    .H_input( s90 ),
    .V_input( s91 ),
    .picture( s92 ),
    .row( s80 ),
    .column( s81 ),
    .clock( clock ),
    .foreground( s93 ),
    .background( s94 ),
    .character( s95 ),
    .Character_Data( Character_Data ),
    .R( s96 ),
    .G( s97 ),
    .B( s98 ),
    .H_output( s99 ),
    .V_output( s100 ),
    .Character_Address( s101 )
  );
  Mux_4x1_NBits #(
    .Bits(4)
  )
  Mux_4x1_NBits_i27 (
    .sel( enable ),
    .in_0( 4'b0 ),
    .in_1( s57 ),
    .in_2( s18 ),
    .in_3( s96 ),
    .out( R )
  );
  Mux_4x1 Mux_4x1_i28 (
    .sel( enable ),
    .in_0( 1'b0 ),
    .in_1( s61 ),
    .in_2( s22 ),
    .in_3( s100 ),
    .out( V_output )
  );
  Mux_4x1 Mux_4x1_i29 (
    .sel( enable ),
    .in_0( 1'b0 ),
    .in_1( s60 ),
    .in_2( s21 ),
    .in_3( s99 ),
    .out( H_output )
  );
  Mux_4x1_NBits #(
    .Bits(4)
  )
  Mux_4x1_NBits_i30 (
    .sel( enable ),
    .in_0( 4'b0 ),
    .in_1( s59 ),
    .in_2( s20 ),
    .in_3( s98 ),
    .out( B )
  );
  Mux_4x1_NBits #(
    .Bits(4)
  )
  Mux_4x1_NBits_i31 (
    .sel( enable ),
    .in_0( 4'b0 ),
    .in_1( s58 ),
    .in_2( s19 ),
    .in_3( s97 ),
    .out( G )
  );
  Mux_4x1_NBits #(
    .Bits(11)
  )
  Mux_4x1_NBits_i32 (
    .sel( enable ),
    .in_0( 11'b0 ),
    .in_1( s62 ),
    .in_2( s23 ),
    .in_3( s101 ),
    .out( Character_Address )
  );
endmodule
module DIG_ROM_2048X16_CharacterROM (
    input [10:0] A,
    input sel,
    output reg [15:0] D
);
    reg [15:0] my_rom [0:2038];

    always @ (*) begin
        if (~sel)
            D = 16'hz;
        else if (A > 11'h7f6)
            D = 16'h0;
        else
            D = my_rom[A];
    end

    initial begin
        my_rom[0] = 16'h0;
        my_rom[1] = 16'h0;
        my_rom[2] = 16'h0;
        my_rom[3] = 16'h0;
        my_rom[4] = 16'h0;
        my_rom[5] = 16'h0;
        my_rom[6] = 16'h0;
        my_rom[7] = 16'h0;
        my_rom[8] = 16'h0;
        my_rom[9] = 16'h0;
        my_rom[10] = 16'h0;
        my_rom[11] = 16'h0;
        my_rom[12] = 16'h0;
        my_rom[13] = 16'h0;
        my_rom[14] = 16'h0;
        my_rom[15] = 16'h0;
        my_rom[16] = 16'h0;
        my_rom[17] = 16'h0;
        my_rom[18] = 16'h0;
        my_rom[19] = 16'h0;
        my_rom[20] = 16'h0;
        my_rom[21] = 16'h0;
        my_rom[22] = 16'h0;
        my_rom[23] = 16'h0;
        my_rom[24] = 16'h0;
        my_rom[25] = 16'h0;
        my_rom[26] = 16'h0;
        my_rom[27] = 16'h0;
        my_rom[28] = 16'h0;
        my_rom[29] = 16'h0;
        my_rom[30] = 16'h0;
        my_rom[31] = 16'h0;
        my_rom[32] = 16'h0;
        my_rom[33] = 16'h0;
        my_rom[34] = 16'h0;
        my_rom[35] = 16'h180;
        my_rom[36] = 16'h180;
        my_rom[37] = 16'h180;
        my_rom[38] = 16'h180;
        my_rom[39] = 16'h180;
        my_rom[40] = 16'h180;
        my_rom[41] = 16'h180;
        my_rom[42] = 16'h180;
        my_rom[43] = 16'h0;
        my_rom[44] = 16'h0;
        my_rom[45] = 16'h180;
        my_rom[46] = 16'h180;
        my_rom[47] = 16'h180;
        my_rom[48] = 16'h180;
        my_rom[49] = 16'h180;
        my_rom[50] = 16'h180;
        my_rom[51] = 16'h180;
        my_rom[52] = 16'h180;
        my_rom[53] = 16'h0;
        my_rom[54] = 16'h0;
        my_rom[55] = 16'h0;
        my_rom[56] = 16'h0;
        my_rom[57] = 16'h0;
        my_rom[58] = 16'h0;
        my_rom[59] = 16'h0;
        my_rom[60] = 16'h0;
        my_rom[61] = 16'h0;
        my_rom[62] = 16'h0;
        my_rom[63] = 16'h0;
        my_rom[64] = 16'h0;
        my_rom[65] = 16'h3e7c;
        my_rom[66] = 16'h1e78;
        my_rom[67] = 16'h0;
        my_rom[68] = 16'h0;
        my_rom[69] = 16'h0;
        my_rom[70] = 16'h0;
        my_rom[71] = 16'h0;
        my_rom[72] = 16'h0;
        my_rom[73] = 16'h0;
        my_rom[74] = 16'h0;
        my_rom[75] = 16'h0;
        my_rom[76] = 16'h0;
        my_rom[77] = 16'h0;
        my_rom[78] = 16'h0;
        my_rom[79] = 16'h0;
        my_rom[80] = 16'h0;
        my_rom[81] = 16'h0;
        my_rom[82] = 16'h0;
        my_rom[83] = 16'h0;
        my_rom[84] = 16'h0;
        my_rom[85] = 16'h0;
        my_rom[86] = 16'h0;
        my_rom[87] = 16'h0;
        my_rom[88] = 16'h0;
        my_rom[89] = 16'h0;
        my_rom[90] = 16'h0;
        my_rom[91] = 16'h0;
        my_rom[92] = 16'h0;
        my_rom[93] = 16'h0;
        my_rom[94] = 16'h0;
        my_rom[95] = 16'h0;
        my_rom[96] = 16'h0;
        my_rom[97] = 16'h3e7c;
        my_rom[98] = 16'h3ffc;
        my_rom[99] = 16'h4182;
        my_rom[100] = 16'h6186;
        my_rom[101] = 16'h6186;
        my_rom[102] = 16'h6186;
        my_rom[103] = 16'h6186;
        my_rom[104] = 16'h6186;
        my_rom[105] = 16'h6186;
        my_rom[106] = 16'h4182;
        my_rom[107] = 16'h3e7c;
        my_rom[108] = 16'h3e7c;
        my_rom[109] = 16'h4182;
        my_rom[110] = 16'h6186;
        my_rom[111] = 16'h6186;
        my_rom[112] = 16'h6186;
        my_rom[113] = 16'h6186;
        my_rom[114] = 16'h6186;
        my_rom[115] = 16'h6186;
        my_rom[116] = 16'h4182;
        my_rom[117] = 16'h3ffc;
        my_rom[118] = 16'h3e7c;
        my_rom[119] = 16'h0;
        my_rom[120] = 16'h0;
        my_rom[121] = 16'h0;
        my_rom[122] = 16'h0;
        my_rom[123] = 16'h0;
        my_rom[124] = 16'h0;
        my_rom[125] = 16'h0;
        my_rom[126] = 16'h0;
        my_rom[127] = 16'h0;
        my_rom[128] = 16'h0;
        my_rom[129] = 16'h3e7c;
        my_rom[130] = 16'h3ff8;
        my_rom[131] = 16'h4180;
        my_rom[132] = 16'h6180;
        my_rom[133] = 16'h6180;
        my_rom[134] = 16'h6180;
        my_rom[135] = 16'h6180;
        my_rom[136] = 16'h6180;
        my_rom[137] = 16'h6180;
        my_rom[138] = 16'h4180;
        my_rom[139] = 16'h3e7c;
        my_rom[140] = 16'h3e7c;
        my_rom[141] = 16'h182;
        my_rom[142] = 16'h186;
        my_rom[143] = 16'h186;
        my_rom[144] = 16'h186;
        my_rom[145] = 16'h186;
        my_rom[146] = 16'h186;
        my_rom[147] = 16'h186;
        my_rom[148] = 16'h182;
        my_rom[149] = 16'h1ffc;
        my_rom[150] = 16'h3e7c;
        my_rom[151] = 16'h0;
        my_rom[152] = 16'h0;
        my_rom[153] = 16'h0;
        my_rom[154] = 16'h0;
        my_rom[155] = 16'h0;
        my_rom[156] = 16'h0;
        my_rom[157] = 16'h0;
        my_rom[158] = 16'h0;
        my_rom[159] = 16'h0;
        my_rom[160] = 16'h0;
        my_rom[161] = 16'h3e00;
        my_rom[162] = 16'h3f00;
        my_rom[163] = 16'h4188;
        my_rom[164] = 16'h6188;
        my_rom[165] = 16'h6198;
        my_rom[166] = 16'h61b0;
        my_rom[167] = 16'h61b0;
        my_rom[168] = 16'h61e0;
        my_rom[169] = 16'h61e0;
        my_rom[170] = 16'h4180;
        my_rom[171] = 16'h3e7c;
        my_rom[172] = 16'h3e7c;
        my_rom[173] = 16'h182;
        my_rom[174] = 16'h786;
        my_rom[175] = 16'h786;
        my_rom[176] = 16'hd86;
        my_rom[177] = 16'hd86;
        my_rom[178] = 16'h1986;
        my_rom[179] = 16'h1186;
        my_rom[180] = 16'h1182;
        my_rom[181] = 16'hfc;
        my_rom[182] = 16'h7c;
        my_rom[183] = 16'h0;
        my_rom[184] = 16'h0;
        my_rom[185] = 16'h0;
        my_rom[186] = 16'h0;
        my_rom[187] = 16'h0;
        my_rom[188] = 16'h0;
        my_rom[189] = 16'h0;
        my_rom[190] = 16'h0;
        my_rom[191] = 16'h0;
        my_rom[192] = 16'h0;
        my_rom[193] = 16'h3e00;
        my_rom[194] = 16'h3f00;
        my_rom[195] = 16'h4180;
        my_rom[196] = 16'h6180;
        my_rom[197] = 16'h6180;
        my_rom[198] = 16'h6180;
        my_rom[199] = 16'h6180;
        my_rom[200] = 16'h6180;
        my_rom[201] = 16'h6180;
        my_rom[202] = 16'h4180;
        my_rom[203] = 16'h3f00;
        my_rom[204] = 16'h3e00;
        my_rom[205] = 16'h4000;
        my_rom[206] = 16'h6060;
        my_rom[207] = 16'h6060;
        my_rom[208] = 16'h6030;
        my_rom[209] = 16'h6030;
        my_rom[210] = 16'h6018;
        my_rom[211] = 16'h6008;
        my_rom[212] = 16'h4000;
        my_rom[213] = 16'h3e78;
        my_rom[214] = 16'h3e7c;
        my_rom[215] = 16'h0;
        my_rom[216] = 16'h0;
        my_rom[217] = 16'h0;
        my_rom[218] = 16'h0;
        my_rom[219] = 16'h0;
        my_rom[220] = 16'h0;
        my_rom[221] = 16'h0;
        my_rom[222] = 16'h0;
        my_rom[223] = 16'h0;
        my_rom[224] = 16'h0;
        my_rom[225] = 16'h0;
        my_rom[226] = 16'h0;
        my_rom[227] = 16'h8;
        my_rom[228] = 16'h8;
        my_rom[229] = 16'h18;
        my_rom[230] = 16'h30;
        my_rom[231] = 16'h30;
        my_rom[232] = 16'h60;
        my_rom[233] = 16'h60;
        my_rom[234] = 16'h0;
        my_rom[235] = 16'h0;
        my_rom[236] = 16'h0;
        my_rom[237] = 16'h0;
        my_rom[238] = 16'h0;
        my_rom[239] = 16'h0;
        my_rom[240] = 16'h0;
        my_rom[241] = 16'h0;
        my_rom[242] = 16'h0;
        my_rom[243] = 16'h0;
        my_rom[244] = 16'h0;
        my_rom[245] = 16'h0;
        my_rom[246] = 16'h0;
        my_rom[247] = 16'h0;
        my_rom[248] = 16'h0;
        my_rom[249] = 16'h0;
        my_rom[250] = 16'h0;
        my_rom[251] = 16'h0;
        my_rom[252] = 16'h0;
        my_rom[253] = 16'h0;
        my_rom[254] = 16'h0;
        my_rom[255] = 16'h0;
        my_rom[256] = 16'h0;
        my_rom[257] = 16'h7c;
        my_rom[258] = 16'h78;
        my_rom[259] = 16'h200;
        my_rom[260] = 16'h600;
        my_rom[261] = 16'h600;
        my_rom[262] = 16'hc00;
        my_rom[263] = 16'h800;
        my_rom[264] = 16'h1800;
        my_rom[265] = 16'h1000;
        my_rom[266] = 16'h0;
        my_rom[267] = 16'h0;
        my_rom[268] = 16'h0;
        my_rom[269] = 16'h0;
        my_rom[270] = 16'h1000;
        my_rom[271] = 16'h1800;
        my_rom[272] = 16'h800;
        my_rom[273] = 16'hc00;
        my_rom[274] = 16'h600;
        my_rom[275] = 16'h600;
        my_rom[276] = 16'h200;
        my_rom[277] = 16'h78;
        my_rom[278] = 16'h7c;
        my_rom[279] = 16'h0;
        my_rom[280] = 16'h0;
        my_rom[281] = 16'h0;
        my_rom[282] = 16'h0;
        my_rom[283] = 16'h0;
        my_rom[284] = 16'h0;
        my_rom[285] = 16'h0;
        my_rom[286] = 16'h0;
        my_rom[287] = 16'h0;
        my_rom[288] = 16'h0;
        my_rom[289] = 16'h3e00;
        my_rom[290] = 16'h1e00;
        my_rom[291] = 16'h40;
        my_rom[292] = 16'h60;
        my_rom[293] = 16'h60;
        my_rom[294] = 16'h30;
        my_rom[295] = 16'h10;
        my_rom[296] = 16'h18;
        my_rom[297] = 16'h8;
        my_rom[298] = 16'h0;
        my_rom[299] = 16'h0;
        my_rom[300] = 16'h0;
        my_rom[301] = 16'h0;
        my_rom[302] = 16'h8;
        my_rom[303] = 16'h18;
        my_rom[304] = 16'h10;
        my_rom[305] = 16'h30;
        my_rom[306] = 16'h60;
        my_rom[307] = 16'h60;
        my_rom[308] = 16'h40;
        my_rom[309] = 16'h1e00;
        my_rom[310] = 16'h3e00;
        my_rom[311] = 16'h0;
        my_rom[312] = 16'h0;
        my_rom[313] = 16'h0;
        my_rom[314] = 16'h0;
        my_rom[315] = 16'h0;
        my_rom[316] = 16'h0;
        my_rom[317] = 16'h0;
        my_rom[318] = 16'h0;
        my_rom[319] = 16'h0;
        my_rom[320] = 16'h0;
        my_rom[321] = 16'h0;
        my_rom[322] = 16'h0;
        my_rom[323] = 16'h1188;
        my_rom[324] = 16'h1188;
        my_rom[325] = 16'h1998;
        my_rom[326] = 16'hdb0;
        my_rom[327] = 16'hdb0;
        my_rom[328] = 16'h7e0;
        my_rom[329] = 16'h7e0;
        my_rom[330] = 16'h180;
        my_rom[331] = 16'h3e7c;
        my_rom[332] = 16'h3e7c;
        my_rom[333] = 16'h180;
        my_rom[334] = 16'h7e0;
        my_rom[335] = 16'h7e0;
        my_rom[336] = 16'hdb0;
        my_rom[337] = 16'hdb0;
        my_rom[338] = 16'h1998;
        my_rom[339] = 16'h1188;
        my_rom[340] = 16'h1188;
        my_rom[341] = 16'h0;
        my_rom[342] = 16'h0;
        my_rom[343] = 16'h0;
        my_rom[344] = 16'h0;
        my_rom[345] = 16'h0;
        my_rom[346] = 16'h0;
        my_rom[347] = 16'h0;
        my_rom[348] = 16'h0;
        my_rom[349] = 16'h0;
        my_rom[350] = 16'h0;
        my_rom[351] = 16'h0;
        my_rom[352] = 16'h0;
        my_rom[353] = 16'h0;
        my_rom[354] = 16'h0;
        my_rom[355] = 16'h180;
        my_rom[356] = 16'h180;
        my_rom[357] = 16'h180;
        my_rom[358] = 16'h180;
        my_rom[359] = 16'h180;
        my_rom[360] = 16'h180;
        my_rom[361] = 16'h180;
        my_rom[362] = 16'h180;
        my_rom[363] = 16'h3e7c;
        my_rom[364] = 16'h3e7c;
        my_rom[365] = 16'h180;
        my_rom[366] = 16'h180;
        my_rom[367] = 16'h180;
        my_rom[368] = 16'h180;
        my_rom[369] = 16'h180;
        my_rom[370] = 16'h180;
        my_rom[371] = 16'h180;
        my_rom[372] = 16'h180;
        my_rom[373] = 16'h0;
        my_rom[374] = 16'h0;
        my_rom[375] = 16'h0;
        my_rom[376] = 16'h0;
        my_rom[377] = 16'h0;
        my_rom[378] = 16'h0;
        my_rom[379] = 16'h0;
        my_rom[380] = 16'h0;
        my_rom[381] = 16'h0;
        my_rom[382] = 16'h0;
        my_rom[383] = 16'h0;
        my_rom[384] = 16'h0;
        my_rom[385] = 16'h0;
        my_rom[386] = 16'h0;
        my_rom[387] = 16'h0;
        my_rom[388] = 16'h0;
        my_rom[389] = 16'h0;
        my_rom[390] = 16'h0;
        my_rom[391] = 16'h0;
        my_rom[392] = 16'h0;
        my_rom[393] = 16'h0;
        my_rom[394] = 16'h0;
        my_rom[395] = 16'h0;
        my_rom[396] = 16'h0;
        my_rom[397] = 16'h0;
        my_rom[398] = 16'h600;
        my_rom[399] = 16'h600;
        my_rom[400] = 16'hc00;
        my_rom[401] = 16'hc00;
        my_rom[402] = 16'h1800;
        my_rom[403] = 16'h1000;
        my_rom[404] = 16'h1000;
        my_rom[405] = 16'h0;
        my_rom[406] = 16'h0;
        my_rom[407] = 16'h0;
        my_rom[408] = 16'h0;
        my_rom[409] = 16'h0;
        my_rom[410] = 16'h0;
        my_rom[411] = 16'h0;
        my_rom[412] = 16'h0;
        my_rom[413] = 16'h0;
        my_rom[414] = 16'h0;
        my_rom[415] = 16'h0;
        my_rom[416] = 16'h0;
        my_rom[417] = 16'h0;
        my_rom[418] = 16'h0;
        my_rom[419] = 16'h0;
        my_rom[420] = 16'h0;
        my_rom[421] = 16'h0;
        my_rom[422] = 16'h0;
        my_rom[423] = 16'h0;
        my_rom[424] = 16'h0;
        my_rom[425] = 16'h0;
        my_rom[426] = 16'h0;
        my_rom[427] = 16'h3e7c;
        my_rom[428] = 16'h3e7c;
        my_rom[429] = 16'h0;
        my_rom[430] = 16'h0;
        my_rom[431] = 16'h0;
        my_rom[432] = 16'h0;
        my_rom[433] = 16'h0;
        my_rom[434] = 16'h0;
        my_rom[435] = 16'h0;
        my_rom[436] = 16'h0;
        my_rom[437] = 16'h0;
        my_rom[438] = 16'h0;
        my_rom[439] = 16'h0;
        my_rom[440] = 16'h0;
        my_rom[441] = 16'h0;
        my_rom[442] = 16'h0;
        my_rom[443] = 16'h0;
        my_rom[444] = 16'h0;
        my_rom[445] = 16'h0;
        my_rom[446] = 16'h0;
        my_rom[447] = 16'h0;
        my_rom[448] = 16'h0;
        my_rom[449] = 16'h0;
        my_rom[450] = 16'h0;
        my_rom[451] = 16'h0;
        my_rom[452] = 16'h0;
        my_rom[453] = 16'h0;
        my_rom[454] = 16'h0;
        my_rom[455] = 16'h0;
        my_rom[456] = 16'h0;
        my_rom[457] = 16'h0;
        my_rom[458] = 16'h0;
        my_rom[459] = 16'h0;
        my_rom[460] = 16'h0;
        my_rom[461] = 16'h0;
        my_rom[462] = 16'h0;
        my_rom[463] = 16'h0;
        my_rom[464] = 16'h0;
        my_rom[465] = 16'h0;
        my_rom[466] = 16'h0;
        my_rom[467] = 16'h0;
        my_rom[468] = 16'h0;
        my_rom[469] = 16'h180;
        my_rom[470] = 16'h180;
        my_rom[471] = 16'h0;
        my_rom[472] = 16'h0;
        my_rom[473] = 16'h0;
        my_rom[474] = 16'h0;
        my_rom[475] = 16'h0;
        my_rom[476] = 16'h0;
        my_rom[477] = 16'h0;
        my_rom[478] = 16'h0;
        my_rom[479] = 16'h0;
        my_rom[480] = 16'h0;
        my_rom[481] = 16'h0;
        my_rom[482] = 16'h0;
        my_rom[483] = 16'h8;
        my_rom[484] = 16'h8;
        my_rom[485] = 16'h18;
        my_rom[486] = 16'h30;
        my_rom[487] = 16'h30;
        my_rom[488] = 16'h60;
        my_rom[489] = 16'h60;
        my_rom[490] = 16'h0;
        my_rom[491] = 16'h0;
        my_rom[492] = 16'h0;
        my_rom[493] = 16'h0;
        my_rom[494] = 16'h600;
        my_rom[495] = 16'h600;
        my_rom[496] = 16'hc00;
        my_rom[497] = 16'hc00;
        my_rom[498] = 16'h1800;
        my_rom[499] = 16'h1000;
        my_rom[500] = 16'h1000;
        my_rom[501] = 16'h0;
        my_rom[502] = 16'h0;
        my_rom[503] = 16'h0;
        my_rom[504] = 16'h0;
        my_rom[505] = 16'h0;
        my_rom[506] = 16'h0;
        my_rom[507] = 16'h0;
        my_rom[508] = 16'h0;
        my_rom[509] = 16'h0;
        my_rom[510] = 16'h0;
        my_rom[511] = 16'h0;
        my_rom[512] = 16'h0;
        my_rom[513] = 16'h3e7c;
        my_rom[514] = 16'h3e7c;
        my_rom[515] = 16'h4006;
        my_rom[516] = 16'h600e;
        my_rom[517] = 16'h601a;
        my_rom[518] = 16'h6032;
        my_rom[519] = 16'h6036;
        my_rom[520] = 16'h6066;
        my_rom[521] = 16'h6066;
        my_rom[522] = 16'h6006;
        my_rom[523] = 16'h0;
        my_rom[524] = 16'h0;
        my_rom[525] = 16'h6006;
        my_rom[526] = 16'h6606;
        my_rom[527] = 16'h6606;
        my_rom[528] = 16'h6c06;
        my_rom[529] = 16'h4c06;
        my_rom[530] = 16'h5806;
        my_rom[531] = 16'h7006;
        my_rom[532] = 16'h6002;
        my_rom[533] = 16'h3e7c;
        my_rom[534] = 16'h3e7c;
        my_rom[535] = 16'h0;
        my_rom[536] = 16'h0;
        my_rom[537] = 16'h0;
        my_rom[538] = 16'h0;
        my_rom[539] = 16'h0;
        my_rom[540] = 16'h0;
        my_rom[541] = 16'h0;
        my_rom[542] = 16'h0;
        my_rom[543] = 16'h0;
        my_rom[544] = 16'h0;
        my_rom[545] = 16'h3e00;
        my_rom[546] = 16'h1f00;
        my_rom[547] = 16'h180;
        my_rom[548] = 16'h180;
        my_rom[549] = 16'h180;
        my_rom[550] = 16'h180;
        my_rom[551] = 16'h180;
        my_rom[552] = 16'h180;
        my_rom[553] = 16'h180;
        my_rom[554] = 16'h180;
        my_rom[555] = 16'h0;
        my_rom[556] = 16'h0;
        my_rom[557] = 16'h180;
        my_rom[558] = 16'h180;
        my_rom[559] = 16'h180;
        my_rom[560] = 16'h180;
        my_rom[561] = 16'h180;
        my_rom[562] = 16'h180;
        my_rom[563] = 16'h180;
        my_rom[564] = 16'h180;
        my_rom[565] = 16'h1ff8;
        my_rom[566] = 16'h3e7c;
        my_rom[567] = 16'h0;
        my_rom[568] = 16'h0;
        my_rom[569] = 16'h0;
        my_rom[570] = 16'h0;
        my_rom[571] = 16'h0;
        my_rom[572] = 16'h0;
        my_rom[573] = 16'h0;
        my_rom[574] = 16'h0;
        my_rom[575] = 16'h0;
        my_rom[576] = 16'h0;
        my_rom[577] = 16'h3e7c;
        my_rom[578] = 16'h1e7c;
        my_rom[579] = 16'h2;
        my_rom[580] = 16'h6;
        my_rom[581] = 16'h6;
        my_rom[582] = 16'h6;
        my_rom[583] = 16'h6;
        my_rom[584] = 16'h6;
        my_rom[585] = 16'h6;
        my_rom[586] = 16'h2;
        my_rom[587] = 16'h3e7c;
        my_rom[588] = 16'h3e7c;
        my_rom[589] = 16'h4000;
        my_rom[590] = 16'h6000;
        my_rom[591] = 16'h6000;
        my_rom[592] = 16'h6000;
        my_rom[593] = 16'h6000;
        my_rom[594] = 16'h6000;
        my_rom[595] = 16'h6000;
        my_rom[596] = 16'h4000;
        my_rom[597] = 16'h3e78;
        my_rom[598] = 16'h3e7c;
        my_rom[599] = 16'h0;
        my_rom[600] = 16'h0;
        my_rom[601] = 16'h0;
        my_rom[602] = 16'h0;
        my_rom[603] = 16'h0;
        my_rom[604] = 16'h0;
        my_rom[605] = 16'h0;
        my_rom[606] = 16'h0;
        my_rom[607] = 16'h0;
        my_rom[608] = 16'h0;
        my_rom[609] = 16'h3e7c;
        my_rom[610] = 16'h1e7c;
        my_rom[611] = 16'h2;
        my_rom[612] = 16'h6;
        my_rom[613] = 16'h6;
        my_rom[614] = 16'h6;
        my_rom[615] = 16'h6;
        my_rom[616] = 16'h6;
        my_rom[617] = 16'h6;
        my_rom[618] = 16'h2;
        my_rom[619] = 16'h3e7c;
        my_rom[620] = 16'h3e7c;
        my_rom[621] = 16'h2;
        my_rom[622] = 16'h6;
        my_rom[623] = 16'h6;
        my_rom[624] = 16'h6;
        my_rom[625] = 16'h6;
        my_rom[626] = 16'h6;
        my_rom[627] = 16'h6;
        my_rom[628] = 16'h2;
        my_rom[629] = 16'h1e7c;
        my_rom[630] = 16'h3e7c;
        my_rom[631] = 16'h0;
        my_rom[632] = 16'h0;
        my_rom[633] = 16'h0;
        my_rom[634] = 16'h0;
        my_rom[635] = 16'h0;
        my_rom[636] = 16'h0;
        my_rom[637] = 16'h0;
        my_rom[638] = 16'h0;
        my_rom[639] = 16'h0;
        my_rom[640] = 16'h0;
        my_rom[641] = 16'h0;
        my_rom[642] = 16'h4002;
        my_rom[643] = 16'h6006;
        my_rom[644] = 16'h6006;
        my_rom[645] = 16'h6006;
        my_rom[646] = 16'h6006;
        my_rom[647] = 16'h6006;
        my_rom[648] = 16'h6006;
        my_rom[649] = 16'h6006;
        my_rom[650] = 16'h4002;
        my_rom[651] = 16'h3e7c;
        my_rom[652] = 16'h3e7c;
        my_rom[653] = 16'h2;
        my_rom[654] = 16'h6;
        my_rom[655] = 16'h6;
        my_rom[656] = 16'h6;
        my_rom[657] = 16'h6;
        my_rom[658] = 16'h6;
        my_rom[659] = 16'h6;
        my_rom[660] = 16'h6;
        my_rom[661] = 16'h2;
        my_rom[662] = 16'h0;
        my_rom[663] = 16'h0;
        my_rom[664] = 16'h0;
        my_rom[665] = 16'h0;
        my_rom[666] = 16'h0;
        my_rom[667] = 16'h0;
        my_rom[668] = 16'h0;
        my_rom[669] = 16'h0;
        my_rom[670] = 16'h0;
        my_rom[671] = 16'h0;
        my_rom[672] = 16'h0;
        my_rom[673] = 16'h3e7c;
        my_rom[674] = 16'h3e78;
        my_rom[675] = 16'h4000;
        my_rom[676] = 16'h6000;
        my_rom[677] = 16'h6000;
        my_rom[678] = 16'h6000;
        my_rom[679] = 16'h6000;
        my_rom[680] = 16'h6000;
        my_rom[681] = 16'h6000;
        my_rom[682] = 16'h4000;
        my_rom[683] = 16'h3e7c;
        my_rom[684] = 16'h3e7c;
        my_rom[685] = 16'h2;
        my_rom[686] = 16'h6;
        my_rom[687] = 16'h6;
        my_rom[688] = 16'h6;
        my_rom[689] = 16'h6;
        my_rom[690] = 16'h6;
        my_rom[691] = 16'h6;
        my_rom[692] = 16'h2;
        my_rom[693] = 16'h1e7c;
        my_rom[694] = 16'h3e7c;
        my_rom[695] = 16'h0;
        my_rom[696] = 16'h0;
        my_rom[697] = 16'h0;
        my_rom[698] = 16'h0;
        my_rom[699] = 16'h0;
        my_rom[700] = 16'h0;
        my_rom[701] = 16'h0;
        my_rom[702] = 16'h0;
        my_rom[703] = 16'h0;
        my_rom[704] = 16'h0;
        my_rom[705] = 16'h3e7c;
        my_rom[706] = 16'h3e78;
        my_rom[707] = 16'h4000;
        my_rom[708] = 16'h6000;
        my_rom[709] = 16'h6000;
        my_rom[710] = 16'h6000;
        my_rom[711] = 16'h6000;
        my_rom[712] = 16'h6000;
        my_rom[713] = 16'h6000;
        my_rom[714] = 16'h4000;
        my_rom[715] = 16'h3e7c;
        my_rom[716] = 16'h3e7c;
        my_rom[717] = 16'h4002;
        my_rom[718] = 16'h6006;
        my_rom[719] = 16'h6006;
        my_rom[720] = 16'h6006;
        my_rom[721] = 16'h6006;
        my_rom[722] = 16'h6006;
        my_rom[723] = 16'h6006;
        my_rom[724] = 16'h4002;
        my_rom[725] = 16'h3e7c;
        my_rom[726] = 16'h3e7c;
        my_rom[727] = 16'h0;
        my_rom[728] = 16'h0;
        my_rom[729] = 16'h0;
        my_rom[730] = 16'h0;
        my_rom[731] = 16'h0;
        my_rom[732] = 16'h0;
        my_rom[733] = 16'h0;
        my_rom[734] = 16'h0;
        my_rom[735] = 16'h0;
        my_rom[736] = 16'h0;
        my_rom[737] = 16'h3e7c;
        my_rom[738] = 16'h1e7c;
        my_rom[739] = 16'h2;
        my_rom[740] = 16'h6;
        my_rom[741] = 16'h6;
        my_rom[742] = 16'h6;
        my_rom[743] = 16'h6;
        my_rom[744] = 16'h6;
        my_rom[745] = 16'h6;
        my_rom[746] = 16'h6;
        my_rom[747] = 16'h0;
        my_rom[748] = 16'h0;
        my_rom[749] = 16'h6;
        my_rom[750] = 16'h6;
        my_rom[751] = 16'h6;
        my_rom[752] = 16'h6;
        my_rom[753] = 16'h6;
        my_rom[754] = 16'h6;
        my_rom[755] = 16'h6;
        my_rom[756] = 16'h6;
        my_rom[757] = 16'h2;
        my_rom[758] = 16'h0;
        my_rom[759] = 16'h0;
        my_rom[760] = 16'h0;
        my_rom[761] = 16'h0;
        my_rom[762] = 16'h0;
        my_rom[763] = 16'h0;
        my_rom[764] = 16'h0;
        my_rom[765] = 16'h0;
        my_rom[766] = 16'h0;
        my_rom[767] = 16'h0;
        my_rom[768] = 16'h0;
        my_rom[769] = 16'h3e7c;
        my_rom[770] = 16'h3e7c;
        my_rom[771] = 16'h4002;
        my_rom[772] = 16'h6006;
        my_rom[773] = 16'h6006;
        my_rom[774] = 16'h6006;
        my_rom[775] = 16'h6006;
        my_rom[776] = 16'h6006;
        my_rom[777] = 16'h6006;
        my_rom[778] = 16'h4002;
        my_rom[779] = 16'h3e7c;
        my_rom[780] = 16'h3e7c;
        my_rom[781] = 16'h4002;
        my_rom[782] = 16'h6006;
        my_rom[783] = 16'h6006;
        my_rom[784] = 16'h6006;
        my_rom[785] = 16'h6006;
        my_rom[786] = 16'h6006;
        my_rom[787] = 16'h6006;
        my_rom[788] = 16'h4002;
        my_rom[789] = 16'h3e7c;
        my_rom[790] = 16'h3e7c;
        my_rom[791] = 16'h0;
        my_rom[792] = 16'h0;
        my_rom[793] = 16'h0;
        my_rom[794] = 16'h0;
        my_rom[795] = 16'h0;
        my_rom[796] = 16'h0;
        my_rom[797] = 16'h0;
        my_rom[798] = 16'h0;
        my_rom[799] = 16'h0;
        my_rom[800] = 16'h0;
        my_rom[801] = 16'h3e7c;
        my_rom[802] = 16'h3e7c;
        my_rom[803] = 16'h4002;
        my_rom[804] = 16'h6006;
        my_rom[805] = 16'h6006;
        my_rom[806] = 16'h6006;
        my_rom[807] = 16'h6006;
        my_rom[808] = 16'h6006;
        my_rom[809] = 16'h6006;
        my_rom[810] = 16'h4002;
        my_rom[811] = 16'h3e7c;
        my_rom[812] = 16'h3e7c;
        my_rom[813] = 16'h2;
        my_rom[814] = 16'h6;
        my_rom[815] = 16'h6;
        my_rom[816] = 16'h6;
        my_rom[817] = 16'h6;
        my_rom[818] = 16'h6;
        my_rom[819] = 16'h6;
        my_rom[820] = 16'h2;
        my_rom[821] = 16'h1e7c;
        my_rom[822] = 16'h3e7c;
        my_rom[823] = 16'h0;
        my_rom[824] = 16'h0;
        my_rom[825] = 16'h0;
        my_rom[826] = 16'h0;
        my_rom[827] = 16'h0;
        my_rom[828] = 16'h0;
        my_rom[829] = 16'h0;
        my_rom[830] = 16'h0;
        my_rom[831] = 16'h0;
        my_rom[832] = 16'h0;
        my_rom[833] = 16'h0;
        my_rom[834] = 16'h0;
        my_rom[835] = 16'h0;
        my_rom[836] = 16'h0;
        my_rom[837] = 16'h0;
        my_rom[838] = 16'h180;
        my_rom[839] = 16'h180;
        my_rom[840] = 16'h0;
        my_rom[841] = 16'h0;
        my_rom[842] = 16'h0;
        my_rom[843] = 16'h0;
        my_rom[844] = 16'h0;
        my_rom[845] = 16'h0;
        my_rom[846] = 16'h0;
        my_rom[847] = 16'h0;
        my_rom[848] = 16'h180;
        my_rom[849] = 16'h180;
        my_rom[850] = 16'h0;
        my_rom[851] = 16'h0;
        my_rom[852] = 16'h0;
        my_rom[853] = 16'h0;
        my_rom[854] = 16'h0;
        my_rom[855] = 16'h0;
        my_rom[856] = 16'h0;
        my_rom[857] = 16'h0;
        my_rom[858] = 16'h0;
        my_rom[859] = 16'h0;
        my_rom[860] = 16'h0;
        my_rom[861] = 16'h0;
        my_rom[862] = 16'h0;
        my_rom[863] = 16'h0;
        my_rom[864] = 16'h0;
        my_rom[865] = 16'h0;
        my_rom[866] = 16'h0;
        my_rom[867] = 16'h180;
        my_rom[868] = 16'h180;
        my_rom[869] = 16'h180;
        my_rom[870] = 16'h180;
        my_rom[871] = 16'h180;
        my_rom[872] = 16'h180;
        my_rom[873] = 16'h180;
        my_rom[874] = 16'h180;
        my_rom[875] = 16'h0;
        my_rom[876] = 16'h0;
        my_rom[877] = 16'h0;
        my_rom[878] = 16'h600;
        my_rom[879] = 16'h600;
        my_rom[880] = 16'hc00;
        my_rom[881] = 16'hc00;
        my_rom[882] = 16'h1800;
        my_rom[883] = 16'h1000;
        my_rom[884] = 16'h1000;
        my_rom[885] = 16'h0;
        my_rom[886] = 16'h0;
        my_rom[887] = 16'h0;
        my_rom[888] = 16'h0;
        my_rom[889] = 16'h0;
        my_rom[890] = 16'h0;
        my_rom[891] = 16'h0;
        my_rom[892] = 16'h0;
        my_rom[893] = 16'h0;
        my_rom[894] = 16'h0;
        my_rom[895] = 16'h0;
        my_rom[896] = 16'h0;
        my_rom[897] = 16'h0;
        my_rom[898] = 16'h0;
        my_rom[899] = 16'h40;
        my_rom[900] = 16'hc0;
        my_rom[901] = 16'hc0;
        my_rom[902] = 16'h180;
        my_rom[903] = 16'h180;
        my_rom[904] = 16'h300;
        my_rom[905] = 16'h300;
        my_rom[906] = 16'h0;
        my_rom[907] = 16'h0;
        my_rom[908] = 16'h0;
        my_rom[909] = 16'h0;
        my_rom[910] = 16'h300;
        my_rom[911] = 16'h300;
        my_rom[912] = 16'h180;
        my_rom[913] = 16'h180;
        my_rom[914] = 16'hc0;
        my_rom[915] = 16'hc0;
        my_rom[916] = 16'h40;
        my_rom[917] = 16'h0;
        my_rom[918] = 16'h0;
        my_rom[919] = 16'h0;
        my_rom[920] = 16'h0;
        my_rom[921] = 16'h0;
        my_rom[922] = 16'h0;
        my_rom[923] = 16'h0;
        my_rom[924] = 16'h0;
        my_rom[925] = 16'h0;
        my_rom[926] = 16'h0;
        my_rom[927] = 16'h0;
        my_rom[928] = 16'h0;
        my_rom[929] = 16'h0;
        my_rom[930] = 16'h0;
        my_rom[931] = 16'h0;
        my_rom[932] = 16'h0;
        my_rom[933] = 16'h0;
        my_rom[934] = 16'h3e7c;
        my_rom[935] = 16'h3e7c;
        my_rom[936] = 16'h0;
        my_rom[937] = 16'h0;
        my_rom[938] = 16'h0;
        my_rom[939] = 16'h0;
        my_rom[940] = 16'h0;
        my_rom[941] = 16'h0;
        my_rom[942] = 16'h0;
        my_rom[943] = 16'h0;
        my_rom[944] = 16'h1e78;
        my_rom[945] = 16'h3e7c;
        my_rom[946] = 16'h0;
        my_rom[947] = 16'h0;
        my_rom[948] = 16'h0;
        my_rom[949] = 16'h0;
        my_rom[950] = 16'h0;
        my_rom[951] = 16'h0;
        my_rom[952] = 16'h0;
        my_rom[953] = 16'h0;
        my_rom[954] = 16'h0;
        my_rom[955] = 16'h0;
        my_rom[956] = 16'h0;
        my_rom[957] = 16'h0;
        my_rom[958] = 16'h0;
        my_rom[959] = 16'h0;
        my_rom[960] = 16'h0;
        my_rom[961] = 16'h0;
        my_rom[962] = 16'h0;
        my_rom[963] = 16'h200;
        my_rom[964] = 16'h300;
        my_rom[965] = 16'h300;
        my_rom[966] = 16'h180;
        my_rom[967] = 16'h180;
        my_rom[968] = 16'hc0;
        my_rom[969] = 16'hc0;
        my_rom[970] = 16'h0;
        my_rom[971] = 16'h0;
        my_rom[972] = 16'h0;
        my_rom[973] = 16'h0;
        my_rom[974] = 16'hc0;
        my_rom[975] = 16'hc0;
        my_rom[976] = 16'h180;
        my_rom[977] = 16'h180;
        my_rom[978] = 16'h300;
        my_rom[979] = 16'h300;
        my_rom[980] = 16'h200;
        my_rom[981] = 16'h0;
        my_rom[982] = 16'h0;
        my_rom[983] = 16'h0;
        my_rom[984] = 16'h0;
        my_rom[985] = 16'h0;
        my_rom[986] = 16'h0;
        my_rom[987] = 16'h0;
        my_rom[988] = 16'h0;
        my_rom[989] = 16'h0;
        my_rom[990] = 16'h0;
        my_rom[991] = 16'h0;
        my_rom[992] = 16'h0;
        my_rom[993] = 16'h3e7c;
        my_rom[994] = 16'h1e7c;
        my_rom[995] = 16'h2;
        my_rom[996] = 16'h6;
        my_rom[997] = 16'h6;
        my_rom[998] = 16'h6;
        my_rom[999] = 16'h6;
        my_rom[1000] = 16'h6;
        my_rom[1001] = 16'h6;
        my_rom[1002] = 16'h2;
        my_rom[1003] = 16'h7c;
        my_rom[1004] = 16'hfc;
        my_rom[1005] = 16'h180;
        my_rom[1006] = 16'h180;
        my_rom[1007] = 16'h180;
        my_rom[1008] = 16'h180;
        my_rom[1009] = 16'h180;
        my_rom[1010] = 16'h180;
        my_rom[1011] = 16'h180;
        my_rom[1012] = 16'h180;
        my_rom[1013] = 16'h0;
        my_rom[1014] = 16'h0;
        my_rom[1015] = 16'h0;
        my_rom[1016] = 16'h0;
        my_rom[1017] = 16'h0;
        my_rom[1018] = 16'h0;
        my_rom[1019] = 16'h0;
        my_rom[1020] = 16'h0;
        my_rom[1021] = 16'h0;
        my_rom[1022] = 16'h0;
        my_rom[1023] = 16'h0;
        my_rom[1024] = 16'h0;
        my_rom[1025] = 16'h3e7c;
        my_rom[1026] = 16'h3ffc;
        my_rom[1027] = 16'h4182;
        my_rom[1028] = 16'h6186;
        my_rom[1029] = 16'h6186;
        my_rom[1030] = 16'h6186;
        my_rom[1031] = 16'h6186;
        my_rom[1032] = 16'h6186;
        my_rom[1033] = 16'h6186;
        my_rom[1034] = 16'h6182;
        my_rom[1035] = 16'hfc;
        my_rom[1036] = 16'h7c;
        my_rom[1037] = 16'h6000;
        my_rom[1038] = 16'h6000;
        my_rom[1039] = 16'h6000;
        my_rom[1040] = 16'h6000;
        my_rom[1041] = 16'h6000;
        my_rom[1042] = 16'h6000;
        my_rom[1043] = 16'h6000;
        my_rom[1044] = 16'h4000;
        my_rom[1045] = 16'h3e78;
        my_rom[1046] = 16'h3e7c;
        my_rom[1047] = 16'h0;
        my_rom[1048] = 16'h0;
        my_rom[1049] = 16'h0;
        my_rom[1050] = 16'h0;
        my_rom[1051] = 16'h0;
        my_rom[1052] = 16'h0;
        my_rom[1053] = 16'h0;
        my_rom[1054] = 16'h0;
        my_rom[1055] = 16'h0;
        my_rom[1056] = 16'h0;
        my_rom[1057] = 16'h3e7c;
        my_rom[1058] = 16'h3e7c;
        my_rom[1059] = 16'h4002;
        my_rom[1060] = 16'h6006;
        my_rom[1061] = 16'h6006;
        my_rom[1062] = 16'h6006;
        my_rom[1063] = 16'h6006;
        my_rom[1064] = 16'h6006;
        my_rom[1065] = 16'h6006;
        my_rom[1066] = 16'h4002;
        my_rom[1067] = 16'h3e7c;
        my_rom[1068] = 16'h3e7c;
        my_rom[1069] = 16'h4002;
        my_rom[1070] = 16'h6006;
        my_rom[1071] = 16'h6006;
        my_rom[1072] = 16'h6006;
        my_rom[1073] = 16'h6006;
        my_rom[1074] = 16'h6006;
        my_rom[1075] = 16'h6006;
        my_rom[1076] = 16'h6006;
        my_rom[1077] = 16'h4002;
        my_rom[1078] = 16'h0;
        my_rom[1079] = 16'h0;
        my_rom[1080] = 16'h0;
        my_rom[1081] = 16'h0;
        my_rom[1082] = 16'h0;
        my_rom[1083] = 16'h0;
        my_rom[1084] = 16'h0;
        my_rom[1085] = 16'h0;
        my_rom[1086] = 16'h0;
        my_rom[1087] = 16'h0;
        my_rom[1088] = 16'h0;
        my_rom[1089] = 16'h3e7c;
        my_rom[1090] = 16'h1ffc;
        my_rom[1091] = 16'h182;
        my_rom[1092] = 16'h186;
        my_rom[1093] = 16'h186;
        my_rom[1094] = 16'h186;
        my_rom[1095] = 16'h186;
        my_rom[1096] = 16'h186;
        my_rom[1097] = 16'h186;
        my_rom[1098] = 16'h182;
        my_rom[1099] = 16'h3e7c;
        my_rom[1100] = 16'h3e7c;
        my_rom[1101] = 16'h182;
        my_rom[1102] = 16'h186;
        my_rom[1103] = 16'h186;
        my_rom[1104] = 16'h186;
        my_rom[1105] = 16'h186;
        my_rom[1106] = 16'h186;
        my_rom[1107] = 16'h186;
        my_rom[1108] = 16'h182;
        my_rom[1109] = 16'h1ffc;
        my_rom[1110] = 16'h3e7c;
        my_rom[1111] = 16'h0;
        my_rom[1112] = 16'h0;
        my_rom[1113] = 16'h0;
        my_rom[1114] = 16'h0;
        my_rom[1115] = 16'h0;
        my_rom[1116] = 16'h0;
        my_rom[1117] = 16'h0;
        my_rom[1118] = 16'h0;
        my_rom[1119] = 16'h0;
        my_rom[1120] = 16'h0;
        my_rom[1121] = 16'h3e7c;
        my_rom[1122] = 16'h3e78;
        my_rom[1123] = 16'h4000;
        my_rom[1124] = 16'h6000;
        my_rom[1125] = 16'h6000;
        my_rom[1126] = 16'h6000;
        my_rom[1127] = 16'h6000;
        my_rom[1128] = 16'h6000;
        my_rom[1129] = 16'h6000;
        my_rom[1130] = 16'h6000;
        my_rom[1131] = 16'h0;
        my_rom[1132] = 16'h0;
        my_rom[1133] = 16'h6000;
        my_rom[1134] = 16'h6000;
        my_rom[1135] = 16'h6000;
        my_rom[1136] = 16'h6000;
        my_rom[1137] = 16'h6000;
        my_rom[1138] = 16'h6000;
        my_rom[1139] = 16'h6000;
        my_rom[1140] = 16'h4000;
        my_rom[1141] = 16'h3e78;
        my_rom[1142] = 16'h3e7c;
        my_rom[1143] = 16'h0;
        my_rom[1144] = 16'h0;
        my_rom[1145] = 16'h0;
        my_rom[1146] = 16'h0;
        my_rom[1147] = 16'h0;
        my_rom[1148] = 16'h0;
        my_rom[1149] = 16'h0;
        my_rom[1150] = 16'h0;
        my_rom[1151] = 16'h0;
        my_rom[1152] = 16'h0;
        my_rom[1153] = 16'h3e7c;
        my_rom[1154] = 16'h1ffc;
        my_rom[1155] = 16'h182;
        my_rom[1156] = 16'h186;
        my_rom[1157] = 16'h186;
        my_rom[1158] = 16'h186;
        my_rom[1159] = 16'h186;
        my_rom[1160] = 16'h186;
        my_rom[1161] = 16'h186;
        my_rom[1162] = 16'h186;
        my_rom[1163] = 16'h0;
        my_rom[1164] = 16'h0;
        my_rom[1165] = 16'h186;
        my_rom[1166] = 16'h186;
        my_rom[1167] = 16'h186;
        my_rom[1168] = 16'h186;
        my_rom[1169] = 16'h186;
        my_rom[1170] = 16'h186;
        my_rom[1171] = 16'h186;
        my_rom[1172] = 16'h182;
        my_rom[1173] = 16'h1ffc;
        my_rom[1174] = 16'h3e7c;
        my_rom[1175] = 16'h0;
        my_rom[1176] = 16'h0;
        my_rom[1177] = 16'h0;
        my_rom[1178] = 16'h0;
        my_rom[1179] = 16'h0;
        my_rom[1180] = 16'h0;
        my_rom[1181] = 16'h0;
        my_rom[1182] = 16'h0;
        my_rom[1183] = 16'h0;
        my_rom[1184] = 16'h0;
        my_rom[1185] = 16'h3e7c;
        my_rom[1186] = 16'h3e78;
        my_rom[1187] = 16'h4000;
        my_rom[1188] = 16'h6000;
        my_rom[1189] = 16'h6000;
        my_rom[1190] = 16'h6000;
        my_rom[1191] = 16'h6000;
        my_rom[1192] = 16'h6000;
        my_rom[1193] = 16'h6000;
        my_rom[1194] = 16'h4000;
        my_rom[1195] = 16'h3e7c;
        my_rom[1196] = 16'h3e7c;
        my_rom[1197] = 16'h4000;
        my_rom[1198] = 16'h6000;
        my_rom[1199] = 16'h6000;
        my_rom[1200] = 16'h6000;
        my_rom[1201] = 16'h6000;
        my_rom[1202] = 16'h6000;
        my_rom[1203] = 16'h6000;
        my_rom[1204] = 16'h4000;
        my_rom[1205] = 16'h3e78;
        my_rom[1206] = 16'h3e7c;
        my_rom[1207] = 16'h0;
        my_rom[1208] = 16'h0;
        my_rom[1209] = 16'h0;
        my_rom[1210] = 16'h0;
        my_rom[1211] = 16'h0;
        my_rom[1212] = 16'h0;
        my_rom[1213] = 16'h0;
        my_rom[1214] = 16'h0;
        my_rom[1215] = 16'h0;
        my_rom[1216] = 16'h0;
        my_rom[1217] = 16'h3e7c;
        my_rom[1218] = 16'h3e78;
        my_rom[1219] = 16'h4000;
        my_rom[1220] = 16'h6000;
        my_rom[1221] = 16'h6000;
        my_rom[1222] = 16'h6000;
        my_rom[1223] = 16'h6000;
        my_rom[1224] = 16'h6000;
        my_rom[1225] = 16'h6000;
        my_rom[1226] = 16'h4000;
        my_rom[1227] = 16'h3e7c;
        my_rom[1228] = 16'h3e7c;
        my_rom[1229] = 16'h4000;
        my_rom[1230] = 16'h6000;
        my_rom[1231] = 16'h6000;
        my_rom[1232] = 16'h6000;
        my_rom[1233] = 16'h6000;
        my_rom[1234] = 16'h6000;
        my_rom[1235] = 16'h6000;
        my_rom[1236] = 16'h6000;
        my_rom[1237] = 16'h4000;
        my_rom[1238] = 16'h0;
        my_rom[1239] = 16'h0;
        my_rom[1240] = 16'h0;
        my_rom[1241] = 16'h0;
        my_rom[1242] = 16'h0;
        my_rom[1243] = 16'h0;
        my_rom[1244] = 16'h0;
        my_rom[1245] = 16'h0;
        my_rom[1246] = 16'h0;
        my_rom[1247] = 16'h0;
        my_rom[1248] = 16'h0;
        my_rom[1249] = 16'h3e7c;
        my_rom[1250] = 16'h3e78;
        my_rom[1251] = 16'h4000;
        my_rom[1252] = 16'h6000;
        my_rom[1253] = 16'h6000;
        my_rom[1254] = 16'h6000;
        my_rom[1255] = 16'h6000;
        my_rom[1256] = 16'h6000;
        my_rom[1257] = 16'h6000;
        my_rom[1258] = 16'h6000;
        my_rom[1259] = 16'h7c;
        my_rom[1260] = 16'h7c;
        my_rom[1261] = 16'h6002;
        my_rom[1262] = 16'h6006;
        my_rom[1263] = 16'h6006;
        my_rom[1264] = 16'h6006;
        my_rom[1265] = 16'h6006;
        my_rom[1266] = 16'h6006;
        my_rom[1267] = 16'h6006;
        my_rom[1268] = 16'h4002;
        my_rom[1269] = 16'h3e7c;
        my_rom[1270] = 16'h3e7c;
        my_rom[1271] = 16'h0;
        my_rom[1272] = 16'h0;
        my_rom[1273] = 16'h0;
        my_rom[1274] = 16'h0;
        my_rom[1275] = 16'h0;
        my_rom[1276] = 16'h0;
        my_rom[1277] = 16'h0;
        my_rom[1278] = 16'h0;
        my_rom[1279] = 16'h0;
        my_rom[1280] = 16'h0;
        my_rom[1281] = 16'h0;
        my_rom[1282] = 16'h4002;
        my_rom[1283] = 16'h6006;
        my_rom[1284] = 16'h6006;
        my_rom[1285] = 16'h6006;
        my_rom[1286] = 16'h6006;
        my_rom[1287] = 16'h6006;
        my_rom[1288] = 16'h6006;
        my_rom[1289] = 16'h6006;
        my_rom[1290] = 16'h4002;
        my_rom[1291] = 16'h3e7c;
        my_rom[1292] = 16'h3e7c;
        my_rom[1293] = 16'h4002;
        my_rom[1294] = 16'h6006;
        my_rom[1295] = 16'h6006;
        my_rom[1296] = 16'h6006;
        my_rom[1297] = 16'h6006;
        my_rom[1298] = 16'h6006;
        my_rom[1299] = 16'h6006;
        my_rom[1300] = 16'h6006;
        my_rom[1301] = 16'h4002;
        my_rom[1302] = 16'h0;
        my_rom[1303] = 16'h0;
        my_rom[1304] = 16'h0;
        my_rom[1305] = 16'h0;
        my_rom[1306] = 16'h0;
        my_rom[1307] = 16'h0;
        my_rom[1308] = 16'h0;
        my_rom[1309] = 16'h0;
        my_rom[1310] = 16'h0;
        my_rom[1311] = 16'h0;
        my_rom[1312] = 16'h0;
        my_rom[1313] = 16'h3e7c;
        my_rom[1314] = 16'h1ff8;
        my_rom[1315] = 16'h180;
        my_rom[1316] = 16'h180;
        my_rom[1317] = 16'h180;
        my_rom[1318] = 16'h180;
        my_rom[1319] = 16'h180;
        my_rom[1320] = 16'h180;
        my_rom[1321] = 16'h180;
        my_rom[1322] = 16'h180;
        my_rom[1323] = 16'h0;
        my_rom[1324] = 16'h0;
        my_rom[1325] = 16'h180;
        my_rom[1326] = 16'h180;
        my_rom[1327] = 16'h180;
        my_rom[1328] = 16'h180;
        my_rom[1329] = 16'h180;
        my_rom[1330] = 16'h180;
        my_rom[1331] = 16'h180;
        my_rom[1332] = 16'h180;
        my_rom[1333] = 16'h1ff8;
        my_rom[1334] = 16'h3e7c;
        my_rom[1335] = 16'h0;
        my_rom[1336] = 16'h0;
        my_rom[1337] = 16'h0;
        my_rom[1338] = 16'h0;
        my_rom[1339] = 16'h0;
        my_rom[1340] = 16'h0;
        my_rom[1341] = 16'h0;
        my_rom[1342] = 16'h0;
        my_rom[1343] = 16'h0;
        my_rom[1344] = 16'h0;
        my_rom[1345] = 16'h7c;
        my_rom[1346] = 16'h7c;
        my_rom[1347] = 16'h2;
        my_rom[1348] = 16'h6;
        my_rom[1349] = 16'h6;
        my_rom[1350] = 16'h6;
        my_rom[1351] = 16'h6;
        my_rom[1352] = 16'h6;
        my_rom[1353] = 16'h6;
        my_rom[1354] = 16'h6;
        my_rom[1355] = 16'h0;
        my_rom[1356] = 16'h0;
        my_rom[1357] = 16'h6006;
        my_rom[1358] = 16'h6006;
        my_rom[1359] = 16'h6006;
        my_rom[1360] = 16'h6006;
        my_rom[1361] = 16'h6006;
        my_rom[1362] = 16'h6006;
        my_rom[1363] = 16'h6006;
        my_rom[1364] = 16'h4002;
        my_rom[1365] = 16'h3e7c;
        my_rom[1366] = 16'h3e7c;
        my_rom[1367] = 16'h0;
        my_rom[1368] = 16'h0;
        my_rom[1369] = 16'h0;
        my_rom[1370] = 16'h0;
        my_rom[1371] = 16'h0;
        my_rom[1372] = 16'h0;
        my_rom[1373] = 16'h0;
        my_rom[1374] = 16'h0;
        my_rom[1375] = 16'h0;
        my_rom[1376] = 16'h0;
        my_rom[1377] = 16'h0;
        my_rom[1378] = 16'h4000;
        my_rom[1379] = 16'h6008;
        my_rom[1380] = 16'h6008;
        my_rom[1381] = 16'h6018;
        my_rom[1382] = 16'h6030;
        my_rom[1383] = 16'h6030;
        my_rom[1384] = 16'h6060;
        my_rom[1385] = 16'h6060;
        my_rom[1386] = 16'h4000;
        my_rom[1387] = 16'h3e00;
        my_rom[1388] = 16'h3e00;
        my_rom[1389] = 16'h4000;
        my_rom[1390] = 16'h6060;
        my_rom[1391] = 16'h6060;
        my_rom[1392] = 16'h6030;
        my_rom[1393] = 16'h6030;
        my_rom[1394] = 16'h6018;
        my_rom[1395] = 16'h6008;
        my_rom[1396] = 16'h6008;
        my_rom[1397] = 16'h4000;
        my_rom[1398] = 16'h0;
        my_rom[1399] = 16'h0;
        my_rom[1400] = 16'h0;
        my_rom[1401] = 16'h0;
        my_rom[1402] = 16'h0;
        my_rom[1403] = 16'h0;
        my_rom[1404] = 16'h0;
        my_rom[1405] = 16'h0;
        my_rom[1406] = 16'h0;
        my_rom[1407] = 16'h0;
        my_rom[1408] = 16'h0;
        my_rom[1409] = 16'h0;
        my_rom[1410] = 16'h4000;
        my_rom[1411] = 16'h6000;
        my_rom[1412] = 16'h6000;
        my_rom[1413] = 16'h6000;
        my_rom[1414] = 16'h6000;
        my_rom[1415] = 16'h6000;
        my_rom[1416] = 16'h6000;
        my_rom[1417] = 16'h6000;
        my_rom[1418] = 16'h6000;
        my_rom[1419] = 16'h0;
        my_rom[1420] = 16'h0;
        my_rom[1421] = 16'h6000;
        my_rom[1422] = 16'h6000;
        my_rom[1423] = 16'h6000;
        my_rom[1424] = 16'h6000;
        my_rom[1425] = 16'h6000;
        my_rom[1426] = 16'h6000;
        my_rom[1427] = 16'h6000;
        my_rom[1428] = 16'h4000;
        my_rom[1429] = 16'h3e78;
        my_rom[1430] = 16'h3e7c;
        my_rom[1431] = 16'h0;
        my_rom[1432] = 16'h0;
        my_rom[1433] = 16'h0;
        my_rom[1434] = 16'h0;
        my_rom[1435] = 16'h0;
        my_rom[1436] = 16'h0;
        my_rom[1437] = 16'h0;
        my_rom[1438] = 16'h0;
        my_rom[1439] = 16'h0;
        my_rom[1440] = 16'h0;
        my_rom[1441] = 16'h0;
        my_rom[1442] = 16'h4002;
        my_rom[1443] = 16'h6006;
        my_rom[1444] = 16'h700e;
        my_rom[1445] = 16'h581a;
        my_rom[1446] = 16'h4c32;
        my_rom[1447] = 16'h6c36;
        my_rom[1448] = 16'h6666;
        my_rom[1449] = 16'h6666;
        my_rom[1450] = 16'h6006;
        my_rom[1451] = 16'h0;
        my_rom[1452] = 16'h0;
        my_rom[1453] = 16'h6186;
        my_rom[1454] = 16'h6186;
        my_rom[1455] = 16'h6186;
        my_rom[1456] = 16'h6186;
        my_rom[1457] = 16'h6186;
        my_rom[1458] = 16'h6186;
        my_rom[1459] = 16'h6186;
        my_rom[1460] = 16'h6186;
        my_rom[1461] = 16'h4002;
        my_rom[1462] = 16'h0;
        my_rom[1463] = 16'h0;
        my_rom[1464] = 16'h0;
        my_rom[1465] = 16'h0;
        my_rom[1466] = 16'h0;
        my_rom[1467] = 16'h0;
        my_rom[1468] = 16'h0;
        my_rom[1469] = 16'h0;
        my_rom[1470] = 16'h0;
        my_rom[1471] = 16'h0;
        my_rom[1472] = 16'h0;
        my_rom[1473] = 16'h0;
        my_rom[1474] = 16'h4002;
        my_rom[1475] = 16'h6006;
        my_rom[1476] = 16'h7006;
        my_rom[1477] = 16'h5806;
        my_rom[1478] = 16'h4c06;
        my_rom[1479] = 16'h6c06;
        my_rom[1480] = 16'h6606;
        my_rom[1481] = 16'h6606;
        my_rom[1482] = 16'h6006;
        my_rom[1483] = 16'h0;
        my_rom[1484] = 16'h0;
        my_rom[1485] = 16'h6006;
        my_rom[1486] = 16'h6066;
        my_rom[1487] = 16'h6066;
        my_rom[1488] = 16'h6036;
        my_rom[1489] = 16'h6032;
        my_rom[1490] = 16'h601a;
        my_rom[1491] = 16'h600e;
        my_rom[1492] = 16'h6006;
        my_rom[1493] = 16'h4002;
        my_rom[1494] = 16'h0;
        my_rom[1495] = 16'h0;
        my_rom[1496] = 16'h0;
        my_rom[1497] = 16'h0;
        my_rom[1498] = 16'h0;
        my_rom[1499] = 16'h0;
        my_rom[1500] = 16'h0;
        my_rom[1501] = 16'h0;
        my_rom[1502] = 16'h0;
        my_rom[1503] = 16'h0;
        my_rom[1504] = 16'h0;
        my_rom[1505] = 16'h3e7c;
        my_rom[1506] = 16'h3e7c;
        my_rom[1507] = 16'h4002;
        my_rom[1508] = 16'h6006;
        my_rom[1509] = 16'h6006;
        my_rom[1510] = 16'h6006;
        my_rom[1511] = 16'h6006;
        my_rom[1512] = 16'h6006;
        my_rom[1513] = 16'h6006;
        my_rom[1514] = 16'h6006;
        my_rom[1515] = 16'h0;
        my_rom[1516] = 16'h0;
        my_rom[1517] = 16'h6006;
        my_rom[1518] = 16'h6006;
        my_rom[1519] = 16'h6006;
        my_rom[1520] = 16'h6006;
        my_rom[1521] = 16'h6006;
        my_rom[1522] = 16'h6006;
        my_rom[1523] = 16'h6006;
        my_rom[1524] = 16'h4002;
        my_rom[1525] = 16'h3e7c;
        my_rom[1526] = 16'h3e7c;
        my_rom[1527] = 16'h0;
        my_rom[1528] = 16'h0;
        my_rom[1529] = 16'h0;
        my_rom[1530] = 16'h0;
        my_rom[1531] = 16'h0;
        my_rom[1532] = 16'h0;
        my_rom[1533] = 16'h0;
        my_rom[1534] = 16'h0;
        my_rom[1535] = 16'h0;
        my_rom[1536] = 16'h0;
        my_rom[1537] = 16'h3e7c;
        my_rom[1538] = 16'h3e7c;
        my_rom[1539] = 16'h4002;
        my_rom[1540] = 16'h6006;
        my_rom[1541] = 16'h6006;
        my_rom[1542] = 16'h6006;
        my_rom[1543] = 16'h6006;
        my_rom[1544] = 16'h6006;
        my_rom[1545] = 16'h6006;
        my_rom[1546] = 16'h4002;
        my_rom[1547] = 16'h3e7c;
        my_rom[1548] = 16'h3e7c;
        my_rom[1549] = 16'h4000;
        my_rom[1550] = 16'h6000;
        my_rom[1551] = 16'h6000;
        my_rom[1552] = 16'h6000;
        my_rom[1553] = 16'h6000;
        my_rom[1554] = 16'h6000;
        my_rom[1555] = 16'h6000;
        my_rom[1556] = 16'h6000;
        my_rom[1557] = 16'h4000;
        my_rom[1558] = 16'h0;
        my_rom[1559] = 16'h0;
        my_rom[1560] = 16'h0;
        my_rom[1561] = 16'h0;
        my_rom[1562] = 16'h0;
        my_rom[1563] = 16'h0;
        my_rom[1564] = 16'h0;
        my_rom[1565] = 16'h0;
        my_rom[1566] = 16'h0;
        my_rom[1567] = 16'h0;
        my_rom[1568] = 16'h0;
        my_rom[1569] = 16'h3e7c;
        my_rom[1570] = 16'h3e7c;
        my_rom[1571] = 16'h4002;
        my_rom[1572] = 16'h6006;
        my_rom[1573] = 16'h6006;
        my_rom[1574] = 16'h6006;
        my_rom[1575] = 16'h6006;
        my_rom[1576] = 16'h6006;
        my_rom[1577] = 16'h6006;
        my_rom[1578] = 16'h6006;
        my_rom[1579] = 16'h0;
        my_rom[1580] = 16'h0;
        my_rom[1581] = 16'h6006;
        my_rom[1582] = 16'h6066;
        my_rom[1583] = 16'h6066;
        my_rom[1584] = 16'h6036;
        my_rom[1585] = 16'h6032;
        my_rom[1586] = 16'h601a;
        my_rom[1587] = 16'h600e;
        my_rom[1588] = 16'h4006;
        my_rom[1589] = 16'h3e7c;
        my_rom[1590] = 16'h3e7c;
        my_rom[1591] = 16'h0;
        my_rom[1592] = 16'h0;
        my_rom[1593] = 16'h0;
        my_rom[1594] = 16'h0;
        my_rom[1595] = 16'h0;
        my_rom[1596] = 16'h0;
        my_rom[1597] = 16'h0;
        my_rom[1598] = 16'h0;
        my_rom[1599] = 16'h0;
        my_rom[1600] = 16'h0;
        my_rom[1601] = 16'h3e7c;
        my_rom[1602] = 16'h3e7c;
        my_rom[1603] = 16'h4002;
        my_rom[1604] = 16'h6006;
        my_rom[1605] = 16'h6006;
        my_rom[1606] = 16'h6006;
        my_rom[1607] = 16'h6006;
        my_rom[1608] = 16'h6006;
        my_rom[1609] = 16'h6006;
        my_rom[1610] = 16'h4006;
        my_rom[1611] = 16'h3e00;
        my_rom[1612] = 16'h3e00;
        my_rom[1613] = 16'h4000;
        my_rom[1614] = 16'h6060;
        my_rom[1615] = 16'h6060;
        my_rom[1616] = 16'h6030;
        my_rom[1617] = 16'h6030;
        my_rom[1618] = 16'h6018;
        my_rom[1619] = 16'h6008;
        my_rom[1620] = 16'h6008;
        my_rom[1621] = 16'h4000;
        my_rom[1622] = 16'h0;
        my_rom[1623] = 16'h0;
        my_rom[1624] = 16'h0;
        my_rom[1625] = 16'h0;
        my_rom[1626] = 16'h0;
        my_rom[1627] = 16'h0;
        my_rom[1628] = 16'h0;
        my_rom[1629] = 16'h0;
        my_rom[1630] = 16'h0;
        my_rom[1631] = 16'h0;
        my_rom[1632] = 16'h0;
        my_rom[1633] = 16'h3e7c;
        my_rom[1634] = 16'h3e78;
        my_rom[1635] = 16'h4000;
        my_rom[1636] = 16'h6000;
        my_rom[1637] = 16'h6000;
        my_rom[1638] = 16'h6000;
        my_rom[1639] = 16'h6000;
        my_rom[1640] = 16'h6000;
        my_rom[1641] = 16'h6000;
        my_rom[1642] = 16'h4000;
        my_rom[1643] = 16'h3e7c;
        my_rom[1644] = 16'h3e7c;
        my_rom[1645] = 16'h2;
        my_rom[1646] = 16'h6;
        my_rom[1647] = 16'h6;
        my_rom[1648] = 16'h6;
        my_rom[1649] = 16'h6;
        my_rom[1650] = 16'h6;
        my_rom[1651] = 16'h6;
        my_rom[1652] = 16'h2;
        my_rom[1653] = 16'h1e7c;
        my_rom[1654] = 16'h3e7c;
        my_rom[1655] = 16'h0;
        my_rom[1656] = 16'h0;
        my_rom[1657] = 16'h0;
        my_rom[1658] = 16'h0;
        my_rom[1659] = 16'h0;
        my_rom[1660] = 16'h0;
        my_rom[1661] = 16'h0;
        my_rom[1662] = 16'h0;
        my_rom[1663] = 16'h0;
        my_rom[1664] = 16'h0;
        my_rom[1665] = 16'h3e7c;
        my_rom[1666] = 16'h1ff8;
        my_rom[1667] = 16'h180;
        my_rom[1668] = 16'h180;
        my_rom[1669] = 16'h180;
        my_rom[1670] = 16'h180;
        my_rom[1671] = 16'h180;
        my_rom[1672] = 16'h180;
        my_rom[1673] = 16'h180;
        my_rom[1674] = 16'h180;
        my_rom[1675] = 16'h0;
        my_rom[1676] = 16'h0;
        my_rom[1677] = 16'h180;
        my_rom[1678] = 16'h180;
        my_rom[1679] = 16'h180;
        my_rom[1680] = 16'h180;
        my_rom[1681] = 16'h180;
        my_rom[1682] = 16'h180;
        my_rom[1683] = 16'h180;
        my_rom[1684] = 16'h180;
        my_rom[1685] = 16'h0;
        my_rom[1686] = 16'h0;
        my_rom[1687] = 16'h0;
        my_rom[1688] = 16'h0;
        my_rom[1689] = 16'h0;
        my_rom[1690] = 16'h0;
        my_rom[1691] = 16'h0;
        my_rom[1692] = 16'h0;
        my_rom[1693] = 16'h0;
        my_rom[1694] = 16'h0;
        my_rom[1695] = 16'h0;
        my_rom[1696] = 16'h0;
        my_rom[1697] = 16'h0;
        my_rom[1698] = 16'h4002;
        my_rom[1699] = 16'h6006;
        my_rom[1700] = 16'h6006;
        my_rom[1701] = 16'h6006;
        my_rom[1702] = 16'h6006;
        my_rom[1703] = 16'h6006;
        my_rom[1704] = 16'h6006;
        my_rom[1705] = 16'h6006;
        my_rom[1706] = 16'h6006;
        my_rom[1707] = 16'h0;
        my_rom[1708] = 16'h0;
        my_rom[1709] = 16'h6006;
        my_rom[1710] = 16'h6006;
        my_rom[1711] = 16'h6006;
        my_rom[1712] = 16'h6006;
        my_rom[1713] = 16'h6006;
        my_rom[1714] = 16'h6006;
        my_rom[1715] = 16'h6006;
        my_rom[1716] = 16'h4002;
        my_rom[1717] = 16'h3e7c;
        my_rom[1718] = 16'h3e7c;
        my_rom[1719] = 16'h0;
        my_rom[1720] = 16'h0;
        my_rom[1721] = 16'h0;
        my_rom[1722] = 16'h0;
        my_rom[1723] = 16'h0;
        my_rom[1724] = 16'h0;
        my_rom[1725] = 16'h0;
        my_rom[1726] = 16'h0;
        my_rom[1727] = 16'h0;
        my_rom[1728] = 16'h0;
        my_rom[1729] = 16'h0;
        my_rom[1730] = 16'h4000;
        my_rom[1731] = 16'h6008;
        my_rom[1732] = 16'h6008;
        my_rom[1733] = 16'h6018;
        my_rom[1734] = 16'h6030;
        my_rom[1735] = 16'h6030;
        my_rom[1736] = 16'h6060;
        my_rom[1737] = 16'h6060;
        my_rom[1738] = 16'h6000;
        my_rom[1739] = 16'h0;
        my_rom[1740] = 16'h0;
        my_rom[1741] = 16'h6000;
        my_rom[1742] = 16'h6600;
        my_rom[1743] = 16'h6600;
        my_rom[1744] = 16'h6c00;
        my_rom[1745] = 16'h4c00;
        my_rom[1746] = 16'h5800;
        my_rom[1747] = 16'h7000;
        my_rom[1748] = 16'h6000;
        my_rom[1749] = 16'h4000;
        my_rom[1750] = 16'h0;
        my_rom[1751] = 16'h0;
        my_rom[1752] = 16'h0;
        my_rom[1753] = 16'h0;
        my_rom[1754] = 16'h0;
        my_rom[1755] = 16'h0;
        my_rom[1756] = 16'h0;
        my_rom[1757] = 16'h0;
        my_rom[1758] = 16'h0;
        my_rom[1759] = 16'h0;
        my_rom[1760] = 16'h0;
        my_rom[1761] = 16'h0;
        my_rom[1762] = 16'h4002;
        my_rom[1763] = 16'h6006;
        my_rom[1764] = 16'h6006;
        my_rom[1765] = 16'h6006;
        my_rom[1766] = 16'h6006;
        my_rom[1767] = 16'h6006;
        my_rom[1768] = 16'h6006;
        my_rom[1769] = 16'h6006;
        my_rom[1770] = 16'h6006;
        my_rom[1771] = 16'h0;
        my_rom[1772] = 16'h0;
        my_rom[1773] = 16'h6186;
        my_rom[1774] = 16'h6186;
        my_rom[1775] = 16'h6186;
        my_rom[1776] = 16'h6186;
        my_rom[1777] = 16'h6186;
        my_rom[1778] = 16'h6186;
        my_rom[1779] = 16'h6186;
        my_rom[1780] = 16'h4182;
        my_rom[1781] = 16'h3ffc;
        my_rom[1782] = 16'h3e7c;
        my_rom[1783] = 16'h0;
        my_rom[1784] = 16'h0;
        my_rom[1785] = 16'h0;
        my_rom[1786] = 16'h0;
        my_rom[1787] = 16'h0;
        my_rom[1788] = 16'h0;
        my_rom[1789] = 16'h0;
        my_rom[1790] = 16'h0;
        my_rom[1791] = 16'h0;
        my_rom[1792] = 16'h0;
        my_rom[1793] = 16'h0;
        my_rom[1794] = 16'h0;
        my_rom[1795] = 16'h1008;
        my_rom[1796] = 16'h1008;
        my_rom[1797] = 16'h1818;
        my_rom[1798] = 16'hc30;
        my_rom[1799] = 16'hc30;
        my_rom[1800] = 16'h660;
        my_rom[1801] = 16'h660;
        my_rom[1802] = 16'h0;
        my_rom[1803] = 16'h0;
        my_rom[1804] = 16'h0;
        my_rom[1805] = 16'h0;
        my_rom[1806] = 16'h660;
        my_rom[1807] = 16'h660;
        my_rom[1808] = 16'hc30;
        my_rom[1809] = 16'hc30;
        my_rom[1810] = 16'h1818;
        my_rom[1811] = 16'h1008;
        my_rom[1812] = 16'h1008;
        my_rom[1813] = 16'h0;
        my_rom[1814] = 16'h0;
        my_rom[1815] = 16'h0;
        my_rom[1816] = 16'h0;
        my_rom[1817] = 16'h0;
        my_rom[1818] = 16'h0;
        my_rom[1819] = 16'h0;
        my_rom[1820] = 16'h0;
        my_rom[1821] = 16'h0;
        my_rom[1822] = 16'h0;
        my_rom[1823] = 16'h0;
        my_rom[1824] = 16'h0;
        my_rom[1825] = 16'h0;
        my_rom[1826] = 16'h0;
        my_rom[1827] = 16'h1008;
        my_rom[1828] = 16'h1008;
        my_rom[1829] = 16'h1818;
        my_rom[1830] = 16'hc30;
        my_rom[1831] = 16'hc30;
        my_rom[1832] = 16'h660;
        my_rom[1833] = 16'h660;
        my_rom[1834] = 16'h0;
        my_rom[1835] = 16'h0;
        my_rom[1836] = 16'h0;
        my_rom[1837] = 16'h180;
        my_rom[1838] = 16'h180;
        my_rom[1839] = 16'h180;
        my_rom[1840] = 16'h180;
        my_rom[1841] = 16'h180;
        my_rom[1842] = 16'h180;
        my_rom[1843] = 16'h180;
        my_rom[1844] = 16'h180;
        my_rom[1845] = 16'h0;
        my_rom[1846] = 16'h0;
        my_rom[1847] = 16'h0;
        my_rom[1848] = 16'h0;
        my_rom[1849] = 16'h0;
        my_rom[1850] = 16'h0;
        my_rom[1851] = 16'h0;
        my_rom[1852] = 16'h0;
        my_rom[1853] = 16'h0;
        my_rom[1854] = 16'h0;
        my_rom[1855] = 16'h0;
        my_rom[1856] = 16'h0;
        my_rom[1857] = 16'h3e7c;
        my_rom[1858] = 16'h1e78;
        my_rom[1859] = 16'h0;
        my_rom[1860] = 16'h8;
        my_rom[1861] = 16'h18;
        my_rom[1862] = 16'h30;
        my_rom[1863] = 16'h30;
        my_rom[1864] = 16'h60;
        my_rom[1865] = 16'h60;
        my_rom[1866] = 16'h0;
        my_rom[1867] = 16'h0;
        my_rom[1868] = 16'h0;
        my_rom[1869] = 16'h0;
        my_rom[1870] = 16'h600;
        my_rom[1871] = 16'h600;
        my_rom[1872] = 16'hc00;
        my_rom[1873] = 16'hc00;
        my_rom[1874] = 16'h1800;
        my_rom[1875] = 16'h1000;
        my_rom[1876] = 16'h0;
        my_rom[1877] = 16'h1e78;
        my_rom[1878] = 16'h3e7c;
        my_rom[1879] = 16'h0;
        my_rom[1880] = 16'h0;
        my_rom[1881] = 16'h0;
        my_rom[1882] = 16'h0;
        my_rom[1883] = 16'h0;
        my_rom[1884] = 16'h0;
        my_rom[1885] = 16'h0;
        my_rom[1886] = 16'h0;
        my_rom[1887] = 16'h0;
        my_rom[1888] = 16'h0;
        my_rom[1889] = 16'h3e00;
        my_rom[1890] = 16'h3e00;
        my_rom[1891] = 16'h4000;
        my_rom[1892] = 16'h6000;
        my_rom[1893] = 16'h6000;
        my_rom[1894] = 16'h6000;
        my_rom[1895] = 16'h6000;
        my_rom[1896] = 16'h6000;
        my_rom[1897] = 16'h6000;
        my_rom[1898] = 16'h6000;
        my_rom[1899] = 16'h0;
        my_rom[1900] = 16'h0;
        my_rom[1901] = 16'h6000;
        my_rom[1902] = 16'h6000;
        my_rom[1903] = 16'h6000;
        my_rom[1904] = 16'h6000;
        my_rom[1905] = 16'h6000;
        my_rom[1906] = 16'h6000;
        my_rom[1907] = 16'h6000;
        my_rom[1908] = 16'h4000;
        my_rom[1909] = 16'h3e00;
        my_rom[1910] = 16'h3e00;
        my_rom[1911] = 16'h0;
        my_rom[1912] = 16'h0;
        my_rom[1913] = 16'h0;
        my_rom[1914] = 16'h0;
        my_rom[1915] = 16'h0;
        my_rom[1916] = 16'h0;
        my_rom[1917] = 16'h0;
        my_rom[1918] = 16'h0;
        my_rom[1919] = 16'h0;
        my_rom[1920] = 16'h0;
        my_rom[1921] = 16'h0;
        my_rom[1922] = 16'h0;
        my_rom[1923] = 16'h1000;
        my_rom[1924] = 16'h1000;
        my_rom[1925] = 16'h1800;
        my_rom[1926] = 16'hc00;
        my_rom[1927] = 16'hc00;
        my_rom[1928] = 16'h600;
        my_rom[1929] = 16'h600;
        my_rom[1930] = 16'h0;
        my_rom[1931] = 16'h0;
        my_rom[1932] = 16'h0;
        my_rom[1933] = 16'h0;
        my_rom[1934] = 16'h60;
        my_rom[1935] = 16'h60;
        my_rom[1936] = 16'h30;
        my_rom[1937] = 16'h30;
        my_rom[1938] = 16'h18;
        my_rom[1939] = 16'h8;
        my_rom[1940] = 16'h8;
        my_rom[1941] = 16'h0;
        my_rom[1942] = 16'h0;
        my_rom[1943] = 16'h0;
        my_rom[1944] = 16'h0;
        my_rom[1945] = 16'h0;
        my_rom[1946] = 16'h0;
        my_rom[1947] = 16'h0;
        my_rom[1948] = 16'h0;
        my_rom[1949] = 16'h0;
        my_rom[1950] = 16'h0;
        my_rom[1951] = 16'h0;
        my_rom[1952] = 16'h0;
        my_rom[1953] = 16'h7c;
        my_rom[1954] = 16'h7c;
        my_rom[1955] = 16'h2;
        my_rom[1956] = 16'h6;
        my_rom[1957] = 16'h6;
        my_rom[1958] = 16'h6;
        my_rom[1959] = 16'h6;
        my_rom[1960] = 16'h6;
        my_rom[1961] = 16'h6;
        my_rom[1962] = 16'h6;
        my_rom[1963] = 16'h0;
        my_rom[1964] = 16'h0;
        my_rom[1965] = 16'h6;
        my_rom[1966] = 16'h6;
        my_rom[1967] = 16'h6;
        my_rom[1968] = 16'h6;
        my_rom[1969] = 16'h6;
        my_rom[1970] = 16'h6;
        my_rom[1971] = 16'h6;
        my_rom[1972] = 16'h2;
        my_rom[1973] = 16'h7c;
        my_rom[1974] = 16'h7c;
        my_rom[1975] = 16'h0;
        my_rom[1976] = 16'h0;
        my_rom[1977] = 16'h0;
        my_rom[1978] = 16'h0;
        my_rom[1979] = 16'h0;
        my_rom[1980] = 16'h0;
        my_rom[1981] = 16'h0;
        my_rom[1982] = 16'h0;
        my_rom[1983] = 16'h0;
        my_rom[1984] = 16'h0;
        my_rom[1985] = 16'h0;
        my_rom[1986] = 16'h0;
        my_rom[1987] = 16'h240;
        my_rom[1988] = 16'h660;
        my_rom[1989] = 16'h660;
        my_rom[1990] = 16'hc30;
        my_rom[1991] = 16'h810;
        my_rom[1992] = 16'h1818;
        my_rom[1993] = 16'h1008;
        my_rom[1994] = 16'h0;
        my_rom[1995] = 16'h0;
        my_rom[1996] = 16'h0;
        my_rom[1997] = 16'h0;
        my_rom[1998] = 16'h0;
        my_rom[1999] = 16'h0;
        my_rom[2000] = 16'h0;
        my_rom[2001] = 16'h0;
        my_rom[2002] = 16'h0;
        my_rom[2003] = 16'h0;
        my_rom[2004] = 16'h0;
        my_rom[2005] = 16'h0;
        my_rom[2006] = 16'h0;
        my_rom[2007] = 16'h0;
        my_rom[2008] = 16'h0;
        my_rom[2009] = 16'h0;
        my_rom[2010] = 16'h0;
        my_rom[2011] = 16'h0;
        my_rom[2012] = 16'h0;
        my_rom[2013] = 16'h0;
        my_rom[2014] = 16'h0;
        my_rom[2015] = 16'h0;
        my_rom[2016] = 16'h0;
        my_rom[2017] = 16'h0;
        my_rom[2018] = 16'h0;
        my_rom[2019] = 16'h0;
        my_rom[2020] = 16'h0;
        my_rom[2021] = 16'h0;
        my_rom[2022] = 16'h0;
        my_rom[2023] = 16'h0;
        my_rom[2024] = 16'h0;
        my_rom[2025] = 16'h0;
        my_rom[2026] = 16'h0;
        my_rom[2027] = 16'h0;
        my_rom[2028] = 16'h0;
        my_rom[2029] = 16'h0;
        my_rom[2030] = 16'h0;
        my_rom[2031] = 16'h0;
        my_rom[2032] = 16'h0;
        my_rom[2033] = 16'h0;
        my_rom[2034] = 16'h0;
        my_rom[2035] = 16'h0;
        my_rom[2036] = 16'h0;
        my_rom[2037] = 16'h1e78;
        my_rom[2038] = 16'h3e7c;
    end
endmodule


module vga (
  input clock,
  input [1:0] ONnotOFF
);
  wire [10:0] s0;
  wire [15:0] s1;
  wire [15:0] s2;
  wire [3:0] s3;
  wire [3:0] s4;
  wire [3:0] s5;
  wire s6;
  wire s7;
  display display_i0 (
    .clock( clock ),
    .enable( ONnotOFF ),
    .Character_Data( s2 ),
    .R( s3 ),
    .G( s4 ),
    .B( s5 ),
    .H_output( s6 ),
    .V_output( s7 ),
    .Character_Address( s0 )
  );
  // Character ROM
  DIG_ROM_2048X16_CharacterROM DIG_ROM_2048X16_CharacterROM_i1 (
    .A( s0 ),
    .sel( 1'b1 ),
    .D( s1 )
  );
  DIG_D_FF_Nbit #(
    .Bits(16),
    .Default(0)
  )
  DIG_D_FF_Nbit_i2 (
    .D( s1 ),
    .C( clock ),
    .Q( s2 )
  );
endmodule
