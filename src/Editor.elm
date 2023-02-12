module Editor exposing (Model, Move(..), Msg(..), getText, init, update, view)

import Array exposing (Array)
import Array.Extra as Arrayx
import Basics.Extra exposing (atMost, flip)
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


getLineLength : Int -> Model -> Int
getLineLength index model =
    getLine index model |> Array.length


getLine : Int -> Model -> Line
getLine index model =
    Array.get index model.lines
        |> Maybe.withDefault emptyLine


getCurrentLine : Model -> Line
getCurrentLine model =
    getLine model.row model


view : Model -> List (Html msg)
view model =
    let
        leftPadding =
            model.lines
                |> Array.length
                |> String.fromInt
                |> String.length
                |> (+) 1
                |> flip String.padLeft ' '

        lineNumbers =
            model.lines
                |> Array.length
                |> List.range 1
                |> List.map String.fromInt
                |> List.map leftPadding
                |> List.map (flip (++) " ")
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
        prevLine =
            getLine (model.row - 1) model

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
                -- Normal case => simply erase one char before the cursor.
                model
                    |> setCurrentLine (Arrayx.removeAt (model.col - 1) curLine)
                    |> shiftCol -1

            else if model.row > 0 then
                -- We've reached the left border of a line => erase that line.
                { model
                    | lines =
                        model.lines
                            |> Array.set
                                (model.row - 1)
                                (Array.append prevLine curLine)
                            |> Arrayx.removeAt model.row
                    , row = model.row - 1
                    , col = getLine (model.row - 1) model |> Array.length
                }

            else
                -- We've reached the beginning of the file => do nothing.
                model


updateOnMove : Move -> Model -> Model
updateOnMove move model =
    let
        iff check newModel =
            if check then
                newModel

            else
                model
    in
    case move of
        Left ->
            iff (model.col > 0)
                { model | col = model.col - 1 }

        Right ->
            iff (model.col < getLineLength model.row model)
                { model | col = model.col + 1 }

        Up ->
            iff (model.row > 0)
                { model
                    | row = model.row - 1
                    , col =
                        atMost (getLineLength (model.row - 1) model)
                            (getLineLength model.row model)
                }

        Down ->
            iff (model.row < Array.length model.lines - 1)
                { model
                    | row = model.row + 1
                    , col =
                        atMost (getLineLength (model.row + 1) model)
                            (getLineLength model.row model)
                }


insert : Char -> Model -> Model
insert char model =
    let
        lineAfterInsert =
            Arrayx.insertAt model.col char <| getCurrentLine model
    in
    model |> setCurrentLine lineAfterInsert |> shiftCol 1


setCurrentLine : Line -> Model -> Model
setCurrentLine line model =
    { model | lines = Array.set model.row line model.lines }


shiftCol : Int -> Model -> Model
shiftCol int model =
    { model | col = model.col + int }



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
        >> Arrayx.indexedMapToList makeSpan
