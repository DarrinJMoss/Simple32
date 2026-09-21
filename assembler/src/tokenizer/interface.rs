
use std::fs;

use crate::tokenizer::tokens::{PoisonedToken, V32Token};

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

struct _TokenizerManager {
    pub curColumn       : u32,
    pub curLine         : u32,
    pub curState        : _TokenizerStates,
    pub dbp             : bool,
    pub errHasOccurred  : bool,

    _fileReference      : Box<[String]>,

    _chrBuffer          : String,

    _poisonedTokenBuffer: Vec<PoisonedToken>,

    _curIntScanType      : _CurrentIntScanType,
}
impl _TokenizerManager {
    pub const fn New(debugPrintingEn : bool, fileString : &mut String) -> _TokenizerManager {
        return _TokenizerManager { 
            curColumn               : 1, 
            curLine                 : 1, 
            errHasOccurred          : false,
            curState                : _TokenizerStates::Scanning, 
            dbp                     : debugPrintingEn,
            _fileReference          : fileString.clone().lines().collect(),
            _poisonedTokenBuffer    : Vec::new(), // Uhh... we'll worry about performance later
            _chrBuffer              : String::new(),
            _curIntScanType         : _CurrentIntScanType::Decimal,
        };
    }

    pub const fn UpdateLnCl(man : &mut _TokenizerManager, input: &char) {
        man.curColumn += 1;
        if *input == '\n' {
            man.curColumn = 1;
            man.curLine += 1;
        }
    }

    pub fn FlushBuffers(&mut self) -> Option<V32Token> {
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

                if          ch.to_ascii_lowercase() == 'x' {
                    if self.dbp { print!("Hexidecimal.") }
                    self._curIntScanType = _CurrentIntScanType::Hex;
                    self._chrBuffer.clear();
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
                }
                else {
                    
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

    let mut manager : _TokenizerManager = _TokenizerManager::New(debugPrints);

    for ch in fileStr.chars() {
        _TokenizerManager::UpdateLnCl(&mut manager, &ch);

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