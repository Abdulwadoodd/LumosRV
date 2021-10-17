
# lui x2, 0x12345
# addi x2,x2, 0x678
# addi x1, x0, 69
# addi x3, x0, 23
# sb x2, 0(x0)
# sh x2, 4(x0)
# sw x2, 8(x0)
# addi x0,x0,0
# jal x4, jmp
# addi x5,x0, 23
# addi x6,x0, 11
# jmp: 
# addi x5, x0, 7
# addi x6, x0, 9
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
