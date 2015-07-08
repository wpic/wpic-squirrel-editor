function debounce(func, wait, immediate) {
  // 'private' variable for instance
  // The returned function will be able to reference this due to closure.
  // Each call to the returned function will share this common timer.
  var timeout;           

  // Calling debounce returns a new anonymous function
  return function() {
    // reference the context and args for the setTimeout function
    var context = this, 
    args = arguments;

    // this is the basic debounce behaviour where you can call this 
    // function several times, but it will only execute once [after
    // a defined delay]. 
    // Clear the timeout (does nothing if timeout var is undefined)
    // so that previous calls within the timer are aborted.
    clearTimeout(timeout);   

    // Set the new timeout
    timeout = setTimeout(function() {

       // Inside the timeout function, clear the timeout variable
       timeout = null;

       // Check if the function already ran with the immediate flag
       if (!immediate) {
         // Call the original function with apply
         // apply lets you define the 'this' object as well as the arguments 
         //    (both captured before setTimeout)
         func.apply(context, args);
       }
    }, wait);

    // If immediate flag is passed (and not already in a timeout)
    //  then call the function without delay
    if (immediate && !timeout) 
      func.apply(context, args);  
   }; 
};