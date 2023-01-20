	.data
str_affiche_plateau_1_a:.asciz "-----------"
str_affiche_plateau_1_b:.asciz "                         0-----------1-----------2\n"
str_affiche_plateau_2_a:.asciz "|           |           |                         |           |           |\n"  #Identique à L12
str_affiche_plateau_3_a:.asciz "|   "
str_affiche_plateau_3_b:.asciz "-------" #utilisee 4 fois
str_affiche_plateau_3_c:.asciz "   |                         |   3-------4-------5   |\n"
str_affiche_plateau_4_a:.asciz "|   |       |       |   |                         |   |       |       |   |\n" #Identique à L10
str_affiche_plateau_5_a:.asciz "|   |   " 	#Utilisee 2 fois
str_affiche_plateau_5_b:.asciz "---" 	#Utilisee 2 fois en L5 et L9 et 4 fois en L7
str_affiche_plateau_5_c:.asciz "   |   |                         |   |   6---7---8   |   |\n"
str_affiche_plateau_6_a:.asciz "|   |   |       |   |   |                         |   |   |       |   |   |\n"  #Identique à L8
str_affiche_plateau_7_a:.asciz "       "
str_affiche_plateau_7_b:.asciz "                         9---10--11      12--13--14\n"
str_affiche_plateau_9_b:.asciz "   |   |                         |   |   15--16--17  |   |\n"
str_affiche_plateau_11_b:.asciz"   |                         |   18------19------20  |\n"
str_affiche_plateau_13_b:.asciz "                         21----------22----------23\n"
str_place_pion_1_a:.asciz "Tour du Joueur "
str_place_pion_1_b:.asciz " :\nEntrez le numéro de la case vide sur laquelle vous voulez placer un pion\n\n"
str_place_pion_2_a:.asciz "Placement invalide, Veuillez recommencer\nEntrez le numéro de la case vide sur laquelle vous voulez placer un pion\n\n"

	#Definition des variables globales :

	#Nombre de pièces sur le terrain
var_J1_nbr_de_pions : .word 0
var_J2_nbr_de_pions : .word 0

	#Phase du jeu (0 = fin du jeu ; 1 = pose des pions ; 2 = mouvement/saut des pions)
var_phase : .word 1

	#tour de quel joueur (1 = tour de Joueur 1 ; 2 = tour de Joueur 2)
var_tour_j : .word 1

	#numéro du tour (pour la phase 1)
var_tour : .word 0

	#tableau des cases (24 t_case ; taille d'une t_case = 1 int + 1 char + 4 int = 32 bits + 8 bits (32 bits quand alignés) + 32*4 bits => 6*32bits = 24 octets
var_tab_plateau : .space 576	#24 t_cases * 24 octets


	# definition des chaines de characteres :
	
	
	#strings utilisées dans la fonction fin_de_partie
str_fin_de_partie_1_a : .asciz "Le joueur "
str_fin_de_partie_1_b : .asciz " a perdu !\n"
str_fin_de_partie_2_a : .asciz "bravo au joueur "
str_fin_de_partie_2_b : .asciz " !\n"


	.text
main :
	#Affectation d'un bloc de pile pour le main
	addi sp, sp, -64
	addi fp, sp, 64

	#appel fonction fct_initialisation	(argument est deja une var globale)
	sw a0, 0(sp)	#OUV	#sauvegarde de a0	inutile car retourne void?
	jal fct_initialisation
	lw a0, 0(sp)	#FIN	#Restitution de a0	inutile car retourne void?

	#appel fonction fct_affiche_plateau	(argument est deja une var globale)
	sw a0, 0(sp)	#OUV	#sauvegarde de a0	inutile car retourne void?
	jal fct_affiche_plateau
	lw a0, 0(sp)	#FIN	#Restitution de a0	inutile car retourne void?

	

	j fct_fin_de_partie	#affiche les gagnants/perdants puis QUITTE le programme
	#FIN MAIN




	#Fonction : initialise les valeurs du tableau avec des cases vides
