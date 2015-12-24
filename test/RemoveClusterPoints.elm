module removeClusterPoints where

import Vector2 as V2

type alias Point = ( Flaot, Float )

type alias Points =
     List Point

{-
The constraint of the minimal distance protects against creation
of spatial clusters of points.
-}

removeClusterPoints : Float -> Points -> Points
removeClusterPoints precision points =
  let
    squarePrecision = 64.0

    isMinDistance : Point -> Point -> Bool
    isMinDistance ( x1, y1 ) (x2, y2) =
      let
        diffX = x2 - x1
        diffY = y2 - y1
        squareDistance = (diffX * diffX) + ( diffY * diffY )
      in
        squareDistance > squarePrecision

    basePoints : Point -> Points -> Points
    basePoints p2 points_ =
      case points_ of 
        p1::_ ->
          if isMinDistance p1 p2
            then p2 :: points_
            else points_

        [ ] ->
          p2 :: [ ]

    in
      List.foldl basePoints [  ] points |> List.reverse
     

