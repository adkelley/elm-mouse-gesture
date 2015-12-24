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
import GraphicsUtils exposing ( Point, toCollage )
import Mouse
import Keyboard
import Window
import Time
import Debug

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

drawGesture : Point -> Point -> Point -> Points -> Form
drawGesture window viewport offset charPoints
  =  List.map ( toCollage window viewport offset ) charPoints 
  |> path
  |> traced { defaultLine
            | color = red
            , width = 5
            }
             

showElementName : Float -> Point -> String -> Form
showElementName scale' offset elementName
  =  toForm ( show elementName )
  |> scale scale'
  |> move offset


view : ( Int, Int ) -> Model -> Element
view ( w, h ) model =
  let
    w' = toFloat w
    h' = toFloat h
    window = ( w', h')
    viewport = ( 400.0, 400.0 )
    offset = ( 0.0, 0.0)
    scale = 2.0
  in
    collage 400 400
      [ drawGesture window viewport offset model.charPoints
      , showElementName scale offset model.elementName
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
                 |> List.reverse
                 |> Debug.log "Mouse Points: "
                 |> removeClusterPoints
                 |> Debug.log "No Clusters: "
                 |> identifyCharPoints
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
        (p1x, p1y ) = p1
        a = V2.direction p1 p2
        ( ax, ay ) = Debug.log "ax, ay" ( fst a, snd a )
        b = V2.direction ( p1x, p1y ) (p1x+1.0, p1y)
        angle = V2.dot b a |> acos
        angle'=
          if (ax < 0 && ay > 0) ||  (ax > 0 && ay > 0) then
            -angle
          else
            angle
      in
        Debug.log "Angle: " angle'


    direction : Point -> Point -> Char
    direction p1 p2 =
       let
         angle = directionAngle p1 p2
       in
         if angle > -0.3926991 && angle <= 0.3926991 then
           '0'
              else if angle > 0.3926991 && angle <= 1.178097 then
                '7'
              else if angle > 1.178097 && angle <= 1.9634954 then
                '6'
              else if angle > 1.9634954 && angle <= 2.74017 then
                '5'
              else if angle > 2.74017 && angle >= -2.74017 then
                '4'
              else if angle > -2.74017 && angle >= -1.9634954 then
                '3'
              else if angle > -1.9634954 && angle >= -1.178097 then
                '2'
          else 
            '1'
              

    levenSequence : Points -> Direction -> Direction
    levenSequence charPoints_ sequence =
      case charPoints_ of
        p2::[ ] ->
            List.reverse sequence

        p1::p2::tail ->
          let
            gesture = direction p1 p2
          in
            levenSequence (p2::tail) (gesture::sequence)

        otherwise ->
            sequence

    score : Direction -> Direction -> Int
    score element gesture =
      editDistance element gesture


    match : Direction -> String
    match sequence =
        "Match point"
                                                 
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
        List.reverse charPoints

      p1::[ ] ->
        List.reverse ( p1::charPoints )

      p1::p2::[ ] ->
        List.reverse ( p2::charPoints )

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
      List.foldl basePoints [  ] points |> List.reverse
     

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
