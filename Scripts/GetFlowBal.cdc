import FungibleToken from 0x05
import FlowToken from 0x05

// Function to retrieve the balance of a FlowToken vault
pub fun retrieveFlowVaultBalance(account: Address): UFix64? {

    // Attempt to borrow the public FlowToken vault capability from the given account
    let flowVaultRef: &FlowToken.Vault{FungibleToken.Balance}?
        = getAccount(account)
            .getCapability(/public/FlowVault)
            .borrow<&FlowToken.Vault{FungibleToken.Balance}>()
    
    // Check if the borrowing was successful
    if let balance = flowVaultRef?.balance {
        // Return the balance if it exists
        return balance
    } else {
        // Return nil if borrowing failed or the Flow vault does not exist
        return nil
    }
}

// Entry point of the script
pub fun main(account: Address): UFix64? {
    // Call the retrieveFlowVaultBalance function and return the result
    return retrieveFlowVaultBalance(account: account)
}