fct_initialisation :
	addi sp, sp, -32	#PRO
	sw ra, 0(sp)		#PRO
	sw fp, 4(sp)		#PRO
	sw t0, 8(sp)		#PRO
	sw t1, 12(sp)		#PRO
	sw t2, 16(sp)		#PRO
	sw t3, 20(sp)		#PRO
	sw t4, 24(sp)		#PRO	
	sw t5, 28(sp)		#PRO
	addi fp, sp, 32		#PRO
	
	#boucle for (int i = 0; i < 24; i++)
	add t0, zero, zero	# t0 = i = 0
for_fct_initialisation :
	slti t1, t0, 24		#test si i < 24 	resultat -> t1
	beq t1, zero, suite_for_fct_initialisation	#saut vers la fin du for loop si t1 = 0
	
	#code for :
	la t2, var_tab_plateau	# t2 = & plateau
	ori t5, zero, 24	# t5 = 24
	mul t3, t0, t5		# t3 = i*24 	(offset de l'& case i)
	add t3, t3, t2		# t3 = & plateau + offset de l'& case i = & case i
	li t4, 0		# t4 = valeur à stocker
	sw t4, 0(t3)		#p[i].valeur = 0;	//case vide
	li t4, 35
	sw t4, 4(t3)		#p[i].symbole = 35;	// 35 correspond à '#' en ascii
	li t4, -1
	sw t4, 8(t3)		#p[i].vn = -1;		//pas de voisin nord
	sw t4, 12(t3)		#p[i].ve = -1;		//pas de voisin est
	sw t4, 16(t3)		#p[i].vs = -1;		//pas de voisin sud
	sw t4, 20(t3)		#p[i].vo = -1;		//pas de voisin ouest	
	
	addi t0, t0, 1		#i++
	j for_fct_initialisation
