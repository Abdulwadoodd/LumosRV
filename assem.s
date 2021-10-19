


# New instruction tests
# lui x1, 0x12345
# addi x1,x1, 0x0A8
# sb x2, 0(x0)
# sh x2, 4(x0)
# sw x2, 8(x0)
# lb x3, 8(x0)
# lh x4, 8(x0)
# lw x5, 8(x0)
# lbu x6, 8(x0)
# lhu x7, 8(x0)
# jal x2, jmp
# addi x3,x0, 23
# addi x4,x0, 11
# jal x6,end


# jmp: 
# addi x5, x0, 7
# jalr x7,x2,0

# end:
# auipc x5,0x4567
# addi x0,x0,0

# Logical operation test
# addi x1,x0,0b10101111
# addi x2,x0,-16
# slli x3,x1,3
# srli x3,x1,3
# srai x4,x2,3
# addi x0,x0,0


# slt with signed and unsigned check    &&      Branch instruction check    
# addi x1, x0, -3
# addi x2, x0, 2
# sltu x3, x1, x2
# slt x4,x1,x2
# bge x2,x1,jmp  #check every branch instruction here
# addi x4,x0,22
# jmp:
# addi x5,x0,69
# addi x0,x0,0


# RV-32I assembly program to calculate the GCD of two number
addi x1, x0, 36     # give 1st number
sw x1, 0(x0)
addi x2, x0, 28     # give 2nd number
sw x2, 4(x0)
#lw x1, 0(x0)
#lw x2, 4(x0)
addi x3, x0, 1
addi x6,x0,31
beq x1,x2,36
sub x4,x2,x1
srl x5,x4,x6
beq x3, x5, 16
sub x2,x2,x1
bne x1,x2,-16
beq x1,x2,12
sub x1,x1,x2
bne x1,x2, -28
sw x1,8(x0)
