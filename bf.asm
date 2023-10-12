	.data
prompt:	.asciiz "Enter BF program: "
program:
	.space 30000
data:	.space 30000

	.text
start:	move $t0, $zero
clear_arrays:
	sb $zero, program($t0)
	sb $zero, data($t0)
	addi $t0, $t0, 1
	blt $t0, 30000, clear_arrays
read_line:
	la $a0, prompt
	li $v0, 4
	syscall
	la $a0, program
	li $a1, 30000
	li $v0, 8
	syscall
	la $s0, program			# $s0 = instruction pointer
	la $s1, data			# $s1 = data pointer
loop:	lb $t0, ($s0)
	add $s0, $s0, 1
	beqz $t0, start
	beq $t0, '>', increment_dp
	beq $t0, '<', decrement_dp
	beq $t0, '+', increment
	beq $t0, '-', decrement
	beq $t0, '.', output
	beq $t0, ',', input
	beq $t0, '[', jump_forward
	beq $t0, ']', jump_backward
	b loop

increment_dp:
	addi $s1, $s1, 1
	b loop

decrement_dp:
	subi $s1, $s1, 1
	b loop

increment:
	lb $t0, ($s1)
	addi $t0, $t0, 1
	sb $t0, ($s1)
	b loop

decrement:
	lb $t0, ($s1)
	subi $t0, $t0, 1
	sb $t0, ($s1)
	b loop

output:	lb $a0, ($s1)
	li $v0, 11
	syscall
	b loop

input:	li $v0, 12
	syscall
	sb $v0, ($s1)
	b loop

jump_forward:
	lb $t0, ($s1)
	bnez $t0, loop
	move $t1, $zero			# $t1 = bracket depth
	find_forward_bracket:
		lb $t0, ($s0)
		addi $s0, $s0, 1
		beq $t0, '[', increase_forward_depth
		beq $t0, ']', decrease_forward_depth
		b find_forward_bracket
	increase_forward_depth:
		addi $t1, $t1, 1
		b find_forward_bracket
	decrease_forward_depth:
		beqz $t1, loop
		subi $t1, $t1, 1
		b find_forward_bracket

jump_backward:
	lb $t0, ($s1)
	beqz $t0, loop
	subi $s0, $s0, 2
	move $t1, $zero
	find_backward_bracket:
		lb $t0, ($s0)
		subi $s0, $s0, 1
		beq $t0, ']', increase_backward_depth
		beq $t0, '[', decrease_backward_depth
		b find_backward_bracket
	increase_backward_depth:
		addi $t1, $t1, 1
		b find_backward_bracket
	decrease_backward_depth:
		beqz $t1, end_jump_backward
		subi $t1, $t1, 1
		b find_backward_bracket
	end_jump_backward:
		addi $s0, $s0, 2
		b loop