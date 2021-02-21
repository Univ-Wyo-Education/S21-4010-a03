
m4_include(../S21-4010/setup.m4)

# University of Wyoming, 4010-Blockchain, Assignment 03 - Transactions

200pts total

Due May 7

Transactions
-------------------------------


In Bitcoin,  Ethereum and many other cryptocurrencies you can send funds from one account to another.
This activity is captured in a transaction.

In this assignment we are going to add transactions to our blockchain.

You will need to implement code in `./bsvr/cli/cli.go` starting at
line 185.  The function is `func (cc *CLI) SendFundsTransaction(`.

Side Note: notice how line continuation works in go with the
declaration of the function.

The function calls
`cc.InstructorSendFundsTransaction` remove that. That is the 
instructors version of the code (The answer that I implemented).

Work through the pseudo code and implement the transaction.

Basically a transaction is finding all the outputs for an account
that do not have any corresponding  input.  These are the unused
outputs that represent the value of the account.   Fortunately
we have an index that tells us where to find these.  Verify that
there is sufficient funds in the account then create inputs for
our new block/new transaction that collects all of the funds.
Given that we have the `sum` of the funds, now create 1 or 2
output transactions.  First a transaction output to the destination


## Pseudocode

1. Calculate the total value of the account 'from'.  Call this 'tot'.
   You can do this by calling `cc.GetTotalValueForAccount(from)`.
2. If the total, `tot` is less than the amount that is to be transferred,
  `amount` then fail.  Return an error "Insufficient funds".  The person
   is trying to bounce a check.
3. Get the list of output tranactions.
   Look in the file .../transaactions/tx.go for the TxOutputType.  These
  need to be collected so that you have them.
   Call this 'oldOutputs'.
4. Find the set of values that are pointed to in the index.  These are the
   values for the 'from' account.  Delete this from the index.  These are the
	  values that have been spent.
   ((( To delete from the index use the from value.  Convert it
	to a stirng.  The key for the index
	cc.BlockIndex.FindValue.AddrIndex  is a string.
	Then use the builtin "delete" to remove this entire key.
	"delete(cc.BlockIndex.FindValue.AddrIndex, fromConvertedToString)
	)))
5. Create a new empty transaction.  Call `transctions.NewEmptyTx` to create.
  Pass in the 'memo' and the 'from' for this tranaction.
6. Convert the 'oldOutputs' into a set of new inputs.  The type is
   ../transctions/tx.go TxInputType.  Call `transactions.CreateTxInputsFromOldOutputs`
  to do this.
7. Save the new inputs in the tx.Input.
8. Create the new output for the 'to' address.  Call `transactions.CreateTxOutputWithFunds`.
   Call this `txOut`.    Take `txOut` and append it to the transaction by calling
   `transactions.AppendTxOutputToTx`.
9. Calculate the amount of "change" - if it is larger than 0 then we owe 'from'
   change.  Create a 2nd transaction with the change.  Append to the transaction the
   TxOutputType.
10. Return


                      
## index.json

`index.json` is saved in the ./main/data directory.   This shows a before and after
of what happens in the index.

From index.js Before:

```
    "0xe7b8a518bf1b5c4f01b2a7ee39a2800a982e06ee": {
        "Addr": "e7b8a518bf1b5c4f01b2a7ee39a2800a982e06ee",
        "Value": [
            { "BlockIndex": 0, "TxOffset": 8, "TxOutputPos": 0 },
            { "BlockIndex": 2, "TxOffset": 0, "TxOutputPos": 1 }
        ]
    },
    "0x9d41e5938767466af28865e1c33071f1561d57a8": {
        "Addr": "9d41e5938767466af28865e1c33071f1561d57a8",
        "Value": [
            { "BlockIndex": 8, "TxOffset": 0, "TxOutputPos": 0 }
        ]
    }
```

After:

```
    "0xe7b8a518bf1b5c4f01b2a7ee39a2800a982e06ee": {
        "Addr": "e7b8a518bf1b5c4f01b2a7ee39a2800a982e06ee",
        "Value": [
            { "BlockIndex": 8, "TxOffset": 0, "TxOutputPos": 1 }
        ]
    },
    "0x9d41e5938767466af28865e1c33071f1561d57a8": {
        "Addr": "9d41e5938767466af28865e1c33071f1561d57a8",
        "Value": [
            { "BlockIndex": 0, "TxOffset": 0, "TxOutputPos": 0 },
            { "BlockIndex": 8, "TxOffset": 0, "TxOutputPos": 0 }
        ]
    }
```


# Data types in Code

from block/block.go:

```
    type BlockType struct {
        Index         int                             // position of this block in the chain, 0, 1, 2, ...
        Desc          string                          // if "genesis" string then this is a genesis block.
        ThisBlockHash hash.BlockHashType              //
        PrevBlockHash hash.BlockHashType              // This is 0 length if this is a "genesis" block
        Nonce         uint64                          //
        Seal          hash.SealType                   //
        MerkleHash    hash.MerkleHashType             // AS-03
        Tx            []*transactions.TransactionType // Add Transactions to Block Later, (AS-04 will do this)
    }
```

from transactions/tx.go:

```
    type TransactionType struct {
        TxOffset       int               // The position of this in the block.
        Input          []TxInputType     // Set of inputs to a transaction
        Output         []TxOutputType    // Set of outputs to a tranaction
        ...
    }

    type TxInputType struct {
        BlockNo     int // Which block is this from
        TxOffset    int // The transaction in the block. In the block[BlockHash].Tx[TxOffset]
        TxOutputPos int // Position of the output in the transaction. In the  block[BlockHash].Tx[TxOffset].Output[TxOutptuPos]
        Amount      int // Value
    }

    type TxOutputType struct {
        BlockNo     int              // Which block is this in
        TxOffset    int              // Which transaction in this block.  block[this].Tx[TxOffset]
        TxOutputPos int              // Position of the output in this block. In the  block[this].Tx[TxOffset].Output[TxOutptuPos]
        Account     addr.AddressType // Acctount funds go to (If this is ""chagne"" then this is the same as TransactionType.Account
        Amount      int              // Amoutn to go to accoutn
    }
```
