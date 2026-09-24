
use std::fs;

use crate::tokenizer::tokens::{PoisonedToken, TokenizerWarning, V32Token, ValidToken};

enum _TokenizerStates {
    Scanning,

    Read_Identifier,
    Read_StrLiteral,

    Read_IntFmtHeader,  // Beginning of non-decimal int formats, i.e., 0x, 0b, and 0o
    Read_IntLit,
}

enum _CurrentIntScanType {
    Decimal,
    Binary,
    Hex,
    Octal,
}

struct _TokenizerManager<'a> {
    pub curColumn       : u32,
    pub curLine         : u32,
    pub curState        : _TokenizerStates,
    pub dbp             : bool,
    pub errHasOccurred  : bool,

    _fileReference      : Box<[&'a str]>,

    _chrBuffer          : String,

    _curTokenType       : Option<ValidToken>,
    _poisonedTokenStack : Vec<PoisonedToken>,
    _warningStack       : Vec<TokenizerWarning>,

    _curIntScanType     : _CurrentIntScanType,
}
impl<'a> _TokenizerManager<'a> {
    pub fn New(debugPrintingEn : bool, fileString : &'a str) -> _TokenizerManager<'a> {
        return _TokenizerManager { 
            curColumn               : 1, 
            curLine                 : 1, 

            curState                : _TokenizerStates::Scanning, 
            
            errHasOccurred          : false,
            dbp                     : debugPrintingEn,
            
            // Splits the input file into lines and collects them into a slice
            _fileReference          : fileString.lines().collect(),

            _chrBuffer              : String::new(),
            _curTokenType           : None,

            _curIntScanType         : _CurrentIntScanType::Decimal,

            _warningStack           : Vec::with_capacity(8),
            _poisonedTokenStack     : Vec::with_capacity(8),
        };
    }

    #[inline]
    pub fn UpdateLinesAndColumns(&mut self, input: &char) {
        self.curColumn += 1;
        if *input == '\n' {
            self.curColumn = 1;
            self.curLine += 1;
        }
    }


    pub fn FlushBuffers(&mut self) -> Option<Box<[V32Token]>> {
        if self._chrBuffer.trim().is_empty()    { 
            self._warningStack      .clear();
            self._poisonedTokenStack.clear();
            self._chrBuffer         .clear();

            return None; 
        }

        if !self._poisonedTokenStack.is_empty() {

        }
        else {

            let tokenSetup : ValidToken = self._curTokenType.as_ref().expect("Write error later").clone();

        }

        self._warningStack      .clear();
        self._poisonedTokenStack.clear();
        self._chrBuffer         .clear();
        
        todo!();
    }


    pub fn HandleInput(&mut self, ch : &char) {
        if self.dbp { print!("Input char [{}] => ", ch.escape_default()) }
        match self.curState {

            _TokenizerStates::Scanning => {
                if self.dbp { print!("Scanning... ") }

                if *ch == '0' {
                    if self.dbp { print!("Leading zero found, detecting type of integer literal.") }
                    self.curState = _TokenizerStates::Read_IntFmtHeader;
                    self._chrBuffer.push(ch.clone());
                }

            },

            _TokenizerStates::Read_Identifier => todo!(),

            _TokenizerStates::Read_StrLiteral => todo!(),

            _TokenizerStates::Read_IntFmtHeader => {
                if self.dbp { print!("Detecting integer literal format header... ") }

                self._curTokenType = Some(ValidToken::Lit_Int { value: 0 });

                if          ch.to_ascii_lowercase() == 'x' {
                    if self.dbp { print!("Hexidecimal.") }
                    self._curIntScanType = _CurrentIntScanType::Hex;    // Update the type of integer we're scanning
                    self._chrBuffer.clear();                            // We need to clear the char buffer since the format specifier has nothing to to do with the number.
                    // Same logic for the rest of the lines
                }
                else if     ch.to_ascii_lowercase() == 'b' {
                    if self.dbp { print!("Binary.") }
                    self._curIntScanType = _CurrentIntScanType::Binary;
                    self._chrBuffer.clear();
                }
                else if     ch.to_ascii_lowercase() == 'o' {
                    if self.dbp { print!("Octal.") }
                    self._curIntScanType = _CurrentIntScanType::Octal;
                    self._chrBuffer.clear();
                }
                else if     ch.to_ascii_lowercase() == 'd' {
                    if self.dbp { print!("Decimal.") }
                    self._curIntScanType = _CurrentIntScanType::Decimal;
                    self._chrBuffer.clear();
                }
                else if     ch.is_numeric() {
                    if self.dbp { print!("No integer format given, assuming redundant leading zero.") }
                    self._curIntScanType = _CurrentIntScanType::Decimal;
                    self._warningStack.push(TokenizerWarning::IntLit_UnnecessaryLeadingZero);
                }
                else {
                    if self.dbp { print!("Unexpected alphabetic character encountered in integer literal.") }
                    self._poisonedTokenStack.push(PoisonedToken::BadIntegerLiteral_UnexpectedAlpha { value: None });
                }
            },
            _TokenizerStates::Read_IntLit => todo!()
        }
        if self.dbp { print!("\n") }
    }
}

pub fn Tokenize(filename : String, debugPrints : bool) -> Result<Vec<V32Token>, ()>{
    
    if debugPrints { println!("Debug printing enabled!\nBeginning tokenizer with file {}", filename) }

    let mut tokens  : Vec<V32Token> = Vec::with_capacity(4096);

    let fileStrErrHandle : Result<String, std::io::Error> = fs::read_to_string(&filename);
    if fileStrErrHandle.is_err() {
        eprintln!("FileIO Error - Could not open file at {}, Err: {:?}", filename, fileStrErrHandle.err().unwrap());
        return Err(());
    }

    let fileStr : String = fileStrErrHandle.unwrap();

    let mut manager : _TokenizerManager = _TokenizerManager::New(debugPrints, &fileStr);

    for ch in fileStr.chars() {
        _TokenizerManager::UpdateLinesAndColumns(&mut manager, &ch);

        if ch.is_whitespace() {
            let potentialToken : Option<V32Token> = manager.FlushBuffers();
            if potentialToken.is_some() {
                tokens.push(potentialToken.unwrap());
            }
        }
        else {
            manager.HandleInput(&ch);
        }

    }

    if manager.errHasOccurred {
        return Err(());
    }
    else {
        return Ok(tokens);
    }
}