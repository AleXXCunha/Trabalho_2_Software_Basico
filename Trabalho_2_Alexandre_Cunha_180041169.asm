;Trabalho 2 Software Basico
;Aluno: Alexandre Abrahami Pinto da Cunha
;Matricula: 18/0041169
;Sistema Operacional: Ubuntu 21.10 [64 bits] 

SECTION .data
request db "Digite o nome do arquivo: ",0
size_request EQU $-request
msg_tam_arquivo db "Tamanho de bytes do arquivo de saida: ",0
size_msg_tam_arquivo EQU $-msg_tam_arquivo
instr_1 db "ADD",0ah
size_instr_1 EQU $-instr_1
instr_2 db "SUB",0ah
size_instr_2 EQU $-instr_2
instr_3 db "MULT",0ah
size_instr_3 EQU $-instr_3
instr_4 db "DIV",0ah
size_instr_4 EQU $-instr_4
instr_5 db "JMP",0ah
size_instr_5 EQU $-instr_5
instr_6 db "JMPN",0ah
size_instr_6 EQU $-instr_6
instr_7 db "JMPP",0ah
size_instr_7 EQU $-instr_7
instr_8 db "JMPZ",0ah
size_instr_8 EQU $-instr_8
instr_9 db "COPY",0ah
size_instr_9 EQU $-instr_9
instr_10 db "LOAD",0ah
size_instr_10 EQU $-instr_10
instr_11 db "STORE",0ah
size_instr_11 EQU $-instr_11
instr_12 db "INPUT",0ah
size_instr_12 EQU $-instr_12
instr_13 db "OUTPUT",0ah
size_instr_13 EQU $-instr_13
instr_14 db "STOP",0ah
size_instr_14 EQU $-instr_14

break dd 0
num_char_lidos dd 0
pos_mem dd 0
num_char_escritos dd 0
pos_nome dd 0
ACC dd 0
num_mem dd 0

SECTION .bss
in_file_name resb 20
out_file_name resb 20
fd_in resd 1
fd_out resd 1
conteudo_arquivo resb 400
tam_arquivo_lido resd 1
num resd 1
entrada resb 20
string_convertida resb 10
ptr_string_convertida resd 1
mem resb 100

SECTION .text
global _start
_start:
	;PEDINDO O NOME DO ARQUIVO A SER LIDO PELO SIMULADOR
	mov eax,4
	mov ebx,1
	mov ecx,request
	mov edx,size_request
	int 80h
	mov eax,3
	mov ebx,0
	mov ecx,in_file_name
	mov edx,20
	int 80h
	mov byte [ecx + eax - 1],0
	
	;RENOMEANDO O ARQUIVO DE SAIDA
	mov ecx,eax
	
escreve_nome:
	cmp byte [in_file_name+ebx],46
	je ponto_ou_fim
	cmp byte [in_file_name+ebx],0
	je ponto_ou_fim

	mov ebx, dword [pos_nome]
	mov al,byte [in_file_name+ebx]
	mov byte [out_file_name+ebx],al
		
	inc dword [pos_nome]
	loop escreve_nome
	
ponto_ou_fim:
	mov byte [out_file_name+ebx],'.'
	mov dword [out_file_name+ebx+1],'diss'	
	
	;ABRINDO O ARQUIVO OBJETO PARA LEITURA
	mov eax,5
	mov ebx,in_file_name
	mov ecx,0
	mov edx,0755o
	int 80h
	mov dword [fd_in],eax
	
	;LENDO O ARQUIVO OBJETO
	push dword [fd_in]
	push conteudo_arquivo
	call ler_arquivo
	
	;FECHANDO O ARQUIVO OBJETO
	mov eax,6
	mov ebx,dword [fd_in]
	int 80h
	
	;CRIANDO O ARQUIVO DE SAIDA PARA ESCRITA
	mov eax,8
	mov ebx,out_file_name
	mov ecx,0755o
	int 80h
	mov dword [fd_out],eax

;LE OS NUMEROS E OS IDENTIFICA, ESCREVENDO NO ARQUIVO DE SAIDA
le_nums_1:
	mov ecx,2
	
	;CONDICAO DE PARADA
	cmp dword [break],1
	je fim_1
	
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	call escrevendo_na_saida
	
	loop le_nums_1

fim_1:
	
;CONVERTE TODAS AS CONSTANTES E ESPACOS DE MEMORIA EM INTEIROS
	mov edx,dword [num_char_lidos]

converte_mem_para_int:

	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	sub ebx,1
	
	lea esi,[num]
	mov ecx,ebx
	call string_to_int
	
	mov ebx,dword [num_mem]
	mov dword [mem+ebx],eax
	mov byte [mem+ebx+4],20h
	
	mov eax,dword [mem+ebx]
	
	add dword [num_mem],5
	mov ecx,1
	add ecx,dword [tam_arquivo_lido]
	sub ecx,dword [num_char_lidos]
	
	loop converte_mem_para_int
	
	mov dword [num_char_lidos],edx
	mov edx,0
	
