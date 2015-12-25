module Elements where

-- Element is a reserved word!
type alias Direction =
     List Char

type alias Element_ =
    { name : String
    , direction : Direction
    }

type alias Elements = List Element_


-- Model
elements : Elements
elements =
    [ { name = "Input Field"
      , direction = [ '6', '0' ] 
      }
    , { name = "Dropdown"
      , direction = [ '0', '2' ]
      }
    ]

