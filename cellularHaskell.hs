import Data.List
import System.Random
import System.Posix

{-

-------- COOL RULES --------

these were tested with a single active cell in the middle (using showSimulation),
might yield cool results with randomSimulation as well though.

3 ancestors:

73
99 -> steep shaded cone
105
109
118 -> shaded cone
120 (random init)
126 -> sierpinsky
129 -> inv. sierpinsky
131 -> inv. shaded cone
150
169
225

5 ancestors:

914134 -> pyramid
914138 -> sierpinsky wide
9141401 -> river
91415443 -> weird mountain

7 ancestors:

21133586
21133650 -> cliff



-------- how to cellular automata --------

(try zooming out your terminal)

ghci filename.hs

set the ancestors variable to the desired value (only 2n+1, even numbers break stuff..),
save the file and reload in ghci (type :r)

for a simulation from a single active cell in the middle, use for example this in ghci:
  (\x -> putStr $ showSimulation 90 x (initState 150)) 99
where 90 is your terminal height and 150 your terminal width.
I'm using a lambda here so that I can easily press upArrow to show the last command
and edit the rule, in order to quickly discover cool rules without having to move your
cursor through the entire command.

for a simulation starting from a random state, use for example this command in ghci:
  (\x -> randomSimulation 90 x 150) 99
Again, using a lambda to have the rule number on the end where I can quickly edit it.

For looping though rules with half a second of delay between the simulations, use this:
  sequence $ map (\x -> (putStr $ (show x) ++ "\n" ++ showSimulation 90 x (initState 150)) >> usleep 500000) [101..127]
where 101..127 is the range to loop over. 101..127 is a pretty range :) (3 ancestors)
This might not work on every system (because of the sleep command, which might not be
very portable..)
Again, using a lambda to have the rule number on the end where I can quickly edit it.
Actually, might move this to a function at some point.


-}

ancestors :: Int
ancestors = 3

-- prints a simulation to the console, starting from a random state.
--
-- arguments:
--   vertical length of the simulation (nr. of steps)
--   nr of rule to use
--   the width of the simulation
randomSimulation :: Int -> Int -> Int -> IO ()
randomSimulation len rule width = (fmap (showSimulation len rule) $ getRandomState width) >>= putStr

-- returns a random state in an IO monad.
--
-- arguments:
--   length of random state to generate
getRandomState :: Int -> IO [Bool]
getRandomState i = sequence $ replicate i $ randomRIO (False, True)

-- returns a state consisting of a single active cell in the
-- middle and inactive cells around it. Length of returned
-- state will be 2n+1.
--
-- arguments:
--   number of inactive cells on either side.
initState :: Int -> [Bool]
initState n = (replicate n False) ++ [True] ++ (replicate n False)

-- returns a String containing newlines (\n) where each
-- line is a state of the simulation, the first line being
-- the string representation of the initial state from the
-- input.
-- 
-- arguments:
--   vertical length of the simulation (nr. of steps)
--   nr of rule to use
--   the initial state
showSimulation :: Int -> Int -> [Bool] -> String
showSimulation len rule state = unlines $ map showState $ take len $ simulate rule state

-- returns an infinite list of states.
--
-- arguments:
--   nr of rule to use
--   the initial state
simulate :: Int -> [Bool] -> [[Bool]]
simulate rule init = iterate (nextState rule) init

-- convert a single state (1 line) to a string
showState :: [Bool] -> String
showState = map f
  where f a = if a then '#' else ' '

-- returns the next state given a certain rule. Depends on
-- global variable 'ancestors'. I know this is not pretty,
-- but given the rather small project size, and that it's
-- not likely gonna grow, this is kinda ok.
--
-- arguments:
--   nr of rule to use
--   the current state
nextState :: Int -> [Bool] -> [Bool]
nextState rule current = map (translate rule) $ toNlets ancestors current

-- returns a single Bool given its ancestors and the rule
--
-- arguments:
--   nr of rule to use
--   the list of ancestors
translate :: Int -> [Bool] -> Bool
translate rule nlet = (reverse (decToBin rule) ++ repeat False) !! binToDec nlet

-- returns a list of lists of bools, which I, for the purposes
-- of this project, call a list of nlets, representing the
-- groupings of ancestors that will be passed in to the rule
-- transformation
--
-- arguments:
--   nr of rule to use
--   current state
toNlets :: Int -> [a] -> [[a]]
toNlets n a =
  let
    wrapped = wrap ((n-1) `quot` 2) a
    len = length a
  in
    transpose $ map (take len) $ map (\x -> drop x wrapped) [0..(n-1)]

-- returns an overwrapped (is that a word?) list, where n
-- elements from the end are prefixed to the start and n
-- elements from the start are added to the end.
--
-- arguments:
--   n - amount of wrapping
--   input list
wrap :: Int -> [a] -> [a]
wrap n a = (drop (len - n) a) ++ a ++ (take n a)
  where len = length a


-- convert from decimal to Bool aray (big endian)
decToBin :: Int -> [Bool]
decToBin x = map (==1) $ reverse $ decToBin' x
  where
    decToBin' 0 = []
    decToBin' y =
      let (a,b) = y `quotRem` 2
      in [b] ++ decToBin' a


-- convert from Bool array to decimal (big endian)
binToDec :: [Bool] -> Int
binToDec x = foldl f 0 x
  where
    f acc e = acc * 2 + if e then 1 else 0


-- left pad a list up to a specified length
--
-- arguments:
--   character to leftpad with
--   final desired length of list
--   input list
lpad :: a -> Int -> [a] -> [a]
lpad x len xs = replicate (len - length xs) x ++ xs
