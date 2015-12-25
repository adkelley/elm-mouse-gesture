module PreProcessPoints ( identifyCharPoints, removeClusters  ) where

import Vector2 as V2

type alias Point = ( Float, Float )
type alias Points = List Point

{-
Characteristic points have a significant change in the angle
between 2 contiguous line segments.  The heuristic for a significant
change in angle is 20+ degrees per Hofman & Piaseki
-}

{--}
identifyCharPoints_ : Points -> Points -> Points
identifyCharPoints_ points charPoints =
  let
    minAngle = degrees 20.0
  in
    case points of
      [ ] ->
        charPoints

      p1::[ ] ->
        charPoints

      p1::p2::[ ] ->
        p2::charPoints

      p1::p2::p3::tail ->
        let 
          ab = V2.toVec2 p2 p1
          bc = V2.toVec2 p2 p3
          angle = V2.angle ab bc
        in
          if angle > minAngle
            then identifyCharPoints_ (p2::p3::tail) (p2::charPoints)
            else identifyCharPoints_ (p1::p3::tail) charPoints


identifyCharPoints : Points -> Points
identifyCharPoints points =
  let
    head xs =
      case List.head xs of
        Just x -> [ x ]
        Nothing -> [ ]   
  in
    identifyCharPoints_ points (head points) |> List.reverse
    
--}
{-
The constraint of the minimal distance protects against creation
of spatial clusters of points.
-}

removeClusters_ : Points -> Points -> Points
removeClusters_  points  noClusters =
  let
    isMinDistance : Point -> Point -> Bool
    isMinDistance a b =
      let
        -- precision = 8
        squarePrecision = 64.0
      in
        ( V2.toVec2 a b  |> V2.lengthSquared ) > squarePrecision
  in
    case points of 
      [ ] ->
        noClusters
        
      p1::[ ] ->
        noClusters
             
      p1::p2::tail ->
        if isMinDistance p1 p2 then
          removeClusters_ ( p2::tail ) (p2::noClusters)
        else
          removeClusters_ ( p1::tail ) noClusters


removeClusters : Points -> Points
removeClusters points =
  let
    head xs =
      case List.head xs of
        Just x -> [ x ]
        Nothing -> [ ]   
  in
    removeClusters_ points (head points) |> List.reverse