salva_mem:
	mov eax, dword [mem+edx]
	mov ebx,dword [num_char_lidos]
	mov dword [conteudo_arquivo+ebx],eax
	mov dword [conteudo_arquivo+ebx+4],20h
	
	add edx,5
	add dword [num_char_lidos],5
	sub dword [num_mem],5
	
	mov ecx,1
	add ecx,dword [num_mem]
	loop salva_mem
		
;LE OS NUMEROS E OS IDENTIFICA, REALIZANDO AS OPERACOES DOS OPCODES
	mov dword [break],0
	mov dword [num_char_lidos],0
	
le_nums_2:
	mov ecx,2
	
	;CONDICAO DE PARADA
	cmp dword [break],1
	je fim_2
	
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	call realizando_instr
	
	loop le_nums_2
	
fim_2:
	;FECHANDO O ARQUIVO DE SAIDA
	mov eax,6
	mov ebx,dword [fd_out]
	int 80h
	
	;MOSTRANDO NA TELA O TAMANHO DE BYTES DO ARQUIVO DE SAIDA
	mov eax,dword[num_char_escritos]
	lea esi, [string_convertida]
	
	call int_to_string
	mov dword [ptr_string_convertida],eax
	
	mov eax,4
	mov ebx,1
	mov ecx,msg_tam_arquivo
	mov edx,size_msg_tam_arquivo
	int 80h
	
	mov eax,4
	mov ebx,1
	mov ecx,dword [ptr_string_convertida]
	mov edx,10
	int 80h
	
	;FINALIZANDO O CODIGO
	mov eax,1
	mov ebx,0
	int 80h

;;;;;;;;;;;;;;;;;;;;;;;FUNCOES;;;;;;;;;;;;;;;;;;;;;;;;;;
;IDENTIFICA O OPCODE E ESCREVE NO ARQUIVO DE SAIDA
escrevendo_na_saida:
	enter 0,0
	
	cmp byte [num],31h
	je escreve_num_1
	cmp byte [num],32h
	je escreve_num_2
	cmp byte [num],33h
	je escreve_num_3
	cmp byte [num],34h
	je escreve_num_4
	cmp byte [num],35h
	je escreve_num_5
	cmp byte [num],36h
	je escreve_num_6
	cmp byte [num],37h
	je escreve_num_7
	cmp byte [num],38h
	je escreve_num_8
	cmp byte [num],39h
	je escreve_num_9
	
escreve_num_1:
	cmp byte [num + 1],30h
	je escreve_num_10
	cmp byte [num + 1],31h
	je escreve_num_11
	cmp byte [num + 1],32h
	je escreve_num_12
	cmp byte [num + 1],33h
	je escreve_num_13
	cmp byte [num + 1],34h
	je escreve_num_14
	
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;ESCREVE 'ADD' NO ARQUIVO DE SAIDA
	push instr_1
	push size_instr_1
	call escrever_arquivo
	add dword [num_char_escritos],size_instr_1
	jmp return_1
		
escreve_num_2:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax

	;ESCREVE 'SUB' NO ARQUIVO DE SAIDA
	push instr_2
	push size_instr_2
	call escrever_arquivo
	add dword [num_char_escritos],size_instr_2
	jmp return_1
	
escreve_num_3:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;ESCREVE 'MULT' NO ARQUIVO DE SAIDA
	push instr_3
	push size_instr_3
	call escrever_arquivo
	add dword [num_char_escritos],size_instr_3
	jmp return_1
	
escreve_num_4:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax

	;ESCREVE 'DIV' NO ARQUIVO DE SAIDA
	push instr_4
	push size_instr_4
	call escrever_arquivo
	add dword [num_char_escritos],size_instr_4
	jmp return_1
	
escreve_num_5:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax

	;ESCREVE 'JMP' NO ARQUIVO DE SAIDA
	push instr_5
	push size_instr_5
	call escrever_arquivo
	add dword [num_char_escritos],size_instr_5
	jmp return_1	
	
escreve_num_6:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax

	;ESCREVE 'JMPN' NO ARQUIVO DE SAIDA
	push instr_6
	push size_instr_6
	call escrever_arquivo
	add dword [num_char_escritos],size_instr_6
	jmp return_1
	
escreve_num_7:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax

	;ESCREVE 'JMPP' NO ARQUIVO DE SAIDA
	push instr_7
	push size_instr_7
	call escrever_arquivo
	add dword [num_char_escritos],size_instr_7
	jmp return_1
	
