module MouseGesture where
{-
 Determining Characteristic points came from:
   "Efficient Recognition of Mouse-based Gestures"
   https://www.ii.pwr.edu.pl/~piasecki/publications/hofman-piasecki-v1-1.pdf
-}

import Color exposing ( .. )
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Levenstein exposing ( editDistance )
import Vector2 as V2
import Mouse
import Keyboard
import Window
import Time
import Debug

type alias Point = (Float, Float)

type alias Points =
     List Point

type alias Direction =
     List Char

-- Element is a reserved word!

type alias Element' =
    { name : String
    , direction : Direction
    }

type alias Elements = List Element'

type alias Model =
    { mousePoints : Points
    , lastPosition : Point
    , mousePressed : Bool
    , charPoints : Points
    , elements : Elements
    , elementName : String
    }

-- Model

setElements : Elements
setElements =
    [ { name = "Input Field"
      , direction = [ '6', '0' ] 
      }
    , { name = "Dropdown"
      , direction = [ '0', '2' ]
      }
    ]

initialModel : Model
initialModel =
    { mousePoints = [ ]
    , lastPosition = ( -1.0, -1.0 )
    , mousePressed = False
    , charPoints = [ ]
    , elementName = ""
    , elements = setElements
    }

-- View

toCollage : Point -> Point -> Point -> Point
toCollage ( w, h ) ( dx, dy ) ( x, y ) =
  ( x + dx - ( w / 2.0), ( h / 2.0 ) - y - dy)


toViewport : Point -> Point -> Point -> Points -> Points
toViewport (w, h ) ( vw, vh ) ( dx, dy ) points =
   let 
      toViewport_ : Point -> Point
      toViewport_ ( x, y ) =
        ( vw / w * x + dx, vh / h * y - dy )
   in
       List.map toViewport_ <| List.map (toCollage ( w, h ) ( dx, dy )) points


drawBorder : Point -> Point -> Form
drawBorder ( w, h ) ( dx, dy )=
  let 
    (left, top) = toCollage (w, h) ( dx, dy ) ( 0.0, 0.0 ) 
    (right, bottom) = toCollage ( w, h ) ( dx, dy ) ( w, h )
  in
      traced { defaultLine
           | color = black
           , width = 2
           }
           ( path [ (left, top), ( right, top ), ( right, bottom ), ( left, bottom ), ( left, top ) ] )


drawGesture : Point -> Point -> Point -> Points -> Form
drawGesture window viewport offset charPoints
  = toViewport window viewport offset charPoints
  |> path
  |> traced { defaultLine
            | color = red
            , width = 5
            }
             

showElementName : String -> Form
showElementName elementName =
   toForm ( show elementName )


view : ( Int, Int ) -> Model -> Element
view ( w, h ) model =
  let
    w' = toFloat w
    h' = toFloat h
    window = ( w', h')
    vw = w' / 4.0
    vh = h' / 4.0
    viewport = (vw, vh)
    dx = 10.0
    dy = 10.0
    offset = ( dx, dy)
  in
    collage (round ( vw + dx*2 )) (round ( vh + dy*2 ))
      [ drawBorder viewport offset
      , drawGesture window viewport offset model.charPoints
      , showElementName model.elementName
      ]
    
-- Update

type Action
  = NoOp
  | MouseUp
  | MouseDown ( Int, Int )


update : Action -> Model -> Model
update action model =
    case action of
      NoOp ->
        model

      MouseUp ->
         if model.mousePressed
           then
             { model
             | mousePoints = [  ]
             , mousePressed = False
             , charPoints
                 =  model.mousePoints
                 |> removeClusterPoints
                 |> identifyCharPoints 
             , elementName
                 =  model.mousePoints
                 |> Debug.log "Mouse Points: "
                 |> removeClusterPoints
                 |> Debug.log "No Clusters: "
                 |> identifyCharPoints
                 |> List.reverse 
                 |> Debug.log "CharPoints: "
                 |> matchElement
             }
            else model

      MouseDown ( x, y ) ->
          let 
            position =
                (toFloat x, toFloat y  )
          in
            { model
            | mousePressed = True
            , mousePoints = position :: model.mousePoints
            , lastPosition = position
            }


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
        (d2x, d2y) = V2.direction p1 p2
        d2x2 = d2x * d2x
        d2y2 = d2y * d2y
        sqrtD2 = sqrt ( d2x2 + d2y2 )
      in
        Debug.log "Angle: " <| acos( d2x / ( sqrtD2 ) ) 


    direction : Point -> Point -> Char
    direction p1 p2 =
       let
         angle = directionAngle p1 p2
       in
         case angle of
           0.0 -> '0'
           90.0 -> '6'
           180.0 -> '4'
           270.0 -> '2'
           otherwise -> '9'

    levenSequence : Points -> Direction -> Direction
    levenSequence charPoints_ sequence =
      case charPoints_ of
        p2::[ ] ->
            List.reverse sequence

        p1::p2::tail ->
            levenSequence (p2::tail) ((direction p1 p2)::sequence)

        otherwise ->
            sequence

    score : Direction -> Direction -> Int
    score element gesture =
      editDistance element gesture


    match : Direction -> String
    match sequence =
        "My String"
                                                 
  in
    match <| Debug.log "Direction" <| levenSequence charPoints [ ]


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
        p1::charPoints

      p1::p2::[ ] ->
        p2::charPoints

      p1::p2::p3::tail ->
        let 
          a = V2.direction p1 p2
          b = V2.direction p2 p3
          angle = V2.dot a b |> acos
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
    identifyCharPoints_ points (head points)
    
--}
{-
The constraint of the minimal distance protects against creation
of spatial clusters of points.
-}

removeClusterPoints : Points -> Points
removeClusterPoints points =
  let
    -- precision = 8
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
      List.foldl basePoints [  ] points 
     

-- Signals

mouseUpDown : Signal Action
mouseUpDown =
    let
      delta = Time.fps 30
      
      toAction n pos =
          case n of
            False -> MouseUp
            True -> MouseDown pos

      actions = Signal.map2 toAction Keyboard.ctrl Mouse.position

      in
        Signal.sampleOn delta actions


input : Signal Action
input =
    mouseUpDown
    

model : Signal Model
model =
    Signal.foldp update initialModel input


main : Signal Element
main =
    Signal.map2 view Window.dimensions model
