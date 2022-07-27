Trabalho 2 da Disciplina de Software Básico, no qual consiste em um simulador em assembly IA-32 para o assembly inventado da matéria, gerando um dissassembler e mostrando na tela ao final o tamanho de bytes do arquivo de saída.

O código foi desenvolvido no Ubuntu 21.10 utilizando o compilador NASM. Para compilar o código basta escrever no terminal:
nasm -f -elf -o objeto.o Trabalho_2_Alexandre_Cunha_180041169.asm

Onde "objeto" é um nome do arquivo objeto arbitrário. Gerando o executável com o ligador ld:
ld -o executavel objeto.o

Onde "executavel" é um nome do executável arbitrário. E somente executando ao final: 
./montador

Não foi possível implementar o simulador para entradas com números negativos. Caso o arquivo não exista ou a entrada não seja somente números, também ocorrerá erro. 

Tentei rodar o código em diferentes máquinas, no windows usando o wsl o código não funciona se não adicionar um espaço ao final do arquivo de entrada (dá seg fault). No Ubuntu isso não ocorre, como os arquivos objetos normalmente não possuem um espaço ao final, o código adiciona sozinho. Logo, se colocar um espaço ao final do arquivo de entrada no Ubuntu ele vai repetir o mesmo processo 2 vezes e também não funcionará.
