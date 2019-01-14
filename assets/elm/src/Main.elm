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


type alias NoteDetails =
    { key : String
    , pitch : Pitch
    }


type Pitch
    = Flat
    | Natural


type alias Piano =
    List NoteDetails


type Instrument
    = Keyboard Piano


type alias Band =
    List Instrument


piano : Piano
piano =
    [ { pitch = Natural, key = "C4" }, { pitch = Flat, key = "C#4" } ]


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
    = Change String
    | Submit String
    | WebsocketIn String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Change input ->
            ( { model | input = input }
            , Cmd.none
            )

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
                        [ text l.key ]
                )
                model.piano
            )
        ]
