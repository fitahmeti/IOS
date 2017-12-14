

import Foundation

let googleKey = "AIzaSyBag1I2lUk7t-uMscSK6EEKjC8NNLvPDeQ"
//let googleKey = "AIzaSyBag1I2lUk7t-uMscSK6EEKjC8NNLvPDeQ"

/// If google key is empty than location fetch via goecode.
var isGooleKeyFound : Bool = {
    return !googleKey.isEmpty
}()
