# Beating C with Dyalog APL: wc

## Background
A recent blog post that bubbled up on [r/programming](https://www.reddit.com/r/programming) entitled [Beating C With 80 Lines Of Haskell: Wc](https://chrispenner.ca/posts/wc) inspired me to see how effective APL would be in solving this problem.

### But Why APL?
Why not? I was told by older students during my university years to avoid APL and any internship or co-op opportunities that used it. Turns out that was bad advice, at least for me--I can see how it might not be other folks' cup of tea, but it is definitely something I like. A few years back I had the opportunity to finally play with an APL derivative K (I got a job at a small K shop). I liked K but had to move on job wise. I recently downloaded a free personal copy of [Dyalog](https://www.dyalog.com) and have been playing around with it while reading through [Mastering Dyalog APL](https://www.dyalog.com/mastering-dyalog-apl.htm) by Bernard Legrand (only a few chapters in so far). I find APL friendlier to use than K and enjoy it a great deal, so this seemed like a good excuse to figure out how to do file I/O while searching through the book's PDF and flexing google-fu.

## On with the code
Just like Chris Penner's original article, I'm comparing against the OSX version of `wc` that shipped with my machine. Just like in the original article, I admit that there are likely faster versions of `wc`--I'm just comparing what I got.

### Counting Words
Counting characters is trivial. Counting lines is almost as trivial, or is as trivial if we count `CRLF` as two lines--I chose the more trivial solution out of laziness. `CRLF` could be counted as one end of line with an additional three lines (warning: guesstimate).

Just as in the original post, the meat of the problem is in accurately counting words. The first step is counting the number of words in a single string. First let's make two definitions:
```
nl←⎕UCS¨10 11 12 13  ⍝ Newline characters
sp←nl,⎕UCS¨9 32  ⍝ Space characters
```
The above doesn't look like "normal" programming languages because APL doesn't use the standard ASCII character set for its symbols/terms which means none of its names are stolen from you--if you name a variable `new` or `this` or `function` it won't clash with anything. Note that it does use ASCII _symbols_ like `+` or `=` but there are no keywords using ASCII numbers/letters.

An explanation of the above:
1. `⍝` denotes a `//` style comment, it's called _lamp_ and it _illuminates_.
2. `nl` and `sp` are variables with `nl` being newline characters and `sp` whitespace characters. In APL, `←` is assignment. Here we assign everything to the right of `nl` or `sp` to the variables `nl` and `sp`.
3. `¨` will create a _derived function_ which will map the function _immediately_ to the left of `¨` across the value to the right. By _immediately_ to the left I mean you read as little as possible to the left to figure out what the lefthand argument is, but the righthand argument is the result of evaluating the _entire_ expression to the right, and this is how APL works in general--take as little as possible from the left but everything from the right.
4. `⎕UCS` happens to be a function in Dyalog for getting unicode characters from numeric values.
5. The ravel function `,` will catenate its lefthand and righthand arguments, so `sp` contains the newlines in `nl` along with tab and space.

Now that we know what constitutes a newline or a space we can figure out how to get `wc` results. Assume the input is stored in the variable `s`, we can even give it a concrete value for now: `s←'I am the model of a modern major general'`. To find where the spaces are we use the membership function `∊` with `s∊sp`, which yields
```
0 1 0 0 1 0 0 0 1 0 0 0 0 0 1 0 0 1 0 1 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0
```
telling us the exact position of any whitespace characters. Let's call this vector `f` for _found_: `f←s∊sp`. We don't want to just count the ones in this vector as then consecutive whitespace characters would each count as a word; what we want to count is when we switch from non-whitespace to whitespace (or vice-versa), and we can accomplish this with the difference between adjacent values. This is easy in APL, it's just `(1↓f)-(¯1)↓f`:
1. `¯` is "high minus" and is used to negate literals.
2. `↓` is the drop function which drops a number of items from the value to the right. If the number on the left is positive, it drops that many from the _front_ of the value, if it is negative then it drops the absolute value of that many from the _back_ of the value. So `1↓f` is `f` without the first item and `(¯1)↓f` is `f` without the last item.
3. `-` is subtraction, so we are subtracting values in `f` from the values to their left. For this particular `f` we get the following:
```
1 ¯1 0 1 ¯1 0 0 1 ¯1 0 0 0 0 1 ¯1 0 1 ¯1 1 ¯1 0 0 0 0 0 1 ¯1 0 0 0 0 1 ¯1 0 0 0 0 0 0
```

This vector is one element _shorter_ than `f`--if `f` were a vector of five items with values `0 1 0 0 1` then we would have calculated `(1 0 0 1) - (0 1 0 0)` after the drops, which would be `1 ¯1 0 1`, a vector of four items. Back to the above result, we can find all the places where `1` appears simply with `1=(1↓f)-(¯1)↓f` which compares every element in the vector to the value `1`, yielding a vector of the same size as the shorter "difference" vector that has `1` where a difference of `1` was found and `0` elsewhere:
```
1 0 0 1 0 0 0 1 0 0 0 0 0 1 0 0 1 0 1 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0
```
And these represent the exact places where a space followed a non-space (the first `1` corresponds to the space between `I` and `am`). Summing this up gives us the number of places a word _terminated_ by being followed by a space, and we can get that sum with the function `+/`. Just as `¨` created a _derived function_ so does `/` -- both are called _operators_. As `¨` was associated with the commonly named function `map` so is `/` associated with the commonly named function `reduce`/`fold`, and so `+/` is a sum function.

For `+/1=(1↓f)-(¯1)↓f` we get `8`, but `'I am the model of a modern major general'` has `9` words, not `8`. The problem is that we were only counting words terminated by a space, not by the end of the string. To count that, we must check if the last character is a space or not and if it's not then we can count the end of the string as terminating a word. We can get the whether the last character was a space or not with `(¯1)↑f`, which will be `1` if `s` ended with a space or `0` if not. Since we want to add exactly one word to the count when a string _does not_ end with a space we negate this with `~` and add that--negation switching `0`s and `1`s. Thus the word count expression is:
```
(~(¯1)↑f)++/1=(1↓f)-(¯1)↓f
```

We only have one piece of input in the above and so it is easy to turn it into a function. In APL we can make a **direct function** by using braces (I won't go into the differences in the two function types here but know that the book references above goes into some details). So we can store this calculation in a variable with:
```
words←{(~(¯1)↑⍵)++/1=(1↓⍵)-(¯1)↓⍵}
```
In APL `⍺` (alpha) and `⍵` (omega) are the names of the left and right arguments to a direct function. We apply a function just like we do the built in primitive functions, we give it parameters: `words s∊sp`. Just like with the built in parameters, `words` will be evaluated on the entire expression to the right which is `s∊sp` (`f` from above). This yields `9`. One problem is that the calculation is wrong for the empty string: `words ''∊sp` gives `1` not `0`. This won't be an issue for us because we won't even be invoking it on empty strings.

### A First Attempt
Now that we can count words in a string we can count words in a file. We could just do this by reading in the entire file all at once and applying the `words` function and then counting the number of characters and the number of newlines. But that would be a bad idea--what if the file is 123GB in size?! Clearly we don't want to read that in all at once, instead we want to read it in a few blocks at a time. We're going to need a loop, and for that we need another type of function, a **procedural function** (again see the referenced book for details).

One computation issue, as mentioned in the original Haskell based blog post, is what happens if we split up the input in the middle of a word? Well, we just use the same technique used in that blog post. No, not monoids (though that is cool), just keeping track if the last character we saw was a non-space or not. If it was and the first new character is _also_ a non-space then we subtract one word from the count as we accumulate.

With that in mind, here's the first attempt
```
res←wc fn;c;w;l;fd;data;blk;nl;sp;lnsp;words
words←{(~(¯1)↑⍵)++/1=(1↓⍵)-(¯1)↓⍵}
blk←256×1024
nl←⎕UCS¨10 11 12 13
sp←nl,⎕UCS¨9 32
c←w←l←0
fd←fn ⎕NTIE 0
lnsp←0
:Repeat
    data←⎕NREAD fd 80 blk
    :If 0=≢data
        :Leave
    :EndIf
    c←c+(≢data)
    l←l++/data∊nl
    data←data∊sp
    w←(w+words data)-(lnsp∧~1↑data)
    lnsp←~(¯1)↑data
:EndRepeat
⎕NUNTIE fd
res←l w c
```
We define the function `wc` with input `fn` (filename) and output `res` (result). The names after `fn` are the names of variables we want to be _local_ which happens to be every variable we are using. If we left a variable out, it would be assumed global and be able to change global state. An explanation:

1. The first line, as just described, declares the function `wc` with input `fn`, output `res`, and a handful of local variables.
2. `words` is the word counting function we derived above.
3. `blk` is the block size we will use while we read from the file `fn`.
4. `nl` and `sp` are the newline and whitespace vectors we defined originally.
5. `c`, `w`, and `l` are character, word, and line counters initially set to `0`.
6. `fd` is the file descriptor for `fn` (next available since we passed `0`).
7. `lnsp` is `1` if the last character read during the previous iteration was not a space, `0` otherwise.
8.  Now we enter a loop with `:Repeat`, the body of which is everything between `:Repeat` and `:EndRepeat`. `:Leave` is like `break` in other languages.
9. `data` is assigned the next block of data read from `fd`. `80` tells the `⎕NREAD` function that we want to read characters (intuitive, right?). `≢data` counts the number of items in `data` and if this is zero (i.e. `data` is empty) we exit the loop. Otherwise we add that count to `c`.
10. We then use `data∊nl` to find the newlines in `data` and sum these up with `+/` and add this sum to `l`.
11. We no longer need the contents of `data` we only need to know where whitespace is, so we store a boolean vector describing this in `data`. Passing this to `words` counts the number of whitespace terminated words in `data`, which we add to `w`. But then, to account for word splitting, we use `1↑data` to get whether the first character we read _this iteration_ was a space and then negate that with `~`; we use `∧` to _and_ that against whether the last character in the _previous iteration_ was _not_ a space, and subtract that from the count. As in C, `0` is false and so `1∧1` is `1` and we only subtract `1` if the previous iteration's data ended with a nonspace _and_ this iteration's data started with one.
12. We then store whether this iteration's data terminated with a nonspace character.
13. Finally we close the file descriptor after the loop and return the line, word, and character counts in `res`.

## Performance Measurements
Using [a user defined timing operator](https://dfns.dyalog.com/c_time.htm) we can time the `wc` function. On a 1.661GB file (which is just the `big.txt` file from the original Haskell post's repository repeated multiple times), I get (on my 11 inch early 2k15 MacBook Air) initially a run of 3.36 seconds, but then 2.75s, 2.34s, 2.36s on immediate subsequent runs now that the computer is pumped and primed. Using the `time` terminal utility to run `wc` against the same file I get _user times_ ranging from 5.345s to 5.549s, so this first attempt is faster and we are done. I get similarly scaled differences for smaller files.

## Splitting It All Up
We can split our procedural function up into a few direct functions and an operator which might make it easier to understand and maintain (or maybe not). We start with a function computing the `wc` stats on a string together with whether the string's first and last character is not a space:

```
blockCount←{
    l←+/⍵∊⎕UCS¨10 11 12 13  ⍝ #lines
    s←⍵∊⎕UCS¨9 10 11 12 13 32  ⍝ is space
    w←(~(¯1)↑s)++/1=(1↓s)-(¯1)↓s  ⍝ words
    ⍝ first-non-space, chars, words, lines, last-non-space
    (~1↑s)(≢⍵)w l(~(¯1)↑s)
}
```

1. We directly use the vector of newlines, passing `⎕UCS¨10 11 12 13` as the righthand argument to the membership function `∊`. The lefthand argument is the righthand argument passed to `blockCount`.
2. `s` is the boolean vector telling us where spaces (`⎕UCS¨9 10 11 12 13 32`) occur in the righthand argument to `blockCount`.
3. From `s` we calculate the words in `blockCount`'s righthand argument directly, just as we did before.
4. Finally we return whether the first character is not a space, the number of characters, the number of words, the number of lines, and whether the last character is not a space.

We can apply `blockCount` to multiple strings. Just like the original Haskell version we need some way to combine the results of applying `blockCount` to sequential strings from a file, which we do with the following:

```
blockCollapse←{
    adjustment←0 0(-+/(1↓⍵[;1])∧(¯1)↓⍵[;5])0 0
    collapsed←(⍵[1;1]),(+⌿⍵)[2 3 4],(⍵[≢⍵;5])
    adjustment+collapsed
}
```

The assumption here is that the results from `blockCount` are stored in a matrix where each row is a result, with the values as described as above (whether the first character is a nonspace, etc...). When we collapse a sequence of `blockCount` results we want a result of the same form as `blockCount`. This will be the following:

1. Whether the first result in the matrix represented a string _starting_ with a nonspace--that value is `⍵[1;1]`.
2. The sum of all the characters from all the results.
3. The sum of all the words from the results minus the number of times a word was split.
4. The sum of all the lines from all the results.
5. Whether the last result in the matrix represented a string _ending_ with a nonspace--that value is `⍵[≢⍵;5]`.

The sums in the middle can be calculated if we reduce addition _down_ the input matrix. `(+⌿⍵)` will calculate that sum, and `(+⌿⍵)[2 3 4]` will be the middle three values of that sum (we don't need the sums of whether the strings started or ended with nonspace characters).

The value we have to subtract--the number of times a word was split--is calculated by taking the sum of whether a string started with a nonspace _anded_ with whether the string before ended with one. That is the value `+/(1↓⍵[;1])∧(¯1)↓⍵[;5])`. `(1↓⍵[;1])` is the first column of our results matrix (which represents whether strings started with a nonspace) without the value from the first result; `(¯1)↓⍵[;5]` is the last column (representing whether strings ended with a nonspace) without the value from the last result. We and these together with `∧` and sum that with `+/` to get the number of times we split a word; prepending `-` negates the value and placing it in the middle of a vector of four zeroes lets us just add it to our calculated result, adjusting the word count appropriately.

Now we add a user defined operator to handle looping over reading a file. The below does this:

```
v←(f rc)fd;data
v←⍬
:Repeat
    data←⎕NREAD fd 80(1024×1024)
    :If 0<≢data
        v←f data
    :EndIf
:Until 0=≢data
```

`v` is the output of the operator, we need this for technical reasons but the value won't be used. Our operator accepts a computation to use on each string on its left and a file descriptor on its right and loops until it has consumed all the data in the file.

Finally, we can bring this all together in a (possibly) simpler implementation of `wc` which relies on the computations we've defined. Since we no longer need to use looping or conditionals in `wc` (all that work is done in `rc`), we can make `wc` a direct function:

```
wc←{
    res←1 5⍴0
    update←{
        val←res,[1]blockCount ⍵
        res∘←val
        val
    }
    fd←⍵ ⎕NTIE 0
    _←update rc fd
    _←⎕NUNTIE fd
    (blockCollapse res)[4 3 2]
}
```

We start by making `res` a zero-filled matrix of one row by five column. Then we define a helper function `update` which will update `res` using `blockCount`. `,[1]` lets us use ravel along its lefthand argument's first axis so that `val` will be `res` with the result from `blockCount ⍵` appended as the last row. `∘←` lets us update `res` from within `update` and we return `val`.

Just like the built in operators we put our operated function on the left of `rc` which creates a derived function that accepts the file descriptor `fd`. `rc` will iterate over the contents of `fd` and successively apply update. We have to assign the result (or just use it somehow) as the first unused computation of a direct function is its return value, and we don't want an early return.

Finally, we used `blockCollapse` to compress the result matrix down into the desired answer and pick out the values we want with `[4 3 2]`.
