#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUM_TO_GUESS=$((1 + $RANDOM % 1000))
NUM_OF_GUESSES=0
echo -e "\nEnter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM number_guess WHERE username = '$USERNAME'")

if [[ -z $USER_ID ]]
then
  USER_INSERT_RESULT=$($PSQL "INSERT INTO number_guess(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM number_guess WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM number_guess WHERE user_id = $USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


GUESS_GAME(){
  if [[ -z $1 ]]
  then
    echo -e "\nGuess the secret number between 1 and 1000:"
  else
    echo $1
  fi

  read GUESS
  
  
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    GUESS_GAME "That is not an integer, guess again:"
  elif [[ $GUESS > $NUM_TO_GUESS ]]
  then
    NUM_OF_GUESSES=$((NUM_OF_GUESSES+1))
    GUESS_GAME "It's lower than that, guess again:"
  elif [[ $GUESS < $NUM_TO_GUESS ]]
  then
    NUM_OF_GUESSES=$((NUM_OF_GUESSES+1))
    GUESS_GAME "It's higher than that, guess again:"
  elif [[ $GUESS == $NUM_TO_GUESS ]]
  then
    NUM_OF_GUESSES=$((NUM_OF_GUESSES+1))
    echo "You guessed it in $NUM_OF_GUESSES tries. The secret number was $NUM_TO_GUESS. Nice job!"
    GAME_INCREMENT_RESULT=$($PSQL "UPDATE number_guess SET games_played = games_played + 1 WHERE username = '$USERNAME'")
    if [[ $NUM_OF_GUESSES < $BEST_GAME ]]
    then
      BEST_GAME_UPDATE_RESULT=$($PSQL "UPDATE number_guess SET best_game = $NUM_OF_GUESSES WHERE username = '$USERNAME'")
    elif [[ -z $BEST_GAME ]]
    then
      BEST_GAME_UPDATE_RESULT=$($PSQL "UPDATE number_guess SET best_game = $NUM_OF_GUESSES WHERE username = '$USERNAME'")
    fi
  fi
}
GUESS_GAME
