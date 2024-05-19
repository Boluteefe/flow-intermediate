import FungibleToken from 0x05
import NewToken from 0x05

transaction(receiver: Address, amount: UFix64) {

    prepare(signer: AuthAccount) {
        // Ensure the signer has the authority to mint NewToken
        let minter = signer.borrow<&NewToken.Minter>(from: /storage/MinterStorage)
            ?? panic("You do not have the necessary permissions to mint NewToken")
        
        // Retrieve the receiver's NewToken Vault capability
        let receiverVault = getAccount(receiver)
            .getCapability<&NewToken.Vault{FungibleToken.Receiver}>(/public/Vault)
            .borrow()
            ?? panic("Failed to access the receiver's NewToken Vault. Please check the account status.")
        
        // Mint the specified amount of NewToken
        let mintedTokens <- minter.mintToken(amount: amount)

        // Deposit the minted tokens into the receiver's NewToken Vault
        receiverVault.deposit(from: <-mintedTokens)
    }

    execute {
        // Log a success message indicating that NewToken has been minted and deposited
        log("NewToken minting and depositing process completed successfully.")
        // Log the amount of NewToken minted and deposited
        log("Minted and deposited NewToken amount: (amount)".concat(amount.toString()))
    }
}
