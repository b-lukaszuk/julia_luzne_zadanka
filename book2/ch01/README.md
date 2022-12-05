# Chapter 1. Introduction to Programming Exercises.

---

# Table of contents

1. [Task 1](#task-1)
2. [Task 2](#task-2)
3. [Task 3](#task-3)
4. [Task 4](#task-4)
5. [Task 5](#task-5)

---

# Task 1

[Go to: Table of contents](#table-of-contents)

## Title

Arithmetic

(Part 1, Exercise 10 from the book)

## Description

Create a program that reads two integers, a and b, from the user. Your program should compute and display:

- The sum of a and b
- The difference when b is subtracted from a
- The product of a and b
- The quotient when a is divided by b
- The remainder when a is divided by b
- The result of log10 a
- The result of a to the power of b

# Task 2

[Go to: Table of contents](#table-of-contents)

## Title

Distance Between Two Points on Earth

(Part 1, Exercise 12 from the book)

## Description

The surface of the Earth is curved, and the distance between degrees of longitude varies with latitude. As a result, finding the distance between two points on the surface of the Earth is more complicated than simply using the Pythagorean theorem.

Let (t1, g1) and (t2, g2) be the latitude and longitude of two points on the Earth’s surface. The distance between these points, following the surface of the Earth, in kilometers is:

<pre>
distance = 6371.01 × arccos(sin(t1) × sin(t2) + cos(t1) × cos(t2) × cos(g1 − g2))
</pre>

The value 6371.01 in the previous equation wasn’t selected at random. It is the average radius of the Earth in kilometers.

Create a program that allows the user to enter the latitude and longitude of two points on the Earth in degrees. Your program should display the distance between the points, following the surface of the earth, in kilometers.

Hint: Python’s trigonometric functions operate in radians. [...] The math module contains a function named radians which converts from degrees to radians.

# Task 3

[Go to: Table of contents](#table-of-contents)

## Title

Making Change

(Part 1, Exercise 13 from the book)

## Description

Write a program that begins by reading a number of cents from the user as an integer. Then your program should compute and display the denominations of the coins that should be used to give that amount of change to the shopper. The change should be given using as few coins as possible. Assume that the machine is loaded with pennies, nickels, dimes, quarters, loonies and toonies.

## My Notes

List of available coins

+ penny - 1/100th of a dollar, a cent
+ nickel - five centes
+ dime - ten cents
+ quarter - 25 cents
+ loonie - 1 dollar coin in Canada (hint from the book)
+ toonie - 2 dollar coin in Canada (hint from the book)

I think I will write the solution using [Pluto.jl](https://github.com/fonsp/Pluto.jl). Since Pluto.jl is interactive (and reactive) I think there is no point of handling user input as in terminal (See: my solution to task2 from this chapter).

# Task 4

[Go to: Table of contents](#table-of-contents)

## Title

Free Fall

(Part 1, Exercise 19 from the book)

## Description

Create a program that determines how quickly an object is traveling when it hits the ground. The user will enter the height from which the object is dropped in meters (m). Because the object is dropped its initial speed is 0 m/s. Assume that the acceleration due to gravity is 9.8 m/s^2. You can use the formula vf = sqrt(v_i^2 + 2ad) to compute the final speed, vf, when the initial speed, vi, acceleration, a, and distance, d, are known.

## My Notes

I think I will write the solution using [Pluto.jl](https://github.com/fonsp/Pluto.jl). Since Pluto.jl is interactive (and reactive) I think there is no point of handling user input as in terminal (See: my solution to task2 from this chapter).

# Task 5

[Go to: Table of contents](#table-of-contents)

## Title

Area of a Regular Polygon

(Part 1, Exercise 23 from the book)

## Description

A polygon is regular if its sides are all the same length and the angles between all of the adjacent sides are equal. The area of a regular polygon can be computed using the following formula, where `s` is the length of a side and `n` is the number of sides:

<pre>
area = (n * s^2) / (4 * tan(PI / n))
</pre>

Write a program that reads s and n from the user and then displays the area of a regular polygon constructed from these values.

## My Notes

I think I will write the solution using [Pluto.jl](https://github.com/fonsp/Pluto.jl). Since Pluto.jl is interactive (and reactive) I think there is no point of handling user input as in terminal (See: my solution to task2 from this chapter).
