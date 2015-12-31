module Tests where

import ElmTest exposing (..)
import GraphicUtils exposing ( toCollagePoint )
import Vector2 as V2 exposing ( toVec2, normalize, length, angle )
import PreProcessPoints exposing ( removeClusters, identifyCharPoints )
import Components exposing ( Components, Component, components )
import Levenstein exposing ( editDistance )
import ClassifyGesture exposing ( classifyGesture )



type alias Point = ( Float, Float )
type alias Points = List Point

{- toCollagePoint Tests -}

noOffset : Test
noOffset =
  let
    window = ( 100.0, 100.0 )
    collage = ( 100.0, 100.0 )
    offset = ( 0.0, 0.0 )
    point = ( 50.0, 50.0 )
  in
    test "wdin = cdim, no offset" <| assertEqual ( 0.0, 0.0 )
                        <| toCollagePoint window collage offset point

withScale : Test
withScale =
  let
    window = ( 100.0, 100.0 )
    collage = ( 50.0, 50.0 )
    offset = ( 0.0, 0.0 )
    point = ( 0.0, 0.0 )
  in
    test "cdim / wdim, no offset" <| assertEqual ( -25.0, 25.0 )
                        <| toCollagePoint window collage offset point

withOffset : Test
withOffset =
  let
    window = ( 100.0, 100.0 )
    collage = ( 100.0, 100.0 )
    offset = ( 50.0, 50.0 )
    point = ( 0.0, 0.0 )
  in
    test "cdim = wdim, with offset" <| assertEqual ( 0.0, 0.0 )
                        <| toCollagePoint window collage offset point


withScaleAndOffset : Test
withScaleAndOffset =
  let
    window = ( 100.0, 100.0 )
    collage = ( 50.0, 50.0 )
    offset = ( 50.0, 50.0 )
    point = ( 0.0, 0.0 )
  in
    test "cdim / wdim, with offset" <| assertEqual ( 0.0, 0.0 )
                        <| toCollagePoint window collage offset point
  
collageTests : List Test
collageTests =
  [ noOffset, withScale, withOffset, withScaleAndOffset ]


toCollagePointSuite : Test
toCollagePointSuite =
  suite "toCollagePoint" collageTests


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


angleTest : Test
angleTest =
  let 
    a = ( 1.0, 0.0 )
    b = ( 0.0, -1.0 )
    theta = (-pi) / 2.0
  in
    test "angleTest" <| assertEqual theta ( V2.angle a b )


vec2Tests : List Test
vec2Tests =
 [ toVec2Test, lengthTest, lengthSquaredTest, normalizeTest, angleTest ]


vector2Suite : Test
vector2Suite =
  suite "Vector2" vec2Tests
    
    
{- PreProcesPoints Suite -}
emptyClusters : Test
emptyClusters =
  let
    l1 = [ ]
  in
    test "empty list" <| assertEqual l1 ( removeClusters l1)


onePoint : Test
onePoint =
  let
    l1 = [ ( 0.0, 0.0 )  ]
  in
    test "one point" <| assertEqual l1 ( removeClusters l1)


twoPoints : Test
twoPoints =
  let
    before = [ ( 0.0, 0.0 ), ( 7.0, 0.0 )  ]
    after = [ ( 0.0, 0.0 ) ]
  in
    test "two points < threshold" <| assertEqual after ( removeClusters before)


morePoints : Test
morePoints =
  let
    before = [ ( 0.0, 0.0 ), ( 7.0, 0.0 ), ( 10.0, 0.0 ), ( 12.0, 0.0 )  ]
    after = [ ( 0.0, 0.0 ), ( 10.0, 0.0 ) ]
  in
    test "more points <> threshold" <| assertEqual after ( removeClusters before)


clusterTests : List Test
clusterTests =
  [ onePoint, twoPoints, morePoints, emptyClusters ]


clusterSuite : Test
clusterSuite =
  suite "RemoveClusters suite" clusterTests


{- charPoints suite -}

angleGreaterTwo : Test
angleGreaterTwo =
  let
    before = [ ( 0.0, 0.0 ), ( 1.0, 0.0 ) ]
    after = [ ( 0.0, 0.0 ), ( 1.0, 0.0 ) ]
  in
    test "angleGreater than tolerance but two points" <| assertEqual after ( identifyCharPoints before)


angle90 : Test
angle90 =
  let
    before = [ ( 0.0, 0.0 ), ( 1.0, 0.0 ), ( 1.0, 1.0 )]
    after = [ ( 0.0, 0.0 ), ( 1.0, 0.0 ), ( 1.0, 1.0 ) ]
  in
    test "angle90 than tolerance" <| assertEqual after ( identifyCharPoints before)

