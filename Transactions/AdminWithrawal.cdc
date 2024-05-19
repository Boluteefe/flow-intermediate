import FungibleToken from 0x05
import FlowToken from 0x05
import NewToken from 0x05

transaction(senderAccount: Address, amount: UFix64) {

    // Define references
    let senderVault: &NewToken.Vault{NewToken.PublicCollection}
    let signerVault: &NewToken.Vault
    let senderFlowVault: &FlowToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, FungibleToken.Provider}
    let adminResource: &NewToken.Admin
    let flowMinter: &FlowToken.Minter

    prepare(acct: AuthAccount) {
        // Borrow references and handle errors
        self.adminResource = acct.borrow<&NewToken.Admin>(from: /storage/AdminStorage)
            ?? panic("Failed to borrow Admin Resource")

        self.signerVault = acct.borrow<&NewToken.Vault>(from: /storage/VaultStorage)
            ?? panic("Signer's Vault not found")

        self.senderVault = getAccount(senderAccount)
            .getCapability(/public/Vault)
            .borrow<&NewToken.Vault{NewToken.PublicCollection}>()
            ?? panic("Sender's Vault not found")

        self.senderFlowVault = getAccount(senderAccount)
            .getCapability(/public/FlowVault)
            .borrow<&FlowToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, FungibleToken.Provider }>()
            ?? panic("Sender's Flow Vault not found")

        self.flowMinter = acct.borrow<&FlowToken.Minter>(from: /storage/FlowMinter)
            ?? panic("Minter not found")
    }

    execute {
        // Admin withdraws tokens from sender's vault
        let newVault <- self.adminResource.adminGetCoin(senderVault: self.senderVault, amount: amount)

        // Deposit withdrawn tokens to signer's vault
        self.signerVault.deposit(from: <-newVault)

        // Mint new FlowTokens
        let newFlowVault <- self.flowMinter.mintTokens(amount: amount)

        // Deposit new FlowTokens to sender's Flow vault
        self.senderFlowVault.deposit(from: <-newFlowVault)
        
        // Log completion message
        log("Transaction completed successfully!")
    }
}
