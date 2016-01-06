module GraphicUtils ( Point, Points, toCartesian
                    , toCartesians, toViewport
                    ) where

type alias Point = ( Float, Float )
type alias Points = List Point

-- window, collage dimensions
type alias Collage = Point  -- collage == viewport
type alias Window = Point
-- in window coordinates
type alias Offset = Point

{-
Transform a point in screen space to cartesian space
Mouse points are in screen coordinates, Collage points are in 
Cartesian coordinates
-}

-- toCartesian : Window -> Collage -> Offset -> Point -> Point
-- toCartesian ( w, h ) ( cw, ch )( dx, dy ) ( x, y ) =
--   let
--     ( sw, sh ) = (cw / w, ch / h) -- Scale = percentage Window / Screen
--   in
--     ( (x - ( w / 2.0) + dx) * sw, ( ( h / 2.0 ) - y - dy ) * sh)


toCartesian : Window -> Point -> Point
toCartesian ( w, h ) ( x, y ) =
    ( x - ( w / 2.0), ( h / 2.0 ) - y )


toCartesians : Point -> Points -> Points
toCartesians window points =
  List.map ( toCartesian window ) points


toViewport : Window -> Collage -> Offset -> Point -> Point
toViewport ( w, h ) ( cw, ch )( dx, dy ) ( x, y ) =
  let
    ( sw, sh ) = (cw / w, ch / h) -- Scale = Collage Dimensions / Window Dimensions
  in
    ( (x + dx) * sw, ( y + dy ) * sh )

