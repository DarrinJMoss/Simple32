
/// Call to get the next item in an iterator. 
/// Returns the provided error type along with printing an error message if the iterator does not have another item.
/// Returns the next item in the iterator if not.
/// 
/// 
/// I.e.,
/// 
/// 
/// let myIterator : Iterator<T>;
/// 
/// let myItem : T = ExpectSequentialIteratorItem(myIterator, Err(U), "Err occurred when getting next token {}", arg)
#[macro_export]
macro_rules! ExpectSequentialIteratorItem {
    ($iterator:ident, $err:expr, $fmt:expr, $($args:tt)*) => {
        match ($iterator.next()) {
            Some(item) => item,
            None => {
                println!($fmt, $($args)*);
                return $err;
            }
        }
    };
    ($iterator:ident, $err:expr, $fmt:expr) => {
        match ($iterator.next()) {
            Some(item) => item,
            None => {
                println!($fmt);
                return $err;
            }
        }
    };
}