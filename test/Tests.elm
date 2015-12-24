module Tests where

import ElmTest exposing (..)
import GraphicsUtils exposing ( Point, toCollage )
import Vector2 as V2


{- toCollage Tests -}

noOffset : Test
noOffset =
  let
    window = ( 100.0, 100.0 )
    collage = ( 100.0, 100.0 )
    offset = ( 0.0, 0.0 )
    point = ( 50.0, 50.0 )
  in
    test "wdin = cdim, no offset" <| assertEqual ( 0.0, 0.0 )
                        <| toCollage window collage offset point

withScale : Test
withScale =
  let
    window = ( 100.0, 100.0 )
    collage = ( 50.0, 50.0 )
    offset = ( 0.0, 0.0 )
    point = ( 0.0, 0.0 )
  in
    test "cdim / wdim, no offset" <| assertEqual ( -25.0, 25.0 )
                        <| toCollage window collage offset point

withOffset : Test
withOffset =
  let
    window = ( 100.0, 100.0 )
    collage = ( 100.0, 100.0 )
    offset = ( 50.0, 50.0 )
    point = ( 0.0, 0.0 )
  in
    test "cdim = wdim, with offset" <| assertEqual ( 0.0, 0.0 )
                        <| toCollage window collage offset point


withScaleAndOffset : Test
withScaleAndOffset =
  let
    window = ( 100.0, 100.0 )
    collage = ( 50.0, 50.0 )
    offset = ( 50.0, 50.0 )
    point = ( 0.0, 0.0 )
  in
    test "cdim / wdim, with offset" <| assertEqual ( 0.0, 0.0 )
                        <| toCollage window collage offset point
  
collageTests : List Test
collageTests =
  [ noOffset, withScale, withOffset, withScaleAndOffset ]


toCollageSuite : Test
toCollageSuite =
  suite "toCollage" collageTests


{- Vector2 Tests -}

toVec2Test : Test
toVec2Test =
  let
    a = ( 0.0, 0.0 )
    b = ( 1.0, 0.0 )
  in
    test "toVec2" <| assertEqual ( 1.0, 0.0 ) ( V2.toVec2 a b )


normalizeTest : Test
normalizeTest =
  let
    a = ( 1.0, 0.0 )
  in
    test "normalize" <| assertEqual ( 1.0, 0.0) ( V2.normalize a )


lengthSquaredTest : Test
lengthSquaredTest =
  let
    a = ( 5.0, 5.0 )
  in
    test "lengthSquaredTest" <| assertEqual 50.0 ( V2.lengthSquared a )

lengthTest : Test
lengthTest =
  let
    a = ( 5.0, 5.0 )
  in
    test "lengthTest" <| assertEqual ( sqrt 50.0 ) ( V2.length a )


vec2Tests : List Test
vec2Tests =
 [ toVec2Test, lengthTest, lengthSquaredTest, normalizeTest ]


vector2Suite : Test
vector2Suite =
  suite "Vector2" vec2Tests
    
    


all : Test
all =
  suite "All the suites" [ toCollageSuite, vector2Suite ]

