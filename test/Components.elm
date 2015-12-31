module Components ( Component, Components
                  , components, initComponent
                  ) where

-- Element is a reserved word!
type alias Sequence =
     List Char

type alias Component =
    { name : String
    , sequence : Sequence
    }

type alias Components = List Component

dropDown : Component
dropDown =
  { name = "Dropdown"
  , sequence = [ '0', '2' ]
  }

inputField : Component
inputField =
  { name = "Input Field"
  , sequence = [ '6', '0' ] 
  }
                    

-- Model
components : Components
components =
   [ dropDown, inputField ]


initComponent : Component
initComponent =
  { name = "", sequence = [ ] }