suite_for_fct_initialisation :	#fin boucle for

	#mise en place des voisins :

	la t0, var_tab_plateau	# t0 = & plateau

	li t1, 1		# t1 = valeur à stocker
	sw t1, 12(t0)		#p[0].ve = 1;		0*24 + 3*4
	li t1, 9
	sw t1, 16(t0)		#p[0].vs = 9;		0*24 + 4*4

	li t1, 2
	sw t1, 36(t0)		#p[1].ve = 2;		1*24 + 3*4
	li t1, 4
	sw t1, 40(t0)		#p[1].vs = 4;		1*24 + 4*4
	li t1, 0
	sw t1, 44(t0)		#p[1].vo = 0;		1*24 + 5*4

	li t1, 14
	sw t1, 64(t0)		#p[2].vs = 14;		2*24 + 4*4
	li t1, 1
	sw t1, 68(t0)		#p[2].vo = 1;		2*24 + 5*4

	#Ce que j'ai rajouté
        li t1,4 
        sw t1,84(t0)            #p[3].ve = 4;         3*24 + 3*4 
        li t1,10 
        sw t1,88(t0)            #p[3].vs = 10;         3*24 + 4*4 

        li t1,1 
        sw t1,104(t0)           #p[4].vn = 1;         4*24 + 2*4 
        li t1,5 
        sw t1,108(t0)           #p[4].ve = 5;         4*24 + 3*4 
        li t1,7 
        sw t1,112(t0)           #p[4].vs = 7;         4*24 + 4*4 
        li t1,3 
        sw t1,116(t0)           #p[4].vo = 3;         4*24 + 5*4 
        li t1,13 

        sw t1,136(t0)           #p[5].vs = 13;         5*24 + 4*4 
        li t1,4 
        sw t1,140(t0)           #p[5].vo = 4;         5*24 + 5*4 
        li t1,7 

        sw t1,156(t0)           #p[6].ve = 7;         6*24 + 3*4 
        li t1,11 
        sw t1,160(t0)           #p[6].vs = 11;         6*24 + 4*4 
        li t1,4 

        sw t1,176(t0)           #p[7].vn = 4;         7*24 + 2*4 
        li t1,8 
        sw t1,180(t0)           #p[7].ve = 8;         7*24 + 3*4 
        li t1,6 
        sw t1,188(t0)           #p[7].vo = 6;         7*24 + 5*4 
        li t1,12 

        sw t1,208(t0)           #p[8].vs = 12;         8*24 + 4*4 
        li t1,7 
        sw t1,212(t0)           #p[8].vo = 7;         8*24 + 5*4 
        li t1,0 

        sw t1,224(t0)           #p[9].vn = 0;         9*24 + 2*4 
        li t1,10 
        sw t1,228(t0)           #p[9].ve = 10;         9*24 + 3*4 
        li t1,21 
        sw t1,232(t0)           #p[9].vs = 21;         9*24 + 4*4 
        li t1,3 

        sw t1,248(t0)           #p[10].vn = 3;         10*24 + 2*4 
        li t1,11 
        sw t1,252(t0)           #p[10].ve = 11;         10*24 + 3*4 
        li t1,18 
        sw t1,256(t0)           #p[10].vs = 18;         10*24 + 4*4 
        li t1,9 
        sw t1,260(t0)           #p[10].vo = 9;         10*24 + 5*4 
        li t1,6 

        sw t1,272(t0)           #p[11].vn = 6;         11*24 + 2*4 
        li t1,15 
        sw t1,280(t0)           #p[11].vs = 15;         11*24 + 4*4 
        li t1,10 
        sw t1,284(t0)           #p[11].vo = 10;         11*24 + 5*4 
        li t1,8 

        sw t1,296(t0)           #p[12].vn = 8;         12*24 + 2*4 
        li t1,13 
        sw t1,300(t0)           #p[12].ve = 13;         12*24 + 3*4 
        li t1,17 
        sw t1,304(t0)           #p[12].vs = 17;         12*24 + 4*4 
        li t1,5 

        sw t1,320(t0)           #p[13].vn = 5;         13*24 + 2*4 
        li t1,14 
        sw t1,324(t0)           #p[13].ve = 14;         13*24 + 3*4 
        li t1,20 
        sw t1,328(t0)           #p[13].vs = 20;         13*24 + 4*4 
        li t1,12 
        sw t1,332(t0)           #p[13].vo = 12;         13*24 + 5*4 
        li t1,2 

        sw t1,344(t0)           #p[14].vn = 2;         14*24 + 2*4 
        li t1,23 
        sw t1,352(t0)           #p[14].vs = 23;         14*24 + 4*4 
        li t1,13 
        sw t1,356(t0)           #p[14].vo = 13;         14*24 + 5*4 
        li t1,11 

        sw t1,368(t0)           #p[15].vn = 11;         15*24 + 2*4 
        li t1,16 
        sw t1,372(t0)           #p[15].ve = 16;         15*24 + 3*4 
        li t1,17 

        sw t1,396(t0)           #p[16].ve = 17;         16*24 + 3*4 
        li t1,19 
        sw t1,400(t0)           #p[16].vs = 19;         16*24 + 4*4 
        li t1,15 
        sw t1,404(t0)           #p[16].vo = 15;         16*24 + 5*4 
        li t1,12 

        sw t1,416(t0)           #p[17].vn = 12;         17*24 + 2*4 
        li t1,16 
        sw t1,428(t0)           #p[17].vo = 16;         17*24 + 5*4 
        li t1,10 

        sw t1,440(t0)           #p[18].vn = 10;         18*24 + 2*4 
        li t1,19 
        sw t1,444(t0)           #p[18].ve = 19;         18*24 + 3*4 
        li t1,16 

        sw t1,464(t0)           #p[19].vn = 16;         19*24 + 2*4 
        li t1,20 
        sw t1,468(t0)           #p[19].ve = 20;         19*24 + 3*4 
        li t1,22 
        sw t1,472(t0)           #p[19].vs = 22;         19*24 + 4*4 
        li t1,18 
        sw t1,476(t0)           #p[19].vo = 18;         19*24 + 5*4 
        li t1,13 

        sw t1,488(t0)           #p[20].vn = 13;         20*24 + 2*4 
        li t1,19 
        sw t1,500(t0)           #p[20].vo = 19;         20*24 + 5*4 
        li t1,9 

        sw t1,512(t0)           #p[21].vn = 9;         21*24 + 2*4 
        li t1,22 
        sw t1,516(t0)           #p[21].ve = 22;         21*24 + 3*4 
        li t1,19 

        sw t1,536(t0)           #p[22].vn = 19;         22*24 + 2*4 
        li t1,23 
        sw t1,540(t0)           #p[22].ve = 23;         22*24 + 3*4 
        li t1,21 
        sw t1,548(t0)           #p[22].vo = 21;         22*24 + 5*4 
        li t1,14 

        sw t1,560(t0)           #p[23].vn = 14;         23*24 + 2*4 
        li t1,22 
        sw t1,572(t0)           #p[23].vo = 22;         23*24 + 5*4 
        li t1,666 
        sw t1,572(t0)           #p[23].vo = 666;         23*24 + 5*4 
        li t1,666 
        sw t1,572(t0)           #p[23].vo = 666;         23*24 + 5*4

	lw ra, 0(sp)		#EPI
	lw fp, 4(sp)		#EPI
	lw t0, 8(sp)		#EPI
	lw t1, 12(sp)		#EPI
	lw t2, 16(sp)		#EPI
	lw t3, 20(sp)		#EPI
	lw t4, 24(sp)		#EPI	
	lw t5, 28(sp)		#EPI
	addi sp, sp, 32		#EPI
	jr ra			#EPI
	#FIN
	

