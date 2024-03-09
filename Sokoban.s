.data
character:  .byte 0,0,0,0
box:        .byte 0,0,0,0
target:     .byte 0,0,0,0
WALL_COLOR: .word 0x808000  #Olive
CHARACTER_COLOR: .word 0x2895FF #blue
BOX_COLOR: .word 0xDAA520 #orange
TARGET_COLOR: .word 0xD69585 #pink
GROUND_COLOR: .word 0xDED6AE #Khaki
FINISH_LINE: .string "Good Job!\n"
FAIL_LINE: .string "It's okay, do better next round!\n"
ASK_REMAKE: .string "Would you like to skip this round? (Enter 0-Yes, Anything else-No): "
ASK_EXIT: .string "Would you like to continue to the next round? (Enter 0-Yes, Anything else-No): "
ASK_PLAYER: .string "How many players do you have(Recommand around 1-5): "
RESULT_FOR: .string "\n       Result for round "
CRESULT_FOR: .string "   Cumulative Leaderboard "
LEADING: .string " is leading the game!!\n"
WINNER: .string " is the winner!!\n"
MWINNER: .string " are the winners!!\n"
ENDDING: .string "================================\n"
HEADING: .string "\n================================"
NEWLINE: .string "\n"
PLAYER: .string " Player"
SCOURE: .string "    Moves made: "
FAIL: .string "    FAIL"
CURRENT1: .string "\nNow is Player"
CURRENT2: .string " turn!\n"
NEWROUND1: .string "\n\nRound "
NEWROUND2: .string " started!!!\n"
LCG_A: .word 0x41C64E6D #LCG Multiplier
LCG_C: .word 0x6073     #LCG Increment
LCG_M: .word 0xFFFFFFFF #LCG Modulus
LCG_S: .word 0x00     #LCG Seed
Brk_P: .word 0x20000000
Lead_P: .word 0         #Break point for leaderBoard
Sort_P: .word 0         #Break point for sorted leaderBoard
Num_play: .word 0x00000 #Numbers of player
Cur_play: .word 0x00000 #Current player
Cur_Move: .word 0x00000 #Cur player move
Round_played: .word 0   #Numbers of round played

.globl main
.text

Malloc_Ask_#Players:
    li a7 4  #Ask the user to input the number of player
    la a0 ASK_PLAYER
    ecall
    call readInt
    
    la a1, Num_play  #Store the number of player into DATA
    sw a0, 0(a1)
    
    
    li t0, 4  #Malloc Memory in heap base on the number of player
    mul t0, a0, t0
    li a7 214  #Sys call brk()
    lw a0, Brk_P

    
    add a0, t0, a0
    la t1, Lead_P
    sw a0, 0(t1) #save the Break point for cumulatives board leaderBoard
    add a0, t0, a0
    la t1, Sort_P  #save the Break point for sorted cumulatives board leaderBoard
    sw a0, 0(t1) 
    add a0, t0, a0
    add a0, t0, a0
    ecall
    
    bne a0, zero, exit #Check if malloc successfully
    
Setup_rand: #randomlize the seed value to make everytime the game is different
li a0 0xFFFFFFFF
jal ra, randOld
la t1, LCG_S
sw a0, 0(t1)

main:
    # TODO: Before we deal with the LEDs, generate random locations for
    # the character, box, and target. static locations have been provided
    # for the (x,y) coordinates for each of these elements within the 8x8
    # grid. 
    # There is a rand function, but note that it isn't very good! You 
    # should at least make sure that none of the items are on top of each
    # other. 


la t1, box
la t2, target
la t3, character
lw t6, LCG_S
Get_Box:   
    li a0, 5
    jal ra, rand
    addi a0, a0, 1
    
    sb a0, 0(t1)
    sb a0, 2(t1)
    lb a2, 0(t1) #get first value of cha
    
    li t4, 1
    li t5, 6
    beq a2, t4, sp_box #check if the box locate aganst the x_wall
    bne a2, t5, commen_box
    
sp_box: #if the box locate aganst the wall
    li a0, 5
    jal ra, rand
    addi a0, a0, 1
    sb a0, 1(t1)
    sb a0, 3(t1)
    lb a3, 1(t1) #get second value of box  
    
    li t4, 1
    li t5, 6
    beq a3, t4, Get_Box  # check if the box is at the corner
    beq a3, t5, Get_Box
    j Get_sp_target_x
    
