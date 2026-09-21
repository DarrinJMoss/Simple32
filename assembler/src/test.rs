use crate::{ExpectSequentialIteratorItem, tokenizer::interface::Tokenize};


pub fn HandleTokenizerTest(mut args : std::vec::IntoIter<String>) -> () {

    let path : String = ExpectSequentialIteratorItem!(args, (), "USER ERR - Expected a path to the file to tokenize, got nothing.");

    let tokensResult :Result<Vec<crate::tokenizer::tokens::V32Token>, ()> = Tokenize(path, true);

    match tokensResult {
        Ok(val) => {
            println!("Tokenizer finished successfully!\nTokens:");
            let mut cnt : u8 = 0;
            for tk in val.iter() {
                print!("[{}], ", tk);

                cnt += 1;

                if cnt >= 8 {
                    print!("\n");
                    cnt = 0;
                }
            }
        },
        Err(_) => println!("Tokenizer exited with error."),
    }
        
}