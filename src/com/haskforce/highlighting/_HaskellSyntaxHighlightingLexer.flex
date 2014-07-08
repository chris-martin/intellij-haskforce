package com.haskforce.highlighting;
import com.intellij.lexer.*;
import com.intellij.psi.tree.IElementType;
import static com.haskforce.psi.HaskellTypes.*;

/**
 * Hand-written lexer used for syntax highlighting in IntelliJ.
 *
 * We currently share token names with the grammar-kit generated
 * parser.
 *
 * Derived from the lexer generated by Grammar-Kit at 29 April 2014.
 */


/*
 * To generate sources from this file -
 *   Click Tools->Run JFlex generator.
 *
 * Command-Shift-G should be the keyboard shortcut, but that is the same
 * shortcut as find previous.
 */


%%

%{
  private int commentLevel;

  public _HaskellSyntaxHighlightingLexer() {
    this((java.io.Reader)null);
  }
%}

/*
 * Missing lexemes: by, haddock things.
 *
 * Comments: one line too many in dashes-comments.
 */

%public
%class _HaskellSyntaxHighlightingLexer
%implements FlexLexer
%function advance
%type IElementType
%unicode
%eof{  return;
%eof}

EOL=\r|\n|\r\n
LINE_WS=[\ \t\f]
WHITE_SPACE=({LINE_WS}|{EOL})+

VARIDREGEXP=([a-z_][a-zA-Z_0-9']+)|[a-z]
CONID=[A-Z][a-zA-Z_0-9']*
CHARTOKEN='(\\.|[^'])'
INTEGERTOKEN=(0(o|O)[0-7]+|0(x|X)[0-9a-fA-F]+|[0-9]+)
FLOATTOKEN=([0-9]+\.[0-9]+((e|E)(\+|\-)?[0-9]+)?|[0-9]+((e|E)(\+|\-)?[0-9]+))
// Multiline line comments are grouped into a single comment for
// code folding reasons.
COMMENT=(--([^\^\r\n][^\r\n]*\n|[\r\n]))+
DASHES=--(-)?
HADDOCK=--\^[^\r\n]*
CPPIF=#if ([^\r\n]*)
ASCSYMBOL=[\!\#\$\%\&\*\+\.\/\<\=\>\?\@\\\^\|\-\~\:]

STRINGGAP=\\[ \t\n\x0B\f\r]*\n[ \t\n\x0B\f\r]*\\

// Avoid "COMMENT" since that collides with the token definition above.
%state INCOMMENT INSTRING INPRAGMA

%%
<YYINITIAL> {
  {WHITE_SPACE}       { return com.intellij.psi.TokenType.WHITE_SPACE; }

  "class"             { return CLASSTOKEN; }
  "data"              { return DATA; }
  "default"           { return DEFAULT; }
  "deriving"          { return DERIVING; }
  "export"            { return EXPORTTOKEN; }
  "foreign"           { return FOREIGN; }
  "instance"          { return INSTANCE; }
  "module"            { return MODULE; }
  "newtype"           { return NEWTYPE; }
  "type"              { return TYPE; }
  "where"             { return WHERE; }
  "as"                { return AS; }
  "import"            { return IMPORT; }
  "infix"             { return INFIX; }
  "infixl"            { return INFIXL; }
  "infixr"            { return INFIXR; }
  "qualified"         { return QUALIFIED; }
  "hiding"            { return HIDING; }
  "case"              { return CASE; }
  "do"                { return DO; }
  "else"              { return ELSE; }
  "#else"             { return CPPELSE; }
  "#endif"            { return CPPENDIF; }
  "if"                { return IF; }
  "in"                { return IN; }
  "let"               { return LET; }
  "of"                { return OF; }
  "then"              { return THEN; }
  "forall"            { return FORALLTOKEN; }

  "<-"                { return LEFTARROW; }
  "->"                { return RIGHTARROW; }
  "=>"                { return DOUBLEARROW; }
  "\\&"               { return NULLCHARACTER; }
  "("                 { return LPAREN; }
  ")"                 { return RPAREN; }
  "|"                 { return PIPE; }
  ","                 { return COMMA; }
  ";"                 { return SEMICOLON; }
  "["                 { return LBRACKET; }
  "]"                 { return RBRACKET; }
  "''"                { return THQUOTE; }
  "`"                 { return BACKTICK; }
  "\""                {
                        yybegin(INSTRING);
                        return DOUBLEQUOTE;
                      }
  "{-#"               {
                        yybegin(INPRAGMA);
                        return OPENPRAGMA;
                      }
  "{-"                {
                        commentLevel = 1;
                        yybegin(INCOMMENT);
                        return COMMENTTEXT;
                      }
  "-}"                { return CLOSECOM; }
  "{"                 { return LBRACE; }
  "}"                 { return RBRACE; }
  "'"                 { return SINGLEQUOTE; }
  "!"                 { return EXCLAMATION; }
  "#"                 { return HASH; }
  "$"                 { return DOLLAR; }
  "%"                 { return PERCENT; }
  "&"                 { return AMPERSAND; }
  "*"                 { return ASTERISK; }
  "+"                 { return PLUS; }
  ".."                { return DOUBLEPERIOD; }
  "."                 { return PERIOD; }
  "/"                 { return SLASH; }
  "<"                 { return LESSTHAN; }
  "="                 { return EQUALS; }
  ">"                 { return GREATERTHAN; }
  "?"                 { return QUESTION; }
  "@"                 { return AMPERSAT; }
  "\\"                { return BACKSLASH; }
  "^"                 { return CARET; }
  "-"                 { return MINUS; }
  "~"                 { return TILDE; }
  "_"                 { return UNDERSCORE; }
  "::"                { return DOUBLECOLON; }
  (":"{ASCSYMBOL}+)   { return CONSYMTOK; }
  ":"                 { return COLON; }

  {VARIDREGEXP}       { return VARIDREGEXP; }
  {CONID}             { return CONIDREGEXP; }
  {CHARTOKEN}         { return CHARTOKEN; }
  {INTEGERTOKEN}      { return INTEGERTOKEN; }
  {FLOATTOKEN}        { return FLOATTOKEN; }
  {COMMENT}           { return COMMENT; }
  {DASHES}            { return DASHES; }
  {HADDOCK}           { return HADDOCK; }
  {CPPIF}             { return CPPIF; }

  [^] { return com.intellij.psi.TokenType.BAD_CHARACTER; }
}

<INCOMMENT> {
    "-}"              {
                        commentLevel--;
                        if (commentLevel == 0) {
                            yybegin(YYINITIAL);
                        }
                        return COMMENTTEXT;
                      }

    "{-"              {
                        commentLevel++;
                        return COMMENTTEXT;
                      }

    [^-{}]+           { return COMMENTTEXT; }
    [^]               { return COMMENTTEXT; }
}

<INSTRING> {
    \"                              {
                                        yybegin(YYINITIAL);
                                        return DOUBLEQUOTE;
                                    }
    (\\)+                           { return STRINGTOKEN; }
    ({STRINGGAP}|\\\"|[^\"\\\n])+   { return STRINGTOKEN; }

    [^]                             { return BADSTRINGTOKEN; }
}

<INPRAGMA> {
    "#-}"           {
                        yybegin(YYINITIAL);
                        return CLOSEPRAGMA;
                    }
    [^-}#]+         { return PRAGMA; }
    [^]             { return PRAGMA; }
}
