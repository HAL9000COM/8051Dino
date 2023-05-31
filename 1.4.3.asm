;#######################---V1.3 Goals---####################

;/ Adding welcome and death music(finished)
;/ Adding multiple barricade random generating system(finished in V1.3.3)
;/ Adding score evaluation system(finished in V1.3.9)
;/ get over 1000 lines of code (gave up)

;#############################################################
;work normally, no change between dino characters, anti-long press, disappear when step on the barricade(Bug?) (Ability!!)

;V1.3.1
;Comment by HAL at 15-Nov-2019 13:43BJT
;standardized var named
;comments waiting translation
;custom dino char accomplished
;Rand working perfectly but loop too fast
;Change code from GB2312 to UTF-8

;V1.3.2
;Adding new record page
;Adding welcome page

;2019-11-16
;V1.3.3
;Adding bird(lots of Bug)
;1.The score and forward became subroutines for different types of barricade.
;2.The upper change is unusable, the rollback didn't preformed due to lazy dev.

;2019-11-20
;V1.3.3b
;use the front of GRAM for bird death decision
;Jump to "fall" subroutine when the ground barricade reaches the end
;Change the interval to ;50(Too long

;2019-11-21
;V1.3.3c
;Adding label :timelimit adjust forward time
;Adjust minimum interval,20(Short:24(properly;26(a little long;30(long;40(long
;The bird only generates after get 10 score (label:bird after score 10)

;V1.3.4  (2019-12-3)
;Change the jump key to external interrupt EX0
;sw change to p3.2
;abnormal location changes????

;V1.3.5  (3.Dec.2019)-HAL
;beep sound subroutine finished
;custom char for barr and bird(actually an airplane)
;

;V1.3.6  (4.Dec.2019)
;simplified the program
;corrected some language mistakes
;

;V1.3.7  (4.Dec.2019)
;add comment of score
;change some display sentence
;

;V1.3.8  (5.Dec.2019)
;Adding score evaluation system
;

;V1.3.9  (5.Dec.2019)
;simplify the score evaluation system(the display of the second row is now subroutine)
;fix the game over music bug
;Auto trigger of keys?(both in interrupt and pulling version) (Hardware problem!)
;

;;#########################################################
;DinoJumpX (build V1.4.0)
;Comment by HAL at 7-Dec-2019 14:38BJT
;rollback of disp init sequence
;change "K1" to "Press"
;change names of some variables and labels
;Early Access end
;release version
;Ready to distribute

;DinoJumpX (build V1.4.1)
;Comment by G at 7-Dec-2019 23:42BJT
;
;adding the running animation (Ability: Stop when the plane reaches the end QAQ)
;optimization of some codes
;

;DinoJumpX (build V1.4.2)
;Comment by HAL at 11-Dec-2019 23:13BJT
;You can get a Trophy Cup after breaking the record

;v1.4.3
;translate and grammar

org 0000h
ljmp start ;avoid interrupt area
org 0003h
ljmp dino_jump
org 0030h
start:

snd          EQU P1.0
sw           EQU P3.2

rs           EQU P2.6
rw           EQU P2.5
en           EQU P2.7

jump_state   EQU 20H
Bar_flag     EQU 21H
sw_long_flag EQU 22H
new_rec_flag EQU 23H
BIRD_FLAG    EQU 24H
snd_flag     EQU 25H

main_timer   EQU 30H
jmp_timer    EQU 31H
FWD_timer    EQU 32H
FWD_timeset  EQU 33H
Bar_loc      EQU 34H
score_lo     EQU 35H
jmp_timeset  EQU 36H
in_rand_reg  EQU 37H
Bar_timeset  EQU 38H
score_hi     EQU 39H
snd_hi       EQU 3AH
snd_lo       EQU 3BH
snd_time     EQU 3CH
snd_counter  EQU 3DH
rand_seed    EQU 3EH
Top_score_lo EQU 40H
Top_score_hi EQU 41H

;init ex0
setb ea
setb it0

CLR rs
CLR rw
CLR en
LCALL Disp_init
LCALL Disp_char_init
mov rand_seed,#02h ;random seed

;;;;;;;;;;;;;Start page "PRESS TO PLAY 'DINO' DINO JUMP ^_^"
MOV R2,#20H
MOV DPTR,#Start_dat
MOV R0,#00H
MOV R1,#60H
start_Gram_counter:
MOV A,R0
MOVC A,@A+DPTR
MOV @R1,A
INC R0
INC R1
DJNZ R2,start_Gram_counter
lcall Disp_refresh

JB sw,$;waiting for key press

;;;;;;;;;;;;;;;;;;Welcome page "ENJOY YOURSELF --CERBERUS"
MOV R2,#20H
MOV DPTR,#Welcome_dat
MOV R0,#00H
MOV R1,#60H
Welcome_Gram_counter:
MOV A,R0
MOVC A,@A+DPTR
MOV @R1,A
INC R0
INC R1
DJNZ R2,Welcome_Gram_counter
lcall Disp_refresh
lcall snd_play
SETB  snd_flag

;;;;;;;;;;;;;;;;;;Welcome page>>>>>>>

;;;;;;;;;;;;;;;;;;;;initialization of the data after fire up
clr jump_state
clr Bar_flag
mov main_timer,#0D
mov score_lo,#30H    ;BCD 0
mov score_hi,#30H    ;BCD 0
mov Top_score_lo,#30H;BCD 0
mov Top_score_hi,#30H;BCD 0 HD44780style
mov jmp_timeset,#30H
mov Bar_timeset,#80D;;;;;;;;;;;;;;;

MOV 5FH,#20H;For the bird death decision
;;;;;;;;;;;;;;;;;;;;;;;initialization of the game graphics
MOV R2,#20H
MOV DPTR,#init_clear_dat
MOV R0,#00H
MOV R1,#60H
Clear_Gram_counter:
MOV A,R0
MOVC A,@A+DPTR
MOV @R1,A
INC R0
INC R1
DJNZ R2,Clear_Gram_counter
lcall Disp_refresh
;;;;;;;;;;;;;;;;;;;;;;;;;start the game
main:
setb ea
setb ex0

;;;;;;;;;;;;;;;;;;;;;move part<<<<<<<<<<<<<<<<<<<<<
jb Bar_flag,have;jump when there is barricade

;bird after score 10
clr c
mov a,score_hi
add a,#0cfh
jnc produce_bar;>>>>>>>>

jnb BIRD_FLAG,no_bird;jump when there is no bird

ljmp bird

no_bird:
lcall rand
mov in_rand_reg,A;in_rand_reg is random

clr c
mov a,in_rand_reg
add a,#125;changable#######################
jnc produce_bar ;big enough?#####generates bird when lesser than setting
;generates bird:
ljmp produce_bird
produce_bar:
;generates barricade
mov 7fh,#02h;barricade
setb Bar_flag
mov Bar_loc,#7fh
mov FWD_timer,main_timer

mov a,main_timer
add a,Bar_timeset
mov FWD_timeset,a;FWD_timeset=main_timer+Bar_timeset


mov r0,Bar_timeset

clr c;<<<<
mov a,Bar_timeset
timelimit:		subb a,#25;2+1
jc not_dec;limit the minimum forward time interval to 2>>>

dec Bar_timeset
dec Bar_timeset
not_dec:

ljmp fall

have:
mov a,FWD_timer
cjne a,FWD_timeset,notmove;FWD_timer=FWD_timeset?

mov a,main_timer
add a,Bar_timeset
mov FWD_timeset,a;FWD_timeset=main_timer+Bar_timeset


mov a,Bar_loc
cjne a,#70h,Not_end;to the end?
clr Bar_flag

mov 70h,#20H;################################
mov Bar_loc,#80H;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ljmp fall

not_end:

mov r0,Bar_loc
dec r0
cjne @r0,#20H,die;die?
jmp $+5
die:	ljmp gameover

mov a,Bar_loc
clr c
subb a,#10h
mov r0,a;;;;;;r0=Bar_loc-#10h
cjne @r0,#00H,not_plus_one

lcall add_score

not_plus_one:

lcall move_forward

notmove:
inc FWD_timer
;;;;;;;;;;;;;;;;;;;;;move part  >>>>>>>

;;;;;;;;;;;;;;;;;;;;fall part  <<<<<<<<<<
fall:
mov a,jmp_timer
cjne a,jmp_timeset,notfall
mov 71h,#00H
mov 61h,#20H

lcall Disp_refresh

clr jump_state
notfall:

;;;;;;;;;;;;;;;;;;;;fall part  >>>>>>>>>>

lcall delay_long
;;;;;delay?
inc main_timer
inc jmp_timer
ljmp main
;;;;;;;;;;;;;;;;;;;;;;;;;gameover, display the score
gameover:
clr ea
clr ex0;turn off ex0

;;;;;;;;;;;;;new record decision<<<<<
jnb new_rec_flag,no_record

;display the new record
MOV R2,#10H
MOV DPTR,#NEWRECORD_dat
MOV R0,#00H
MOV R1,#60H
Nrec_Gram_counter:
MOV A,R0
MOVC A,@A+DPTR
MOV @R1,A
INC R0
INC R1
DJNZ R2,Nrec_Gram_counter

MOV 6EH,score_hi
MOV 6FH,score_lo
;display the evaluation
lcall evaluation
lcall Disp_refresh
lcall snd_play

jmp main_initialize
;;;;;;;;;;;;;new record decision>>>>>
no_record:

MOV 60H,#20H;
MOV 61H,#54H;T
MOV 62H,#4FH;o
MOV 63H,#50H;p
mov 64h,#3AH;:
mov 65h,Top_score_hi;
mov 66h,Top_score_lo;
mov 67h,#20H;
mov 68h,#20H;
mov 69h,#59H;Y
mov 6Ah,#4FH;O
mov 6Bh,#55H;U
MOV 6CH,#3AH;:
MOV 6DH,score_hi
MOV 6EH,score_lo
MOV 6FH,#20H

lcall Evaluation
lcall Disp_refresh
lcall snd_play
;;;;;;;;;;;;;;;;;;;;;;;;initialization the data
main_initialize:

clr jump_state
clr Bar_flag
mov main_timer,#0
mov score_lo,#30H
mov jmp_timeset,#30H
mov in_rand_reg,#30H
mov Bar_timeset,#80;;3##########################changeable
mov score_hi,#30H

clr new_rec_flag
clr BIRD_FLAG
;;;;;;;;;;;;;;;;;;;;;;;;;press key to continue
JB sw,$

;;;;clear
MOV R2,#20H
MOV DPTR,#init_clear_dat
MOV R0,#00H
MOV R1,#60H
CLEARSHOW_Gram_counter:
MOV A,R0
MOVC A,@A+DPTR
MOV @R1,A
INC R0
INC R1
DJNZ R2,CLEARSHOW_Gram_counter

ljmp main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;display subroutine

Disp_init:
MOV P0,#00000001b  ;Clear display
SETB en
LCALL delay_long
CLR en

MOV P0,#00000110b  ;Entry mode
SETB en
LCALL delay_long
CLR en

MOV P0,#00001100b  ;Dis on cur off
SETB en
LCALL delay_long
CLR en

MOV P0,#00111100b  ;Func set
SETB en
LCALL delay_long
CLR en

RET

Disp_char_init:
MOV P0,#01000000b  ;set CGRAM addr 00H
SETB en
LCALL delay_disp
CLR en

SETB rs           ;custom_char
MOV R1,#28H
MOV DPTR,#custom_char_dat
MOV R0,#00H
custom_char_counter:
MOV A,R0
MOVC A,@A+DPTR
MOV P0,A
SETB en
LCALL delay_disp
CLR en
INC R0
DJNZ R1,custom_char_counter
CLR rs

MOV P0,#10000000b  ;set DDRAM addr 00H
SETB en
LCALL delay_disp
CLR en
SETB rs

RET

Disp_refresh:
SETB rs
clr ea
MOV R1,#60h
first_line:
MOV P0,@R1
INC R1
SETB en
LCALL delay_disp
CLR en
CJNE R1,#70H,first_line
MOV A,#24D
LCALL flush_line

sec_line:
MOV P0,@R1
INC R1
SETB en
LCALL delay_disp
CLR en
CJNE R1,#80H,sec_line
MOV A,#24D
LCALL flush_line
setb ea
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
flush_line:
SETB en
LCALL delay_disp
CLR en
DJNZ 0e0h,flush_line
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
delay_disp:
MOV R5,#15
DJNZ R5,$
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
delay_long:

delay_long_flag1:	mov R4,#7
delay_long_flag2:	mov R5,#127
DJNZ R5,$
DJNZ R4,delay_long_flag2

ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
delay_main:         mov r1,#255
delay_main_flag1:	mov r3,#05
delay_main_flag2:	mov r2,#255
djnz r2,$
djnz r3,delay_main_flag2
djnz r1,delay_main_flag1
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rand:
mov	a,rand_seed
jnz	rand8b
cpl	a
mov	rand_seed,a
ret

rand8b:
anl	a,#10111000b
mov	c,p
mov	a,rand_seed
rlc	a
mov	rand_seed,a
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;
add_score:
inc score_lo

;score carry<<<<
mov r0,score_lo
cjne r0,#3AH,not_carry
mov score_lo,#30H
inc score_hi
not_carry:
;update the top score
clr c
mov a,Top_score_hi
subb a,score_hi;Top_score_hi-score_hi
jnc more_or_equ;jump if score_hi<=Top_score_hi
mov Top_score_hi,score_hi
mov Top_score_lo,score_lo;the score_hi is higher than the top score
setb new_rec_flag;reachs the top score
more_or_equ:
mov a,score_hi
cjne a,Top_score_hi,not_equ
;score_hi=Top_score_hi
clr c
mov a,Top_score_lo
subb a,score_lo; Top_score_lo-score_lo
jc lo_bigger; if Top_score_lo <=score_lo, jump;the score_hi is higher than the top score
ljmp not_equ
lo_bigger:
mov Top_score_lo,score_lo
setb new_rec_flag;reaches top score
not_equ:
mov 6fh,score_lo;display score in real-time.
mov 6eh,score_hi
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_dino:
mov a,61h
cjne a,#20h,Not_change_dino
mov a,bar_loc
jb acc.0,dino2
mov 71h,#00H;dino1
jmp Not_change_dino
dino2:	mov 71h,#03H;dino2;;>>>>>>>>
Not_change_dino:
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
move_forward:
dec Bar_loc;;;barricade go forward
lcall change_dino

mov r0,Bar_loc
mov @r0,#02H

mov r0,Bar_loc
inc r0
mov @r0,#20H
lcall Disp_refresh
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;11-16<
produce_bird:mov 6ch,#01h;produce bird
setb BIRD_FLAG
mov Bar_loc,#6ch;bird location
mov a,main_timer
add a,Bar_timeset
mov FWD_timeset,a;FWD_timeset=main_timer+Bar_timeset

mov 7fh,#20H;clear 7fh

clr c;<<<<
mov a,Bar_timeset
timelimit2:		subb a,#25;2+1
jc not_dec_bird;limit the minimum forward time interval to 2>>>

dec Bar_timeset

not_dec_bird:

ljmp fall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bird:		mov a,FWD_timeset
cjne a,main_timer,birdnotmove
;go forward
mov a,FWD_timeset
add a,Bar_timeset
mov FWD_timeset,a;

mov r0,Bar_loc
dec r0
cjne @r0,#20H,to_gameover

clr c
mov a,Bar_loc
add a,#10h
mov r0,a
cjne @r0,#20H,to_add_score

mov a,Bar_loc
cjne a,#60h,tomoveforward
;reaches the end
clr BIRD_FLAG
mov 60h,#20H
ljmp birdnotmove

to_add_score:lcall add_score

tomoveforward:dec Bar_loc
mov r0,Bar_loc
mov @r0,#01h

inc r0
mov @r0,#20H
lcall change_dino
jmp pass_gameover

to_gameover:ljmp gameover
pass_gameover:	 lcall Disp_refresh
birdnotmove:		ljmp fall

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dino_jump:
jb jump_state,havejump
jb sw,nojump

mov 61h,#00H;dino
mov 71h,#20H;void

lcall Disp_refresh

setb jump_state
mov jmp_timer,main_timer

mov a,main_timer;set the jump time to 3 times of the forward time
add a,Bar_timeset
add a,Bar_timeset
add a,Bar_timeset
mov jmp_timeset,a ;jmp_timeset
nojump:
havejump:
reti

;;;;;;;;;;;;;;;;;;;;play the music
snd_play:

MOV snd_hi,#253D
MOV snd_lo,#5D
MOV snd_time,#1D
;decide which music
JNB  snd_flag,play_Start_snd
JB new_rec_flag,PLAY_NEW_REC

MOV DPTR,#Death_snd;death music
jmp here
play_Start_snd:
MOV DPTR,#Start_snd;start music
JMP HERE
PLAY_NEW_REC:;new record music
MOV DPTR,#NEW_REC_SND

HERE:
SETB snd ;toggle snd
LCALL PLAY ; call delay
CLR snd ;
LCALL PLAY ;call delay
INC snd_counter
MOV A,snd_counter
CJNE A,snd_time,HERE
;SJMP HERE ;load TH , TL again
JMP NEXT

PLAY:
MOV TMOD,#01;timer 0 , mode 1 (16-bit mode)
mov TL0,snd_lo ;TL0=F2H , the low byte
MOV TH0,snd_hi ;TH0=FFH , the high byte
SETB TR0 ;start timer0
AGAIN: JNB TF0,AGAIN ;monitor timer 0 flag until it rolls over
CLR TR0 ;stop timer 0
CLR TF0 ;clear timer 0 flag
ret

NEXT:
CLR     A
MOVC    A,@A+DPTR
MOV     snd_hi,A
INC DPTR
CLR A
MOVC    A,@A+DPTR
MOV     snd_lo,A
INC DPTR
CLR A
MOVC    A,@A+DPTR
MOV     snd_time,A
INC DPTR
CJNE A,#00H,HERE

RET
;;;;;;;;;;;;;;;;;;;;;;;;;;evaluation subroutine
evaluation:	mov r7,score_hi

CJNE r7,#30h,more_10
;define the data location
mov dptr,#less_10
;refresh the GRAM
LCALL RELOAD_SEC_LINE
jmp	out
more_10:	CJNE r7,#31h,more_20
mov dptr,#less_20
LCALL RELOAD_SEC_LINE
jmp out
more_20:	CJNE r7,#32h,more_30
mov dptr,#less_30
LCALL RELOAD_SEC_LINE
jmp out
more_30:	CJNE r7,#33h,more_40
mov dptr,#less_40
LCALL RELOAD_SEC_LINE
jmp out
more_40:
mov dptr,#bigger_40
LCALL RELOAD_SEC_LINE
out:		RET
;;;;;;;;;;;;;;;;;;;;;;refresh the GRAM:
RELOAD_SEC_LINE:
mov r0,#70h
mov r1,#0
mov a,#0
mov a,r1
movc a,@a+dptr
mov @r0,a
inc r1
inc r0
cjne r0,#80h,$-5
RET
;;;;;;;;;;;;;;;;;;;;;;;;;;; DB AIRE
Death_snd: ;;death music
DB 254,154,127
DB 252,173,127
DB 252,122,127
DB 252,68,0
Start_snd: ;; start music
DB 254,34,127
DB 254,61,127
DB 254,86,127
DB 254,110,127
DB 254,133,127
DB 254,154,0
NEW_REC_SND:;; new record music
DB 254,244,100;
DB 254,211,100
DB 254,174,100
DB 254,211,150
DB 254,174,200
DB 0,0,0
;;;;;;;;;;;;;;;;;"  PRESS TO PLAY  "  ,  " 'DINO' DINO JUMP ^_^"
Start_dat:
DB '  PRESS TO PLAY '
DB 20H,00H,20H,'DINO JUMP ^_^'

;;;;;;;;;;;;;;;;;;;;"ENJOY YOURSELF  " , "      --Cerberus"
Welcome_dat:
DB 'ENJOY YOURSELF  '  ;45H,6EH,6AH,6FH,79H,20H,59H,6FH,75H,72H,73H,65H,6CH,66H,20H,20H
DB '      --Cerberus'  ;20H,20H,20H,20H,20H,20H,0B0H,0B0H,43H,65H,72H,62H,65H,72H,75H,73H

;;;;;;;;;;;;;;;;;;;initialization and clear
init_clear_dat:
DB '              00'  ;20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,30H,30H
DB 20H,00H,'              '  ;20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H,20H

;;;;;;;;;;;;;;;;;;;;;"NEW RECORD!! xx  "
NEWRECORD_dat:
DB 'NEW RECORD!! ',04H,'  '  ;4EH,65H,77H,  20H,  52H,65H,63H,6FH,72H,64H,  21H,21H,  20H,20H,20H,20H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;custom characters
custom_char_dat:
DB 01111b ;dino
DB 01101b
DB 01111b
DB 01000b
DB 01110b
DB 01000b
DB 01110b
DB 10001b

DB 00100b ;bird
DB 00101b
DB 01101b
DB 11111b
DB 01101b
DB 00101b
DB 00100b
DB 00000b

DB 00010b ;barr(flag)
DB 00110b
DB 01110b
DB 11110b
DB 00010b
DB 00010b
DB 00010b
DB 11111b

DB 01111b ;dino2
DB 01101b
DB 01111b
DB 01000b
DB 01110b
DB 01000b
DB 01110b
DB 01010b

DB 11111b ;cup
DB 10001b
DB 10001b
DB 01110b
DB 00100b
DB 00100b
DB 01110b
DB 11111b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;evaluations
less_10:
DB ' More Practice? '
less_20:
DB '    Not Bad     '
less_30:
DB '   Excellant!   '
less_40:
DB '  Awesome Man!! '
bigger_40:
DB '   God like!!!  '

END
