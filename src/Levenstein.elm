module Levenstein
    ( editDistance ) where

import List exposing ( head, tail, length )

type alias Cost = Int
type alias Gesture = List Char

minimum : Cost -> Cost -> Cost -> Cost
minimum a b c =
  min a (min b c)


{-
Recursive (slow) implementation of the Levenstein Distance Algorithm
https://en.wikipedia.org/wiki/Levenshtein_distance#Recursive

This will need to be refactored to a matrix method for production
http://people.cs.pitt.edu/~kirk/cs1501/Pruhs/Fall2006/Assignments/editdistance/Levenshtein%20Distance.htm
-}

editDistance : Gesture -> Gesture -> Cost
editDistance try move =
  let 
    cost = 
      if ( head try ) == ( head move )
        then 0
        else 1
    ts =
       case tail try of
         Just a -> a
         Nothing -> [ ]
    ms =
       case tail move of
         Just a -> a
         Nothing -> [ ]
  in
    if try == [ ] then
      length move
    else if move == [ ] then
      length try
    else
      minimum ( (+) ( editDistance ts move ) 1 )
              ( (+) ( editDistance try ms ) 1 )
              ( (+) ( editDistance ts ms ) cost )
