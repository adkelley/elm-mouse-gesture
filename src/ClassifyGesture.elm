module ClassifyGesture ( classifyGesture ) where

import Components exposing ( Component, Components, initComponent, components )
import Levenstein exposing ( Sequence, editDistance )
-- todo: expose Vec2
import Vector2 as V2 exposing ( Vec2, angle, toVec2 )

type alias Point = ( Float, Float )
type alias Points = List Point

{- 
Given a list of CharPoints, compute the direction vectors and
use them to determine the closest matching element from the
list of elements
-}

directionChar : Point -> Point -> Char
directionChar p1 p2 =
  let
    pi18 = pi / 8.0
    pi38 = 3.0 * pi18
    pi58 = 5.0 * pi18
    pi78 = 7.0 * pi18
    angle_ = angle ( 1.0, 0.0 ) ( toVec2 p1 p2 )
  in
    if angle_ > -pi18 && angle_ <= pi18 then '0'
    else if angle_ > pi18 && angle_ <= pi38 then '7'
    else if angle_ > pi38 && angle_ <= pi58 then '6'
    else if angle_ > pi58 && angle_ <= pi78 then '5'
    else if angle_ > pi78 && angle_ <= -pi78 then '4'
    else if angle_ < -pi18 && angle_ >= -pi38 then '1'
    else if angle_ < -pi38 && angle_ >= -pi58 then '2'
    else if angle_ < -pi58 && angle_ >= -pi78 then '3'
    else '4'


makeSequence : Points -> Sequence -> Sequence
makeSequence charPoints sequence =
    case charPoints of
        p1::p2::tail ->
          let
            direction = directionChar p1 p2
          in
            makeSequence (p2::tail) (direction::sequence)

        otherwise ->
            List.reverse sequence
  


lowestScore : Sequence -> Components -> Component -> Int -> Component
lowestScore gesture elements match lowScore =
  case elements of
    [ ] -> match

    element_::tail ->
      let 
        score = editDistance element_.sequence gesture
      in
        if score < lowScore
        then lowestScore gesture tail element_ score
        else lowestScore gesture tail match lowScore


classifyGesture : Points -> Component
classifyGesture charPoints =
  let
    sequence = makeSequence charPoints [  ]
  in
    lowestScore sequence components initComponent 10000