commen_box:
    li a0, 5
    jal ra, rand
    addi a0, a0, 1   
    sb a0, 1(t1)
    sb a0, 3(t1)
    lb a3, 1(t1) #get second value of box
    
    li t4, 1
    li t5, 6
    beq a3, t4, Get_sp_target_y #check if the box locate aganst the y_wall
    beq a3, t5, Get_sp_target_y
    j Get_target 
    
#special get_target case when box is against the x_wall    
Get_sp_target_x:
    sb a2, 0(t2)
    sb a2, 2(t2)
    li a0, 5
    jal ra, rand
    addi a0, a0, 1
    sb a0, 1(t2)
    sb a0, 3(t2)
    
    lb a4, 0(t2) #get first value of target
    lb a5, 1(t2) #get second value of target
    
    bne a3, a5, Get_character
    j Get_sp_target_x

#special get_target case when box is against the y_wall
Get_sp_target_y:    
    sb a3, 1(t2)
    sb a3, 3(t2)
    li a0, 5
    jal ra, rand
    addi a0, a0, 1
    sb a0, 0(t2)
    sb a0, 2(t2)
    
    lb a4, 0(t2) #get first value of target
    lb a5, 1(t2) #get second value of target
    
    bne a2, a4, Get_character
    j Get_sp_target_y

#Regular get_target case 
Get_target:      
    li a0, 5
    jal ra, rand
    addi a0, a0, 1
    sb a0, 0(t2)
    sb a0, 2(t2)
    li a0, 5
    jal ra, rand
    addi a0, a0, 1
    sb a0, 1(t2)
    sb a0, 3(t2)
    
    lb a4, 0(t2) #get first value of box
    lb a5, 1(t2) #get second value of box
    
    bne a2, a4, Get_character
    bne a3, a5, Get_character
    j Get_target

Get_character:  
    li a0, 5
    jal ra, rand
    addi a0, a0, 1
    sb a0, 0(t3)
    sb a0, 2(t3)
    li a0, 5
    jal ra, rand
    addi a0, a0, 1
    sb a0, 1(t3)
    sb a0, 3(t3)
    
    lb a6, 0(t3) #get first value of target
    lb a7, 1(t3) #get second value of target
    
    bne a2, a6, Check_pos #check target and cha
    bne a3, a7, Check_pos
    j Get_character
    
Check_pos: 
    bne a6, a4, Done_pos #check target and box
    bne a7, a5, Done_pos
    j Get_character

Done_pos: 
   
    # TODO: Now, light up the playing field. Add walls around the edges
    # and light up the character, box, and target with the colors you have
    # chosen. (Yes, you choose, and you should document your choice.)
    # Hint: the LEDs are an array, so you should be able to calculate 
    # offsets from the (0, 0) LED.

# Clear the grid
li t3, 0
li t2, 7
lw a0, GROUND_COLOR
Clear_Grid_xf:
    addi t3, t3, 1
    bge t3, t2, Clear_DONEf
    li t4, 0
    mv a1, t3
Clear_Grid_yf:
    addi t4, t4, 1
    bge t4, t2, Clear_Grid_xf
    mv a2, t4
    jal setLED
    j Clear_Grid_yf
Clear_DONEf:
    
    
li t3, 8 # Setup for wall when x=0
li a1, 0 # x value
lw a0, WALL_COLOR
    
Set_WallColor:
    addi t3, t3, -1  # loop for x=0
    mv a2, t3
    jal ra, setLED
    
    bne t3, zero, Set_WallColor 
    
WallColor_row1_set:  
    li t3, 8  # Setup for wall when x=7
    li a1, 7  # x value
WallColor_row1:  
    addi t3, t3, -1 # loop for x=7
    mv a2, t3  
    jal ra, setLED
    
    bne t3, zero, WallColor_row1

WallColor_col1_set:
    li t3, 7  # Setup for wall when y=0
    li a2, 0
    li t4, 1
WallColor_col1:
    addi t3, t3, -1  # loop for y=0
    mv a1, t3
    jal ra, setLED
    
    bne t3, t4, WallColor_col1
    
WallColor_col2_set:
    li t3, 7  # Setup for wall when y=7
    li a2, 7
WallColor_col2:
    addi t3, t3, -1  # loop for y=7
    mv a1, t3
    jal ra, setLED
    
    bne t3, t4, WallColor_col2
 
Light_character:
    la t1, character
    lb a1, 0(t1) #get first value of cha
    lb a2, 1(t1) #get second value of cha
    lw a0, CHARACTER_COLOR
    jal ra, setLED
