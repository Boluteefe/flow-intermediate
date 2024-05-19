import FungibleToken from 0x05

// Contract representing a new token with fungible properties
pub contract NewToken: FungibleToken {

    // Total supply of tokens
    pub var totalSupply: UFix64
    // Array to store vault UUIDs
    pub var vaults: [UInt64]

    // Event emitted upon initializing tokens with an initial supply
    pub event TokensInitialized(initialSupply: UFix64)
    // Event emitted upon withdrawing tokens
    pub event TokensWithdrawn(amount: UFix64, from: Address?)
    // Event emitted upon depositing tokens
    pub event TokensDeposited(amount: UFix64, to: Address?)

       
    // Interface defining functionalities for the token vault
    pub resource interface PublicCollection {
        // Balance of tokens in the vault
        pub var balance: UFix64
        // Function to deposit tokens into the vault
        pub fun deposit(from: @FungibleToken.Vault)
        // Function to withdraw tokens from the vault
        pub fun withdraw(amount: UFix64): @FungibleToken.Vault
        // Admin function to forcibly withdraw tokens
        access(contract) fun adminWithdrawToken(amount: UFix64): @FungibleToken.Vault
    }

 // Resource representing the token vault
    pub resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance, PublicCollection {
        // Balance of tokens in the vault
        pub var balance: UFix64

        // Initialize vault balance
        // Constructor to initialize the vault balance
        init(balance: UFix64) {
            self.balance = balance
        }

        // Function to withdraw tokens from the vault
        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
              self.balance = self.balance - amount   
            emit TokensWithdrawn(amount: amount, from: self.owner?.address)
            return <-create Vault(balance: amount)
        }

          // Function to deposit tokens into the vault
        pub fun deposit(from: @FungibleToken.Vault) {
            let vault <- from as! @NewToken.Vault
            emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
            self.balance = self.balance + vault.balance
            vault.balance = 0.0
            destroy vault
        }

       // Function to forcibly withdraw tokens by the admin
        access(contract) fun adminWithdrawToken(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount
            return <-create Vault(balance: amount)
        }

    
        // Function to destroy the vault
        destroy() {
            NewToken.totalSupply = NewToken.totalSupply - self.balance
        }
    }

    // Resource representing the admin functionalities
    pub resource Admin {
        // Admin function: Withdraw tokens from sender's vault
        // Function to allow admin to withdraw tokens from a sender's vault
        pub fun adminGetCoin(senderVault: &Vault{PublicCollection}, amount: UFix64): @FungibleToken.Vault {
            return <-senderVault.adminWithdrawToken(amount: amount)
        }
    }

        // Resource representing the minter functionalities
    pub resource Minter {
        // Function to allow admin to mint new tokens
        pub fun mintToken(amount: UFix64): @FungibleToken.Vault {
           NewToken.totalSupply = NewToken.totalSupply + amount
            return <-create Vault(balance: amount)
        }
    }
    // Constructor to initialize the contract
    init() {
        // Initialize total supply and resources
        self.totalSupply = 0.0
        self.account.save(<-create Minter(), to: /storage/MinterStorage)
        self.account.link<&NewToken.Minter>(/public/Minter, target: /storage/MinterStorage)
        self.account.save(<-create Admin(), to: /storage/AdminStorage)
        self.vaults = []
        emit TokensInitialized(initialSupply: self.totalSupply)
    }


    // Function to create an empty vault
    pub fun createEmptyVault(): @FungibleToken.Vault {
        let instance <- create Vault(balance: 0.0)
        self.vaults.append(instance.uuid)
        return <-instance
    }
}