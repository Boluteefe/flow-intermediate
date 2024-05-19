import FungibleToken from 0x05
import NewToken from 0x05

pub fun main(account: Address) {

    // Attempt to borrow PublicVault capability
    let publicVault: &NewToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, NewToken.PublicCollection}? =
        getAccount(account).getCapability(/public/Vault)
            .borrow<&NewToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, NewToken.PublicCollection}>()

    if (publicVault == nil) {
        // Create and link an empty vault if capability is not present
        let newVault <- NewToken.createEmptyVault()
        getAuthAccount(account).save(<-newVault, to: /storage/VaultStorage)
        getAuthAccount(account).link<&NewToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, NewToken.PublicCollection}>(
            /public/Vault,
            target: /storage/VaultStorage
        )
        log("Empty vault created")
        
        // Borrow the vault capability again to display its balance
        let retrievedVault: &NewToken.Vault{FungibleToken.Balance}? =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&NewToken.Vault{FungibleToken.Balance}>()
        log(retrievedVault?.balance)
    } else {
        log("Vault already exists and is properly linked")
        
        // Borrow the vault capability for further checks
        let checkVault: &NewToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, NewToken.PublicCollection} =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&NewToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, NewToken.PublicCollection}>()
                ?? panic("Vault capability not found")
        
        // Check if the vault's UUID is in the list of vaults
        if NewToken.vaults.contains(checkVault.uuid) {
            log(publicVault?.balance)
            log("This is a NewToken vault")
        } else {
            log("This is not a NewToken vault")
        }
    }
}