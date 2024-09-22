#!/usr/bin/env bash

EDITOR="nano"
PFILES=".agenda"
ARCHIVO=$HOME/$PFILES
#PWD=$( cd -- "$(dirname "$0")" >/dev/null 2>&1 && pwd -P )/$PFILES

AYUDA="AGENDA\n La presente herramienta consta de generación y control de
plantillas de registros.\n Los registros son creados con campos por defecto (ID,
PROJECT, TITLE, STATUS, ASSIGNEE, CREATION_DATE, DUE_DATE, SUMMARY)\npero
pueden añadirse o cambiarse detalles en con cualquier editor
de texto.\n Los registros se encuentran en el directorio $ARCHIVO.\n\n
-a\tInicia la creación de un nuevo registro.\n
-o\tLista los registros con estado abierto (STATUS open).\n
-c\tInserta un comentario a un registro existente.\n
-n\tLista los comentarios o notas en un registro dado.\n
-r\tElimina un registro existente.\n
-b\tLista los registros con estado bloqueado (STATUS blocked).\n
-p\tLista los nombres proyectos a asociados a los registros existentes(campo PROJECT).\n
-m\tAbre un registro con un editor de textos.\n
-l\tLista todos los registros con un resumen de información para cada caso.\n\n
Es posible acceder a las funciones invocadas al utilizar alternativas a los\narguentos
listados anteriormente pero no se prefieren esas formas dado que su\nprimer
propósito fue el de acotar el resultado obtenido.\n\n
Eliminar un campo, editar su contenido o insertar un campo personalizado se hará\nmediante
el editor de textos. Se prefirió la simplicidad y la agilidad al crear los registros\ny
se insta a tomar cuanto tiempo fuera necesario para hacer modificaciones."

getLabel(){
	grep $3 $1 $2 | cut -d " " -f 2
}

issueID2Path(){
	read -r -p "# Ingrese el ID del registro: " ID
	grep -r "ID $ID" $ARCHIVO | cut -d ":" -f 1
}

# -c
addComment(){
	echo "### Comentar un registro:"
	listIssues
	NOTA=$(issueID2Path)

	while
		echo -e "# Ingrese una nota de hasta 75 caracteres:"
		read -r -p "> " INPUT
		[ ${#INPUT} -gt 75 ]
	do true; done

	echo -e "NOTE $INPUT" >> $NOTA
	echo -e "# Registro ID:$(grep ID $NOTA | cut -d " " -f 2) actualizado.\n"
}

# -n
printNotes(){
	listIssues
	REG=$(issueID2Path)
	listIssueX ID $(grep ID $REG | cut -d " " -f 2)
	grep NOTE $REG | cut -d " " -f 2-
}

# -a
newIssue(){
	echo "### Nuevo registro"
	while
		read -r -p "# TITULO NUEVO: " TITLE
		[ -f $ARCHIVO/$TITLE ]
	do true; done
	ID=$(getLabel ID $ARCHIVO -r | awk 'BEGIN{a=   0}{if ($1>0+a) a=$1} END{print (a+1)}')
	echo -e "# Ingrese los valores solicitados:"
	LP=($(getLabel PROJ $ARCHIVO -r | uniq))
	echo -e $"> Proyectos existentes:\n${LP[@]}"
	read -r -p "> PORYECTO: " PROJECT
	read -r -p "> STATUS: " STATUS
	read -r -p "> RESPONSABLE: " ASSIGNEE
	cat > $ARCHIVO/$TITLE << EOF
ID $ID
PROJECT $PROJECT
TITLE $TITLE
STATUS $STATUS
ASSIGNEE $ASSIGNEE
CREATION_DATE
DUE_DATE
SUMMARY
EOF
}

# -r
removeIssue(){
	LISTAR=""
	echo -e "# Presione enter/intro para continuar sin verificar el listado.\n# Presione cualquier tecla para listar todos los registros."
	read -r -p "> " LISTAR
	[ ! -z $LISTAR ] && listIssues
        read -r -p "Ingrese el ID del registro a eliminar: " ID
	$( grep -r "ID $ID" $ARCHIVO | cut -d ":" -f 1 | xargs rm ) || echo -e "# No se pudo eliminar el registro."
}

# -o -b
listIssueX(){
	FILES=$(grep -r $1 $ARCHIVO | grep -i $2 | cut -d ":" -f 1 | awk -F "/" '{print $NF}')
	echo -e $"\n### Issues - $1: $2"
	for ITEM in ${FILES[@]}
	do
		H0=$(getLabel ID $ARCHIVO/$ITEM)
		H1=$(getLabel TITLE $ARCHIVO/$ITEM)
		H2=$(getLabel PROJECT $ARCHIVO/$ITEM)
		H3=$(getLabel ASSIGNEE $ARCHIVO/$ITEM)
		echo -e ">  ID: $H0\tTítulo: $H1\t Proyecto: $H2\tResponsable: $H3"
	done
}

# -p
listProjects(){
	echo -e "\n### Proyectos:"
	getLabel PROJ $ARCHIVO -r | uniq
}

# -l
listIssues(){
	FILES=$(ls $ARCHIVO)
	for REG in ${FILES[@]}
	do
		H0=$(getLabel ID $ARCHIVO/$REG)
		H1=$(getLabel PROJECT $ARCHIVO/$REG)
		H2=$(getLabel TITLE $ARCHIVO/$REG)
		H3=$(getLabel STATUS $ARCHIVO/$REG)
		echo -e ">  ID: $H0\tProyecto: $H1\tIssue: $H2\tSTATUS: $H3"
	done
}

# -m
manualEditor(){
	listIssues
        REG=$(issueID2Path)
	bash -c $"$EDITOR $REG"
}

#MAIN
case $1 in
	-a | anotar | agendar | add)
		newIssue
		;;
	-c | comentario | comentar | comment)
		addComment
		;;
	-n | notas)
		printNotes
		;;
	-r | remove | borrar)
		removeIssue
		;;
	-o | open)
                listIssueX STATUS open
                ;;
        -b | blocked | block)
                listIssueX STATUS blocked
                ;;
        -p | proyecto | project)
                listProjects
                ;;
	-l | lista | list)
		listIssues
		;;
	-m | editor | modify)
		manualEditor
		;;
	*)
		echo -e $AYUDA
		;;
esac
