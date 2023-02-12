module Editor exposing (Model, Move(..), Msg(..), getText, init, update, view)

import Array exposing (Array)
import Array.Extra as Arrayx
import Html exposing (Html, code, div, pre, span, text)
import Html.Attributes exposing (style)


type Msg
    = Symbol Char
    | Enter
    | Move Move
    | Backspace


type Move
    = Left
    | Right
    | Up
    | Down


type alias Model =
    { lines : Array Line
    , row : Int
    , col : Int
    }



-- CREATE


init : Model
init =
    { lines = emptyLine |> List.singleton |> Array.fromList
    , row = 0
    , col = 0
    }



-- QUERY


getText : Model -> String
getText model =
    model.lines
        |> Array.toList
        |> List.map lineToString
        |> String.concat


getLine : Int -> Model -> Line
getLine index model =
    Array.get index model.lines
        |> Maybe.withDefault emptyLine


getCurrentLine : Model -> Line
getCurrentLine model =
    getLine model.row model



-- TODO: display cursor when at end of line.


view : Model -> List (Html msg)
view model =
    let
        leftPadding =
            model.lines
                |> Array.length
                |> String.fromInt
                |> String.length
                |> (+) 1

        lineNumbers =
            model.lines
                |> Array.length
                |> List.range 1
                |> List.map String.fromInt
                |> List.map (String.padLeft leftPadding ' ')
                |> List.map (\s -> s ++ " ")
                |> String.join "\n"

        listOfLines =
            model.lines
                |> Array.toList
                |> List.indexedMap makeLine
                |> List.concat

        makeLine row line =
            lineToHtml
                (if row == model.row then
                    model.col

                 else
                    -1
                )
                line
    in
    div
        [ style "display" "flex"
        , style "height" "100vh"
        , style "overflow" "scroll"
        ]
        [ pre
            [ style "background-color" "#efefef"
            , style "margin-right" "5px"
            , style "min-height" "100%"
            , style "height" "max-content"
            ]
            [ code [] [ text lineNumbers ] ]
        , pre
            [ style "min-height" "100%"
            , style "height" "max-content"
            ]
            [ code [] listOfLines ]
        ]
        |> List.singleton



-- UPDATE


update : Msg -> Model -> Model
update msg model =
    let
        curLine =
            getCurrentLine model

        curLineAfterCursor =
            Arrayx.sliceFrom model.col curLine

        curLineBeforeCursor =
            Arrayx.sliceUntil model.col curLine
    in
    case msg of
        Symbol char ->
            insert char model

        Enter ->
            { model
                | lines =
                    model.lines
                        |> Arrayx.insertAt (model.row + 1) curLineAfterCursor
                        |> Array.set model.row curLineBeforeCursor
                , row = model.row + 1
                , col = 0
            }

        Move move ->
            updateOnMove move model

        Backspace ->
            if model.col > 0 then
                { model
                    | lines =
                        curLineAfterCursor
                            |> Array.append (Arrayx.pop curLineBeforeCursor)
                            |> (\line -> Array.set model.row line model.lines)
                    , col = model.col - 1
                }

            else
                model


updateOnMove : Move -> Model -> Model
updateOnMove move model =
    case move of
        Left ->
            if model.col > 0 then
                { model | col = model.col - 1 }

            else
                model

        Right ->
            if model.col < Array.length (getCurrentLine model) then
                { model | col = model.col + 1 }

            else
                model

        Up ->
            if model.row > 0 then
                { model
                    | row = model.row - 1
                    , col =
                        min (Array.length <| getLine (model.row - 1) model)
                            (Array.length <| getCurrentLine model)
                }

            else
                model

        Down ->
            if model.row < Array.length model.lines - 1 then
                { model
                    | row = model.row + 1
                    , col =
                        min (Array.length <| getLine (model.row + 1) model)
                            (Array.length <| getCurrentLine model)
                }

            else
                model


insert : Char -> Model -> Model
insert char model =
    let
        curLine =
            getCurrentLine model

        lineAfterInsert =
            Arrayx.insertAt model.col char curLine
    in
    { model
        | lines = Array.set model.row lineAfterInsert model.lines
        , col = model.col + 1
    }



-- LINE


type alias Line =
    Array Char


emptyLine : Line
emptyLine =
    Array.empty


lineToString : Line -> String
lineToString =
    Array.toList >> String.fromList >> (\string -> string ++ "\n")


lineToHtml : Int -> Line -> List (Html msg)
lineToHtml cursor =
    let
        addCursorIfNeeded line =
            if cursor >= Array.length line then
                Array.push ' ' line

            else
                line

        background index =
            if index == cursor then
                [ style "background-color" "black"
                , style "color" "white"
                ]

            else
                [ style "background-color" "white" ]

        makeSpan index char =
            span (background index) [ char |> String.fromChar |> text ]
    in
    addCursorIfNeeded
        >> Array.push '\n'
        >> Array.indexedMap makeSpan
        >> Array.toList