escreve_num_8:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax

	;ESCREVE 'JMPZ' NO ARQUIVO DE SAIDA
	push instr_8
	push size_instr_8
	call escrever_arquivo
	add dword [num_char_escritos],size_instr_8
	jmp return_1
	
escreve_num_9:
	;PEGANDO O OPERANDO 1
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;PEGANDO O OPERANDO 2
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax

	;ESCREVE 'COPY' NO ARQUIVO DE SAIDA
	push instr_9
	push size_instr_9
	call escrever_arquivo
	add dword [num_char_escritos],size_instr_9
	jmp return_1
	
escreve_num_10:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax

	;ESCREVE 'LOAD' NO ARQUIVO DE SAIDA
	push instr_10
	push size_instr_10
	call escrever_arquivo
	add dword [num_char_escritos],size_instr_10
	jmp return_1
	
escreve_num_11:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax

	;ESCREVE 'STORE' NO ARQUIVO DE SAIDA
	push instr_11
	push size_instr_11
	call escrever_arquivo
	add dword [num_char_escritos],size_instr_11
	jmp return_1
	
escreve_num_12:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax

	;ESCREVE 'INPUT' NO ARQUIVO DE SAIDA
	push instr_12
	push size_instr_12
	call escrever_arquivo
	add dword [num_char_escritos],size_instr_12
	jmp return_1
	
escreve_num_13:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax

	;ESCREVE 'OUTPUT' NO ARQUIVO DE SAIDA
	push instr_13
	push size_instr_13
	call escrever_arquivo
	add dword [num_char_escritos],size_instr_13
	jmp return_1
	
escreve_num_14:
	;ESCREVE 'STOP' NO ARQUIVO DE SAIDA
	push instr_14
	push size_instr_14
	call escrever_arquivo
	add dword [num_char_escritos],size_instr_14
	
	;CONDICAO DE PARADA ATINGIDA
	mov dword [break],1
	
return_1:
	leave
	ret

;IDENTIFICA O OPCODE E REALIZA A INTRUCAO 
realizando_instr:
	enter 0,0
	
	cmp byte [num],31h
	je num_1
	cmp byte [num],32h
	je num_2
	cmp byte [num],33h
	je num_3
	cmp byte [num],34h
	je num_4
	cmp byte [num],35h
	je num_5
	cmp byte [num],36h
	je num_6
	cmp byte [num],37h
	je num_7
	cmp byte [num],38h
	je num_8
	cmp byte [num],39h
	je num_9
	
num_1:
	cmp byte [num + 1],30h
	je num_10
	cmp byte [num + 1],31h
	je num_11
	cmp byte [num + 1],32h
	je num_12
	cmp byte [num + 1],33h
	je num_13
	cmp byte [num + 1],34h
	je num_14
	
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;REALIZANDO A OPERACAO DE 'ADD'
	call encontra_mem
	
	push eax
	call pega_char
	
	mov edx,dword [num]
	add dword [ACC],edx
	jmp return_2	
num_2:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;REALIZANDO A OPERACAO DE 'SUB'
	call encontra_mem
	
	push eax
	call pega_char
	
	mov edx,dword [num]
	sub dword [ACC],edx
	jmp return_2
num_3:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;REALIZANDO A OPERACAO DE 'MULT'
	call encontra_mem
	
	push eax
	call pega_char
	
	mov eax,dword [ACC]
	mov ecx,dword [num]
	imul eax,ecx
	mov dword [ACC],eax
	jmp return_2
num_4:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;REALIZANDO A OPERACAO DE 'DIV'
	call encontra_mem
	
	push eax
	call pega_char
	
	mov edx,0
	mov ecx,dword [num]
	mov eax,dword [ACC]
	div ecx
	mov dword [ACC],eax
	jmp return_2
num_5:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;REALIZANDO A OPERACAO DE 'JMP'
	call encontra_mem
	mov dword [num_char_lidos],eax	
	jmp return_2
num_6:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;REALIZANDO A OPERACAO DE 'JMPN'
	cmp dword [ACC],0
	jge positivo
	
	call encontra_mem
	mov dword [num_char_lidos],eax
	
positivo:
	jmp return_2
num_7:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;REALIZANDO A OPERACAO DE 'JMPP'
	
	cmp dword [ACC],0
	jle negativo
	
	call encontra_mem
	mov dword [num_char_lidos],eax
	
negativo:
	jmp return_2
num_8:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;REALIZANDO A OPERACAO DE 'JMPZ'
	cmp dword [ACC],0
	jne nao_zero
	
	call encontra_mem
	mov dword [num_char_lidos],eax
	
nao_zero:
	jmp return_2
