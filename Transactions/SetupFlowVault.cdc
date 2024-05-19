import FungibleToken from 0x05
import FlowToken from 0x05

transaction {

    let flowTokenVault: &FlowToken.Vault?
    let account: AuthAccount

    prepare(acct: AuthAccount) {
        // Borrow the FlowToken vault reference if it exists
        self.flowTokenVault = acct.getCapability(/public/FlowVault)
            .borrow<&FlowToken.Vault>()

        // Set the account reference
        self.account = acct
    }

    execute {
        if self.flowTokenVault == nil {
            // If the FlowToken vault doesn't exist, create and link it
            let newVault <- FlowToken.createEmptyVault()
            self.account.save(<-newVault, to: /storage/FlowVault)
            self.account.link<&FlowToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, FungibleToken.Provider}>(/public/FlowVault, target: /storage/FlowVault)
            log("An empty FlowToken vault has been successfully created and linked.")
        } else {
            // Log a message indicating that the FlowToken vault already exists and is properly linked
            log("A FlowToken vault already exists and is properly linked.")
        }
    }
}
