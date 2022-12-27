	.data
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
	
	#TO DO : finir tous les voisins

#	li t1, 
#	sw t1, (t0)		#		*24 + 2*4
#	li t1, 
#	sw t1, (t0)		#		*24 + 3*4
#	li t1, 
#	sw t1, (t0)		#		*24 + 4*4
#	li t1, 
#	sw t1, (t0)		#		*24 + 5*4

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