# Fonction d'affichage du plateau
fct_affiche_plateau : 
	#TO DO : écrire la fonction
	addi sp, sp, -32	#PRO
	sw ra, 0(sp)		#PRO
	sw fp, 4(sp)		#PRO
	sw t0, 8(sp)		#PRO
	sw t1, 12(sp)		#PRO
	sw t2, 16(sp)		#PRO
	sw t3, 20(sp)		#PRO
	sw t4, 24(sp)		#PRO	
	sw t5, 28(sp)		#PRO
	addi fp, sp, 32		#PRO
	
	la t2, var_tab_plateau	# t2 = & plateau

	ori a7,zero,11   #Print p[0].symbole
	lw a0,4(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_1_a
	ecall

	ori a7,zero,11   #Print p[1].symbole
	lw a0,28(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_1_a
	ecall

	ori a7,zero,11   #Print p[2].symbole
	lw a0,52(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_1_b
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_2_a
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_3_a
	ecall

	ori a7,zero,11   #Print p[3].symbole
	lw a0,76(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_3_b
	ecall

	ori a7,zero,11   #Print p[4].symbole
	lw a0,100(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_3_b
	ecall

	ori a7,zero,11   #Print p[5].symbole
	lw a0,124(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_3_c
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_4_a
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_5_a
	ecall

	ori a7,zero,11   #Print p[6].symbole
	lw a0,148(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_5_b
	ecall

	ori a7,zero,11   #Print p[7].symbole
	lw a0,172(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_5_b
	ecall

	ori a7,zero,11   #Print p[8].symbole
	lw a0,196(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_5_c
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_6_a
	ecall

	ori a7,zero,11   #Print p[9].symbole
	lw a0,220(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_5_b
	ecall

	ori a7,zero,11   #Print p[10].symbole
	lw a0,244(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_5_b
	ecall

	ori a7,zero,11   #Print p[11].symbole
	lw a0,268(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_7_a
	ecall

	ori a7,zero,11   #Print p[12].symbole
	lw a0,292(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_5_b
	ecall

	ori a7,zero,11   #Print p[13].symbole
	lw a0,316(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_5_b
	ecall

	ori a7,zero,11   #Print p[14].symbole
	lw a0,340(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_7_b
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_6_a
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_5_a
	ecall

	ori a7,zero,11   #Print p[15].symbole
	lw a0,364(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_5_b
	ecall

	ori a7,zero,11   #Print p[16].symbole
	lw a0,388(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_5_b
	ecall

	ori a7,zero,11   #Print p[17].symbole
	lw a0,412(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_9_b
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_4_a
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_3_a
	ecall

	ori a7,zero,11   #Print p[18].symbole
	lw a0,436(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_3_b
	ecall


	ori a7,zero,11   #Print p[19].symbole
	lw a0,460(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_3_b
	ecall

	ori a7,zero,11   #Print p[20].symbole
	lw a0,484(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_11_b
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_2_a
	ecall

	ori a7,zero,11   #Print p[21].symbole
	lw a0,508(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_1_a
	ecall

	ori a7,zero,11   #Print p[22].symbole
	lw a0,532(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_1_a
	ecall

	ori a7,zero,11   #Print p[23].symbole
	lw a0,556(t2)
	ecall

	ori a7,zero,4   #Print string
	la a0,str_affiche_plateau_13_b
	ecall

	lw ra, 0(sp)		#EPI
	lw fp, 4(sp)		#EPI
	lw t0, 8(sp)		#EPI
	lw t1, 12(sp)		#EPI
	lw t2, 16(sp)		#EPI
	lw t3, 20(sp)		#EPI
	lw t4, 24(sp)		#EPI	
	lw t5, 28(sp)		#EPI
	addi sp, sp, 32		#EPI

	jr ra			#EPI
	#FIN

	
#Fonction qui teste si la case entree en parametre fait partie d'un moulin
#retourne 1 si la case fait partie d'un moulin et 0 sinon
fct_test_moulin : 
	#TO DO : écrire la fonction
	jr ra			#EPI
	#FIN
	
#teste si une capture est possible, si oui demande à l'utilisateur la case à capturer et effectue la capture
fct_capture : 
	#TO DO : écrire la fonction
	jr ra			#EPI
	#FIN

#demande à l'utilisateur de placer un pion, puis le place dans le plateau si placement valable:
#retourne l'indice de la case jouée
fct_place_pion :
	#TO DO : écrire la fonction
	addi sp, sp, -32	#PRO
	sw ra, 0(sp)		#PRO
	sw fp, 4(sp)		#PRO
	sw t0, 8(sp)		#PRO
	sw t1, 12(sp)		#PRO
	sw t2, 16(sp)		#PRO
	sw t3, 20(sp)		#PRO
	sw t4, 24(sp)		#PRO	
	sw t5, 28(sp)		#PRO
	addi fp, sp, 32		#PRO
	
	la a0, str_place_pion_1_a	#Tour du Joueur :
	ori a7,zero,4   		#Print string
	ecall

	la t2, var_tour_j
	lw t5,0(t2)			#t2 prend var_tour_j
	
	ori a7,zero,1   
	or a0,zero,t5
	ecall				#Print tour_j

	la a0, str_place_pion_1_b	#Tour du Joueur :
	ori a7,zero,4   		#Print string
	ecall

if_place_pion_1:
	ori a7,zero,4   		#Read integer
	ori a2,a0,0			#a2 = a0 (le return)
	ecall

	blt a0,zero,suite_if_place_pion_1  #input<0
	ori t2,zero,23
	blt t2,a0,suite_if_place_pion_1 #input>23

	la t4, var_tab_plateau		#t4 = &plateau
	lw t3,a0(t4)			#t3 = p[input].valeur
	bne t3,zero,suite_if_place_pion_1  #p[input].valeur != 0

	la a0, str_place_pion_2_a	#Placement invalide...
	ori a7,zero,4   		#Print string
	ecall
	j if_place_pion_1
suite_if_place_pion_1:

	sw t5, a0(t4)			#p[input].valeur = tour_j
	
	ori t2,zero,1
	bne t5,t2,suite_if_place_pion_2  #If tour_j = 1 :

	la t4, var_J1_nbr_de_pions	#t4 = &J1_nbr_de_pions
	lw t1,0(t4)			#t1 = J1_nbr_de_pions
	addi t3,t1,1			#t3 = t1 + 1
	sw t3,0(t4)			#J1_nbr_de_pions = t3

	la t4, var_tab_plateau		#t4 = &var_tab_plateau
	addi t2, a0, 4			#t2 = input + 4 
	ori t1,zero,88			#t1 = 88
	sw t3,0(t4)			#var_tab_plateau[input].symbole = t1
suite_if_place_pion_2:

	ori t2,zero,2
	bne t5,t2,suite_if_place_pion_3

	la t4, var_J2_nbr_de_pions	#t4 = &J2_nbr_de_pions
	lw t1,0(t4)			#t1 = J2_nbr_de_pions
	addi t3,t1,1			#t3 = t1 + 1
	sw t3,0(t4)			#J2_nbr_de_pions = t3

	la t4, var_tab_plateau		#t4 = &var_tab_plateau
	addi t2, a0, 4			#t2 = input + 4 
	ori t1,zero,79			#t1 = 79
	sw t3,0(t4)			#var_tab_plateau[input].symbole = t1
suite_if_place_pion_3:

	lw ra, 0(sp)		#EPI
	lw fp, 4(sp)		#EPI
	lw t0, 8(sp)		#EPI
	lw t1, 12(sp)		#EPI
	lw t2, 16(sp)		#EPI
	lw t3, 20(sp)		#EPI
	lw t4, 24(sp)		#EPI	
	lw t5, 28(sp)		#EPI
	addi sp, sp, 32		#EPI

	jr ra			#EPI
	#FIN

#demande à l'utilisateur le pion à déplacer et la case de destination, puis le déplace si le déplacement est valable:
#retourne l'indice de la case de destination
fct_deplace_pion :
	#TO DO : écrire la fonction
	jr ra			#EPI
	#FIN

#demande à l'utilisateur le pion à déplacer et la case de destination, puis le déplace si le déplacement est valable:
#retourne l'indice de la case de destination
fct_saut_pion :
	#TO DO : écrire la fonction
	jr ra			#EPI
	#FIN
	
#teste si un coup est possible pour le joueur actif (renvoie 1 si oui, 0 sinon)
fct_test_coup_possible :
	#TO DO : écrire la fonction
	jr ra			#EPI
	#FIN
	
#Affiche le vainqueur et quite le programme
fct_fin_de_partie :
	# pas besoin de prologue/épilogue car la fonction quite le programme à la fin
	
	ori t0, zero, 1		# t0 = gagnant = 1 par defaut
	lw t1, var_tour_j	# t1 = perdant = var_tour_j
	bne t0, t1, suite_if_fct_fin_de_partie		# test (var_tour_j != 1)	//if (perdant == 1)
	ori t0, zero, 0		# t0 = gagnant = 0
suite_if_fct_fin_de_partie :
	
	#Affichage du message	printf("Le joueur %d a perdu !\n",perdant);
	ori a7, zero, 4
	la a0, str_fin_de_partie_1_a
	ecall

	ori a7, zero, 1
	ori a0, t1, 0
	ecall

	ori a7, zero, 4
	la a0, str_fin_de_partie_1_b
	ecall
	#Affichage du message	printf("bravo au joueur %d !\n",gagnant);
	ori a7, zero, 4
	la a0, str_fin_de_partie_2_a
	ecall
	ori a7, zero, 1
	ori a0, t0, 0
	ecall
	ori a7, zero, 4
	la a0, str_fin_de_partie_2_b
	ecall
	
	ori a7, zero, 10	# exit()
	ecall
	#FIN


