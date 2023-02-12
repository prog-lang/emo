port module Main exposing (..)

import Browser exposing (Document)
import Browser.Events as Events
import Char exposing (isHexDigit)
import Editor
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
    | EditorMsg Editor.Msg



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
        |> List.map (Html.map EditorMsg)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyboardEvent event ->
            updateOnKeyboardEvent event model

        GotCpuState state ->
            ( { model | cpuState = state }, Cmd.none )

        EditorMsg editorMsg ->
            updateOnEditorMsg editorMsg model


updateOnEditorMsg : Editor.Msg -> Model -> ( Model, Cmd Msg )
updateOnEditorMsg editorMsg model =
    let
        cmd =
            case editorMsg of
                Editor.LineClicked line ->
                    line
                        |> String.filter isHexDigit
                        |> cpuExecuteHexInstruction

                _ ->
                    Cmd.none
    in
    ( { model | editor = Editor.update editorMsg model.editor }
    , cmd
    )


updateOnKeyboardEvent : KeyboardEvent -> Model -> ( Model, Cmd Msg )
updateOnKeyboardEvent event model =
    case event.key of
        Nothing ->
            ( model, Cmd.none )

        Just key ->
            updateOnKeyDown event key model


updateOnKeyDown : KeyboardEvent -> String -> Model -> ( Model, Cmd Msg )
updateOnKeyDown _ key model =
    let
        firstChar =
            String.toList >> List.head >> Maybe.withDefault ' '
    in
    case key of
        "Enter" ->
            ( { model | editor = Editor.update Editor.Enter model.editor }
            , Cmd.none
            )

        "Backspace" ->
            ( { model
                | editor = Editor.update Editor.Backspace model.editor
              }
            , Cmd.none
            )

        "ArrowLeft" ->
            ( { model
                | editor = Editor.update (Editor.Move Editor.Left) model.editor
              }
            , Cmd.none
            )

        "ArrowRight" ->
            ( { model
                | editor = Editor.update (Editor.Move Editor.Right) model.editor
              }
            , Cmd.none
            )

        "ArrowUp" ->
            ( { model
                | editor = Editor.update (Editor.Move Editor.Up) model.editor
              }
            , Cmd.none
            )

        "ArrowDown" ->
            ( { model
                | editor = Editor.update (Editor.Move Editor.Down) model.editor
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
