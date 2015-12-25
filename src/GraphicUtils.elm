module GraphicUtils ( toCollagePoint ) where

type alias Point = ( Float, Float )
-- window, collage dimensions
type alias Window = Point
type alias Collage = Point
-- in window coordinates
type alias Offset = Point

{-
Transform a point in window space to a point in collage space
-}

toCollagePoint : Window -> Collage -> Offset -> Point -> Point
toCollagePoint ( w, h ) ( cw, ch )( dx, dy ) ( x, y ) =
  let
    ( sw, sh ) = (cw / w, ch / h) -- percentage Collage / Window
  in
    ( (x - ( w / 2.0) + dx) * sw, ( ( h / 2.0 ) - y - dy ) * sh)


{-
Transform a collage point to viewport point
-}
toViewport : Point -> Point -> Point -> Point -> Point
toViewport (w, h ) ( vw, vh ) ( dx, dy ) ( x, y ) =
  ( (vw / w) * x + dx, (vh / h) * y + dy )

