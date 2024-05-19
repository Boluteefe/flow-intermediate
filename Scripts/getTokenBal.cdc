import FungibleToken from 0x05

// Function to retrieve the balances of FungibleToken vaults for a given user
pub fun main(user: Address): {UInt64: UFix64} {

    // Retrieve the user's authentication account
    let authAccount = getAuthAccount(user)
    
    // Initialize a dictionary to store vault UUIDs and balances
    var vaults: {UInt64: UFix64} = {}

    // Iterate through each stored item in the account's storage
    authAccount.forEachStored(fun(path: StoragePath, type: Type): Bool {
        // Check if the stored item is a FungibleToken vault
        if type.isSubtype(of: Type<@FungibleToken.Vault>()) {
            // Borrow a reference to the FungibleToken vault
            let vaultRef = authAccount.borrow<&FungibleToken.Vault>(from: path)!
            // Store the vault's UUID and balance in the dictionary
            vaults[vaultRef.uuid] = vaultRef.balance
        }
        // Continue iterating
        return true
    })

    // Return the dictionary containing vault UUIDs and balances
    return vaults
}
