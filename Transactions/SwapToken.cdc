import SwapToken from 0x05

transaction(amount: UFix64) {

    // Define the signer account
    let signer: AuthAccount

    // Prepare block: Set the signer account
    prepare(acct: AuthAccount) {
        self.signer = acct
    }

    // Execute block: Call the SwapToken contract to swap tokens
    execute {
        // Call the SwapToken contract to swap tokens
        SwapToken.swapTokens(signer: self.signer, swapAmount: amount)

        // Log a success message
        log("Tokens swapped successfully")
    }
}