num_9:
	;PEGANDO O OPERANDO 1
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	call encontra_mem
	mov edx,dword [conteudo_arquivo+eax]
	
	;PEGANDO O OPERANDO 2
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;FAZENDO A OPERACAO DE 'COPY'
	call encontra_mem
	mov dword [conteudo_arquivo+eax],edx

	jmp return_2
num_10:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;FAZENDO A OPERACAO DE 'LOAD'
	call encontra_mem
	mov edx,dword [conteudo_arquivo+eax]
	mov dword [ACC],edx

	jmp return_2
num_11:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;FAZENDO A OPERACAO DE 'STORE'
	call encontra_mem
	mov edx,dword [ACC]
	mov dword [conteudo_arquivo+eax],edx
	mov byte [conteudo_arquivo+eax+4],20h

	jmp return_2
num_12:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;FAZENDO A OPERACAO DE 'INPUT'
	mov eax,3
	mov ebx,0
	mov ecx,entrada
	mov edx,10
	int 80h
	sub eax,1
	
	lea esi,[entrada]
	mov ecx,eax
	call string_to_int
	
	mov dword [entrada],eax
	
	call encontra_mem
	
	;SALVA NA MEMORIA
	mov edx,dword [entrada]
	mov dword [conteudo_arquivo+eax],edx
	mov byte [conteudo_arquivo+eax+4],20h

	jmp return_2
num_13:
	;PEGANDO O OPERANDO
	push dword [num_char_lidos]
	call pega_char
	mov dword [num_char_lidos],eax
	
	;FAZENDO A OPERACAO DE 'OUTPUT'
	call encontra_mem
	
	mov eax,dword [conteudo_arquivo+eax]
	
	lea esi, [string_convertida]
	call int_to_string
	mov dword [num],eax
	
	mov eax,4
	mov ebx,1
	mov ecx,dword [num]
	mov edx,10
	int 80h

	jmp return_2
num_14:
	;CONDICAO DE PARADA ATINGIDA
	mov dword [break],1
	
return_2:
	leave
	ret

;LENDO OS NUMEROS DO ARQUIVO OBJETO
ler_arquivo:
	enter 0,0
	
	mov eax,3
	mov ebx,dword [EBP+12]
	mov ecx,dword [EBP+8]
	mov edx,400
	int 80h
	mov byte [ecx + eax - 1],20h
	mov dword [tam_arquivo_lido],eax
	
	leave
	ret

;LE TODOS OS CARACTERES ATE ENCONTRAR UM ESPACO EM BRANCO	
pega_char:
	enter 4,0
	mov dword [EBP-4],0
	
le_char:
	mov ecx,2
	
	mov ebx,dword [EBP+8]
	mov al,byte [conteudo_arquivo+ebx]
	mov ebx,dword [EBP-4]
	mov byte [num+ebx],al
	
	mov ebx,dword [EBP+8]
	inc dword [EBP+8]
	inc dword [EBP-4]
	cmp byte [conteudo_arquivo+ebx],20h
	je espaco

	loop le_char
	
espaco:
	mov eax,dword [EBP+8]
	mov ebx,dword [EBP-4]
	leave
	ret

;ENCONTRA O ESPACO DE MEMORIA A SER SALVO
encontra_mem:
	enter 4,0
	mov dword [EBP-4],0
	
	lea esi,[num]	
	
	cmp byte [num+1],20h
	jne digitos_2
	mov ecx,1
	jmp digito_1
	
digitos_2:
	mov ecx,2
	
digito_1:
	call string_to_int
	
ler_prox_instr:
encontra_espacos:
	mov ecx,2
	
	mov ebx,dword [EBP-4]
	inc dword [EBP-4]
	cmp byte [conteudo_arquivo+ebx],20h
	je achou_espaco
	
	loop encontra_espacos
	
achou_espaco:

	mov ecx,eax
	sub eax,1	
	loop ler_prox_instr
	
	mov eax,dword [EBP-4]

	leave
	ret


;ESCREVENDO NO ARQUIVO DE SAIDA
escrever_arquivo:
	enter 0,0
	
	mov eax,4
	mov ebx,dword [fd_out]
	mov ecx,[EBP+12]
	mov edx,[EBP+8]
	int 80h
	
	leave
	ret
	
;CONVERTE DE STRING PARA INTEIRO
string_to_int:
	sub ebx,ebx
prox_digito:
	movzx eax,byte [esi]
	inc esi
	sub al,'0'
	imul ebx,10
	add ebx,eax
	loop prox_digito
	
	mov eax,ebx
	ret

;CONVERTE DE INTEIRO PARA STRING
int_to_string:
	mov byte [esi],10
	
	mov ebx,10
prox_char:
	sub edx,edx
	div ebx
	add dl,'0'
	dec esi
	mov [esi],dl
	test eax,eax
	jnz prox_char
	mov eax,esi
	ret
