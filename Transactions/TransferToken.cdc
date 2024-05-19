import FungibleToken from 0x05
import NewToken from 0x05

transaction(receiverAccount: Address, amount: UFix64) {

    // Reference to the sender's vault
    let signerVault: &NewToken.Vault
    // Reference to the receiver's vault with receiver capability
    let receiverVault: &NewToken.Vault{FungibleToken.Receiver}

    prepare(acct: AuthAccount) {
        // Borrow the sender's vault reference
        self.signerVault = acct.borrow<&NewToken.Vault>(from: /storage/VaultStorage)
            ?? panic("Failed to retrieve sender's vault")

        // Borrow the receiver's vault reference
        self.receiverVault = getAccount(receiverAccount)
            .getCapability(/public/Vault)
            .borrow<&NewToken.Vault{FungibleToken.Receiver}>()
            ?? panic("Failed to retrieve receiver's vault")
    }

    execute {
        // Withdraw tokens from sender's vault and deposit into receiver's vault
        self.receiverVault.deposit(from: <-self.signerVault.withdraw(amount: amount))
        // Log a success message after completing the token transfer
        log("Token transfer from sender to receiver completed successfully")
    }
}
