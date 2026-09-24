use core::fmt;




/// Automatically generates a print statement for the token given the following inputs:
/// 
/// 1: isErr                (Boolean Literal)               => Changes the aesthetic from warnings to errors.
/// 
/// 2: message              (String format!() expression)   => The descriptive message of the error/warning.
/// 
/// 3: lineN                (Integer Identifier)            => The line number the token is found on.
/// 
/// 4: clmnN                (Integer Identifier)            => The column number the token is found on.
/// 
/// 5: chspan               (Integer Identifier)            => How many characters wide the token is.
/// 
/// 6: offendingLine        (String Identifier)             => The whole line the token occurs on.
/// 
/// 7: offendingLineAbove   (Optional<String> Identifier)   => The line above the offending line.
/// 
/// 8: offendingLineBelow   (Optional<String> Identifier)   => The line below the offending line.

// Note: This probably should have been an inline function, but I wanted to take the oppertunity to learn
//       rust macros.
macro_rules! _FormatTokenDisplay {
    ($isErr:literal, $message:expr, $lineN:ident, $clmnN:ident, $chspan:ident, $offendingLine:ident, $offendingLineAbove:ident, $offendingLineBelow:ident) => {
        {
            let err : bool = $isErr;
            if err {
                print!("\x1b[1;31m");
            }
            else {
                print!("\x1b[1;33m");
            }
            println!("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
            if err {
                println!("Error in {}:{}", $lineN, $clmnN);
            } else {
                println!("Warning in {}:{}", $lineN, $clmnN);
            }
            if $offendingLineAbove.is_some() {
                println!("{}", $offendingLineAbove.unwrap());
            }
            println!("{}", $offendingLine);
            for _ in 0..*($clmnN) {
                print!("-");
            }
            for _ in 0..*($chspan) {
                print!("^");
            }
            if $offendingLineBelow.is_some() {
                println!("\n{}\n\n{}", $offendingLineBelow.unwrap(), $message);
            }
            else {
                println!("\n\n{}", $message);
            }
            println!("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\x1b[0m\n");
        }
    };
}

/// Trait implemented by the poisoned token and tokenizer warning enums, allowing them both to be printed.
pub trait TokenNoticeDisplay {
    fn Display(&self, lineNum : &u32, columnNum : &u32, charspan : &u32, offendingline : &str, aboveOffendingLine : Option<&str>, belowOffendingLine : Option<&str>) -> ();
}





/// A data structure containing a token output alongside information regarding where to locate the token within the file.
pub struct V32Token {
    pub tokenResult         : V32TokenResult,
     
    pub tokenLine           : u32,
    pub tokenColumnStart    : u32,
    pub tokenCharSpan       : u32,
}
impl V32Token {

    pub fn DisplayMsg(&self, offendingLine : &str, offendingLineAbove : Option<&str>, offendingLineBelow : Option<&str>) {
        match &self.tokenResult {
            V32TokenResult::Good { tkn : _ }                                        => return,
            V32TokenResult::Warning { tkn : _, warnings } => {
                for warning in warnings.iter() {
                    warning.Display(&self.tokenLine, &self.tokenColumnStart, &self.tokenCharSpan, offendingLine, offendingLineAbove, offendingLineBelow)
                }
            },
            V32TokenResult::Poisoned { tkn }                        => tkn    .Display(&self.tokenLine, &self.tokenColumnStart, &self.tokenCharSpan, offendingLine, offendingLineAbove, offendingLineBelow),
        }
    }

}
impl fmt::Display for V32Token {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.tokenResult.fmt(f)
    }
}




/// Enum containing the results of a tokenizer buffer flush.
/// 
/// TokenResults can either be good, a warning (good + a message to the developer), or poisoned (bad token with error info).
/// 
/// Pattern match the expression to access the underlying token.
#[derive(Debug)]
pub enum V32TokenResult {
    /// A valid token output with no warning messages.
    Good        { tkn : ValidToken },
    /// A valid token output with a warning message.
    Warning     { tkn : ValidToken, warnings : Box<[TokenizerWarning]> },
    /// A bad token with an error message.
    Poisoned    { tkn : PoisonedToken },
}
impl fmt::Display for V32TokenResult {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            V32TokenResult::Good        { tkn }                 => tkn.fmt(f),
            V32TokenResult::Warning     { tkn, warnings : _ }   => tkn.fmt(f),
            V32TokenResult::Poisoned    { tkn }              => tkn.fmt(f),
        }
    }
}