Light_box:
    la t1, box
    lb a1, 0(t1) #get first value of box
    lb a2, 1(t1) #get second value of box
    lw a0, BOX_COLOR
    jal ra, setLED
Light_target:
    la t1, target 
    lb a1, 0(t1) #get first value of target
    lb a2, 1(t1) #get second value of target
    lw a0, TARGET_COLOR
    jal ra, setLED
    

    # TODO: Enter a loop and wait for user input. Whenever user input is
    # received, update the grid with the new location of the player (and if applicable, box and target). You will also need to restart the
    # game if the user requests it and indicate when the box is located
    # in the same position as the target.
Print_round:
    li a7, 4
    la a0 NEWROUND1
    ecall
    
    li a7, 1
    lw a0, Round_played
    addi a0, a0, 1
    ecall
    
    li a7, 4
    la a0 NEWROUND2
    ecall
    
Mulpti_player_Loop:
    la t5, Cur_Move #Reset Player move to 0
    sw zero, 0(t5)
    
    lw t5, Cur_play # Check if everyone is finish
    lw t4, Num_play
    bge t5, t4, DisplayResult #If everyone finished this round, display the result
    addi t5, t5, 1
    la t4, Cur_play # Update current player in DATA
    sw t5, 0(t4)
    
    li a7, 4
    la a0 CURRENT1
    ecall
    
    li a7, 1
    mv a0, t5
    ecall
    
    li a7, 4
    la a0 CURRENT2
    ecall
    
la t4, character
lb a5, target
lb a6, target+1
Game_Loop:
    jal pollDpad
    
    la t5, Cur_Move #Current player move +1
    lw t1, Cur_Move
    addi t1, t1, 1
    sw t1, 0(t5)
    
    la t5, box
    lb a3, 0(t5)
    lb a4, 1(t5)
    li t1, 1
    li t2, 2
    li t3, 3
    beq a0, t3, Go_right
    beq a0, t2, Go_left
    beq a0, t1, Go_down
Go_up:
    lb a2, 1(t4) # y for cha
    li a7, 1
    beq a2, a7, Ask_Remake # Bounds the wall then ask the player if they want to restart
    
    lb a1, 0(t4) # x for cha
    addi a2, a2, -1
    
    jal Check_Bounds
    bne a0, zero, No_box_up
    
    beq a4, a7, Game_Loop # Hit the box but it is not movable
    # Now we know it pushed the box, update all the value
    sb a2, 1(t4) # save new player pos on DATA
    addi a4, a4, -1    
    la t5, box
    sb a4, 1(t5) # save new box pos on DATA
    
    lw a0, CHARACTER_COLOR
    jal setLED
    
    addi a2, a2, 1
    jal Check_Cover_target #check if it is not TARGET pos
    
    addi a2, a2, -2
    lw a0, BOX_COLOR
    jal setLED
    
    j Check_Status
No_box_up:
    sb a2, 1(t4) #Update player pos on Data, Grid
    addi a2, a2, 1
    jal Check_Cover_target
    
    j Game_Loop
        
Go_down:
    lb a2, 1(t4) # y for cha
    li a7, 6
    beq a2, a7, Ask_Remake # Bounds the wall then ask the player if they want to restart
    
    lb a1, 0(t4) # x for cha
    addi a2, a2, 1
    
    jal Check_Bounds
    bne a0, zero, No_box_down
    beq a4, a7, Game_Loop # Hit the box but it is not movable
    
    # Now we know it pushed the box, update all the value
    sb a2, 1(t4) # save new player pos on DATA
    addi a4, a4, 1    
    la t5, box
    sb a4, 1(t5) # save new box pos on DATA
    
    lw a0, CHARACTER_COLOR
    jal setLED
    
    addi a2, a2, -1
    jal Check_Cover_target  #CHECK IF IT IS NOT TARGET pos
    
    addi a2, a2, 2
    lw a0, BOX_COLOR
    jal setLED
    
    j Check_Status
No_box_down:
    sb a2, 1(t4) #Update player pos on Data, Grid
    addi a2, a2, -1
    
    jal Check_Cover_target
    j Game_Loop 
    
