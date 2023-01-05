#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --tuples-only -c"

USER() {
  RAND_NUM=$(( $RANDOM % 1000 + 1 ))
  echo -e "\nEnter your username: "
  read USERNAME
  USER=$($PSQL "SELECT username, games, best FROM games WHERE username = '$USERNAME'")
  if [[ -z $USER ]];
  then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    echo -e "\nGuess the secret number between 1 and 1000:\n"
    PLAY $RAND_NUM $USERNAME
  else
    echo $USER | while read USERNAME BAR GAMES BAR BEST
    do
      echo -e "\nWelcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses."
    done
    echo -e "\nGuess the secret number between 1 and 1000:\n"
    PLAY $RAND_NUM $USERNAME
  fi
}

PLAY() {
  C=1
  read NUMBER
  if [[ ! $NUMBER =~ ^[0-9]+$ ]];
  then
    echo -e "\nThat is not an integer, guess again:\n"
    PLAY $RAND_NUM
  else
    if [[ "$NUMBER" < $RAND_NUM ]];
    then
      echo -e "\nIt's higher than that, guess again:\n"
      PLAY $RAND_NUM
    elif [[ "$NUMBER" > $RAND_NUM ]];
    then
      echo -e "\nIt's lower than that, guess again:\n"
      PLAY $RAND_NUM
    else      
      echo -e "\nYou guessed it in $C tries. The secret number was $RAND_NUM. Nice job!"
      INSERT $USERNAME $C
    fi
    ((C=$C+1))
  fi
}

INSERT() {
  USER_DATA=$($PSQL "SELECT username, games, best FROM games")
  echo $USER_DATA | while read USERNAME BAR GAMES BAR BEST
  do
    USER_EXIST=$($PSQL "SELECT username FROM games WHERE username = '$USERNAME'")
    if [[ -z $USER_EXIST ]];
    then
      INSERT_NEW=$($PSQL "INSERT INTO games(username, games, best) VALUES('$USERNAME', 1, $C)")
    else
      if [[ $BEST > $C ]];
      then
        INSERT_GAME=$($PSQL "UPDATE games SET games = games + 1 WHERE username='$USERNAME'")
      else
        INSERT_NEW_RECORD=$($PSQL "UPDATE games SET (games, best) = (games + 1, $C) WHERE username = '$USERNAME'")
      fi
    fi
  done
}

USER
