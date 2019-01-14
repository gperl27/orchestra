port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events as HE exposing (onClick)
import Json.Encode as JE



-- JavaScript usage: app.ports.websocketIn.send(response);


port websocketIn : (String -> msg) -> Sub msg



-- JavaScript usage: app.ports.websocketOut.subscribe(handler);


port websocketOut : String -> Cmd msg


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



{- MODEL -}


type alias Note =
    { key : String
    , pitch : Pitch
    , name : String
    }


type Pitch
    = Flat
    | Natural


type alias Piano =
    List Note


type Instrument
    = Keyboard Piano


type alias Band =
    List Instrument


piano : Piano
piano =
    [ { pitch = Natural, key = "C4", name = "C" }
    , { pitch = Flat, key = "C#4", name = "C#" }
    , { pitch = Natural, key = "D4", name = "D" }
    , { pitch = Flat, key = "D#4", name = "D#" }
    , { pitch = Natural, key = "E4", name = "E" }
    , { pitch = Natural, key = "F4", name = "F" }
    , { pitch = Flat, key = "F#4", name = "F#" }
    , { pitch = Natural, key = "G4", name = "G" }
    , { pitch = Flat, key = "G#4", name = "G#" }
    , { pitch = Natural, key = "A4", name = "A" }
    , { pitch = Flat, key = "A#4", name = "A#" }
    , { pitch = Natural, key = "B4", name = "B" }
    , { pitch = Natural, key = "C5", name = "C" }
    ]


band : Band
band =
    [ Keyboard piano ]


type alias Model =
    { responses : List String
    , input : String
    , piano : Piano
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { responses = []
      , input = ""
      , piano = piano
      }
    , Cmd.none
    )



{- UPDATE -}


type Msg
    = Submit String
    | WebsocketIn String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Submit value ->
            ( model
            , websocketOut value
            )

        WebsocketIn value ->
            ( { model | responses = value :: model.responses }
            , Cmd.none
            )



{- SUBSCRIPTIONS -}


subscriptions : Model -> Sub Msg
subscriptions model =
    websocketIn WebsocketIn



{- VIEW -}


view : Model -> Html Msg
view model =
    div []
        [ ul []
            (List.map
                (\l ->
                    button
                        [ classList
                            [ ( "natural", l.pitch == Natural )
                            , ( "flat", l.pitch == Flat )
                            ]
                        , onClick (Submit l.key)
                        ]
                        [ text l.name ]
                )
                model.piano
            )
        ]
