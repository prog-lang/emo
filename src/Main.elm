port module Main exposing (..)

import Browser exposing (Document)
import Browser.Events as Events
import Editor exposing (Move(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Keyboard.Event exposing (KeyboardEvent, decodeKeyboardEvent)



-- FLAGS


type alias Flags =
    ()



-- MODEL


type alias Model =
    { editor : Editor.Model
    , cpuState : String
    }



-- MSG


type Msg
    = KeyboardEvent Keyboard.Event.KeyboardEvent
    | GotCpuState String



-- MAIN


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- INIT


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( initModel, Cmd.none )


initModel : Model
initModel =
    { editor = Editor.init
    , cpuState = "UNKNOWN"
    }



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Emo"
    , body = viewBody model
    }


viewBody : Model -> List (Html Msg)
viewBody model =
    Editor.view model.editor



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyboardEvent event ->
            updateOnKeyboardEvent event model

        GotCpuState state ->
            ( { model | cpuState = state }, Cmd.none )


updateOnKeyboardEvent : KeyboardEvent -> Model -> ( Model, Cmd Msg )
updateOnKeyboardEvent event model =
    case event.key of
        Nothing ->
            ( model, Cmd.none )

        Just key ->
            updateOnKeyDown event key model


updateOnKeyDown : KeyboardEvent -> String -> Model -> ( Model, Cmd Msg )
updateOnKeyDown event key model =
    let
        firstChar =
            String.toList >> List.head >> Maybe.withDefault ' '
    in
    case key of
        "Enter" ->
            if event.ctrlKey then
                ( model
                , Editor.getText model.editor
                    |> String.trim
                    |> cpuExecuteHexInstruction
                )

            else
                ( { model | editor = Editor.update Editor.Enter model.editor }
                , Cmd.none
                )

        -- TODO: implement proper Backspace behaviour.
        "Backspace" ->
            ( { model
                | editor = Editor.update (Editor.Move Left) model.editor
              }
            , Cmd.none
            )

        "ArrowLeft" ->
            ( { model
                | editor = Editor.update (Editor.Move Left) model.editor
              }
            , Cmd.none
            )

        "ArrowRight" ->
            ( { model
                | editor = Editor.update (Editor.Move Right) model.editor
              }
            , Cmd.none
            )

        "ArrowUp" ->
            ( { model
                | editor = Editor.update (Editor.Move Up) model.editor
              }
            , Cmd.none
            )

        "ArrowDown" ->
            ( { model
                | editor = Editor.update (Editor.Move Down) model.editor
              }
            , Cmd.none
            )

        other ->
            if String.length other == 1 then
                ( { model
                    | editor =
                        Editor.update
                            (Editor.Symbol <| firstChar other)
                            model.editor
                  }
                , Cmd.none
                )

            else
                ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Events.onKeyDown <|
            Json.Decode.map KeyboardEvent decodeKeyboardEvent
        , cpuState GotCpuState
        ]



-- PORTS


port cpuState : (String -> msg) -> Sub msg


port cpuExecuteHexInstruction : String -> Cmd msg