Go_left:
    lb a1, 0(t4) # x for cha
    li a7, 1
    beq a1, a7, Ask_Remake # Bounds the wall then ask the player if they want to restart
    
    lb a2, 1(t4) # y for cha
    addi a1, a1, -1
    
    jal Check_Bounds
    bne a0, zero, No_box_left
    
    beq a3, a7, Game_Loop # Hit the box but it is not movable
    # Now we know it pushed the box, update all the value
    sb a1, 0(t4) # save new player pos on DATA
    addi a3, a3, -1 
    la t5, box   
    sb a3, 0(t5) # save new box pos on DATA
    
    lw a0, CHARACTER_COLOR
    jal setLED
    
    addi a1, a1, 1
    jal Check_Cover_target #check if it is not TARGET pos
    
    addi a1, a1, -2
    lw a0, BOX_COLOR
    jal setLED
    
    j Check_Status
No_box_left:
    sb a1, 0(t4) #Update player pos on Data, Grid
    addi a1, a1, 1
    jal Check_Cover_target
    
    j Game_Loop
    
Go_right:
    lb a1, 0(t4) # x for cha
    li a7, 6
    beq a1, a7, Ask_Remake # Bounds the wall then ask the player if they want to restart
    
    lb a2, 1(t4) # y for cha
    addi a1, a1, 1
    
    jal Check_Bounds
    bne a0, zero, No_box_right
    
    beq a3, a7, Game_Loop # Hit the box but it is not movable
    # Now we know it pushed the box, update all the value
    sb a1, 0(t4) # save new player pos on DATA
    addi a3, a3, 1  
    la t5, box  
    sb a3, 0(t5) # save new box pos on DATA
    
    lw a0, CHARACTER_COLOR
    jal setLED
    
    addi a1, a1, -1
    jal Check_Cover_target #check if it is not TARGET pos
    
    addi a1, a1, 2
    lw a0, BOX_COLOR
    jal setLED
    
    j Check_Status
No_box_right:
    sb a1, 0(t4) #Update player pos on Data, Grid
    addi a1, a1, -1
    jal Check_Cover_target
    
    j Game_Loop 
    
DisplayResult:
    la t1, Round_played #Round +1
    lw t2, Round_played
    addi t2, t2, 1
    sw t2, 0(t1)
    
    la t1, Cur_play # Reset Current player to 0
    sw zero, 0(t1)
    
    li a7, 4
    la a0, HEADING
    ecall
    
    li a7, 4
    la a0, RESULT_FOR
    ecall
    
    li a7, 1
    mv a0, t2
    ecall
    
    li a7, 4
    la a0, NEWLINE
    ecall 
    
    lw t1, Num_play
    li t2, 0
    li a1, -1
Result_Loop:
    bge t2, t1, End_Result
    
    addi t2, t2, 1
    
    li a7, 4
    la a0, PLAYER
    ecall
    
    li a7, 1
    mv a0, t2
    ecall
    
    lw t5, Brk_P
    addi t4, t2, -1
    li t3, 4
    mul t4, t3, t4
    add t5, t5, t4
    lw a2, 0(t5)
    beq a2, a1, fail_case
    
    li a7, 4
    la a0, SCOURE
    ecall
    
    li a7, 1
    mv a0, a2
    ecall
  
    li a7, 4
    la a0, NEWLINE
    ecall  
    
    j Result_Loop   
fail_case:
    li a7, 4
    la a0, FAIL
    ecall  
    
    li a7, 4
    la a0, NEWLINE
    ecall  
    
    j Result_Loop
End_Result:
    li a7, 4
    la a0, ENDDING
    ecall
    jal Print_Com
    jal Sort
    jal Print_sort
    
    li a7, 4
    la a0, ASK_EXIT
    ecall
    
    call readInt
    bne a0, zero, Exit_move
    
    j main
Exit_move:
    li a7, 4
    la a0, PLAYER
    ecall
    
    lw a4, Sort_P
    li a7, 1
    lw a0, 0(a4)
    ecall
    
    lw a1, 4(a4)
    lw a2,12(a4)
    beq a1, a2, Mul_win
    
    li a7, 4
    la a0, WINNER
    ecall
    
    j Done_ENDGAME
Mul_win:
    addi a4, a4, 8
    
    li a7, 4
    la a0, PLAYER
    ecall
    
    li a7, 1
    lw a0, 0(a4)
    ecall
    
    lw a1, 4(a4)
    lw a2,12(a4)
    beq a1, a2, Mul_win
    
    li a7, 4
    la a0, MWINNER
    ecall

Done_ENDGAME:
    j exit
    

    
