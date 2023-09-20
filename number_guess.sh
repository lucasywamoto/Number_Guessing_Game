#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#echo -e "\n~~ WELCOME TO NUMBER GUESS GAME~~\n"

echo -e "\nEnter your username:"
read USERNAME

USERNAME_USED=$($PSQL "SELECT username FROM players WHERE username='$USERNAME'")

if [[ -z $USERNAME_USED ]]
  then
    INSERT_PLAYER=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  else
    PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games FULL JOIN players USING(player_id) WHERE player_id=$PLAYER_ID")
    BEST_GAME=$($PSQL "SELECT MIN(guesses_number) FROM games FULL JOIN players USING(player_id) WHERE player_id=$PLAYER_ID")
    
    echo $PLAYER_ID $GAMES_PLAYED $BEST_GAME
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$((1 + RANDOM % 1000))
echo $SECRET_NUMBER
NUMBER_OF_GUESSES=0
echo -e "\nGuess the secret number between 1 and 1000:"

while [[ $NUMBER_INPUT -ne $SECRET_NUMBER ]]
do
  read NUMBER_INPUT
  if ! [[ $NUMBER_INPUT =~ ^[0-9]+$ ]] 
  then
    echo -e "\nThat is not an integer, guess again:"
  elif [[ $NUMBER_INPUT -gt $SECRET_NUMBER ]]
  then
    echo -e "\nIt's lower than that, guess again:"
  elif  [[ $NUMBER_INPUT -lt $SECRET_NUMBER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
  fi
  NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1))
done

PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
INSERT_GAME=$($PSQL "INSERT INTO games(player_id, guesses_number) VALUES ($PLAYER_ID , $NUMBER_OF_GUESSES)")

echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
