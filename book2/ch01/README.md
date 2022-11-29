# Chapter 1. Introduction to Programming Exercises.

---

# Table of contents

1. [Task 1](#task-1)
2. [Task 2](#task-2)

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
