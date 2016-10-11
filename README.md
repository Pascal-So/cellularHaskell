# cellularHaskell
cellular automata in haskell

## Usage

Try zooming out your terminal for better results.

`ghci filename.hs`

Set the ancestors variable to the desired value (only 2n+1, even numbers break stuff..), then save the file and reload it in ghci (type `:r`)


For a simulation from a **single active cell in the middle**, use for example this in ghci:
```Haskell
(\x -> putStr $ showSimulation 90 x (initState 150)) 99
```
where `90` is your terminal height and `150` your terminal width.
I'm using a lambda here so that I can easily press upArrow to show the last command and edit the rule, in order to quickly discover cool rules without having to move your cursor through the entire command.

For a simulation starting from a **random state**, use for example this command in ghci:
```Haskell
(\x -> randomSimulation 90 x 150) 99
```  
Again, using a lambda to have the rule number on the end where I can quickly edit it.

For **looping though rules** with half a second of delay between the simulations, use this:
```Haskell
sequence $ map (\x -> (putStr $ (show x) ++ "\n" ++ showSimulation 90 x (initState 150)) >> usleep 500000) [101..127]
```
where `101..127` is the range to loop over. `101..127` is a pretty range :) (3 ancestors)
This might not work on every system (because of the sleep command, which might not be
very portable..)
Again, using a lambda to have the rule number on the end where I can quickly edit it.
Actually, might move this to a function at some point.

For running the **simulation with a random rule**, use this:
```Haskell
randomRIO (1, 127) >>= (\x -> putStr $ (show x) ++ "\n" ++ showSimulation 90 x (initState 150))
```
This will print a simulation starting from a single active cell in the middle, using a random rule between 1 and 127 inclusive. For 5 ancestors, use `randomRIO (1,2147483647)` and for 7 ancestors use `randomRIO (1,170141183460469231731687303715884105727)`. We don't need to include the second half, because the second half should be equivalent to the first due to symmetry.


## cool rules


these were tested with a single active cell in the middle (using showSimulation),
might yield cool results with randomSimulation as well though.

(if you don't want to/aren't able to try these out on your machine, you can still see some results in coolResults.md)

### 3 ancestors:

* 73
* 99 -> steep shaded cone
* 105
* 109
* 118 -> shaded cone
* 120 (random init)
* 126 -> sierpinsky
* 129 -> inv. sierpinsky
* 131 -> inv. shaded cone
* 150
* 169
* 225

### 5 ancestors:

* 914134 -> pyramid
* 914138 -> sierpinsky wide
* 9141401 -> river
* 91415443 -> weird mountain

### 7 ancestors:

* 21133586
* 21133650 -> cliff