-- Todo: Review the validity of this test
angleLessGreater : Test
angleLessGreater =
  let
    before = [ ( 0.0, 0.0 ), ( 1.0, 0.0 ), (0.0, 0.15 ) ]
    after = [ ( 0.0, 0.0 ), ( 1.0, 0.0 ), ( 0.0, 0.15 ) ]
  in
    test "angleLessGreater than tolerance" <| assertEqual after ( identifyCharPoints before)


emptyCharPoints : Test
emptyCharPoints =
  let
    l1 = [ ]
  in
    test "empty list" <| assertEqual l1 ( identifyCharPoints l1 )


charPointsTests : List Test
charPointsTests =
  [ emptyCharPoints, angleGreaterTwo, angleLessGreater, angle90 ]


charPointsSuite : Test
charPointsSuite =
  suite "CharPoints suite" charPointsTests


initializeComponents : Test
initializeComponents =
  let
    table : Components
    table =
    [ { name = "Dropdown"
      , sequence = [ '0', '2' ]
      }
    , { name = "Input Field"
      , sequence = [ '6', '0' ] 
      }
    ]
  in
    test "initialize components" <| assertEqual table components
    

componentsTest : List Test
componentsTest =
  [ initializeComponents ]


componentsSuite : Test
componentsSuite =
  suite "Components suite" componentsTest


kittenSitting : Test
kittenSitting =
  let
    kitten : List Char
    kitten = [ 'k', 'i', 't', 't', 'e', 'n' ]
    sitting : List Char
    sitting = [ 's', 'i', 't', 't', 'i', 'n', 'g' ]
    cost = 3
  in
    test "Levenstein cost kitten vs. sitting = 2" <| assertEqual cost ( editDistance kitten sitting )

emptySequence : Test
emptySequence =
  let
    kitten : List Char
    kitten = [ 'k', 'i', 't', 't', 'e', 'n' ]
    empty : List Char
    empty = [ ]
    cost = 6
  in
    test "Levenstein cost kitten vs. empty list = 6" <| assertEqual cost ( editDistance kitten empty )
    

levensteinTest : List Test
levensteinTest =
  [ kittenSitting, emptySequence ]


levensteinSuite : Test
levensteinSuite =
  suite "Levenstein suite" levensteinTest


-- xAxis1 : Test
-- xAxis1 =
--   let
--     p1 = ( 0.0, 0.0 )
--     p2 = ( 0.0, 1.0 )
--     r = pi / 2.0
--   in
--     test "90 degrees: direction is North" <| assertEqual r ( angleXAxis p1 p2 )

-- xAxis2 : Test
-- xAxis2 =
--   let
--     p1 = ( 0.0, 0.0 )
--     p2 = ( -1.0, 0.0 )
--     r = pi
--   in
--     test "180 degrees: direction is West" <| assertEqual r ( angleXAxis p1 p2 )
    

-- xAxis3 : Test
-- xAxis3 =
--   let
--     p1 = ( 0.0, 0.0 )
--     p2 = ( 0.785398, -0.785398 )
--     r = degrees (-45.0)
--   in
--     test "-45 degrees: direction is South East" <| assertEqual r ( angleXAxis p1 p2 )
    

-- makeSequence1 : Test
-- makeSequence1 =
--   let
--     charPoints = [ ( 0.0, 0.0 ), ( 1.0, 0.0 ), ( 1.0, 1.0) ]
--     sequence = makeSequence charPoints [  ]
--     sequence_ = [ '0', '6' ]
--   in
--     test "L reversed" sequence sequence_ 


classifyGesture1 : Test
classifyGesture1 =
  let
    gesture = [ ( 0.0, 0.0 ), ( 1.0, 0.0 ), ( 1.0, -1.0 ) ]
    match : Component
    match = { name = "Dropdown", sequence = [ '0', '2' ] }
  in
    test "Dropdown" <| assertEqual match (classifyGesture gesture)


classifyGesture2 : Test
classifyGesture2 =
  let
    gesture = [ ( 0.0, 0.0 ), ( 0.0, 1.0 ), ( 1.0, 1.0 ) ]
    match : Component
    match = { name = "Input Field", sequence = [ '6', '0' ] }
  in
    test "Dropdown" <| assertEqual match (classifyGesture gesture)


classifyGestureTests : List Test
classifyGestureTests =
  [ classifyGesture1, classifyGesture2 ]


classifyGestureSuite : Test
classifyGestureSuite =
  suite "ClassifyGesture suite" classifyGestureTests


all : Test
all =
  suite "All the suites" [ toCollagePointSuite
                         , vector2Suite
                         , clusterSuite
                         , charPointsSuite
                         , componentsSuite
                         , levensteinSuite
                         , classifyGestureSuite
                         ]

