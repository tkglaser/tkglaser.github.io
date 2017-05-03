---
layout: post
title:  "How floating points broke our checkout wizard"
date:   2017-03-03
permalink: /how-floating-points-broke-our-checkout-wizard/
image: /assets/images/numbers.jpg
---
Want to see something fun? Open the JavaScript console of your browser and type
```javascript
3*2.2
```
The result is (in Chrome 56):
```javascript
6.6000000000000005
```
<!--more-->
It might be surprising that an error, even if it is a relatively small one, would occur with such a simple calculation.

In our e-commerce website, the total price at checkout was calculated in JavaScript and then checked on the server. So our customer was buying 3 items at £2.20 and… you can guess the rest.

The reason lies with the way a computer performs floating point arithmetics. Of course, every computer internally uses 1s and 0s only, so all numbers must be converted to a binary format. For some decimal numbers this is problematic. For instance, the decimal 0.1 is infinitely recurring in binary and can therefore not be precisely expressed. Imagine the fraction 1/3 which can only approximated with 0.3333333. One tenth (or 0.1) is such a fraction in binary.

This “bug” is unfixable because it is not really a bug. The only way is to work around it. So the golden rule of working with money on computers is

Never use floating point arithmetics, use the minor denomination instead.

In our example we now calculate 3*220p which gives the correct answer.