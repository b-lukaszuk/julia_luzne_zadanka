# Chapter 6. Dictionary Exercises.

---

# Table of contents

0. [Notice](#notice)
1. [Task 1](#task-1)
2. [Task 2](#task-2)
3. [Task 3](#task-3)
4. [Task 4](#task-4)
5. [Task 5](#task-5)

---

# Notice

[Go to: Table of contents](#table-of-contents)

The *.jl files are just code and comments written and used in Emacs/VS Code interactive mode for Julia.

NO GUARANTEE THAT THE CODE WILL WORK OR WORKS CORRECTLY! USE IT AT YOUR OWN RISK!

# Task 1

[Go to: Table of contents](#table-of-contents)

## Title

Two Dice Simulation

(Part 1, Exercise 129 from the book)

## Description

In this exercise you will simulate 1,000 rolls of two dice.

[...] it should display a table that summarizes this data. Express the frequency for each total as a percentage of the total number of rolls. Your program should also display the percentage expected by probability theory for each total.

# Task 2

[Go to: Table of contents](#table-of-contents)

## Title

Write Out Numbers in English

(Part 1, Exercise 133 from the book)

## Description

[...] create a function that takes an integer between 0 and 999 as its only parameter, and returns a string containing the English words for that number. For example, if the parameter to the function is 142 then your function should return “one hundred forty two”.

# Task 3

[Go to: Table of contents](#table-of-contents)

## Title

Create a Bingo Card

(Part 1, Exercise 138 from the book)

## Description

A [Bingo card](https://en.wikipedia.org/wiki/Bingo_(American_version)#Bingo_cards) consists of 5 columns of 5 numbers. The columns are labeled with the letters B, I, N, G and O. There are 15 numbers that can appear under each letter. In particular, the numbers that can appear under the B range from 1 to 15, the numbers that can appear under the I range from 16 to 30, the numbers that can appear under the N range from 31 to 45, and so on.

Write a function that creates a random Bingo card [...]. [...] write a program that displays a random Bingo card.

# Task 4

[Go to: Table of contents](#table-of-contents)

## Title

Checking for a Winning Card

(Part 1, Exercise 139 from the book)

## Description

A winning Bingo card contains a line of 5 numbers that have all been called. [...] we will mark that a number has been called by replacing it with a 0 in the Bingo card dictionary.

Write a function that takes a dictionary representing a Bingo card as its only parameter. If the card contains a line of five zeros (vertical, horizontal or diagonal) then your function should return True, indicating that the card has won. Otherwise the function should return False.

[...] You will probably want to import your solution to Exercise 138 when completing this exercise.

# Task 5

[Go to: Table of contents](#table-of-contents)

## Title

Play Bingo

(Part 1, Exercise 140 from the book)

## Description

In this exercise you will write a program that simulates a game of Bingo [...]. Begin by generating a list of all of the valid Bingo calls (B1 through O75). [...] Then your program should consume calls out of the list, crossing out numbers on the card, until the card contains a crossed out line (horizontal, vertical or diagonal). Simulate 1,000 games and report the minimum, maximum and average number of calls that must be made before the card wins.

## My notes

Not sure what the 'all of the valid Bingo calls (B1 through O75)' means. I think I should generate a sequence of numbers 1:75, shuffle them, and draw one at a time until a random bingo card is filled (that's what I will do).
