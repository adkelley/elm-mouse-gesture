module Vector2 where

type alias Vec2 = ( Float, Float )
type alias Point = ( Float, Float )


toVec2 : Point -> Point -> Vec2
toVec2 (rx, ry) ( sx, sy ) =
    ( sx - rx, sy - ry )


length : Vec2 -> Float
length ( vx, vy ) =
  sqrt( vx * vx + vy * vy )


normalize : Vec2 -> Vec2
normalize ( vx, vy  ) =
  let 
    im = 1.0 / length ( vx, vy )
  in
    ( vx * im, vy * im )
  
-- calculate unit direction vector 
-- from points r s
direction : Point -> Point -> Vec2
direction r s =
    toVec2 r s |> normalize


dot : Vec2 -> Vec2 -> Float
dot ( ax, ay ) ( bx, by ) =
    ax * bx + ay * by

