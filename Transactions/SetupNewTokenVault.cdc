import FungibleToken from 0x05
import NewToken from 0x05

transaction {

    //  Reference to the user's vault
    var userVault: &NewToken.Vault{FungibleToken.Balance, FungibleToken.Provider, FungibleToken.Receiver, NewToken.PublicCollection}?
   // Reference to the user's account
    var account: AuthAccount

    prepare(acct: AuthAccount) {
         // Borrow the vault capability and set the account reference
        self.account = acct
        self.userVault = acct.borrow<&NewToken.Vault{FungibleToken.Balance, FungibleToken.Provider, FungibleToken.Receiver, NewToken.PublicCollection}>(from: /storage/VaultStorage)
    }

    execute {
        // Check if the userVault is nil
        if self.userVault == nil {
            // Create and link an empty vault if nill
            let emptyVault <- NewToken.createEmptyVault()
            self.account.save(<-emptyVault, to: /storage/VaultStorage)
            self.account.link<&NewToken.Vault{FungibleToken.Balance, FungibleToken.Provider, FungibleToken.Receiver, NewToken.PublicCollection}>(/public/Vault, target: /storage/VaultStorage)
            log("An empty vault has been successfully created and linked.")
        } else {
         // Log if a vault already exists and is properly linked
            log("A vault already exists and is properly linked.")
        }
    }
}
