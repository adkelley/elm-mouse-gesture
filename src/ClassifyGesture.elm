module Classify where

import Elements exposing ( elements )
import Levenstein exposing ( editDistance )

{- 
Given a list of CharPoints, compute the direction vectors and
use them to determine the closest matching element from the
list of elements
-}

matchElement : Points -> String
matchElement charPoints =
  let
    directionAngle : Point -> Point -> Float
    directionAngle p1 p2 =
      let
        (p1x, p1y ) = p1
        a = V2.direction p1 p2
        ( ax, ay ) = Debug.log "ax, ay" ( fst a, snd a )
        b = V2.direction ( p1x, p1y ) (p1x+1.0, p1y)
        angle = V2.dot b a |> acos
        angle'=
          if (ax < 0 && ay > 0) ||  (ax > 0 && ay > 0) then
            -angle
          else
            angle
      in
        Debug.log "Angle: " angle'


    direction : Point -> Point -> Char
    direction p1 p2 =
       let
         angle = directionAngle p1 p2
       in
         if angle > -0.3926991 && angle <= 0.3926991 then
           '0'
              else if angle > 0.3926991 && angle <= 1.178097 then
                '7'
              else if angle > 1.178097 && angle <= 1.9634954 then
                '6'
              else if angle > 1.9634954 && angle <= 2.74017 then
                '5'
              else if angle > 2.74017 && angle >= -2.74017 then
                '4'
              else if angle > -2.74017 && angle >= -1.9634954 then
                '3'
              else if angle > -1.9634954 && angle >= -1.178097 then
                '2'
          else 
            '1'
              

    levenSequence : Points -> Direction -> Direction
    levenSequence charPoints_ sequence =
      case charPoints_ of
        p2::[ ] ->
            List.reverse sequence

        p1::p2::tail ->
          let
            gesture = direction p1 p2
          in
            levenSequence (p2::tail) (gesture::sequence)

        otherwise ->
            sequence

    score : Direction -> Direction -> Int
    score element gesture =
      editDistance element gesture


    match : Direction -> String
    match sequence =
        "Match point"
                                                 
  in
    match <| Debug.log "Direction" <| levenSequence charPoints [ ]


