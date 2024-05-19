import FungibleToken from 0x05
import FlowToken from 0x05

// Transaction to interact with the FlowToken Minter
transaction() {

  // Reference to the FlowToken Minter
  let minterRef: &FlowToken.Minter

  prepare(acct: AuthAccount) {
    // Attempt to borrow the FlowToken Minter reference from storage
    self.minterRef = acct.borrow<&FlowToken.Minter>(from: /storage/FlowMinter)
        ?? panic("Unable to access FlowToken Minter")
    log("FlowToken Minter reference acquired successfully")
  }

  execute {
  }
}
