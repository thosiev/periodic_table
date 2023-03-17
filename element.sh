#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

EXIT() {
echo  "$1"
exit 0
}


# Error if no argument is not provided
if [[ ! $1 ]] 
then
EXIT "Please provide an element as an argument."
fi

# if argument is a number
if [[ $1  =~ ^[0-9]+$ ]]
then
atomic_number=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
fi


symbol=$($PSQL "SELECT symbol FROM elements WHERE symbol='$1'")
name=$($PSQL "SELECT name FROM elements WHERE name='$1'")

# if argument is neigher a symbol not a name
if [[ -z $symbol && -z $name && -z $atomic_number ]]
then
EXIT "I could not find that element in the database."
# argument is a symbol but not a name, or a number
elif [[ -z $name && -z $atomic_number && ! -z $symbol ]]
then
name=$($PSQL "SELECT name FROM elements WHERE symbol='$symbol';")
atomic_number=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$symbol'")
# argument is a name but not a symbol
elif [[ -z $symbol && -z $atomic_number && ! -z $name ]]
then
symbol=$($PSQL "SELECT symbol FROM elements WHERE name='$name'")
atomic_number=$($PSQL "SELECT atomic_number FROM elements WHERE name='$name'")
elif [[ -z $symbol &&  ! -z atomic_number && -z $name  ]]
then
symbol=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$atomic_number")
name=$($PSQL "SELECT name FROM elements WHERE atomic_number=$atomic_number")
fi



# get all the other properties
atomic_mass=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$atomic_number")
melting_point_celsius=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$atomic_number ")
boiling_point_celsius=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$atomic_number ") 
type=$($PSQL "SELECT type FROM properties AS p INNER JOIN types AS t ON t.type_id = p.type_id WHERE p.atomic_number=$atomic_number")

# echo the result
echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
#echo "The element with atomic number 1 is Hydrogen (H). It's a nonmetal, with a mass of 1.008 amu. Hydrogen has a melting point of -259.1 celsius and a boiling point of -252.9 celsius."
