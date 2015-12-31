module Vector2 ( Vec2, toVec2, lengthSquared, length
               , normalize, direction, dot, angle
               ) where

type alias Vec2 = ( Float, Float )

-- convert two points in space to a vector
toVec2 : ( Float, Float ) -> ( Float, Float ) -> Vec2
toVec2 (ax, ay) ( bx, by ) =
    ( bx - ax, by - ay )


lengthSquared : Vec2 -> Float
lengthSquared ( v0, v1 ) =
  v0 * v0 + v1 * v1
  

length : Vec2 -> Float
length ( v0, v1 ) =
  sqrt( v0 * v0 + v1 * v1 )


normalize : Vec2 -> Vec2
normalize ( v0, v1  ) =
  let 
    im = 1.0 / length ( v0, v1 )
  in
    ( v0 * im, v1 * im )
  
-- calculate unit direction vector 
-- from points r s
direction : ( Float, Float ) -> ( Float, Float ) -> Vec2
direction r s =
    toVec2 r s |> normalize


dot : Vec2 -> Vec2 -> Float
dot ( a0, a1 ) ( b0, b1 ) =
    a0 * b0 + a1 * b1

determinant : Vec2 -> Vec2 -> Float
determinant ( a0, a1 ) ( b0, b1  ) =
  a0 * b1 - b0 * a1

{-- compute angle between to vectors -}

angle : Vec2 -> Vec2 -> Float
angle v1 v2 =
   atan2 ( determinant v1 v2 ) ( dot v1 v2 ) 
