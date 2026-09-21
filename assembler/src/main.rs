#![allow(nonstandard_style)]
use std::env;

pub mod test;
pub mod compile;
pub mod tokenizer;
pub mod utils;

fn main() {
    
    let res : Option<()> = ParseCmdLineArgs();

    if res.is_none() {
        eprintln!("ERR - Expected argument in assembler. Found none.\n\tUse v32a help for more info on how to use this software.")
    }

}


fn ParseCmdLineArgs() -> Option<()> {

    let argv : Vec<String> = env::args().collect();

    let mut argvIterator: std::vec::IntoIter<String> = argv.into_iter();

    // We don't need the exe source
    argvIterator.next();
    
    match argvIterator.next()?.to_lowercase().as_str() {

        "help" => {
            todo!("Help option");
        }

        "compile" => {
            compile::interface::HandleCompile(argvIterator);
        }

        "test-tkn" => {
            test::HandleTokenizerTest(argvIterator);
        }

        invalidCmd => {
            eprintln!("USER ERR - Invalid arguement \'{}\'.\n\tUse v32a help for more info on how to use this software.", invalidCmd);
        }
    }

    return Some(());

}