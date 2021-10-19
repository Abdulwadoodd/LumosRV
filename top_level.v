`timescale 1ns/1ns

module top_level (
    input clk, rst,
    //output [31:0] Reg_File,
    //output [3:0] ALUControl,
    
    output reg [31:0] PC,
    output [31:0] Instr, RF1, RF2, RF3, RF4, RF5, RF6, RF7, DM0, DM4, DM8);
    // Control Flags
    wire  RegWrite, ALUSrc2, ALUSrc1;
    wire [1:0] ResultSrc,MemWrite;
    wire [2:0] MemRead,br_type;
    wire [3:0] ALUControl;
    //necessary wires and reg for top level Data Path
    wire [31:0] ReadData,RD2, RD1,ImmExt;
    reg [31:0] Result, SrcA, SrcB, PCNext,PCPlus4,ALUResult;
    reg br_taken;

    always @(*) begin
        PCNext <= br_taken ? ALUResult : PCPlus4;
    end

    always @(*) begin
        PCPlus4 <= PC + 32'd4;
    end

    always @(posedge clk) begin
        if(rst)
            PC <= 32'd0;
        else
            PC <= PCNext;
    end

    instr_mem a1(.A(PC), .RD(Instr));

    reg [6:0] opcode;
    reg [2:0] func3;
    reg func7_5;
    reg [4:0] A1,A2,A3; 

    always @(*) begin
        opcode <= Instr[6:0];
        func3 <= Instr[14:12];
        func7_5 <= Instr[30];
        A1 <= Instr[19:15];
        A2 <= Instr[24:20];
        A3 <= Instr[11:7];
    end

    extend a2(.ImmExt(ImmExt), .Instr(Instr));

    register_file a4 ( .RD1(RD1), .RD2(RD2), .RF1(RF1), .RF2(RF2), .RF3(RF3), .RF4(RF4), .RF5(RF5),
                       .RF6(RF6), .RF7(RF7), .WD3(Result), .A1(A1), .A2(A2), .A3(A3), 
                        .WE3(RegWrite), .clk(clk),.rst(rst) );

    always @(*) begin
        SrcA <= ALUSrc1 ? PC : RD1;
    end
    
    always @(*) begin
        SrcB <= ALUSrc2 ? ImmExt : RD2; 
    end
    
    // ALU
    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResult = SrcA + SrcB;
            4'b0001: ALUResult = SrcA - SrcB;
            4'b0010: ALUResult = SrcA & SrcB;
            4'b0011: ALUResult = SrcA | SrcB;
            4'b0100: ALUResult = SrcB;
            4'b0101: ALUResult = $signed(SrcA) < $signed(SrcB);
            4'b0110: ALUResult = SrcA ^ SrcB;
            4'b0111: ALUResult = SrcA >> SrcB;
            4'b1000: ALUResult = SrcA << SrcB;
            4'b1001: ALUResult = $signed(SrcA) >>> $signed(SrcB);
            4'b1010: ALUResult = SrcA < SrcB;
            //4'b1011: ALUResult = $signed(SrcA) - $signed(SrcB);
            default: ALUResult = 32'd0;
        endcase
    end

    //Branch Module
    always@(*)begin
        case (br_type)
            3'b000: br_taken = 1'b0;
            3'b001: br_taken = (RD1 == RD2);  //beq
            3'b010: br_taken = (RD1 != RD2);  //bne
            3'b011: br_taken = (RD1 < RD2);   //sltu
            3'b100: br_taken = (RD1 >= RD2);  //bgeu
            3'b101: br_taken = ($signed(RD1) < $signed(RD2));     //slt
            3'b110: br_taken = ($signed(RD1) >= $signed(RD2));    //bge
            3'b111: br_taken = 1'b1;     // JAL, JALR
            default: br_taken = 1'b0;
        endcase              
    end

    Data_Memory a5( .RD(ReadData),.DM0(DM0), .DM4(DM4), .DM8(DM8), .WD(RD2), .A(ALUResult), 
                    .WE(MemWrite), .RE(MemRead) , .clk(clk), .rst(rst));

    always @(*) begin
        case (ResultSrc)
            2'b00: Result <= ALUResult;
            2'b01: Result <= ReadData;
            2'b10: Result <= PCPlus4;
            default: Result <= 32'd0;
        endcase
        //Result <= ResultSrc ? ReadData: ALUResult;
    end

    ControlUnit a6( .opcode(opcode), .func3(func3), .func7_5(func7_5), .ResultSrc(ResultSrc),
                    .MemWrite(MemWrite), .ALUSrc2(ALUSrc2), .ALUSrc1(ALUSrc1), .RegWrite(RegWrite), 
                    .ALUControl(ALUControl), .MemRead(MemRead), .br_type(br_type));

endmodule