Ask_Remake:
    li a7, 4
    la a0, ASK_REMAKE
    ecall
    
    call readInt
    bne a0, zero, Game_Loop
    
    jal Clear_Grid
    jal Relightup
    
    li t1, -1 # Store the player score into heap
    lw t5, Brk_P
    lw t2, Cur_play
    addi t2, t2, -1
    li t3, 4
    mul t2, t3, t2
    add t5, t5, t2
    sw t1, 0(t5)
    
    lw t4, Lead_P 
    add t4, t4, t2 # Store the player score into cmulative board
    lw t5, 0(t4)
    li t1, 20 #if fail, set the round move to 20
    add t1, t5, t1
    sw t1, 0(t4)
    
    li a7, 4 #Print the fail line to stdout
    la a0 FAIL_LINE
    ecall
    
    j Mulpti_player_Loop
    
Check_Status:
    la t5, box
    lb a3, 0(t5)
    lb a4, 1(t5)
    bne a3, a5, Not_win_yet
    bne a4, a6, Not_win_yet
    
    li a7, 4
    la a0, FINISH_LINE
    ecall
    
    jal Clear_Grid
    jal Relightup
    
    lw t1, Cur_Move # Store the player score into heap
    lw t5, Brk_P
    lw t2, Cur_play

    addi t2, t2, -1
    li t3, 4
    mul t2, t3, t2
    add t5, t5, t2
    sw t1, 0(t5)
    
    lw t4, Lead_P 
    add t4, t4, t2 # Store the player score into cmulative board
    lw t5, 0(t4)
    add t1, t5, t1
    sw t1, 0(t4)
    
    
    
    j Mulpti_player_Loop
    
Not_win_yet:
    j Game_Loop

    # TODO: That's the base game! Now, pick a pair of enhancements and
    # consider how to implement them.
 
exit:
    li a7, 10
    ecall
    
    
# --- HELPER FUNCTIONS ---
# Feel free to use (or modify) them however you see fit

#Print the Leaderboard
Print_sort:
    li a7, 4
    la a0, CRESULT_FOR
    ecall
    
    li a7, 4
    la a0, NEWLINE
    ecall 
    
    lw t1, Num_play
    li t2, 0
    lw t5, Sort_P
PSort_Loop:
    bge t2, t1, End_Ps
    
    addi t2, t2, 1
    
    li a7, 4
    la a0, PLAYER
    ecall
    
    li a7, 1
    lw a0, 0(t5)
    ecall
    
    li a7, 4
    la a0, SCOURE
    ecall
    
    li a7, 1
    lw a0, 4(t5)
    ecall
    
    addi t5, t5, 8
  
    li a7, 4
    la a0, NEWLINE
    ecall  
    
    j PSort_Loop   
End_Ps:
    li a7, 4
    la a0, ENDDING
    ecall
    
    jr ra

# sort the player point
Sort:
    lw a0, Sort_P 
    addi a0, a0, 4
    lw a1, Num_play
Start_sort:
    li t0, 0 # swapped = false
    li t1, 1
First_sort:
    bge t1, a1, end_sort
    slli t3, t1, 3
    add t3, a0, t3
    lw t4, -8(t3) # i - 1
    lw t5, 0(t3) # i
    bge t5, t4, next_sort
    li t0, 1 # swapped = true
    sw t4, 0(t3)
    sw t5, -8(t3)
    lw t4, -4(t3)
    lw t5, -12(t3)
    sw t4, -12(t3)
    sw t5, -4(t3)
next_sort:
    addi t1, t1, 1
    j First_sort
end_sort:
    bnez t0, Start_sort
    jr ra

# Print the cumulative board
Print_Com:
    lw t1, Num_play
    li t2, 0
    lw a4, Sort_P
Com_Loop:
    bge t2, t1, End_Com
    
    addi t2, t2, 1
    
    sw t2, 0(a4) # save the player number into sort arry in heap
    
    li t4, 0
    lw t5, Lead_P
    addi t4, t2, -1
    li t3, 4
    mul t4, t3, t4
    add t5, t5, t4
    lw a2, 0(t5)

    sw a2, 4(a4)# save the player sore into sort arry in heap
    
    addi a4, a4, 8 # update address
    
    j Com_Loop   
End_Com:  
    jr ra

#Reset the grid for the next player
Relightup:
ReLight_character:
    la t1, character
    lb a1, 2(t1) #get first value of cha
    lb a2, 3(t1) #get second value of cha
    sb a1, 0(t1)
    sb a2, 1(t1)
    lw a0, CHARACTER_COLOR
    addi sp, sp, -4
    sw ra, 0(sp)
    jal setLED
    lw ra, 0(sp)
    addi sp, sp, 4
