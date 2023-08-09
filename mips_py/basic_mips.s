# $t4 stores constant I/O address of LEDs (255)
addi $t4, $t4, 255
# $t3 stores final LED register value of 16
addi $t3, $t3, 16

# $t0 stores current LED I/O register value, initialized to 1
addi $t0, $zero, 2

# On every loop iteration:
# Set LED I/O register
sw $t0, 0($t4)
# Check if we've reached last LED, and if so reset to top
beq $t0, $t3, -3
# Otherwise, move to next LED
sll $t0, $t0, 1
# Jump back to start of loop
beq $zero, $zero, -4