/// A valid token output from the V32 Tokenizer, contains info about the type of token and associated data 
/// (I.e., integer ltierals have a field with the data value as an int, string ltierals and itentifiers have a string member, etc.).
#[derive(Debug, Clone)]
pub enum ValidToken {
    Lit_Int {
        value : u32,
    },
    Lit_Str {
        value : String
    },
    Identifier {
        value : String,
    },

    Operator_Plus,
    Operator_Minus,
    Operator_Asterisk,
    Operator_FwSlash,
    Operator_Percent,

    Punctuation_Comma,
    Punctuation_Colon,
    Punctuation_ClBrace_L,
    Punctuation_ClBrace_R,
    Punctuation_SqBrace_L,
    Punctuation_SqBrace_R,
}
impl fmt::Display for ValidToken {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ValidToken::Lit_Int               { value  }    => write!(f, "Integer Literal: {}", value),
            ValidToken::Lit_Str               { value }  => write!(f, "String Literal: \'{}\'", value),
            ValidToken::Identifier            { value }  => write!(f, "Itentifier : {}", value),
            ValidToken::Operator_Plus                             => write!(f, "Operator +"),
            ValidToken::Operator_Minus                            => write!(f, "Operator -"),
            ValidToken::Operator_Asterisk                         => write!(f, "Operator *"),
            ValidToken::Operator_FwSlash                          => write!(f, "Operator /"),
            ValidToken::Operator_Percent                          => write!(f, "Operator %"),
            ValidToken::Punctuation_Comma                         => write!(f, "Punctuation ,"),
            ValidToken::Punctuation_Colon                         => write!(f, "Punctuation :"),
            ValidToken::Punctuation_ClBrace_L                     => write!(f, "Punctuation {{"),
            ValidToken::Punctuation_ClBrace_R                     => write!(f, "Punctuation }}"),
            ValidToken::Punctuation_SqBrace_L                     => write!(f, "Punctuation ["),
            ValidToken::Punctuation_SqBrace_R                     => write!(f, "Punctuation ]"),
        }
    }
}




/// A bad token whose result was born from an error in the system. Contains error information.
#[derive(Debug)]
pub enum PoisonedToken {
    /// Random alphabetic character found in the middle of a proviced string literal.
    /// 
    /// I.e.: 10000 => Fine | 0x50FF => Fine | 0b011001 => Fine | 65_535 => Fine | 123Hi!456 => BadIntegerLiteral_UnexpectedAlpha
    BadIntegerLiteral_UnexpectedAlpha { value : Option<String> },
}

impl fmt::Display for PoisonedToken {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            PoisonedToken::BadIntegerLiteral_UnexpectedAlpha { value } => write!(f, "Poisoned Token! Type: BadIntegerLiteral_UnexpectedAlpha RawToken: {}", value.as_ref().expect("Program Err in tokens.rs | PoisonedToken::BadIntegerLiteral_UnexpectedAlpha::fmt | String internal not set on poisoned token.")),
        }
    }
}

impl TokenNoticeDisplay for PoisonedToken {
    fn Display(&self, lineNum : &u32, columnNum : &u32, charspan : &u32, offendingline : &str, aboveOffendingLine : Option<&str>, belowOffendingLine : Option<&str>) -> () {
        match &self {
            PoisonedToken::BadIntegerLiteral_UnexpectedAlpha { value } => _FormatTokenDisplay!(true, format!("Unexpected alphabetic character in integer literal.\n\tToken: {}", value.as_ref().expect("Program Err in tokens.rs | PoisonedToken::BadIntegerLiteral_UnexpectedAlpha::Display | String internal not set on poisoned token.")), lineNum, columnNum, charspan, offendingline, aboveOffendingLine, belowOffendingLine),
        }
    }
}




/// A warning message the tokenizer generated when parsing the associated token.
#[derive(Debug)]
pub enum TokenizerWarning {
    IntLit_UnnecessaryLeadingZero
}
impl TokenNoticeDisplay for TokenizerWarning {
    fn Display(&self, lineNum : &u32, columnNum : &u32, charspan : &u32, offendingline : &str, aboveOffendingLine : Option<&str>, belowOffendingLine : Option<&str>) -> () {
        match &self {
            TokenizerWarning::IntLit_UnnecessaryLeadingZero => _FormatTokenDisplay!(false, format!("Unnecessary leading zero in integer literal.\n\tToken:"), lineNum, columnNum, charspan, offendingline, aboveOffendingLine, belowOffendingLine),
        }
    }
}