ReLight_box:
    la t1, box
    lb a1, 2(t1) #get first value of box
    lb a2, 3(t1) #get second value of box
    sb a1, 0(t1)
    sb a2, 1(t1)
    lw a0, BOX_COLOR
    addi sp, sp, -4
    sw ra, 0(sp)
    jal setLED
    lw ra, 0(sp)
    addi sp, sp, 4
ReLight_target:
    la t1, target
    lb a1, 2(t1) #get first value of box
    lb a2, 3(t1) #get second value of box
    sb a1, 0(t1)
    sb a2, 1(t1)
    lw a0, TARGET_COLOR
    addi sp, sp, -4
    sw ra, 0(sp)
    jal setLED
    lw ra, 0(sp)
    addi sp, sp, 4    
Done_Relight:
    jr ra
    
# Clear the grid
Clear_Grid:
li t3, 0
li t2, 7
lw a0, GROUND_COLOR
Clear_Grid_x:
    addi t3, t3, 1
    beq t3, t2, Clear_DONE
    li t4, 0
    mv a1, t3
Clear_Grid_y:
    addi t4, t4, 1
    bge t4, t2, Clear_Grid_x
    mv a2, t4
    addi sp, sp, -4
    sw ra, 0(sp)
    jal setLED
    lw ra, 0(sp)
    addi sp, sp, 4
    j Clear_Grid_y
Clear_DONE:
    jr ra
    
# if there is a box return 0, else, udate player new pos on Grid and return 1
Check_Bounds:
    bne a1, a3, Check_No_BoxDone
    bne a2, a4, Check_No_BoxDone
    
    li a0, 0
    jr ra
Check_No_BoxDone:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    lw a0, CHARACTER_COLOR # undate new pos on grid
    jal setLED
    
    lw ra, 0(sp)
    addi sp, sp, 4
    li a0, 1
    jr ra
    
Check_Cover_target:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    bne a1, a5, No_Cover_Target
    bne a2, a6, No_Cover_Target
    
    lw a0, TARGET_COLOR
    jal setLED
    
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
No_Cover_Target:
    lw a0, GROUND_COLOR
    jal setLED
    
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

rand:
    lw t4, LCG_M
    lw t5, LCG_A
    mul t6, t6, t5
    lw t5, LCG_C
    add t6, t6, t5
    remu t6, t6, t4
    la t4, LCG_S
    sw t6, 0(t4)
    
    remu a0, t6, a0
    jr ra
    
# Takes in a number in a0, and returns a (sort of) (okay no really) random 
# number from 0 to this number (exclusive)
randOld:
    mv t0, a0
    li a7, 30
    ecall
    remu a0, a0, t0
    jr ra
    
# Takes in an RGB color in a0, an x-coordinate in a1, and a y-coordinate
# in a2. Then it sets the led at (x, y) to the given color.
setLED:
    li t1, LED_MATRIX_0_WIDTH
    mul t0, a2, t1
    add t0, t0, a1
    li t1, 4
    mul t0, t0, t1
    li t1, LED_MATRIX_0_BASE
    add t0, t1, t0
    sw a0, (0)t0
    jr ra
    
# Polls the d-pad input until a button is pressed, then returns a number
# representing the button that was pressed in a0.
# The possible return values are:
# 0: UP
# 1: DOWN
# 2: LEFT
# 3: RIGHT
pollDpad:
    mv a0, zero
    li t1, 4
pollLoop:
    bge a0, t1, pollLoopEnd
    li t2, D_PAD_0_BASE
    slli t3, a0, 2
    add t2, t2, t3
    lw t3, (0)t2
    bnez t3, pollRelease
    addi a0, a0, 1
    j pollLoop
pollLoopEnd:
    j pollDpad
pollRelease:
    lw t3, (0)t2
    bnez t3, pollRelease
pollExit:
    jr ra

#Read player input from stdin
readInt:
    addi sp, sp, -12
    li a0, 0
    mv a1, sp
    li a2, 12
    li a7, 63
    ecall
    li a1, 1
    add a2, sp, a0
    addi a2, a2, -2
    mv a0, zero
parse:
    blt a2, sp, parseEnd
    lb a7, 0(a2)
    addi a7, a7, -48
    li a3, 9
    mul a7, a7, a1
    add a0, a0, a7
    li a3, 10
    mul a1, a1, a3
    addi a2, a2, -1
    j parse
parseEnd:
    addi sp, sp, 12
    ret
