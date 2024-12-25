
extern "C" {
    fn printer(); 
    
    fn print_string(message: *const i8);
}

fn main() -> std::io::Result<()> {

    let msg = "hello";
    
    // rust types are not inherently compatible
    // to C
    //

    let c_msg = std::ffi::CString::new(msg)?;

    // FFI in Rust are UNSAFE
    unsafe {
        print_string(c_msg.as_ptr());
    }
    Ok(())
}


