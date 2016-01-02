module MouseGesture where
{-
 Determining Characteristic points came from:
   "Efficient Recognition of Mouse-based Gestures"
   https://www.ii.pwr.edu.pl/~piasecki/publications/hofman-piasecki-v1-1.pdf
-}

import Color exposing ( .. )
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)

import GraphicUtils exposing ( toCartesian, toCollage )
--import Vector2 as V2 exposing ( Vec2, toVec2, normalize, length, angle )
import PreProcessPoints exposing ( removeClusters, identifyCharPoints )
import Components exposing ( Component, initComponent )
--import Levenstein exposing ( editDistance )
import ClassifyGesture exposing ( classifyGesture )

import Mouse
import Keyboard
import Window
import Time
--import Debug

type alias Point = ( Float, Float )
type alias Points =  List Point

type alias Model =
    { mousePoints : Points
    , lastPosition : Point
    , mousePressed : Bool
    , charPoints : Points
    , component : Component
    }

-- Model

initialModel : Model
initialModel =
    { mousePoints = [ ]
    , lastPosition = ( -1.0, -1.0 )
    , mousePressed = False
    , charPoints = [ ]
    , component = initComponent
    }

-- View

drawGesture : Point -> Point -> Point -> Points -> Form
drawGesture window collage offset charPoints
-- todo: map collage coordinates to a viewport
  = List.map ( toCollage window collage offset ) charPoints 
  |> path
  |> traced { defaultLine
            | color = red
            , width = 4
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
    cw = round ( w' / 4.0 )
    ch = round ( h' / 4.0 )
    window = ( w', h')
    collage' = ( toFloat cw, toFloat ch )
    strokeOffset = ( 0.0, 0.0)
    mousePoints = toCartesians window model.mousePoints
    textScale = 2.0
    textOffset = ( 0.0, -50.0 )
  in
    collage cw ch
      [ drawGesture window collage' strokeOffset mousePoints
      , drawGesture window collage' strokeOffset model.charPoints
      , showElementName textScale textOffset model.component.name
      ]
    
-- Update

toCartesians : Point -> Points -> Points
toCartesians window points =
  List.map ( toCartesian window ) points


type Action
  = NoOp
  | MouseUp ( Int, Int )
  | MouseDown ( Int, Int )


update : Action -> Model -> Model
update action model =
    case action of
      NoOp ->
        model

      MouseUp ( w, h ) ->
         if model.mousePressed
           then
             let
               charPoints'
                 =  model.mousePoints
                 |> List.reverse
--                 |> Debug.log "Mouse Points: "
                 |> toCartesians ( toFloat w, toFloat h )
--                 |> Debug.log "toCartesian: " 
                 |> removeClusters
--                 |> Debug.log "No Clusters: "
                 |> identifyCharPoints
--                 |> Debug.log "CharPoints: "
             in
               { model
               | mousePoints = [  ]
               , mousePressed = False
               , charPoints = charPoints'
               , component
                 =  charPoints'
                 |> classifyGesture 
             }
            else model

      MouseDown ( x, y ) ->
          let 
            position =
                (toFloat x, toFloat y  )
          in
            { model
            | mousePressed = True
            , mousePoints =
                if position == model.lastPosition then
                  model.mousePoints
                else
                  position :: model.mousePoints
            , lastPosition = position
            }


-- Signals

mouseUpDown : Signal Action
mouseUpDown =
    let
      delta = Time.fps 30
      
      toAction n pos dim =
          case n of
            False -> MouseUp dim
            True -> MouseDown pos

      actions = Signal.map3 toAction Keyboard.ctrl Mouse.position Window.dimensions

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
